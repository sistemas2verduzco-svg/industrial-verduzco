from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from models import db, Producto, Proveedor, ProductoProveedor, HistorialPreciosProveedor, Usuario
from auth import AuthManager
import os
from dotenv import load_dotenv
from functools import wraps
import secrets
from werkzeug.utils import secure_filename
from datetime import datetime
from time import time

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

# Crear tablas
with app.app_context():
    db.create_all()
    # Crear usuario admin por defecto si no existe
    try:
        if not Usuario.query.filter_by(username='admin').first():
            admin_user = Usuario(
                username='admin',
                correo='admin@example.com',
                es_admin=True,
                activo=True
            )
            admin_user.set_password('admin123')
            db.session.add(admin_user)
            db.session.commit()
            print("✓ Usuario admin por defecto creado.")
    except Exception as e:
        db.session.rollback()
        print(f"ℹ Usuario admin ya existe o error: {e}")

# Inicializar AuthManager con BD
auth_manager = AuthManager(db=db)


# Helper: check if session user is admin
def is_admin_user():
    username = session.get('admin_user')
    if not username:
        return False
    try:
        user = Usuario.query.filter_by(username=username).first()
        return bool(user and user.es_admin)
    except Exception:
        return False


def is_root_user():
    """Return True only if logged-in user is 'root' (exact match)."""
    username = session.get('admin_user')
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
        username = session.get('admin_user') if 'admin_user' in session else None

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

    # --- Cierre de sesión automático a las 19:00 (7pm) ---
    hora_limite = 19  # 7pm
    ahora = datetime.now().hour
    # Si el usuario está logueado y es después de la hora límite, cerrar sesión
    if 'admin_user' in session and ahora >= hora_limite:
        session.clear()
        return redirect(url_for('login', mensaje='La sesión ha sido cerrada automáticamente por horario de seguridad (después de las 19:00).'))

# ==================== DECORADOR DE AUTENTICACIÓN ====================

def login_required(f):
    """Decorador para proteger rutas que requieren autenticación"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'admin_user' not in session:
            # Si la ruta es una API, devolver JSON 401 en lugar de redirigir
            if request.path.startswith('/api/') or request.headers.get('Accept', '').find('application/json') != -1:
                return jsonify({'error': 'Autenticación requerida'}), 401
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# ==================== RUTAS DE AUTENTICACIÓN ====================

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Página de login para el admin"""
    mensaje = request.args.get('mensaje')
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        # Rate-limit by IP
        client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
        entry = FAILED_LOGINS.get(client_ip, [0, 0, 0])
        attempt_count, first_ts, locked_until = entry
        now = time()

        # Clear window if older than lockout window
        if first_ts and now - first_ts > LOCKOUT_SECONDS:
            attempt_count, first_ts, locked_until = 0, 0, 0

        if locked_until and now < locked_until:
            remaining = int(locked_until - now)
            return render_template('login.html', error=f'Too many attempts. Try again in {remaining} seconds.', mensaje=mensaje), 429
        
        # Verificar credenciales dentro del contexto de BD
        credentials_valid = False
        try:
            # Intentar verificar en BD
            try:
                usuario = Usuario.query.filter_by(username=username, activo=True).first()
                if usuario and usuario.check_password(password):
                    credentials_valid = True
            except Exception as bd_error:
                print(f"[BD ERROR] Fallo al consultar Usuario: {bd_error}")
                # Si falla BD, intentar fallback
                if username == 'admin' and password == 'admin123':
                    credentials_valid = True
        except Exception as e:
            print(f"[LOGIN ERROR] Error general: {e}")
            return render_template('login.html', error='Error interno del servidor. Contacte al administrador.', mensaje=mensaje), 500
        
        if credentials_valid:
            # success: reset counter for this IP
            if client_ip in FAILED_LOGINS:
                FAILED_LOGINS.pop(client_ip, None)
            session['admin_user'] = username
            return redirect(url_for('admin'))
        else:
            # failure: increment
            attempt_count += 1
            if not first_ts:
                first_ts = now
            # Lock if exceeded
            if attempt_count >= MAX_LOGIN_ATTEMPTS:
                locked_until = now + LOCKOUT_SECONDS
                FAILED_LOGINS[client_ip] = [attempt_count, first_ts, locked_until]
                return render_template('login.html', error='Demasiados intentos. Intenta nuevamente más tarde.', mensaje=mensaje), 429
            else:
                FAILED_LOGINS[client_ip] = [attempt_count, first_ts, 0]
                return render_template('login.html', error='Credenciales inválidas', mensaje=mensaje), 401
    
    return render_template('login.html', mensaje=mensaje)

@app.route('/logout')
def logout():
    """Cerrar sesión"""
    session.pop('admin_user', None)
    return redirect(url_for('index'))

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

@app.route('/admin')
@login_required
def admin():
    """Panel de administración"""
    return render_template('admin.html')

@app.route('/proveedores')
@login_required
def proveedores():
    """Página de gestión de proveedores"""
    return render_template('proveedores.html')


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
    if not is_root_user():
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

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Recurso no encontrado'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Error interno del servidor'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
