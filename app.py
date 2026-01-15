from flask import Flask, render_template, request, jsonify, session, redirect, url_for, send_file, send_from_directory
from models import db, Producto, Proveedor, ProductoProveedor, HistorialPreciosProveedor, Usuario, Ticket, ComentarioTicket, Role, Permission, QCReport, QCItem, QCProduccionRegistro, Máquina, ComponenteMáquina, HojaRuta, EstacionTrabajo, EstacionPlantilla, ProcesoCatalogo, ClaveProducto, ClaveProceso
from auth import AuthManager
from email_manager import EmailManager
import os
import json
from dotenv import load_dotenv
from sqlalchemy import text
from functools import wraps
import secrets
from werkzeug.utils import secure_filename
from datetime import datetime
from time import time
import logging
from openpyxl import Workbook
from io import BytesIO
import uuid

# Configurar logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('catalogo_app.log'),
        logging.StreamHandler()  # También mostrar en consola
    ]
)
logger = logging.getLogger(__name__)

# Simple in-memory login rate limiter
# Keys: by IP address. Tracks [attempt_count, first_attempt_ts, locked_until_ts]
FAILED_LOGINS = {}
# Configurable via env
MAX_LOGIN_ATTEMPTS = int(os.getenv('MAX_LOGIN_ATTEMPTS', '5'))
LOCKOUT_SECONDS = int(os.getenv('LOCKOUT_SECONDS', '300'))  # default 5 minutes

load_dotenv()

app = Flask(__name__)

# Configuración para carga de archivos
UPLOAD_FOLDER = 'uploads/productos'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# Configuración segura
app.secret_key = os.getenv('SECRET_KEY', secrets.token_hex(16))

# Configuración de BD
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://catalogo_user:catalogo_pass@localhost:5432/catalogo_db')
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

# Nota: la creación de tablas se realiza con `create_db.py` para evitar
# colisiones al arrancar múltiples workers (ej. Gunicorn). Ejecutar:
#   python create_db.py
# una vez antes de arrancar la app en producción.

# Inicializar AuthManager con BD
auth_manager = AuthManager(db=db)

# Inicializar EmailManager para notificaciones
email_manager = EmailManager()


# Helper: check if session user is admin (LEGACY - kept for backwards compatibility)
def is_admin_user():
    username = session.get('user')
    if not username:
        return False
    try:
        user = Usuario.query.filter_by(username=username, activo=True).first()
        return bool(user and user.es_admin)
    except Exception:
        return False


def is_root_user():
    """Return True only if logged-in user is 'root' (exact match)."""
    username = session.get('user')
    return username == 'root'


# Registrar accesos (IP, UA, path) en cada petición - evita estáticos
@app.before_request
def log_access_y_cierre_por_hora():
    try:
        path = request.path
        # skip static files and health checks
        if path.startswith('/static') or path.startswith('/favicon'):
            return

        # get client ip (respect X-Forwarded-For when behind proxy)
        if request.headers.get('X-Forwarded-For'):
            client_ip = request.headers.get('X-Forwarded-For').split(',')[0].strip()
        else:
            client_ip = request.remote_addr

        ua = request.headers.get('User-Agent')
        referer = request.headers.get('Referer')
        username = session.get('user') if 'user' in session else None

        # Create log entry
        from models import AccessLog
        entry = AccessLog(
            ip=client_ip,
            username=username,
            path=path,
            method=request.method,
            user_agent=ua,
            referer=referer
        )
        db.session.add(entry)
        db.session.commit()
    except Exception:
        try:
            db.session.rollback()
        except Exception:
            pass
        # do not interrupt request flow on log error
        return

# ==================== DECORADOR DE AUTENTICACIÓN UNIFICADO ====================

def login_required(f):
    """Decorador para proteger rutas que requieren autenticación (cualquier usuario)"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user' not in session:
            # Si la ruta es una API, devolver JSON 401 en lugar de redirigir
            if request.path.startswith('/api/') or request.headers.get('Accept', '').find('application/json') != -1:
                return jsonify({'error': 'Autenticación requerida'}), 401
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def ingeniero_login_required(f):
    """DEPRECATED - usar @login_required en su lugar. Redirige a /login para consistencia."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user' not in session:
            if request.path.startswith('/api/') or request.headers.get('Accept', '').find('application/json') != -1:
                return jsonify({'error': 'Autenticación requerida'}), 401
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# ==================== RUTAS DE AUTENTICACIÓN UNIFICADAS ====================

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login unificado para todos los usuarios (admin, ingenieros, etc.)
    Redirige automáticamente según el rol del usuario.
    """
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        logger.info(f"[LOGIN UNIFICADO] Intento de login para usuario: {username}")
        
        # Rate-limit by IP (saltarse en modo testing)
        client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
        
        if not app.config.get('TESTING', False):
            entry = FAILED_LOGINS.get(client_ip, [0, 0, 0])
            attempt_count, first_ts, locked_until = entry
            now = time()

            if first_ts and now - first_ts > LOCKOUT_SECONDS:
                attempt_count, first_ts, locked_until = 0, 0, 0

            if locked_until and now < locked_until:
                remaining = int(locked_until - now)
                logger.warning(f"[LOGIN] IP {client_ip} bloqueada. Faltan {remaining}s")
                return render_template('login.html', error=f'Demasiados intentos. Intenta en {remaining}s.'), 429
        
        credentials_valid = False
        usuario = None
        try:
            logger.debug(f"[LOGIN] Consultando usuario '{username}' en BD...")
            usuario = Usuario.query.filter_by(username=username, activo=True).first()
            if usuario and usuario.check_password(password):
                credentials_valid = True
                logger.info(f"[LOGIN] ✓ Autenticación exitosa para {username}")
            else:
                logger.warning(f"[LOGIN] ✗ Credenciales inválidas para {username}")
        except Exception as bd_error:
            logger.error(f"[BD ERROR] Fallo en login: {bd_error}", exc_info=True)
            # Fallback para testing
            if username == 'admin' and password == 'admin123':
                credentials_valid = True
                logger.info(f"[LOGIN] ✓ Fallback credentials para {username}")
        except Exception as e:
            logger.error(f"[LOGIN ERROR] {e}", exc_info=True)
            return render_template('login.html', error='Error interno del servidor.'), 500
        
        if credentials_valid and usuario:
            # Limpiar contador de intentos fallidos
            if not app.config.get('TESTING', False) and client_ip in FAILED_LOGINS:
                FAILED_LOGINS.pop(client_ip, None)
            
            # Guardar en sesión unificada
            session['user'] = username
            logger.info(f"[LOGIN] ✓ Sesión iniciada para {username}")
            
            # Redirigir automáticamente según rol
            if usuario.es_admin:
                logger.info(f"[LOGIN] Redirigiendo admin '{username}' a /admin")
                return redirect(url_for('admin'))
            elif usuario.role and usuario.role.name == 'support':
                logger.info(f"[LOGIN] Redirigiendo ingeniero '{username}' a /soporte")
                return redirect(url_for('soporte_tecnico'))
            else:
                # Usuario sin rol asignado
                logger.warning(f"[LOGIN] Usuario '{username}' sin rol asignado; redirigiendo a /dashboard")
                return redirect(url_for('dashboard'))
        else:
            # Gestionar intentos fallidos
            if not app.config.get('TESTING', False):
                attempt_count += 1
                if not first_ts:
                    first_ts = now
                if attempt_count >= MAX_LOGIN_ATTEMPTS:
                    locked_until = now + LOCKOUT_SECONDS
                    FAILED_LOGINS[client_ip] = [attempt_count, first_ts, locked_until]
                    logger.warning(f"[LOGIN] IP {client_ip} bloqueada por {MAX_LOGIN_ATTEMPTS} intentos")
                    return render_template('login.html', error='Demasiados intentos. Intenta más tarde.'), 429
                else:
                    FAILED_LOGINS[client_ip] = [attempt_count, first_ts, 0]
            return render_template('login.html', error='Credenciales inválidas', intento=attempt_count if not app.config.get('TESTING') else None), 401
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    """Cerrar sesión (para todos los usuarios)"""
    session.pop('user', None)
    # Limpiar keys antiguas si existen (para compatibilidad)
    session.pop('admin_user', None)
    session.pop('ingeniero_user', None)
    return redirect(url_for('login'))
# ==================== PERMISSION HELPERS (UNIFICADOS) ==================

def get_current_user():
    """Obtiene el usuario actual desde la sesión unificada."""
    username = session.get('user')
    if not username:
        return None
    try:
        return Usuario.query.filter_by(username=username, activo=True).first()
    except Exception:
        return None


@app.context_processor
def inject_user_helpers():
    """Inyecta `current_user` y `has_permission` en todas las plantillas."""
    user = get_current_user()
    def has_permission(module, action):
        if not user:
            return False
        return user.has_permission(module, action)
    return dict(current_user=user, has_permission=has_permission)


def requires_permission(module, action):
    """Decorador para requerir un permiso específico en una ruta o API.
    
    Uso: @requires_permission('tickets', 'view')
    """
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            user = get_current_user()
            if not user:
                if request.path.startswith('/api/'):
                    return jsonify({'error': 'Autenticación requerida'}), 401
                return redirect(url_for('login'))
            if not user.has_permission(module, action):
                if request.path.startswith('/api/'):
                    return jsonify({'error': 'Permiso denegado'}), 403
                return render_template('403.html'), 403
            return f(*args, **kwargs)
        return decorated
    return decorator

# ==================== DASHBOARD / HOME CENTRAL ====================

@app.route('/dashboard')
@login_required
def dashboard():
    """Dashboard central - cada usuario ve su panel según permisos."""
    user = get_current_user()
    if not user:
        return redirect(url_for('login'))
    
    # Admin → ir a admin
    if user.es_admin:
        return redirect(url_for('admin'))
    # Ingeniero de soporte → ir a soporte
    elif user.role and user.role.name == 'support':
        return redirect(url_for('soporte_tecnico'))
    # Otro rol → mostrar página genérica de bienvenida
    else:
        return render_template('dashboard.html', user=user)

# ==================== RUTAS FRONTEND ====================

@app.route('/')
@login_required
def index():
    """Página principal - Catálogo (privado)"""
    return render_template('index.html')


@app.route('/producto/<int:producto_id>')
@login_required
def producto_detalle(producto_id):
    producto = Producto.query.get_or_404(producto_id)
    # Traer proveedores y precios relacionados
    proveedores = []
    for pp in producto.proveedores:
        prov = pp.proveedor.to_dict() if pp.proveedor else None
        historial = [h.to_dict() for h in pp.historial_precios]
        proveedores.append({
            'asignacion_id': pp.id,
            'proveedor': prov,
            'precio_proveedor': pp.precio_proveedor,
            'fecha_precio': pp.fecha_precio.isoformat() if pp.fecha_precio else None,
            'cantidad_minima': pp.cantidad_minima,
            'historial_precios': historial
        })
    return render_template('producto_detalle.html', producto=producto, proveedores=proveedores)


@app.route('/control_calidad')
@login_required
def control_calidad_list():
    """Lista las máquinas disponibles para control de calidad."""
    maquinas = Máquina.query.order_by(Máquina.nombre.asc()).all()
    return render_template('control_calidad_list.html', maquinas=maquinas)


@app.route('/control_calidad/<int:maquina_id>', methods=['GET', 'POST'])
@login_required
def control_calidad_maquina(maquina_id):
    """Formulario de control de calidad para una máquina específica."""
    maquina = Máquina.query.get_or_404(maquina_id)

    # Obtener componentes configurados para esta máquina
    componentes = ComponenteMáquina.query.filter_by(maquina_id=maquina_id).order_by(ComponenteMáquina.orden).all()
    if not componentes:
        # Si no hay componentes, crear una lista vacía
        componentes = []

    informe_guardado = False

    if request.method == 'POST':
        # Directorio para guardar evidencias
        reports_dir = os.path.join('uploads', 'qc_reports')
        images_dir = os.path.join(reports_dir, 'images')
        os.makedirs(images_dir, exist_ok=True)
        # Directorio para guardar modelos 3D (STL)
        models_dir = os.path.join('uploads', 'models')
        os.makedirs(models_dir, exist_ok=True)

        # Crear QCReport
        report = QCReport(maquina_id=maquina.id, usuario=session.get('user'), observaciones=request.form.get('observaciones'))
        db.session.add(report)
        db.session.flush()  # Obtener el ID del reporte

        # Crear QCItem por cada componente
        for idx, comp in enumerate(componentes):
            checked = bool(request.form.get(f'check_{idx}'))
            evidencia_file = request.files.get(f'evidence_{idx}')
            model_file = request.files.get(f'model_{idx}')
            evidence_url = None
            if evidencia_file and evidencia_file.filename:
                filename = secure_filename(f"qc_m{maquina.id}_{comp.id}_{int(time())}_{evidencia_file.filename}")
                save_path = os.path.join(images_dir, filename)
                evidencia_file.save(save_path)
                evidence_url = os.path.relpath(save_path, start=os.getcwd())

            # Guardar modelo STL (si se sube)
            stl_url = None
            if model_file and model_file.filename:
                # Forzar extensión .stl si viene con nombre válido
                model_filename = secure_filename(f"model_m{maquina.id}_c{comp.id}_{int(time())}_{model_file.filename}")
                # asegurarse de que la extensión sea .stl
                if not model_filename.lower().endswith('.stl'):
                    model_filename = model_filename + '.stl'
                model_save_path = os.path.join(models_dir, model_filename)
                try:
                    model_file.save(model_save_path)
                    stl_url = os.path.relpath(model_save_path, start=os.getcwd())
                except Exception as e:
                    logger.error(f"Error guardando STL: {e}", exc_info=True)

            item = QCItem(report_id=report.id, nombre=comp.nombre, checked=checked, evidence_url=evidence_url)
            db.session.add(item)

        try:
            db.session.commit()
            informe_guardado = True
        except Exception as e:
            db.session.rollback()
            logger.error(f"Error guardando informe QC en BD: {e}", exc_info=True)

    # Crear estructura de datos para la plantilla (incluye id y posible STL)
    models_dir = os.path.join('uploads', 'models')
    comp_list = []
    for c in componentes:
        # Buscar un STL existente para este componente (por convención de nombre)
        stl_url = None
        try:
            if os.path.exists(models_dir):
                for fname in os.listdir(models_dir):
                    if fname.lower().startswith(f"model_m{maquina.id}_c{c.id}_") and fname.lower().endswith('.stl'):
                        # tomar el primero (más reciente sería mejor, pero esto es suficiente)
                        stl_url = os.path.relpath(os.path.join(models_dir, fname), start=os.getcwd())
                        break
        except Exception:
            stl_url = None

        comp_list.append({
            'id': c.id,
            'nombre': c.nombre,
            'descripcion': c.descripcion,
            'image_url': None,
            'checked': False,
            'stl_url': stl_url
        })

    return render_template('control_calidad_detalle.html', maquina=maquina, componentes=comp_list, informe_guardado=informe_guardado)


@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    # Sirve archivos desde la carpeta uploads de forma segura
    uploads_root = os.path.join(os.getcwd(), 'uploads')
    try:
        return send_from_directory(uploads_root, filename)
    except Exception:
        return ('', 404)


# ==================== MÓDULO HOJAS DE RUTA ====================

@app.route('/hojas_ruta')
@login_required
def hojas_ruta_list():
    """Lista de máquinas con sus hojas de ruta activas y estado de producción."""
    maquinas = Máquina.query.order_by(Máquina.nombre.asc()).all()
    
    # Obtener hoja activa para cada máquina
    maquinas_data = []
    for maq in maquinas:
        hoja_activa = HojaRuta.query.filter_by(maquina_id=maq.id, estado='activa').first()
        estacion_actual = None
        if hoja_activa:
            estacion_actual = EstacionTrabajo.query.filter_by(
                hoja_ruta_id=hoja_activa.id, 
                estado='en_curso'
            ).order_by(EstacionTrabajo.orden).first()
        
        maquinas_data.append({
            'id': maq.id,
            'nombre': maq.nombre,
            'descripcion': maq.descripcion,
            'imagen_url': maq.imagen_url,
            'hoja_activa': hoja_activa.to_dict() if hoja_activa else None,
            'activo': getattr(maq, 'activo', False),
            'estacion_actual': estacion_actual.nombre if estacion_actual else 'Sin producción',
            'tipo': getattr(maq, 'tipo', None),
            'plantilla_default': getattr(maq, 'plantilla_default', None)
        })
    
    return render_template('hojas_ruta_list.html', maquinas=maquinas_data)


@app.route('/hojas_ruta_form')
@login_required
def hojas_ruta_form():
    """Formulario para crear una hoja de ruta con todos los campos del formato."""
    maquinas = Máquina.query.order_by(Máquina.nombre.asc()).all()
    # Listado reciente (máximo 50) para consulta rápida
    hojas = HojaRuta.query.order_by(HojaRuta.fecha_creacion.desc()).limit(50).all()
    hojas_data = []
    for h in hojas:
        hojas_data.append({
            'id': h.id,
            'maquina': h.maquina.nombre if getattr(h, 'maquina', None) else str(h.maquina_id),
            'maquina_id': h.maquina_id,
            'nombre': h.nombre,
            'estado': h.estado,
            'cantidad_piezas': h.cantidad_piezas,
            'fecha_creacion': h.fecha_creacion.isoformat() if h.fecha_creacion else None
        })
    return render_template('hojas_ruta_form.html', maquinas=maquinas, hojas=hojas_data)


@app.route('/hoja/<int:hoja_id>')
@login_required
def hoja_ruta_ver(hoja_id):
    """Vista independiente para ver una hoja por ID, sin requerir máquina."""
    hoja = HojaRuta.query.get_or_404(hoja_id)
    h = hoja.to_dict()
    estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden).all()
    h['estaciones'] = [e.to_dict() for e in estaciones]
    return render_template('hoja_ruta_ver.html', hoja=h)


@app.route('/hojas_ruta/<int:maquina_id>')
@login_required
def hojas_ruta_detalle(maquina_id):
    """Detalle de hojas de ruta para una máquina específica."""
    maquina = Máquina.query.get_or_404(maquina_id)
    hojas = HojaRuta.query.filter_by(maquina_id=maquina_id).order_by(HojaRuta.fecha_creacion.desc()).all()
    
    hojas_data = []
    for hoja in hojas:
        # Usa to_dict() completo para incluir todos los campos (calidad, pn, tiempos, etc.)
        h = hoja.to_dict()
        # Asegura orden de estaciones
        estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden).all()
        h['estaciones'] = [e.to_dict() for e in estaciones]
        hojas_data.append(h)
    
    return render_template('hojas_ruta_detalle.html', maquina=maquina, hojas=hojas_data)


@app.route('/qc_estaciones/<int:maquina_id>')
@login_required
def qc_estaciones_maquina(maquina_id):
    """Vista independiente de control de calidad para producción por máquina."""
    maquina = Máquina.query.get_or_404(maquina_id)
    hoja_activa = HojaRuta.query.filter_by(maquina_id=maquina_id, estado='activa').first()
    registros = QCProduccionRegistro.query.filter_by(maquina_id=maquina_id).order_by(QCProduccionRegistro.creado_en.desc()).limit(50).all()
    return render_template('qc_estaciones.html', maquina=maquina, hoja_activa=hoja_activa, registros=registros)


# API para crear / actualizar hojas de ruta

@app.route('/api/hojas_ruta', methods=['POST'])
@login_required
def api_crear_hoja_ruta():
    """Crear una nueva hoja de ruta con estaciones desde la clave seleccionada."""
    data = request.get_json()
    nombre = data.get('nombre')
    clave_id = data.get('clave_id')
    cantidad_piezas = data.get('cantidad_piezas')

    if not nombre:
        return jsonify({'error': 'nombre requerido'}), 400
    if not clave_id:
        return jsonify({'error': 'clave_id requerido'}), 400
    if not cantidad_piezas or cantidad_piezas <= 0:
        return jsonify({'error': 'cantidad_piezas debe ser mayor a 0'}), 400

    # Obtener la clave y sus procesos
    clave = ClaveProducto.query.get(clave_id)
    if not clave:
        return jsonify({'error': 'Clave no encontrada'}), 404

    try:
        # Crear hoja de ruta
        hoja = HojaRuta(
            maquina_id=int(data.get('maquina_id')) if data.get('maquina_id') else None,
            nombre=nombre,
            descripcion=data.get('descripcion'),
            estado=data.get('estado', 'activa'),
            producto=clave.nombre,  # Nombre del producto desde la clave
            calidad=data.get('calidad'),
            pn=clave.clave,  # Clave del producto
            revision=data.get('revision'),
            fecha_salida=datetime.fromisoformat(data['fecha_salida']) if data.get('fecha_salida') else None,
            cantidad_piezas=int(cantidad_piezas),
            orden_trabajo_hr=data.get('orden_trabajo'),  # Campo unificado
            orden_trabajo_pt=data.get('orden_trabajo_pt'),
            almacen=data.get('almacen'),
            no_sin_orden=data.get('no_sin_orden'),
            materia_prima=data.get('materia_prima'),
            total_tiempo=data.get('total_tiempo'),
            dias_a_laborar=float(data['dias_a_laborar']) if data.get('dias_a_laborar') else None,
            fecha_termino=datetime.fromisoformat(data['fecha_termino']) if data.get('fecha_termino') else None,
            aprobada=False,
            rechazada=False,
            scrap=data.get('scrap'),  # Ahora es texto
            retrabajo=data.get('retrabajo'),  # Ahora es texto
            supervisor=data.get('supervisor'),
            operador=data.get('operador'),
            eficiencia=float(data['eficiencia']) if data.get('eficiencia') else None
        )
        db.session.add(hoja)
        db.session.flush()  # Obtener el ID de la hoja

        # Crear estaciones desde los procesos de la clave
        procesos = ClaveProceso.query.filter_by(clave_id=clave_id).order_by(ClaveProceso.orden).all()
        for idx, cp in enumerate(procesos, start=1):
            estacion = EstacionTrabajo(
                hoja_ruta_id=hoja.id,
                nombre=f"{cp.operacion or cp.proceso.operacion or cp.proceso.nombre}",
                pro_c=str(idx),  # Número de proceso
                centro_trabajo=cp.centro_trabajo or cp.proceso.centro_trabajo,
                operacion=cp.operacion or cp.proceso.operacion or cp.proceso.nombre,
                orden=cp.orden,
                t_e=cp.t_e or cp.proceso.tiempo_estimado,
                t_tct=cp.t_tct,
                t_tco=cp.t_tco,
                t_to=cp.t_to,
                total_piezas=cantidad_piezas,
                estado='pendiente'
            )
            db.session.add(estacion)

        db.session.commit()
        logger.info(f"[HOJAS_RUTA] Nueva hoja creada: {hoja.id} con {len(procesos)} estaciones desde clave {clave.clave}")
        return jsonify(hoja.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error creando hoja de ruta: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/hojas_ruta/<int:hoja_id>', methods=['PUT'])
@login_required
def api_actualizar_hoja_ruta(hoja_id):
    """Actualizar estado de una hoja de ruta."""
    hoja = HojaRuta.query.get_or_404(hoja_id)
    data = request.get_json()
    
    if 'estado' in data:
        hoja.estado = data['estado']
    if 'nombre' in data:
        hoja.nombre = data['nombre']
    if 'descripcion' in data:
        hoja.descripcion = data['descripcion']
    
    db.session.commit()
    logger.info(f"[HOJAS_RUTA] Hoja actualizada: {hoja_id}")
    return jsonify(hoja.to_dict()), 200


@app.route('/api/claves_procesos', methods=['GET'])
@login_required
def api_claves_procesos():
    """Obtener todas las claves con sus procesos y tiempo total T/O."""
    try:
        claves = ClaveProducto.query.filter_by(activo=True).order_by(ClaveProducto.clave.asc()).all()
        result = []
        for clave in claves:
            # Obtener último T/O de la secuencia
            ultimo_proceso = ClaveProceso.query.filter_by(clave_id=clave.id).order_by(ClaveProceso.orden.desc()).first()
            tiempo_to = ultimo_proceso.t_to if ultimo_proceso and ultimo_proceso.t_to else "00:00:00"
            
            result.append({
                'id': clave.id,
                'clave': clave.clave,
                'nombre': clave.nombre,
                'tiempo_to': tiempo_to,  # Tiempo total de producción (T/O)
                'procesos': [p.to_dict() for p in clave.procesos]
            })
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error obteniendo claves/procesos: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/estaciones', methods=['POST'])
@login_required
def api_crear_estacion():
    """Crear una nueva estación de trabajo en una hoja de ruta."""
    data = request.get_json()
    hoja_ruta_id = data.get('hoja_ruta_id')
    nombre = data.get('nombre')
    
    if not hoja_ruta_id or not nombre:
        return jsonify({'error': 'hoja_ruta_id y nombre requeridos'}), 400
    
    # Obtener orden máxima actual
    max_orden = db.session.query(db.func.max(EstacionTrabajo.orden)).filter_by(
        hoja_ruta_id=hoja_ruta_id
    ).scalar() or 0
    
    estacion = EstacionTrabajo(
        hoja_ruta_id=hoja_ruta_id,
        nombre=nombre,
        descripcion=data.get('descripcion'),
        orden=max_orden + 1,
        estado='pendiente'
    )
    db.session.add(estacion)
    db.session.commit()
    
    logger.info(f"[HOJAS_RUTA] Nueva estación creada: {estacion.id}")
    return jsonify(estacion.to_dict()), 201


# ==== Producción / flujo operativo ==== 
@app.route('/api/produccion/aprobar_ot', methods=['POST'])
@login_required
def api_aprobar_ot():
    data = request.get_json() or {}
    maquina_id = data.get('maquina_id')
    ot = data.get('orden_trabajo')
    # Sólo registramos en logs por ahora
    logger.info(f"[PRODUCCION] OT aprobada para maquina={maquina_id} OT={ot}")
    return jsonify({'ok': True, 'message': 'OT aprobada'}), 200


@app.route('/api/maquinas/<int:maquina_id>/activar', methods=['POST'])
@login_required
def api_activar_maquina(maquina_id):
    maq = Máquina.query.get_or_404(maquina_id)
    try:
        maq.activo = True
        db.session.commit()
        logger.info(f"[MAQUINA] Activada maquina {maquina_id}")
        return jsonify({'ok': True, 'maquina_id': maquina_id, 'activo': True}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error activando maquina: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo activar la máquina. Ejecuta ALTER TABLE para agregar columna activo si no existe.'}), 500


@app.route('/api/maquinas/<int:maquina_id>/desactivar', methods=['POST'])
@login_required
def api_desactivar_maquina(maquina_id):
    maq = Máquina.query.get_or_404(maquina_id)
    try:
        maq.activo = False
        db.session.commit()
        logger.info(f"[MAQUINA] Desactivada maquina {maquina_id}")
        return jsonify({'ok': True, 'maquina_id': maquina_id, 'activo': False}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error desactivando maquina: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo desactivar la máquina.'}), 500


@app.route('/api/produccion/ingresar_piezas', methods=['POST'])
@login_required
def api_ingresar_piezas():
    """Recibe: maquina_id, cantidad, clave, tiempo_total (HH:MM:SS opcional), producto (opcional).
    Crea una HojaRuta con esos datos y la marca como activa.
    """
    data = request.get_json() or {}
    maquina_id = data.get('maquina_id')
    cantidad = data.get('cantidad')
    clave = data.get('clave')
    tiempo_total = data.get('tiempo_total')
    producto = data.get('producto')

    if not maquina_id or not cantidad or not clave:
        return jsonify({'error': 'maquina_id, cantidad y clave son requeridos'}), 400

    try:
        nombre = f"Producción {clave}"
        hoja = HojaRuta(
            maquina_id=maquina_id,
            nombre=nombre,
            producto=producto or clave,
            pn=clave,
            cantidad_piezas=int(cantidad),
            total_tiempo=tiempo_total,
            fecha_salida=datetime.utcnow(),
            estado='activa'
        )
        db.session.add(hoja)
        db.session.flush()  # obtener id sin commit

        # Clonar plantillas de estaciones según plantilla_nombre (si viene) o por tipo de la máquina
        try:
            maquina = Máquina.query.get(maquina_id)
            plantilla_nombre = data.get('plantilla_nombre')
            if plantilla_nombre:
                plantillas = EstacionPlantilla.query.filter_by(maquina_tipo=maquina.tipo if maquina else None, plantilla_nombre=plantilla_nombre).order_by(EstacionPlantilla.orden).all()
            else:
                plantilla_tipo = maquina.tipo if maquina else None
                plantillas = EstacionPlantilla.query.filter_by(maquina_tipo=plantilla_tipo).order_by(EstacionPlantilla.orden).all() if plantilla_tipo else []

            for p in plantillas:
                est = EstacionTrabajo(
                    hoja_ruta_id=hoja.id,
                    nombre=(p.operacion or p.pro_c or 'Estación'),
                    pro_c=p.pro_c,
                    centro_trabajo=p.centro_trabajo,
                    operacion=p.operacion,
                    orden=p.orden,
                    t_e=p.t_e,
                    t_tct=p.t_tct,
                    t_tco=p.t_tco,
                    t_to=p.t_to
                )
                db.session.add(est)
        except Exception as e2:
            logger.warning(f"No se clonaron plantillas para maquina {maquina_id}: {e2}")

        db.session.commit()
        logger.info(f"[PRODUCCION] Hoja creada {hoja.id} para maquina {maquina_id} y plantillas clonadas")
        return jsonify({'success': True, 'hoja': hoja.to_dict()}), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error creando hoja de ruta desde ingreso de piezas: {e}", exc_info=True)
        return jsonify({'error': 'Error creando hoja de ruta'}), 500


@app.route('/api/qc_estaciones', methods=['POST'])
@login_required
def api_qc_estaciones_registro():
    """Registrar control de calidad de producción (independiente del QC de maquinaria)."""
    payload = request.get_json(silent=True) or request.form
    maquina_id = payload.get('maquina_id')
    clave_pieza = payload.get('clave_pieza')
    resultado = payload.get('resultado')

    if not maquina_id or not clave_pieza or not resultado:
        return jsonify({'error': 'maquina_id, clave_pieza y resultado son requeridos'}), 400

    def to_int(value):
        try:
            return int(value) if value is not None and value != '' else None
        except Exception:
            return None

    mediciones = None
    mediciones_raw = payload.get('mediciones')
    if mediciones_raw:
        if isinstance(mediciones_raw, (dict, list)):
            mediciones = mediciones_raw
        else:
            try:
                mediciones = json.loads(mediciones_raw)
            except Exception:
                mediciones = {'valor': str(mediciones_raw)}

    try:
        registro = QCProduccionRegistro(
            maquina_id=int(maquina_id),
            hoja_ruta_id=to_int(payload.get('hoja_ruta_id')),
            clave_pieza=clave_pieza,
            lote=payload.get('lote'),
            cantidad_inspeccionada=to_int(payload.get('cantidad_inspeccionada')),
            cantidad_aprobada=to_int(payload.get('cantidad_aprobada')),
            cantidad_rechazada=to_int(payload.get('cantidad_rechazada')),
            resultado=resultado,
            notas=payload.get('notas'),
            mediciones=mediciones,
            usuario=session.get('user')
        )
        db.session.add(registro)
        db.session.commit()
        logger.info(f"[QC ESTACIONES] Registro creado {registro.id} para maquina {maquina_id}")
        return jsonify({'success': True, 'registro': registro.to_dict()}), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error guardando QC estaciones: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo guardar el control de calidad'}), 500


@app.route('/api/maquinas/<int:maquina_id>/plantilla_default', methods=['POST'])
@login_required
def api_set_plantilla_default(maquina_id):
    """Asigna una plantilla por defecto a una máquina (campo plantilla_default)."""
    data = request.get_json() or {}
    plantilla = data.get('plantilla_nombre')
    if plantilla is None:
        return jsonify({'error': 'plantilla_nombre es requerido'}), 400
    try:
        maquina = Máquina.query.get_or_404(maquina_id)
        maquina.plantilla_default = plantilla
        db.session.commit()
        logger.info(f"[MAQUINA] plantilla_default set {plantilla} for maquina {maquina_id}")
        return jsonify({'success': True, 'maquina': maquina.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error asignando plantilla_default: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo asignar plantilla_default'}), 500


@app.route('/api/estaciones/<int:estacion_id>', methods=['PUT'])
@login_required
def api_actualizar_estacion(estacion_id):
    """Actualizar estado y detalles de una estación."""
    estacion = EstacionTrabajo.query.get_or_404(estacion_id)
    data = request.get_json()
    
    if 'estado' in data:
        estacion.estado = data['estado']
        if data['estado'] == 'en_curso' and not estacion.fecha_inicio:
            estacion.fecha_inicio = datetime.utcnow()
        elif data['estado'] == 'completada' and not estacion.fecha_finalizacion:
            estacion.fecha_finalizacion = datetime.utcnow()
    
    if 'nombre' in data:
        estacion.nombre = data['nombre']
    if 'descripcion' in data:
        estacion.descripcion = data['descripcion']
    if 'notas' in data:
        estacion.notas = data['notas']
    
    db.session.commit()
    logger.info(f"[HOJAS_RUTA] Estación actualizada: {estacion_id}")
    return jsonify(estacion.to_dict()), 200


@app.route('/api/plantillas_estaciones', methods=['GET'])
@login_required
def api_list_plantillas():
    """Listar plantillas; opcionalmente filtrar por `maquina_tipo` query param."""
    tipo = request.args.get('maquina_tipo')
    if tipo:
        plantillas = EstacionPlantilla.query.filter_by(maquina_tipo=tipo).order_by(EstacionPlantilla.plantilla_nombre, EstacionPlantilla.orden).all()
    else:
        plantillas = EstacionPlantilla.query.order_by(EstacionPlantilla.maquina_tipo, EstacionPlantilla.plantilla_nombre, EstacionPlantilla.orden).all()
    return jsonify({'plantillas': [p.to_dict() for p in plantillas]})


@app.route('/api/plantillas_estaciones/nombres')
@login_required
def api_plantilla_nombres():
    """Devuelve nombres de plantillas (distinct) para un tipo de máquina dado."""
    tipo = request.args.get('maquina_tipo')
    if not tipo:
        return jsonify({'error': 'maquina_tipo requerido'}), 400
    try:
        rows = db.session.query(EstacionPlantilla.plantilla_nombre).filter_by(maquina_tipo=tipo).distinct().all()
        nombres = [r[0] for r in rows if r[0]]
        return jsonify({'nombres': nombres})
    except Exception as e:
        logger.error(f"Error fetch plantilla nombres: {e}", exc_info=True)
        return jsonify({'error': 'Error interno'}), 500


@app.route('/api/plantillas_estaciones', methods=['POST'])
@login_required
def api_create_plantilla():
    data = request.get_json() or {}
    required = ['maquina_tipo', 'operacion']
    for r in required:
        if r not in data:
            return jsonify({'error': f'{r} es requerido'}), 400
    try:
        p = EstacionPlantilla(
            plantilla_nombre=data.get('plantilla_nombre'),
            maquina_tipo=data.get('maquina_tipo'),
            pro_c=data.get('pro_c'),
            centro_trabajo=data.get('centro_trabajo'),
            operacion=data.get('operacion'),
            orden=int(data.get('orden') or 0),
            t_e=data.get('t_e'),
            t_tct=data.get('t_tct'),
            t_tco=data.get('t_tco'),
            t_to=data.get('t_to')
        )
        db.session.add(p)
        db.session.commit()
        return jsonify({'success': True, 'plantilla': p.to_dict()}), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error creando plantilla: {e}", exc_info=True)
        return jsonify({'error': 'Error creando plantilla'}), 500


@app.route('/api/plantillas_estaciones/<int:pid>', methods=['PUT'])
@login_required
def api_update_plantilla(pid):
    p = EstacionPlantilla.query.get_or_404(pid)
    data = request.get_json() or {}
    for k in ['plantilla_nombre', 'maquina_tipo', 'pro_c', 'centro_trabajo', 'operacion', 'orden', 't_e', 't_tct', 't_tco', 't_to']:
        if k in data:
            setattr(p, k, data[k])
    try:
        db.session.commit()
        return jsonify({'success': True, 'plantilla': p.to_dict()})
    except Exception:
        db.session.rollback()
        return jsonify({'error': 'No se pudo actualizar plantilla'}), 500


@app.route('/api/plantillas_estaciones/<int:pid>', methods=['DELETE'])
@login_required
def api_delete_plantilla(pid):
    p = EstacionPlantilla.query.get_or_404(pid)
    try:
        db.session.delete(p)
        db.session.commit()
        return jsonify({'success': True})
    except Exception:
        db.session.rollback()
        return jsonify({'error': 'No se pudo eliminar plantilla'}), 500


@app.route('/plantillas_estaciones')
@login_required
def plantillas_page():
    if not is_admin_user():
        return render_template('403.html'), 403
    return render_template('plantillas_estaciones.html')


@app.route('/admin')
@login_required
def admin():
    """Panel de administración"""
    return render_template('admin.html')


@app.route('/admin/users')
@login_required
def admin_users_page():
    """Página de administración de usuarios (solo admin)."""
    if not is_admin_user():
        return render_template('403.html'), 403
    return render_template('admin_users.html')


# ======= API: Usuarios (admin only) ======
@app.route('/api/users')
@login_required
def api_list_users():
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    users = Usuario.query.order_by(Usuario.id.asc()).all()
    data = []
    for u in users:
        data.append({
            'id': u.id,
            'username': u.username,
            'correo': u.correo,
            'activo': u.activo,
            'es_admin': u.es_admin,
            'role': u.role.name if u.role else None,
            'fecha_creacion': u.fecha_creacion.isoformat() if u.fecha_creacion else None
        })
    return jsonify({'users': data})


@app.route('/api/permissions')
@login_required
def api_list_permissions():
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    perms = Permission.query.order_by(Permission.module, Permission.action).all()
    return jsonify({'permissions': [p.to_dict() for p in perms]})


@app.route('/api/roles')
@login_required
def api_list_roles():
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    roles = Role.query.order_by(Role.name).all()
    return jsonify({'roles': [r.to_dict() for r in roles]})


@app.route('/api/roles/<int:role_id>/permissions', methods=['PUT'])
@login_required
def api_set_role_permissions(role_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    payload = request.get_json() or {}
    perm_ids = payload.get('permission_ids', [])
    role = Role.query.get_or_404(role_id)
    # fetch permissions
    perms = Permission.query.filter(Permission.id.in_(perm_ids)).all() if perm_ids else []
    role.permissions = perms
    db.session.add(role)
    db.session.commit()
    return jsonify({'ok': True, 'role': role.to_dict()})


@app.route('/api/roles/<int:role_id>/modules', methods=['PUT'])
@login_required
def api_set_role_modules(role_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    payload = request.get_json() or {}
    modules = payload.get('modules', [])
    role = Role.query.get_or_404(role_id)
    role.set_modules(modules)
    db.session.add(role)
    db.session.commit()
    return jsonify({'ok': True, 'role': role.to_dict()})


@app.route('/api/users', methods=['POST'])
@login_required
def api_create_user():
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    data = request.get_json() or {}
    username = data.get('username')
    correo = data.get('correo')
    password = data.get('password')
    role_name = data.get('role')
    es_admin = bool(data.get('es_admin', False))
    if not username or not password:
        return jsonify({'error': 'username y password requeridos'}), 400
    if Usuario.query.filter_by(username=username).first():
        return jsonify({'error': 'username ya existe'}), 409
    u = Usuario(username=username, correo=correo, es_admin=es_admin, activo=True)
    u.set_password(password)
    if role_name:
        role = Role.query.filter_by(name=role_name).first()
        if role:
            u.role = role
    db.session.add(u)
    db.session.commit()
    return jsonify({'ok': True, 'user': u.to_dict()}), 201


@app.route('/api/users/<int:user_id>/toggle_active', methods=['PUT'])
@login_required
def api_toggle_active(user_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    u = Usuario.query.get_or_404(user_id)
    if u.username == 'admin':
        return jsonify({'error': 'No se puede desactivar el usuario admin'}), 400
    u.activo = not bool(u.activo)
    db.session.add(u)
    db.session.commit()
    return jsonify({'ok': True, 'activo': u.activo})


@app.route('/api/users/<int:user_id>/role', methods=['PUT'])
@login_required
def api_set_role(user_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    payload = request.get_json() or {}
    role_name = payload.get('role')
    u = Usuario.query.get_or_404(user_id)
    if u.username == 'admin' and role_name != 'admin':
        return jsonify({'error': 'El usuario admin debe conservar role admin'}), 400
    if role_name:
        role = Role.query.filter_by(name=role_name).first()
        if not role:
            return jsonify({'error': 'Role no encontrado'}), 404
        u.role = role
    else:
        u.role = None
    db.session.add(u)
    db.session.commit()
    return jsonify({'ok': True, 'role': u.role.name if u.role else None})


@app.route('/api/users/<int:user_id>', methods=['DELETE'])
@login_required
def api_delete_user(user_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    u = Usuario.query.get_or_404(user_id)
    if u.username == 'admin':
        return jsonify({'error': 'No se puede borrar el usuario admin'}), 400
    db.session.delete(u)
    db.session.commit()
    return jsonify({'ok': True})


@app.route('/api/users/<int:user_id>', methods=['GET'])
@login_required
def api_get_user(user_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    u = Usuario.query.get_or_404(user_id)
    data = {
        'id': u.id,
        'username': u.username,
        'correo': u.correo,
        'activo': u.activo,
        'es_admin': u.es_admin,
        'role': u.role.name if u.role else None,
        'fecha_creacion': u.fecha_creacion.isoformat() if u.fecha_creacion else None
    }
    try:
        # devolver contraseña desencriptada SOLO para admin
        data['password'] = u.decrypt_password()
    except Exception:
        data['password'] = None
    return jsonify({'user': data})


@app.route('/api/users/<int:user_id>', methods=['PUT'])
@login_required
def api_update_user(user_id):
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    u = Usuario.query.get_or_404(user_id)
    data = request.get_json() or {}
    correo = data.get('correo')
    password = data.get('password')
    es_admin = data.get('es_admin')
    role_name = data.get('role')

    if correo is not None:
        u.correo = correo
    if password:
        u.set_password(password)
    if es_admin is not None:
        u.es_admin = bool(es_admin)
    if role_name is not None:
        if role_name == '':
            u.role = None
        else:
            role = Role.query.filter_by(name=role_name).first()
            if role:
                u.role = role
    db.session.add(u)
    db.session.commit()
    return jsonify({'ok': True, 'user': u.to_dict()})


@app.route('/delete_nonadmin_users', methods=['POST'])
@login_required
def delete_nonadmin_users():
    """Endpoint conveniente que borra todos los usuarios salvo 'admin'. Protegido a admin."""
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    users = Usuario.query.filter(Usuario.username != 'admin').all()
    deleted = 0
    for u in users:
        db.session.delete(u)
        deleted += 1
    db.session.commit()
    return f"Usuarios eliminados: {deleted}", 200

@app.route('/proveedores')
@login_required
def proveedores():
    """Página de gestión de proveedores"""
    return render_template('proveedores.html')
@app.route('/reportar')
def reportar_incidencia():
    """Página pública para reportar incidencias (sin login)"""
    return render_template('reportar_incidencia.html')

@app.route('/soporte')
@login_required
def soporte_tecnico():
    """Panel de ingenieros para gestionar tickets de soporte"""
    return render_template('soporte_tecnico.html')


# ========== Paneles de Tickets (rutas asignadas) ===========
@app.route('/tickets')
@login_required
def tickets_panel():
    """Panel de tickets para usuarios (mis tickets)."""
    return render_template('tickets.html')


@app.route('/tickets/admin')
@login_required
def tickets_admin_panel():
    """Panel de administración de tickets (solo admin)."""
    if not is_admin_user():
        return render_template('403.html'), 403
    return render_template('tickets_admin.html')


@app.route('/tickets/ingeniero')
@login_required
def tickets_ingeniero_panel():
    """Panel específico para ingenieros de soporte."""
    user = get_current_user()
    if not user:
        return redirect(url_for('login'))
    if not (user.es_admin or (user.role and user.role.name == 'support')):
        return render_template('403.html'), 403
    return render_template('tickets_ingeniero.html')



# ========== Public read-only endpoints and consulta page ===========
@app.route('/catalogo_consulta')
def catalogo_consulta():
    """Página pública de consulta para accesos directos (sin login)."""
    return render_template('catalogo_consulta.html')


def _producto_sanitizado(p):
    return {
        'id': p.id,
        'nombre': p.nombre,
        'descripcion': p.descripcion,
        'precio': p.precio,
        'cantidad': p.cantidad,
        'imagen_url': p.imagen_url,
        'categoria': p.categoria
    }


@app.route('/public/categorias', methods=['GET'])
def public_categorias():
    """Public endpoint para obtener categorías distintas."""
    try:
        cats = db.session.query(Producto.categoria).filter(Producto.categoria != None).distinct().all()
        # cats is list of tuples
        lista = sorted([c[0] for c in cats if c[0]])
        return jsonify(lista)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/public/productos/buscar', methods=['GET'])
def public_buscar_productos():
    """Public endpoint para buscar productos (sin login)."""
    try:
        query = request.args.get('q', '').lower()
        categoria = request.args.get('categoria', '').lower()

        productos_q = Producto.query
        if query:
            productos_q = productos_q.filter(
                db.or_(
                    Producto.nombre.ilike(f'%{query}%'),
                    Producto.descripcion.ilike(f'%{query}%')
                )
            )
        if categoria:
            productos_q = productos_q.filter(Producto.categoria.ilike(f'%{categoria}%'))

        productos = productos_q.all()
        return jsonify([_producto_sanitizado(p) for p in productos])
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/public/productos', methods=['GET'])
def public_get_productos():
    """Public endpoint para listar todos los productos (sin login)."""
    try:
        productos = Producto.query.all()
        return jsonify([_producto_sanitizado(p) for p in productos])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ==================== API CRUD ====================

# GET - Obtener todos los productos
@app.route('/api/productos', methods=['GET'])
@login_required
def get_productos():
    productos = Producto.query.all()
    return jsonify([p.to_dict() for p in productos])

# GET - Obtener producto por ID
@app.route('/api/productos/<int:id>', methods=['GET'])
@login_required
def get_producto(id):
    producto = Producto.query.get(id)
    if not producto:
        return jsonify({'error': 'Producto no encontrado'}), 404
    return jsonify(producto.to_dict())

# POST - Crear producto
@app.route('/api/productos', methods=['POST'])
@login_required
def crear_producto():
    data = request.get_json()
    
    if not data or not data.get('nombre') or not data.get('precio'):
        return jsonify({'error': 'Nombre y precio son obligatorios'}), 400
    
    nuevo_producto = Producto(
        nombre=data.get('nombre'),
        descripcion=data.get('descripcion', ''),
        precio=float(data.get('precio')),
        cantidad=int(data.get('cantidad', 0)),
        imagen_url=data.get('imagen_url', ''),
        categoria=data.get('categoria', '')
    )
    
    db.session.add(nuevo_producto)
    db.session.commit()
    
    return jsonify(nuevo_producto.to_dict()), 201

# PUT - Actualizar producto
@app.route('/api/productos/<int:id>', methods=['PUT'])
@login_required
def actualizar_producto(id):
    producto = Producto.query.get(id)
    
    if not producto:
        return jsonify({'error': 'Producto no encontrado'}), 404
    
    data = request.get_json()
    
    producto.nombre = data.get('nombre', producto.nombre)
    producto.descripcion = data.get('descripcion', producto.descripcion)
    producto.precio = float(data.get('precio', producto.precio))
    producto.cantidad = int(data.get('cantidad', producto.cantidad))
    producto.imagen_url = data.get('imagen_url', producto.imagen_url)
    producto.categoria = data.get('categoria', producto.categoria)
    
    db.session.commit()
    
    return jsonify(producto.to_dict())

# DELETE - Eliminar producto
@app.route('/api/productos/<int:id>', methods=['DELETE'])
@login_required
def eliminar_producto(id):
    producto = Producto.query.get(id)
    
    if not producto:
        return jsonify({'error': 'Producto no encontrado'}), 404
    
    db.session.delete(producto)
    db.session.commit()
    
    return jsonify({'mensaje': 'Producto eliminado correctamente'})

# ==================== RUTAS ADICIONALES ====================

@app.route('/api/estadisticas', methods=['GET'])
def estadisticas():
    """Estadísticas del catálogo"""
    total_productos = Producto.query.count()
    valor_total_inventario = db.session.query(db.func.sum(Producto.precio * Producto.cantidad)).scalar() or 0
    
    # Estadísticas por categoría
    categorias = db.session.query(
        Producto.categoria,
        db.func.count(Producto.id).label('cantidad'),
        db.func.avg(Producto.precio).label('precio_promedio')
    ).group_by(Producto.categoria).all()
    
    stats_por_categoria = [
        {
            'categoria': cat[0] or 'Sin categoría',
            'cantidad': cat[1],
            'precio_promedio': float(cat[2]) if cat[2] else 0
        }
        for cat in categorias
    ]
    
    return jsonify({
        'total_productos': total_productos,
        'valor_total_inventario': float(valor_total_inventario),
        'categorias': stats_por_categoria,
        'producto_mas_caro': db.session.query(Producto).order_by(Producto.precio.desc()).first().to_dict() if total_productos > 0 else None,
        'producto_mas_barato': db.session.query(Producto).order_by(Producto.precio.asc()).first().to_dict() if total_productos > 0 else None,
        'stock_total': db.session.query(db.func.sum(Producto.cantidad)).scalar() or 0
    })

@app.route('/api/productos/buscar', methods=['GET'])
@login_required
def buscar_productos():
    """Buscar productos por nombre, categoría o descripción"""
    query = request.args.get('q', '').lower()
    categoria = request.args.get('categoria', '').lower()
    precio_min = request.args.get('precio_min', type=float)
    precio_max = request.args.get('precio_max', type=float)
    
    productos = Producto.query
    
    if query:
        productos = productos.filter(
            db.or_(
                Producto.nombre.ilike(f'%{query}%'),
                Producto.descripcion.ilike(f'%{query}%')
            )
        )
    
    if categoria:
        productos = productos.filter(Producto.categoria.ilike(f'%{categoria}%'))
    
    if precio_min is not None:
        productos = productos.filter(Producto.precio >= precio_min)
    
    if precio_max is not None:
        productos = productos.filter(Producto.precio <= precio_max)
    
    return jsonify([p.to_dict() for p in productos.all()])

@app.route('/api/productos/exportar', methods=['GET'])
@login_required
def exportar_productos():
    """Exportar productos a CSV"""
    import csv
    from io import StringIO
    from flask import make_response
    
    productos = Producto.query.all()
    
    output = StringIO()
    writer = csv.DictWriter(output, fieldnames=['id', 'nombre', 'descripcion', 'precio', 'cantidad', 'categoria', 'fecha_creacion'])
    writer.writeheader()
    
    for p in productos:
        writer.writerow({
            'id': p.id,
            'nombre': p.nombre,
            'descripcion': p.descripcion,
            'precio': p.precio,
            'cantidad': p.cantidad,
            'categoria': p.categoria,
            'fecha_creacion': p.fecha_creacion.isoformat()
        })
    
    response = make_response(output.getvalue())
    response.headers['Content-Disposition'] = 'attachment; filename=productos.csv'
    response.headers['Content-Type'] = 'text/csv'
    return response


@app.route('/api/productos/exportar-excel', methods=['GET'])
@login_required
def exportar_excel():
    """Exportar productos a XLSX con imágenes incrustadas"""
    try:
        from openpyxl import Workbook
        from openpyxl.drawing.image import Image as XLImage
        from openpyxl.styles import Font, PatternFill, Alignment
        from io import BytesIO
        import requests
        from PIL import Image
    except ImportError:
        return jsonify({'error': 'Dependencias faltantes (openpyxl, Pillow)'}), 500

    productos = Producto.query.all()

    wb = Workbook()
    ws = wb.active
    ws.title = "Catálogo"

    # Header con estilos
    headers = ['ID', 'Nombre', 'Descripción', 'Categoría', 'Precio', 'Stock', 'Imagen', 'Fecha Creación']
    ws.append(headers)
    header_fill = PatternFill(start_color='4472C4', end_color='4472C4', fill_type='solid')
    header_font = Font(bold=True, color='FFFFFF')

    for cell in ws[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal='center', vertical='center')

    # Anchos de columnas
    ws.column_dimensions['A'].width = 8
    ws.column_dimensions['B'].width = 25
    ws.column_dimensions['C'].width = 35
    ws.column_dimensions['D'].width = 15
    ws.column_dimensions['E'].width = 12
    ws.column_dimensions['F'].width = 10
    ws.column_dimensions['G'].width = 20
    ws.column_dimensions['H'].width = 18

    # Datos
    for idx, p in enumerate(productos, start=2):
        ws[f'A{idx}'] = p.id
        ws[f'B{idx}'] = p.nombre
        ws[f'C{idx}'] = p.descripcion or ''
        ws[f'D{idx}'] = p.categoria or ''
        ws[f'E{idx}'] = p.precio
        ws[f'F{idx}'] = p.cantidad
        ws[f'H{idx}'] = p.fecha_creacion.isoformat() if p.fecha_creacion else ''

        # Descargar e insertar imagen si existe
        if p.imagen_url:
            try:
                # Si es URL completa, descargar; si es ruta local, usarla directo
                if p.imagen_url.startswith('http'):
                    img_response = requests.get(p.imagen_url, timeout=5)
                    img_data = BytesIO(img_response.content)
                else:
                    # Ruta local (relative a UPLOAD_FOLDER)
                    img_path = os.path.join(UPLOAD_FOLDER, os.path.basename(p.imagen_url))
                    if os.path.exists(img_path):
                        img_data = img_path
                    else:
                        img_data = None

                if img_data:
                    # Insertar imagen redimensionada
                    if isinstance(img_data, BytesIO):
                        pil_img = Image.open(img_data)
                    else:
                        pil_img = Image.open(img_data)

                    # Redimensionar a máx 200x200 para que quepan en Excel
                    pil_img.thumbnail((200, 200), Image.Resampling.LANCZOS)

                    # Guardar en BytesIO
                    img_bytes = BytesIO()
                    pil_img.save(img_bytes, format='PNG')
                    img_bytes.seek(0)

                    # Insertar en Excel
                    xl_img = XLImage(img_bytes)
                    xl_img.width = 150
                    xl_img.height = 150
                    ws.add_image(xl_img, f'G{idx}')
                    ws.row_dimensions[idx].height = 120
            except Exception as e:
                # Si falla descargar, dejar URL como texto
                ws[f'G{idx}'] = p.imagen_url
                print(f"Warning: No se pudo insertar imagen de {p.nombre}: {e}")
        else:
            ws[f'G{idx}'] = 'Sin imagen'

    # Guardar a BytesIO
    output = BytesIO()
    wb.save(output)
    output.seek(0)

    response = make_response(output.getvalue())
    response.headers['Content-Disposition'] = 'attachment; filename=catalogo_productos.xlsx'
    response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    return response


@app.route('/api/productos/importar-excel', methods=['POST'])
@login_required
def importar_excel():
    """Importar productos desde Excel (CLAVES.xlsx)
    Mapea: Columna C (Clave) -> nombre, Columna F (Producto) -> descripción
    """
    if not is_admin_user():
        return jsonify({'error': 'Solo admins pueden importar'}), 403
    
    try:
        import openpyxl
    except ImportError:
        return jsonify({'error': 'openpyxl no instalado'}), 500
    
    # Verificar si hay archivo en request
    if 'file' not in request.files:
        return jsonify({'error': 'No se encontró archivo'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Archivo vacío'}), 400
    
    if not file.filename.lower().endswith('.xlsx'):
        return jsonify({'error': 'Solo se aceptan archivos .xlsx'}), 400
    
    try:
        # Cargar workbook
        wb = openpyxl.load_workbook(file)
        ws = wb.active
        
        # Mapear columnas: Clave (C=3), Producto (F=6)
        # Row 1 es encabezado, comenzar desde row 2
        
        stats = {
            'creados': 0,
            'actualizados': 0,
            'errores': 0,
            'detalles': []
        }
        
        for row_num, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
            try:
                # row es tupla con valores: índice 2 = columna C (Clave), índice 5 = columna F (Producto)
                clave = row[2]  # Columna C
                descripcion = row[5]  # Columna F
                
                # Validar que ambos campos existan
                if not clave or not descripcion:
                    stats['detalles'].append(f"Fila {row_num}: Falta Clave o Producto")
                    continue
                
                # Convertir a string y limpiar
                clave = str(clave).strip()
                descripcion = str(descripcion).strip()
                
                # Buscar si el producto ya existe por nombre (clave)
                producto = Producto.query.filter_by(nombre=clave).first()
                
                if producto:
                    # ACTUALIZAR
                    producto.descripcion = descripcion
                    stats['actualizados'] += 1
                    stats['detalles'].append(f"Actualizado: {clave}")
                else:
                    # CREAR NUEVO
                    nuevo_producto = Producto(
                        nombre=clave,
                        descripcion=descripcion,
                        precio=0.0,
                        cantidad=0,
                        categoria='Importado',
                        imagen_url=None
                    )
                    db.session.add(nuevo_producto)
                    stats['creados'] += 1
                    stats['detalles'].append(f"Creado: {clave}")
                
            except Exception as e:
                stats['errores'] += 1
                stats['detalles'].append(f"Fila {row_num}: Error - {str(e)}")
                continue
        
        # Guardar cambios
        try:
            db.session.commit()
            stats['mensaje'] = 'Importación completada'
        except Exception as e:
            db.session.rollback()
            stats['mensaje'] = f'Error al guardar: {str(e)}'
            stats['errores'] += 1
        
        return jsonify(stats), 200
    
    except Exception as e:
        return jsonify({'error': f'Error procesando Excel: {str(e)}'}), 500


@app.route('/api/productos/bajo-stock', methods=['GET'])
@login_required
def bajo_stock():
    """Obtener productos con bajo stock (< 5 unidades)"""
    productos = Producto.query.filter(Producto.cantidad < 5).all()
    return jsonify([p.to_dict() for p in productos])

@app.route('/api/categorias', methods=['GET'])
def obtener_categorias():
    """Obtener todas las categorías únicas"""
    categorias = db.session.query(Producto.categoria).distinct().filter(
        Producto.categoria != None
    ).all()
    return jsonify([cat[0] for cat in categorias])


@app.route('/api/logs', methods=['GET'])
@login_required
def get_logs():
    """Obtener logs de acceso (solo admin). Parámetro opcional: limit (default 50)"""
    if not is_admin_user():
        return jsonify({'error': 'Prohibido'}), 403

    limit = min(int(request.args.get('limit', 50)), 500)
    try:
        logs = db.session.query('access_logs').from_statement(db.text('SELECT * FROM access_logs ORDER BY timestamp DESC LIMIT :lim')).params(lim=limit).all()
        # Fallback to ORM query if direct text not supported
    except Exception:
        from models import AccessLog
        logs = AccessLog.query.order_by(AccessLog.timestamp.desc()).limit(limit).all()

    # Convert to dicts
    result = []
    for l in logs:
        try:
            result.append(l.to_dict())
        except Exception:
            # if row is a tuple from raw query, try mapping
            try:
                d = {
                    'id': l.id,
                    'ip': l.ip,
                    'username': l.username,
                    'path': l.path,
                    'method': l.method,
                    'user_agent': l.user_agent,
                    'referer': l.referer,
                    'timestamp': l.timestamp.isoformat() if hasattr(l, 'timestamp') else None
                }
                result.append(d)
            except Exception:
                continue

    return jsonify(result)


@app.route('/admin/puerta')
@login_required
def puerta():
    """Vista web exclusiva para el usuario 'root' con registros de acceso."""
    # Permitimos ver la 'Puerta' a cualquier administrador (es_admin)
    if not is_admin_user():
        return render_template('login.html', error='Acceso restringido'), 403

    from models import AccessLog
    limit = min(int(request.args.get('limit', 200)), 2000)
    logs = AccessLog.query.order_by(AccessLog.timestamp.desc()).limit(limit).all()
    # convert timestamps to ISO for template
    logs_serialized = []
    for l in logs:
        logs_serialized.append({
            'timestamp': l.timestamp.isoformat(),
            'username': l.username,
            'ip': l.ip,
            'path': l.path,
            'method': l.method,
            'user_agent': l.user_agent,
            'referer': l.referer
        })
    return render_template('puerta.html', logs=logs_serialized)


# ==================== ENDPOINTS DE PROVEEDORES ====================

# GET - Obtener todos los proveedores
@app.route('/api/proveedores', methods=['GET'])
@login_required
def get_proveedores():
    proveedores = Proveedor.query.all()
    return jsonify([p.to_dict() for p in proveedores])

# GET - Obtener proveedor por ID
@app.route('/api/proveedores/<int:id>', methods=['GET'])
@login_required
def get_proveedor(id):
    proveedor = Proveedor.query.get(id)
    if not proveedor:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    return jsonify(proveedor.to_dict())

# POST - Crear proveedor
@app.route('/api/proveedores', methods=['POST'])
@login_required
def crear_proveedor():
    data = request.get_json()
    
    if not data or not data.get('nombre'):
        return jsonify({'error': 'Nombre es obligatorio'}), 400
    
    # Verificar si ya existe
    existente = Proveedor.query.filter_by(nombre=data.get('nombre')).first()
    if existente:
        return jsonify({'error': 'El proveedor ya existe'}), 400
    
    nuevo_proveedor = Proveedor(
        nombre=data.get('nombre'),
        telefono=data.get('telefono', ''),
        rfc=data.get('rfc', ''),
        domicilio=data.get('domicilio', ''),
        correo=data.get('correo', ''),
        contacto=data.get('contacto', ''),
        notas=data.get('notas', '')
    )
    
    db.session.add(nuevo_proveedor)
    db.session.commit()
    
    return jsonify(nuevo_proveedor.to_dict()), 201

# PUT - Actualizar proveedor
@app.route('/api/proveedores/<int:id>', methods=['PUT'])
@login_required
def actualizar_proveedor(id):
    proveedor = Proveedor.query.get(id)
    
    if not proveedor:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    
    data = request.get_json()
    
    proveedor.nombre = data.get('nombre', proveedor.nombre)
    proveedor.telefono = data.get('telefono', proveedor.telefono)
    proveedor.rfc = data.get('rfc', proveedor.rfc)
    proveedor.domicilio = data.get('domicilio', proveedor.domicilio)
    proveedor.correo = data.get('correo', proveedor.correo)
    proveedor.contacto = data.get('contacto', proveedor.contacto)
    proveedor.notas = data.get('notas', proveedor.notas)
    
    db.session.commit()
    
    return jsonify(proveedor.to_dict())

# DELETE - Eliminar proveedor
@app.route('/api/proveedores/<int:id>', methods=['DELETE'])
@login_required
def eliminar_proveedor(id):
    proveedor = Proveedor.query.get(id)
    
    if not proveedor:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    
    db.session.delete(proveedor)
    db.session.commit()
    
    return jsonify({'mensaje': 'Proveedor eliminado correctamente'})

# ==================== ENDPOINTS DE PRODUCTO-PROVEEDOR ====================

# GET - Obtener proveedores de un producto
@app.route('/api/productos/<int:producto_id>/proveedores', methods=['GET'])
@login_required
def get_proveedores_producto(producto_id):
    producto = Producto.query.get(producto_id)
    if not producto:
        return jsonify({'error': 'Producto no encontrado'}), 404
    
    return jsonify([pp.to_dict() for pp in producto.proveedores])

# POST - Asignar proveedor a producto
@app.route('/api/productos/<int:producto_id>/proveedores', methods=['POST'])
@login_required
def asignar_proveedor(producto_id):
    data = request.get_json()
    
    producto = Producto.query.get(producto_id)
    if not producto:
        return jsonify({'error': 'Producto no encontrado'}), 404
    
    proveedor = Proveedor.query.get(data.get('proveedor_id'))
    if not proveedor:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    
    # Verificar si ya existe la relación
    existente = ProductoProveedor.query.filter_by(
        producto_id=producto_id,
        proveedor_id=data.get('proveedor_id')
    ).first()
    
    if existente:
        # Actualizar precio si existe
        existente.precio_proveedor = float(data.get('precio_proveedor', existente.precio_proveedor))
        if data.get('fecha_precio'):
            existente.fecha_precio = datetime.strptime(data.get('fecha_precio'), '%Y-%m-%d').date()
        db.session.commit()
        return jsonify(existente.to_dict()), 200
    
    # Crear nueva relación
    from datetime import datetime as dt
    fecha_precio = data.get('fecha_precio')
    if fecha_precio:
        fecha_precio = datetime.strptime(fecha_precio, '%Y-%m-%d').date()
    else:
        fecha_precio = dt.now().date()
    
    nuevo_asignar = ProductoProveedor(
        producto_id=producto_id,
        proveedor_id=data.get('proveedor_id'),
        precio_proveedor=float(data.get('precio_proveedor')),
        fecha_precio=fecha_precio,
        cantidad_minima=int(data.get('cantidad_minima', 1))
    )
    
    db.session.add(nuevo_asignar)
    db.session.commit()
    
    return jsonify(nuevo_asignar.to_dict()), 201

# DELETE - Desasignar proveedor de producto
@app.route('/api/productos/<int:producto_id>/proveedores/<int:proveedor_id>', methods=['DELETE'])
@login_required
def desasignar_proveedor(producto_id, proveedor_id):
    asignacion = ProductoProveedor.query.filter_by(
        producto_id=producto_id,
        proveedor_id=proveedor_id
    ).first()
    
    if not asignacion:
        return jsonify({'error': 'Asignación no encontrada'}), 404
    
    db.session.delete(asignacion)
    db.session.commit()
    
    return jsonify({'mensaje': 'Proveedor desasignado correctamente'})

# ==================== ENDPOINTS DE HISTORIAL DE PRECIOS ====================

# GET - Obtener historial de precios de un proveedor en un producto
@app.route('/api/productos/<int:producto_id>/proveedores/<int:proveedor_id>/historial', methods=['GET'])
@login_required
def get_historial_precios(producto_id, proveedor_id):
    asignacion = ProductoProveedor.query.filter_by(
        producto_id=producto_id,
        proveedor_id=proveedor_id
    ).first()
    
    if not asignacion:
        return jsonify({'error': 'Asignación no encontrada'}), 404
    
    historial = HistorialPreciosProveedor.query.filter_by(
        producto_proveedor_id=asignacion.id
    ).order_by(HistorialPreciosProveedor.fecha_precio.desc()).all()
    
    return jsonify([h.to_dict() for h in historial])

# POST - Agregar precio histórico
@app.route('/api/productos/<int:producto_id>/proveedores/<int:proveedor_id>/historial', methods=['POST'])
@login_required
def agregar_precio_historico(producto_id, proveedor_id):
    asignacion = ProductoProveedor.query.filter_by(
        producto_id=producto_id,
        proveedor_id=proveedor_id
    ).first()
    
    if not asignacion:
        return jsonify({'error': 'Asignación no encontrada'}), 404
    
    data = request.get_json()
    
    if not data.get('precio'):
        return jsonify({'error': 'El precio es requerido'}), 400
    
    if not data.get('fecha_precio'):
        return jsonify({'error': 'La fecha es requerida'}), 400
    
    try:
        fecha_precio = datetime.strptime(data.get('fecha_precio'), '%Y-%m-%d').date()
        
        # Crear nuevo registro de precio histórico
        nuevo_precio = HistorialPreciosProveedor(
            producto_proveedor_id=asignacion.id,
            precio=float(data.get('precio')),
            fecha_precio=fecha_precio,
            notas=data.get('notas', '')
        )
        
        # Actualizar el precio actual en ProductoProveedor
        asignacion.precio_proveedor = float(data.get('precio'))
        asignacion.fecha_precio = fecha_precio
        
        db.session.add(nuevo_precio)
        db.session.commit()
        
        return jsonify({
            'mensaje': 'Precio agregado al historial',
            'precio_historico': nuevo_precio.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Error: {str(e)}'}), 500

# DELETE - Eliminar precio histórico
@app.route('/api/historial-precios/<int:precio_id>', methods=['DELETE'])
@login_required
def eliminar_precio_historico(precio_id):
    precio = HistorialPreciosProveedor.query.get(precio_id)
    
    if not precio:
        return jsonify({'error': 'Registro de precio no encontrado'}), 404
    
    db.session.delete(precio)
    db.session.commit()
    
    return jsonify({'mensaje': 'Precio histórico eliminado correctamente'})

# ==================== ENDPOINTS DE CARGA DE IMÁGENES ====================

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# POST - Subir imagen para producto
@app.route('/api/productos/upload-imagen', methods=['POST'])
@login_required
def upload_imagen():
    if 'imagen' not in request.files:
        return jsonify({'error': 'No se envió archivo'}), 400
    
    file = request.files['imagen']
    
    if file.filename == '':
        return jsonify({'error': 'No se seleccionó archivo'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': 'Formato de archivo no permitido. Usa: png, jpg, jpeg, gif, webp'}), 400
    
    try:
        # Generar nombre seguro con timestamp
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_')
        filename = timestamp + filename
        
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Retornar path relativo para acceso
        image_url = f'/uploads/productos/{filename}'
        
        return jsonify({
            'mensaje': 'Imagen subida exitosamente',
            'url': image_url,
            'filename': filename
        }), 201
    
    except Exception as e:
        return jsonify({'error': f'Error al subir imagen: {str(e)}'}), 500

# GET - Servir imagen (ruta para acceso de archivos)
@app.route('/uploads/productos/<filename>')
@login_required
def descargar_imagen(filename):
    from flask import send_from_directory
    try:
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)
    except Exception as e:
        return jsonify({'error': 'Imagen no encontrada'}), 404


# ==================== RUTAS DE TICKETS ====================

# 1. POST /api/tickets (PÚBLICO - sin login)
@app.route('/api/tickets', methods=['POST'])
def crear_ticket():
    """Crear ticket (nombre_solicitante, email, departamento, titulo, descripcion)"""
    try:
        data = request.get_json()
        
        # Validar campos requeridos
        campos_requeridos = ['nombre_solicitante', 'email', 'departamento', 'titulo', 'descripcion']
        for campo in campos_requeridos:
            if not data.get(campo):
                return jsonify({'error': f'Campo requerido: {campo}'}), 400
        
        # Generar número único de ticket
        numero_ticket = f"TKT-{int(time() * 1000)}"
        
        # Crear ticket
        nuevo_ticket = Ticket(
            numero_ticket=numero_ticket,
            nombre_solicitante=data.get('nombre_solicitante'),
            email_solicitante=data.get('email'),
            departamento=data.get('departamento'),
            titulo=data.get('titulo'),
            descripcion=data.get('descripcion'),
            estado='nuevo',
            prioridad=data.get('prioridad', 'media'),
            categoria=data.get('categoria', 'general'),
            fecha_creacion=datetime.utcnow()
        )
        
        db.session.add(nuevo_ticket)
        db.session.commit()
        
        logger.info(f"✓ Ticket creado: {numero_ticket} por {data.get('nombre_solicitante')}")
        
        return jsonify({
            'id': nuevo_ticket.id,
            'numero_ticket': numero_ticket,
            'mensaje': 'Ticket creado exitosamente'
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al crear ticket: {e}")
        return jsonify({'error': str(e)}), 500


# 2. GET /api/bandeja-entrada (LOGIN REQUERIDO)
@app.route('/api/bandeja-entrada', methods=['GET'])
@ingeniero_login_required
def bandeja_entrada():
    """Ver todos los tickets con estado 'nuevo' (sin ingeniero_id)"""
    try:
        # Obtener tickets sin asignar
        tickets = Ticket.query.filter_by(estado='nuevo', ingeniero_id=None).order_by(Ticket.fecha_creacion.desc()).all()
        
        return jsonify({
            'tickets': [
                {
                    'id': t.id,
                    'numero_ticket': t.numero_ticket,
                    'titulo': t.titulo,
                    'nombre_solicitante': t.nombre_solicitante,
                    'email_solicitante': t.email_solicitante,
                    'departamento': t.departamento,
                    'estado': t.estado,
                    'prioridad': t.prioridad,
                    'categoria': t.categoria,
                    'fecha_creacion': t.fecha_creacion.isoformat() if t.fecha_creacion else None
                }
                for t in tickets
            ]
        }), 200
        
    except Exception as e:
        logger.error(f"Error en bandeja_entrada: {e}")
        return jsonify({'error': str(e)}), 500


# 3. POST /api/tickets/<id>/tomar (LOGIN REQUERIDO)
@app.route('/api/tickets/<int:ticket_id>/tomar', methods=['POST'])
@ingeniero_login_required
def tomar_ticket(ticket_id):
    """Ingeniero 'toma' el ticket"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        ticket = Ticket.query.get(ticket_id)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        
        if ticket.estado != 'nuevo':
            return jsonify({'error': 'El ticket no está disponible'}), 400
        
        # Asignar al usuario actual
        ticket.ingeniero_id = usuario.id
        ticket.estado = 'en_progreso'
        ticket.fecha_asignacion = datetime.utcnow()
        
        db.session.commit()
        
        logger.info(f"✓ Ticket {ticket.numero_ticket} asignado a {usuario.username}")
        
        return jsonify({
            'mensaje': 'Ticket asignado exitosamente',
            'numero_ticket': ticket.numero_ticket
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al tomar ticket: {e}")
        return jsonify({'error': str(e)}), 500


# 4. GET /api/mis-tickets (LOGIN REQUERIDO)
@app.route('/api/mis-tickets', methods=['GET'])
@ingeniero_login_required
def mis_tickets():
    """Ver tickets donde ingeniero_id = usuario actual (en_progreso o resuelto)"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        tickets = Ticket.query.filter(
            Ticket.ingeniero_id == usuario.id,
            Ticket.estado.in_(['en_progreso', 'resuelto'])
        ).order_by(Ticket.fecha_creacion.desc()).all()
        
        resultado = []
        for t in tickets:
            comentarios = ComentarioTicket.query.filter_by(ticket_id=t.id).all()
            resultado.append({
                'id': t.id,
                'numero_ticket': t.numero_ticket,
                'titulo': t.titulo,
                'nombre_solicitante': t.nombre_solicitante,
                'email_solicitante': t.email_solicitante,
                'departamento': t.departamento,
                'descripcion': t.descripcion,
                'estado': t.estado,
                'prioridad': t.prioridad,
                'categoria': t.categoria,
                'fecha_creacion': t.fecha_creacion.isoformat() if t.fecha_creacion else None,
                'fecha_asignacion': t.fecha_asignacion.isoformat() if t.fecha_asignacion else None,
                'fecha_resolucion': t.fecha_resolucion.isoformat() if t.fecha_resolucion else None,
                'comentarios_count': len(comentarios),
                'comentarios': [
                    {
                        'id': c.id,
                        'contenido': c.contenido,
                        'imagen_url': c.imagen_url,
                        'fecha_creacion': c.fecha_creacion.isoformat() if c.fecha_creacion else None
                    }
                    for c in comentarios
                ]
            })
        
        return jsonify({'tickets': resultado}), 200
        
    except Exception as e:
        logger.error(f"Error en mis_tickets: {e}")
        return jsonify({'error': str(e)}), 500


# 5. GET /api/tickets/<id> (LOGIN REQUERIDO)
@app.route('/api/tickets/<int:ticket_id>', methods=['GET'])
@ingeniero_login_required
def obtener_ticket(ticket_id):
    """Ver detalles de un ticket con todos sus comentarios"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        ticket = Ticket.query.get(ticket_id)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        
        # Verificar permisos: solicitante, ingeniero o admin
        es_solicitante = ticket.email_solicitante
        es_ingeniero = ticket.ingeniero_id == usuario.id
        es_admin = is_admin_user()
        
        if not (es_solicitante or es_ingeniero or es_admin):
            return jsonify({'error': 'Acceso denegado'}), 403
        
        comentarios = ComentarioTicket.query.filter_by(ticket_id=ticket_id).all()
        
        # Obtener nombre del ingeniero asignado
        ingeniero_nombre = None
        if ticket.ingeniero_id:
            ing = Usuario.query.get(ticket.ingeniero_id)
            ingeniero_nombre = ing.username if ing else None
        
        return jsonify({
            'ticket': {
                'id': ticket.id,
                'numero_ticket': ticket.numero_ticket,
                'titulo': ticket.titulo,
                'nombre_solicitante': ticket.nombre_solicitante,
                'email_solicitante': ticket.email_solicitante,
                'departamento': ticket.departamento,
                'descripcion': ticket.descripcion,
                'estado': ticket.estado,
                'prioridad': ticket.prioridad,
                'categoria': ticket.categoria,
                'ingeniero_id': ticket.ingeniero_id,
                'ingeniero_nombre': ingeniero_nombre,
                'fecha_creacion': ticket.fecha_creacion.isoformat() if ticket.fecha_creacion else None,
                'fecha_asignacion': ticket.fecha_asignacion.isoformat() if ticket.fecha_asignacion else None,
                'fecha_resolucion': ticket.fecha_resolucion.isoformat() if ticket.fecha_resolucion else None,
                'comentarios': [
                    {
                        'id': c.id,
                        'contenido': c.contenido,
                        'imagen_url': c.imagen_url,
                        'fecha_creacion': c.fecha_creacion.isoformat() if c.fecha_creacion else None,
                        'ingeniero_nombre': Usuario.query.get(c.ingeniero_id).username if c.ingeniero_id else 'Desconocido'
                    }
                    for c in comentarios
                ]
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Error al obtener ticket: {e}")
        return jsonify({'error': str(e)}), 500


# 6. POST /api/tickets/<id>/comentario (LOGIN REQUERIDO)
@app.route('/api/tickets/<int:ticket_id>/comentario', methods=['POST'])
@ingeniero_login_required
def agregar_comentario(ticket_id):
    """Agregar comentario/documentación con imagen opcional"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        ticket = Ticket.query.get(ticket_id)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        
        # Verificar que es el ingeniero asignado
        if ticket.ingeniero_id != usuario.id:
            return jsonify({'error': 'Acceso denegado'}), 403
        
        data = request.get_json()
        contenido = data.get('contenido')
        
        if not contenido:
            return jsonify({'error': 'Contenido requerido'}), 400
        
        imagen_url = data.get('imagen_url')
        
        comentario = ComentarioTicket(
            ticket_id=ticket_id,
            ingeniero_id=usuario.id,
            contenido=contenido,
            imagen_url=imagen_url,
            fecha_creacion=datetime.utcnow()
        )
        
        db.session.add(comentario)
        db.session.commit()
        
        logger.info(f"✓ Comentario agregado al ticket {ticket.numero_ticket}")
        
        return jsonify({
            'id': comentario.id,
            'mensaje': 'Comentario agregado exitosamente'
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al agregar comentario: {e}")
        return jsonify({'error': str(e)}), 500


# 7. PUT /api/tickets/<id>/estado (LOGIN REQUERIDO)
@app.route('/api/tickets/<int:ticket_id>/estado', methods=['PUT'])
@ingeniero_login_required
def cambiar_estado_ticket(ticket_id):
    """Cambiar estado a 'resuelto'"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        ticket = Ticket.query.get(ticket_id)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        
        # Solo el ingeniero asignado puede cambiar el estado
        if ticket.ingeniero_id != usuario.id:
            return jsonify({'error': 'Acceso denegado'}), 403
        
        data = request.get_json()
        nuevo_estado = data.get('estado', 'resuelto')
        
        if nuevo_estado not in ['en_progreso', 'resuelto']:
            return jsonify({'error': 'Estado inválido'}), 400
        
        ticket.estado = nuevo_estado
        
        if nuevo_estado == 'resuelto':
            ticket.fecha_resolucion = datetime.utcnow()
        
        db.session.commit()
        
        logger.info(f"✓ Ticket {ticket.numero_ticket} cambiado a {nuevo_estado}")
        
        return jsonify({
            'mensaje': 'Estado actualizado',
            'numero_ticket': ticket.numero_ticket,
            'estado': nuevo_estado
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al cambiar estado: {e}")
        return jsonify({'error': str(e)}), 500


# 7.5 PUT /api/tickets/<id>/devolver (LOGIN REQUERIDO - devolver a bandeja)
@app.route('/api/tickets/<int:ticket_id>/devolver', methods=['PUT'])
@ingeniero_login_required
def devolver_ticket(ticket_id):
    """Devolver ticket a la bandeja (poner como 'nuevo' sin ingeniero)"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        ticket = Ticket.query.get(ticket_id)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        
        # Solo el ingeniero asignado puede devolverlo
        if ticket.ingeniero_id != usuario.id:
            return jsonify({'error': 'Solo el ingeniero asignado puede devolver este ticket'}), 403
        
        # Devolver a estado nuevo y limpiar ingeniero_id
        ticket.estado = 'nuevo'
        ticket.ingeniero_id = None
        ticket.fecha_asignacion = None
        
        db.session.commit()
        logger.info(f"✓ Ticket {ticket.numero_ticket} devuelto a bandeja por {usuario.username}")
        
        return jsonify({
            'mensaje': 'Ticket devuelto a la bandeja',
            'numero_ticket': ticket.numero_ticket,
            'estado': ticket.estado
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al devolver ticket: {e}")
        return jsonify({'error': str(e)}), 500


# 8. POST /api/tickets/<id>/imagen (LOGIN REQUERIDO)
@app.route('/api/tickets/<int:ticket_id>/imagen', methods=['POST'])
@ingeniero_login_required
def subir_imagen_ticket(ticket_id):
    """Subir imagen para comentario"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        ticket = Ticket.query.get(ticket_id)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        
        if ticket.ingeniero_id != usuario.id:
            return jsonify({'error': 'Acceso denegado'}), 403
        
        if 'imagen' not in request.files:
            return jsonify({'error': 'No se proporcionó imagen'}), 400
        
        archivo = request.files['imagen']
        
        if archivo.filename == '':
            return jsonify({'error': 'No se seleccionó archivo'}), 400
        
        # Validar extensión
        ext = archivo.filename.rsplit('.', 1)[1].lower() if '.' in archivo.filename else ''
        if ext not in ALLOWED_EXTENSIONS:
            return jsonify({'error': f'Extensión no permitida. Permitidas: {ALLOWED_EXTENSIONS}'}), 400
        
        # Guardar archivo
        nombre_seguro = secure_filename(f"ticket_{ticket_id}_{uuid.uuid4()}.{ext}")
        ruta_archivo = os.path.join(UPLOAD_FOLDER, nombre_seguro)
        archivo.save(ruta_archivo)
        
        # Retornar URL
        url_imagen = f"/uploads/productos/{nombre_seguro}"
        
        logger.info(f"✓ Imagen subida para ticket {ticket.numero_ticket}")
        
        return jsonify({
            'url': url_imagen,
            'mensaje': 'Imagen subida exitosamente'
        }), 201
        
    except Exception as e:
        logger.error(f"Error al subir imagen: {e}")
        return jsonify({'error': str(e)}), 500


# 9. GET /api/tickets/descargar/excel (LOGIN REQUERIDO)
@app.route('/api/tickets/descargar/excel', methods=['GET'])
@ingeniero_login_required
def descargar_tickets_excel():
    """Descargar en Excel los 'mis-tickets' con: numero, titulo, solicitante, estado, fecha_creacion, comentarios_count"""
    try:
        usuario = Usuario.query.filter_by(username=session.get('ingeniero_user')).first()
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 401
        
        # Obtener tickets del usuario
        tickets = Ticket.query.filter(
            Ticket.ingeniero_id == usuario.id,
            Ticket.estado.in_(['en_progreso', 'resuelto'])
        ).order_by(Ticket.fecha_creacion.desc()).all()
        
        # Crear workbook
        wb = Workbook()
        ws = wb.active
        ws.title = "Mis Tickets"
        
        # Encabezados
        encabezados = ['Número', 'Título', 'Solicitante', 'Estado', 'Fecha Creación', 'Comentarios']
        ws.append(encabezados)
        
        # Datos
        for ticket in tickets:
            comentarios_count = len(ComentarioTicket.query.filter_by(ticket_id=ticket.id).all())
            ws.append([
                ticket.numero_ticket,
                ticket.titulo,
                ticket.nombre_solicitante,
                ticket.estado,
                ticket.fecha_creacion.strftime('%d/%m/%Y %H:%M') if ticket.fecha_creacion else '',
                comentarios_count
            ])
        
        # Ajustar ancho de columnas
        for column in ws.columns:
            max_length = 0
            column_letter = column[0].column_letter
            for cell in column:
                try:
                    if len(str(cell.value)) > max_length:
                        max_length = len(str(cell.value))
                except:
                    pass
            adjusted_width = min(max_length + 2, 50)
            ws.column_dimensions[column_letter].width = adjusted_width
        
        # Guardar en memoria
        output = BytesIO()
        wb.save(output)
        output.seek(0)
        
        filename = f"mis_tickets_{datetime.now().strftime('%d%m%Y_%H%M%S')}.xlsx"
        
        logger.info(f"✓ Tickets descargados en Excel por {usuario.username}")
        
        return send_file(
            output,
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            as_attachment=True,
            download_name=filename
        )
        
    except Exception as e:
        logger.error(f"Error al descargar tickets en Excel: {e}")
        return jsonify({'error': str(e)}), 500


# ==================== RUTAS DE INGENIEROS ====================

# GET - Obtener lista de ingenieros (Admin)
@app.route('/api/ingenieros', methods=['GET'])
@login_required
def obtener_ingenieros():
    """Obtiene lista de ingenieros"""
    try:
        ingenieros = Ingeniero.query.all()
        
        return jsonify({
            'ingenieros': [i.to_dict() for i in ingenieros]
        }), 200
        
    except Exception as e:
        logger.error(f"Error al obtener ingenieros: {e}")
        return jsonify({'error': str(e)}), 500


# POST - Registrar nuevo ingeniero (Admin)
@app.route('/api/ingenieros', methods=['POST'])
@login_required
def crear_ingeniero():
    """Crea un nuevo registro de ingeniero"""
    if not is_admin_user():
        return jsonify({'error': 'Acceso denegado'}), 403
    
    try:
        data = request.get_json()
        usuario_id = data.get('usuario_id')
        
        usuario = Usuario.query.get(usuario_id)
        if not usuario:
            return jsonify({'error': 'Usuario no encontrado'}), 404
        
        # Verificar si ya es ingeniero
        if Ingeniero.query.filter_by(usuario_id=usuario_id).first():
            return jsonify({'error': 'Este usuario ya es ingeniero'}), 400
        
        nuevo_ingeniero = Ingeniero(
            usuario_id=usuario_id,
            especialidad=data.get('especialidad'),
            telefono=data.get('telefono'),
            disponible=True
        )
        
        db.session.add(nuevo_ingeniero)
        db.session.commit()
        
        logger.info(f"✓ Nuevo ingeniero registrado: {usuario.username}")
        
        return jsonify({
            'mensaje': 'Ingeniero registrado exitosamente',
            'ingeniero': nuevo_ingeniero.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al crear ingeniero: {e}")
        return jsonify({'error': str(e)}), 500


# PUT - Actualizar datos de ingeniero
@app.route('/api/ingenieros/<int:ingeniero_id>', methods=['PUT'])
@login_required
def actualizar_ingeniero(ingeniero_id):
    """Actualiza datos de un ingeniero"""
    if not is_admin_user():
        return jsonify({'error': 'Acceso denegado'}), 403
    
    try:
        ingeniero = Ingeniero.query.get(ingeniero_id)
        if not ingeniero:
            return jsonify({'error': 'Ingeniero no encontrado'}), 404
        
        data = request.get_json()
        
        if 'especialidad' in data:
            ingeniero.especialidad = data['especialidad']
        if 'telefono' in data:
            ingeniero.telefono = data['telefono']
        if 'disponible' in data:
            ingeniero.disponible = data['disponible']
        
        db.session.commit()
        
        logger.info(f"✓ Ingeniero {ingeniero.usuario.username} actualizado")
        
        return jsonify({
            'mensaje': 'Ingeniero actualizado exitosamente',
            'ingeniero': ingeniero.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error al actualizar ingeniero: {e}")
        return jsonify({'error': str(e)}), 500


# ==================== PROCESOS Y CLAVES - ADMIN PANEL ====================

@app.route('/procesos')
@login_required
@requires_permission('catalog', 'edit')
def procesos_panel():
    """Panel de administración para procesos (catálogo) y claves (productos)."""
    try:
        clave_id = request.args.get('clave_id', type=int)
        claves = ClaveProducto.query.order_by(ClaveProducto.clave.asc()).all()
        procesos = ProcesoCatalogo.query.filter_by(activo=True).order_by(ProcesoCatalogo.nombre.asc()).all()
        clave_sel = ClaveProducto.query.get(clave_id) if clave_id else None
        return render_template('procesos_admin.html', claves=claves, procesos=procesos, clave_sel=clave_sel)
    except Exception as e:
        logger.error(f"Error cargando panel de procesos: {e}")
        return render_template('procesos_admin.html', claves=[], procesos=[], clave_sel=None, error=str(e))


@app.route('/procesos/clave/save', methods=['POST'])
@login_required
@requires_permission('catalog', 'edit')
def procesos_clave_save():
    """Crear o actualizar una clave producto."""
    try:
        clave_id = request.form.get('id', type=int)
        clave = request.form.get('clave', '').strip()
        nombre = request.form.get('nombre', '').strip()
        notas = request.form.get('notas', '').strip()
        activo = request.form.get('activo') == 'on'

        if not clave:
            return redirect(url_for('procesos_panel'))

        if clave_id:
            obj = ClaveProducto.query.get_or_404(clave_id)
            obj.clave = clave
            obj.nombre = nombre
            obj.notas = notas
            obj.activo = activo
        else:
            obj = ClaveProducto(clave=clave, nombre=nombre, notas=notas, activo=activo)
            db.session.add(obj)
        db.session.commit()
        return redirect(url_for('procesos_panel', clave_id=obj.id))
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error guardando clave: {e}")
        return redirect(url_for('procesos_panel'))


@app.route('/procesos/clave/<int:clave_id>/secuencia/save', methods=['POST'])
@login_required
@requires_permission('catalog', 'edit')
def procesos_clave_secuencia_save(clave_id):
    """Guardar la secuencia de procesos para una clave."""
    try:
        clave = ClaveProducto.query.get_or_404(clave_id)
        # Arrays enviados desde el formulario
        procesos_ids = request.form.getlist('proceso_id[]')
        ordenes = request.form.getlist('orden[]')
        ct_list = request.form.getlist('ct[]')
        oper_list = request.form.getlist('operacion[]')
        t_e_list = request.form.getlist('t_e[]')
        t_tct_list = request.form.getlist('t_tct[]')
        t_tco_list = request.form.getlist('t_tco[]')
        t_to_list = request.form.getlist('t_to[]')
        tiempos = request.form.getlist('tiempo_est[]')  # legacy opcional
        notas_list = request.form.getlist('notas[]')

        # Limpiar actuales
        ClaveProceso.query.filter_by(clave_id=clave.id).delete()
        db.session.flush()

        # Crear nuevos en orden
        for idx, pid in enumerate(procesos_ids):
            try:
                p_id = int(pid)
            except ValueError:
                continue
            orden = int(ordenes[idx]) if idx < len(ordenes) and str(ordenes[idx]).isdigit() else idx + 1
            ct = ct_list[idx] if idx < len(ct_list) else None
            oper = oper_list[idx] if idx < len(oper_list) else None
            t_e = t_e_list[idx] if idx < len(t_e_list) else None
            t_tct = t_tct_list[idx] if idx < len(t_tct_list) else None
            t_tco = t_tco_list[idx] if idx < len(t_tco_list) else None
            t_to = t_to_list[idx] if idx < len(t_to_list) else None
            tiempo = tiempos[idx] if idx < len(tiempos) else None
            nota = notas_list[idx] if idx < len(notas_list) else None
            cp = ClaveProceso(
                clave_id=clave.id,
                proceso_id=p_id,
                orden=orden,
                centro_trabajo=ct,
                operacion=oper,
                t_e=t_e,
                t_tct=t_tct,
                t_tco=t_tco,
                t_to=t_to,
                tiempo_estimado=tiempo,
                notas=nota
            )
            db.session.add(cp)

        db.session.commit()
        return redirect(url_for('procesos_panel', clave_id=clave.id))
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error guardando secuencia de clave {clave_id}: {e}")
        return redirect(url_for('procesos_panel', clave_id=clave_id))


@app.route('/procesos/clave/<int:clave_id>/delete', methods=['POST'])
@login_required
@requires_permission('catalog', 'edit')
def procesos_clave_delete(clave_id):
    try:
        obj = ClaveProducto.query.get_or_404(clave_id)
        db.session.delete(obj)
        db.session.commit()
        return redirect(url_for('procesos_panel'))
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error eliminando clave {clave_id}: {e}")
        return redirect(url_for('procesos_panel'))


@app.route('/procesos/base/save', methods=['POST'])
@login_required
@requires_permission('catalog', 'edit')
def procesos_base_save():
    """Crear o actualizar un proceso del catálogo."""
    try:
        proc_id = request.form.get('id', type=int)
        codigo = request.form.get('codigo', '').strip()
        nombre = request.form.get('nombre', '').strip()
        operacion = request.form.get('operacion', '').strip()
        descripcion = request.form.get('descripcion', '').strip()
        centro_trabajo = request.form.get('centro_trabajo', '').strip()
        tiempo_est = request.form.get('tiempo_estimado', '').strip()
        activo = request.form.get('activo') == 'on'

        # Si no quieren código, lo permitimos vacío. Si no se envía nombre, usar operacion como nombre
        if not nombre:
            nombre = operacion or 'Operacion'

        if proc_id:
            p = ProcesoCatalogo.query.get_or_404(proc_id)
            p.codigo = codigo
            p.nombre = nombre
            p.operacion = operacion
            p.descripcion = descripcion
            p.centro_trabajo = centro_trabajo
            p.tiempo_estimado = tiempo_est
            p.activo = activo
        else:
            p = ProcesoCatalogo(codigo=codigo or None, nombre=nombre, operacion=operacion, descripcion=descripcion, centro_trabajo=centro_trabajo, tiempo_estimado=tiempo_est, activo=activo)
            db.session.add(p)
        db.session.commit()
        return redirect(url_for('procesos_panel'))
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error guardando proceso base: {e}")
        return redirect(url_for('procesos_panel'))


@app.route('/procesos/base/<int:proc_id>/delete', methods=['POST'])
@login_required
@requires_permission('catalog', 'edit')
def procesos_base_delete(proc_id):
    try:
        uso = ClaveProceso.query.filter_by(proceso_id=proc_id).count()
        if uso > 0:
            # Evitar borrar si está en uso
            return redirect(url_for('procesos_panel'))
        p = ProcesoCatalogo.query.get_or_404(proc_id)
        db.session.delete(p)
        db.session.commit()
        return redirect(url_for('procesos_panel'))
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error eliminando proceso base {proc_id}: {e}")
        return redirect(url_for('procesos_panel'))


@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Recurso no encontrado'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Error interno del servidor'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
