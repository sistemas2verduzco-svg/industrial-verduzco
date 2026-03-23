from flask import Flask, render_template, request, jsonify, session, redirect, url_for, send_file, send_from_directory, make_response, flash
from models import db, Producto, Proveedor, ProductoProveedor, HistorialPreciosProveedor, Usuario, Ticket, ComentarioTicket, Role, Permission, QCReport, QCItem, QCProduccionRegistro, Máquina, ComponenteMáquina, HojaRuta, HojaRutaCargaPiezasHistorial, HojaRutaFlujoLogistica, EntregaRegistro, AlmacenRegistro, FacturacionRegistro, EstacionTrabajo, EstacionPlantilla, ProcesoCatalogo, ClaveProducto, ClaveProceso, EntregaParcial
from auth import AuthManager
from email_manager import EmailManager
import os
import json
from dotenv import load_dotenv
from sqlalchemy import text, func
from functools import wraps
import secrets
from werkzeug.utils import secure_filename
from datetime import datetime, timedelta
from time import time
import logging
from openpyxl import Workbook
from io import BytesIO
import uuid
import math
import re
import subprocess
import sys
import threading

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

# Jobs para importación asíncrona de procesos/claves.
# Persistimos estado en disco para evitar problemas con múltiples workers de gunicorn.
PROCESOS_IMPORT_LOCK = threading.Lock()
PROCESOS_IMPORT_DIR = os.path.join('uploads', 'imports_jobs')
os.makedirs(PROCESOS_IMPORT_DIR, exist_ok=True)


def _procesos_import_job_path(job_id):
    safe = re.sub(r'[^a-zA-Z0-9_-]', '', str(job_id or ''))
    return os.path.join(PROCESOS_IMPORT_DIR, f'{safe}.json')


def _get_procesos_import_job(job_id):
    path = _procesos_import_job_path(job_id)
    if not os.path.exists(path):
        return None
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception:
        return None


def _set_procesos_import_job(job_id, **fields):
    with PROCESOS_IMPORT_LOCK:
        job = _get_procesos_import_job(job_id) or {}
        job.update(fields)
        path = _procesos_import_job_path(job_id)
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(job, f, ensure_ascii=False)


def _run_procesos_import_job(job_id, filename, abs_saved_path, sheet):
    _set_procesos_import_job(job_id, status='running', started_at=datetime.utcnow().isoformat())
    try:
        cmd = [sys.executable, 'tools/import_procesos.py', '--file', abs_saved_path, '--overwrite']
        if sheet:
            cmd.extend(['--sheet', sheet])

        result = subprocess.run(
            cmd,
            cwd=os.getcwd(),
            capture_output=True,
            text=True,
            timeout=900,
        )
        combined = '\n'.join([x for x in [result.stdout, result.stderr] if x]).strip()

        if result.returncode != 0:
            logger.error(f"[IMPORT_PROCESOS] Error importando {filename}: {combined}")
            _set_procesos_import_job(
                job_id,
                status='error',
                error='Falló la importación de procesos',
                output=combined[-6000:] if combined else '',
                finished_at=datetime.utcnow().isoformat(),
            )
            return

        logger.info(f"[IMPORT_PROCESOS] Importación OK para archivo {filename}")
        _set_procesos_import_job(
            job_id,
            status='success',
            output=combined[-6000:] if combined else 'Importación ejecutada sin salida.',
            finished_at=datetime.utcnow().isoformat(),
        )
    except subprocess.TimeoutExpired:
        logger.error(f"[IMPORT_PROCESOS] Timeout importando {filename}")
        _set_procesos_import_job(
            job_id,
            status='error',
            error='La importación excedió el tiempo límite (900s)',
            finished_at=datetime.utcnow().isoformat(),
        )
    except Exception as e:
        logger.error(f"[IMPORT_PROCESOS] Excepción importando {filename}: {e}")
        _set_procesos_import_job(
            job_id,
            status='error',
            error=f'Error procesando importación: {str(e)}',
            finished_at=datetime.utcnow().isoformat(),
        )
    finally:
        try:
            if os.path.exists(abs_saved_path):
                os.remove(abs_saved_path)
        except Exception:
            pass

# Jornada laboral para planeacion de hojas de ruta
WORKDAY_BLOCKS = ((6, 30, 12, 0), (12, 30, 16, 0))
WORKDAY_SECONDS = (5 * 3600 + 30 * 60) + (3 * 3600 + 30 * 60)  # 9h


def _is_workday(dt_or_date):
    if hasattr(dt_or_date, 'weekday'):
        return dt_or_date.weekday() < 5  # Monday=0 ... Sunday=6
    return False


def _norm_text(value):
    text = str(value or '').upper().strip()
    return (text.replace('Á', 'A')
                .replace('É', 'E')
                .replace('Í', 'I')
                .replace('Ó', 'O')
                .replace('Ú', 'U'))


def _clean_nullable_text(value):
    text = str(value or '').strip()
    if text.lower() in ('none', 'null', 'nan', 'nat', '-'):
        return ''
    return text


def _qc_strip_scrap_summary(text):
    src = str(text or '')
    cleaned = re.sub(
        r'\n?\[QC_SCRAP_SUMMARY_START\].*?\[QC_SCRAP_SUMMARY_END\]\n?',
        '\n',
        src,
        flags=re.S,
    )
    return cleaned.strip()


def _qc_parse_scrap_summary(text):
    src = str(text or '')
    m = re.search(r'\[QC_SCRAP_SUMMARY_START\](.*?)\[QC_SCRAP_SUMMARY_END\]', src, flags=re.S)
    if not m:
        return None

    block = m.group(1)
    values = {}
    for line in block.splitlines():
        line = line.strip()
        if not line or '=' not in line:
            continue
        k, v = line.split('=', 1)
        values[k.strip().upper()] = v.strip()

    def _to_int(key, default=0):
        try:
            return max(0, int(values.get(key, default)))
        except Exception:
            return default

    return {
        'lote_inicial': _to_int('LOTE_INICIAL', 0),
        'total_scrap': _to_int('TOTAL_SCRAP', 0),
        'lote_final': _to_int('LOTE_FINAL', 0),
        'detalle': values.get('DETALLE', ''),
        'actualizado_por': values.get('ACTUALIZADO_POR', ''),
        'fecha': values.get('FECHA', ''),
    }


def _qc_extract_scrap_block(text):
    src = str(text or '')
    m = re.search(r'\[QC_SCRAP_SUMMARY_START\].*?\[QC_SCRAP_SUMMARY_END\]', src, flags=re.S)
    return m.group(0).strip() if m else ''


def _qc_parse_review_block(notas_text):
    notas = str(notas_text or '')
    status_match = re.search(r'STATUS=(QC_OK|QC_NOK)', notas)
    status = status_match.group(1) if status_match else None

    block_match = re.search(r'\[QC_REVIEW_START\](.*?)\[QC_REVIEW_END\]', notas, flags=re.S)
    block = block_match.group(1) if block_match else ''

    def _extract(field, default=''):
        m = re.search(rf'^{field}=(.*)$', block, flags=re.M)
        return m.group(1).strip() if m else default

    def _extract_int(field, default=0):
        try:
            return max(0, int(_extract(field, str(default))))
        except Exception:
            return default

    return {
        'status': status,
        'usuario': _extract('USUARIO', ''),
        'fecha': _extract('FECHA', ''),
        'dimensional': _extract('DIMENSIONAL', 'NO') == 'OK',
        'visual': _extract('VISUAL', 'NO') == 'OK',
        'rebaba': _extract('REBABA', 'NO') == 'OK',
        'material': _extract('MATERIAL', 'NO') == 'OK',
        'ajuste': _extract('AJUSTE', 'NO') == 'OK',
        'limpieza': _extract('LIMPIEZA', 'NO') == 'OK',
        'scrap_piezas': _extract_int('SCRAP_PIEZAS', 0),
        'observaciones': _extract('OBSERVACIONES', ''),
    }


def _parse_time_to_seconds(value):
    if value is None:
        return 0
    raw = str(value).strip()
    if not raw:
        return 0

    try:
        parts = [int(p) for p in raw.split(':')]
    except Exception:
        return 0

    if len(parts) == 3:
        h, m, s = parts
        return max(0, h * 3600 + m * 60 + s)
    if len(parts) == 2:
        m, s = parts
        return max(0, m * 60 + s)
    if len(parts) == 1:
        return max(0, parts[0])
    return 0


def _format_seconds_to_hms(total_seconds):
    sec = max(0, int(total_seconds or 0))
    h = sec // 3600
    m = (sec % 3600) // 60
    s = sec % 60
    return f"{h:02d}:{m:02d}:{s:02d}"


def _station_seconds(est):
    for field in ('t_e', 't_tct', 't_tco', 't_to'):
        sec = _parse_time_to_seconds(getattr(est, field, None))
        if sec > 0:
            return sec
    return 0


def _stations_for_machine_type(estaciones, maquina_tipo):
    if not maquina_tipo:
        return estaciones

    tipo = _norm_text(maquina_tipo)
    filtered = []
    for est in estaciones:
        haystack = ' '.join([
            _norm_text(getattr(est, 'centro_trabajo', '')),
            _norm_text(getattr(est, 'nombre', '')),
            _norm_text(getattr(est, 'operacion', '')),
        ])
        if tipo and tipo in haystack:
            filtered.append(est)
    return filtered or estaciones


def _align_to_work_slot(dt):
    base = dt if isinstance(dt, datetime) else datetime.utcnow()

    # Skip weekends: always move to next Monday start block.
    while not _is_workday(base):
        base = (base + timedelta(days=1)).replace(hour=WORKDAY_BLOCKS[0][0], minute=WORKDAY_BLOCKS[0][1], second=0, microsecond=0)

    b1s = base.replace(hour=WORKDAY_BLOCKS[0][0], minute=WORKDAY_BLOCKS[0][1], second=0, microsecond=0)
    b1e = base.replace(hour=WORKDAY_BLOCKS[0][2], minute=WORKDAY_BLOCKS[0][3], second=0, microsecond=0)
    b2s = base.replace(hour=WORKDAY_BLOCKS[1][0], minute=WORKDAY_BLOCKS[1][1], second=0, microsecond=0)
    b2e = base.replace(hour=WORKDAY_BLOCKS[1][2], minute=WORKDAY_BLOCKS[1][3], second=0, microsecond=0)

    if base < b1s:
        return b1s
    if b1s <= base < b1e:
        return base
    if b1e <= base < b2s:
        return b2s
    if b2s <= base < b2e:
        return base
    next_day = base + timedelta(days=1)
    return next_day.replace(hour=WORKDAY_BLOCKS[0][0], minute=WORKDAY_BLOCKS[0][1], second=0, microsecond=0)


def _add_work_seconds(start_dt, seconds):
    remaining = max(0, int(seconds or 0))
    current = _align_to_work_slot(start_dt)

    if remaining == 0:
        return current

    while remaining > 0:
        b1s = current.replace(hour=WORKDAY_BLOCKS[0][0], minute=WORKDAY_BLOCKS[0][1], second=0, microsecond=0)
        b1e = current.replace(hour=WORKDAY_BLOCKS[0][2], minute=WORKDAY_BLOCKS[0][3], second=0, microsecond=0)
        b2s = current.replace(hour=WORKDAY_BLOCKS[1][0], minute=WORKDAY_BLOCKS[1][1], second=0, microsecond=0)
        b2e = current.replace(hour=WORKDAY_BLOCKS[1][2], minute=WORKDAY_BLOCKS[1][3], second=0, microsecond=0)

        if b1s <= current < b1e:
            block_end = b1e
        elif b2s <= current < b2e:
            block_end = b2e
        else:
            current = _align_to_work_slot(current)
            continue

        available = max(0, int((block_end - current).total_seconds()))
        if remaining <= available:
            return current + timedelta(seconds=remaining)

        remaining -= available
        current = _align_to_work_slot(block_end + timedelta(seconds=1))

    return current


def _working_seconds_between(start_dt, end_dt):
    if not isinstance(start_dt, datetime) or not isinstance(end_dt, datetime):
        return 0
    if end_dt <= start_dt:
        return 0

    total = 0
    day = start_dt.date()
    end_day = end_dt.date()

    while day <= end_day:
        if not _is_workday(day):
            day += timedelta(days=1)
            continue

        for h1, m1, h2, m2 in WORKDAY_BLOCKS:
            block_start = datetime.combine(day, datetime.min.time()).replace(hour=h1, minute=m1)
            block_end = datetime.combine(day, datetime.min.time()).replace(hour=h2, minute=m2)

            overlap_start = max(block_start, start_dt)
            overlap_end = min(block_end, end_dt)
            if overlap_end > overlap_start:
                total += int((overlap_end - overlap_start).total_seconds())

        day += timedelta(days=1)

    return max(0, total)


def _bounded_working_seconds(start_dt, end_dt, window_start, window_end):
    if not all(isinstance(x, datetime) for x in (start_dt, end_dt, window_start, window_end)):
        return 0

    overlap_start = max(start_dt, window_start)
    overlap_end = min(end_dt, window_end)
    if overlap_end <= overlap_start:
        return 0

    return _working_seconds_between(overlap_start, overlap_end)


def _apply_hoja_time_plan(hoja, estaciones, maquina_tipo=None, fallback_total_time=None):
    cantidad = max(1, int(hoja.cantidad_piezas or 0))
    estaciones_base = _stations_for_machine_type(estaciones, maquina_tipo)

    per_piece_seconds = sum(_station_seconds(e) for e in estaciones_base)

    # Si no hubo tiempos por proceso, usar último T/O o fallback provisto
    if per_piece_seconds <= 0:
        for est in sorted(estaciones_base, key=lambda x: getattr(x, 'orden', 0), reverse=True):
            sec = _parse_time_to_seconds(getattr(est, 't_to', None))
            if sec > 0:
                per_piece_seconds = sec
                break

    total_seconds = per_piece_seconds * cantidad
    if total_seconds <= 0 and fallback_total_time:
        total_seconds = _parse_time_to_seconds(fallback_total_time)

    if total_seconds <= 0:
        hoja.total_tiempo = None
        hoja.dias_a_laborar = None
        hoja.fecha_termino = None
        return

    hoja.total_tiempo = _format_seconds_to_hms(total_seconds)
    hoja.dias_a_laborar = round(total_seconds / WORKDAY_SECONDS, 2)

    inicio = hoja.fecha_salida or datetime.utcnow()
    hoja.fecha_termino = _add_work_seconds(inicio, total_seconds)


def _resolve_clave_descripcion_by_pn(pn_value):
    """Resolve a human-readable description for a PN.
    Priority: clave.notas -> clave.nombre -> process description/notes/operation -> key code.
    """
    pn = (pn_value or '').strip()
    if not pn:
        return ''

    normalized = pn.upper()
    clave = ClaveProducto.query.filter(func.upper(func.trim(ClaveProducto.clave)) == normalized).first()
    if not clave:
        # Fallback: at least show the key code for legacy hojas.
        return pn

    notas = _clean_nullable_text(getattr(clave, 'notas', None))
    if notas:
        return notas

    nombre_clave = _clean_nullable_text(getattr(clave, 'nombre', None))
    if nombre_clave:
        return nombre_clave

    procesos = ClaveProceso.query.filter_by(clave_id=clave.id).order_by(ClaveProceso.orden.asc()).all()
    for cp in procesos:
        candidates = [
            (cp.proceso.descripcion if getattr(cp, 'proceso', None) else '') or '',
            getattr(cp, 'notas', None) or '',
            getattr(cp, 'operacion', None) or '',
            (cp.proceso.operacion if getattr(cp, 'proceso', None) else '') or '',
            (cp.proceso.nombre if getattr(cp, 'proceso', None) else '') or '',
        ]
        for c in candidates:
            text = _clean_nullable_text(c)
            if text:
                return text

    # Final fallback for legacy data without notes/description.
    return _clean_nullable_text(getattr(clave, 'clave', None)) or pn


def _sync_hoja_estado_with_checks(hoja, estaciones=None, now_dt=None):
    """Sincroniza el estado de hoja contra sus checks de procesos.
    Regla: completada solo si todas las estaciones estan completadas.
    """
    if estaciones is None:
        estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).all()

    total = len(estaciones)
    completadas = sum(1 for e in estaciones if (e.estado or '').lower() == 'completada')

    if total > 0 and completadas == total:
        new_estado = 'completada'
        new_fecha_termino = hoja.fecha_termino or (now_dt or datetime.utcnow())
    else:
        new_estado = 'activa'
        new_fecha_termino = None

    changed = (hoja.estado != new_estado) or (hoja.fecha_termino != new_fecha_termino)
    hoja.estado = new_estado
    hoja.fecha_termino = new_fecha_termino
    return changed


_HOJA_CARGAS_TABLE_READY = False


def _ensure_hoja_cargas_historial_table():
    global _HOJA_CARGAS_TABLE_READY

    if _HOJA_CARGAS_TABLE_READY:
        return True

    try:
        HojaRutaCargaPiezasHistorial.__table__.create(bind=db.engine, checkfirst=True)
        _HOJA_CARGAS_TABLE_READY = True
        return True
    except Exception as exc:
        logger.warning(f"No se pudo asegurar la tabla de historial de cargas de hojas: {exc}")
        try:
            db.session.rollback()
        except Exception:
            pass
        return False


def _current_username_for_audit(user=None):
    username = getattr(user, 'username', None) if user else None
    if username:
        return username
    return (session.get('user') or 'sistema').strip() or 'sistema'


def _serialize_hoja_carga_historial(item):
    return {
        'id': item.id,
        'cantidad_anterior': item.cantidad_anterior,
        'cantidad_cambio': item.cantidad_cambio,
        'cantidad_nueva': item.cantidad_nueva,
        'tipo_movimiento': item.tipo_movimiento,
        'usuario': item.usuario,
        'fecha_creacion': item.fecha_creacion.isoformat() if item.fecha_creacion else None,
    }


def _registrar_carga_piezas_hoja(hoja, cantidad_anterior, cantidad_nueva, usuario, origen='ajuste'):
    cantidad_anterior = int(cantidad_anterior or 0)
    cantidad_nueva = int(cantidad_nueva or 0)

    if cantidad_nueva == cantidad_anterior:
        return None
    if not _ensure_hoja_cargas_historial_table():
        return None

    delta = cantidad_nueva - cantidad_anterior
    if origen == 'creacion':
        tipo_movimiento = 'inicial'
    elif delta > 0:
        tipo_movimiento = 'incremento'
    elif delta < 0:
        tipo_movimiento = 'decremento'
    else:
        tipo_movimiento = 'ajuste'

    movimiento = HojaRutaCargaPiezasHistorial(
        hoja_ruta_id=hoja.id,
        cantidad_anterior=cantidad_anterior,
        cantidad_cambio=delta,
        cantidad_nueva=cantidad_nueva,
        tipo_movimiento=tipo_movimiento,
        usuario=usuario,
    )
    db.session.add(movimiento)
    return movimiento

# Simple in-memory login rate limiter
# Keys: by IP address. Tracks [attempt_count, first_attempt_ts, locked_until_ts]
FAILED_LOGINS = {}
# Configurable via env
MAX_LOGIN_ATTEMPTS = int(os.getenv('MAX_LOGIN_ATTEMPTS', '5'))
LOCKOUT_SECONDS = int(os.getenv('LOCKOUT_SECONDS', '300'))  # default 5 minutes

# API key for plant sync
SYNC_API_KEY = os.getenv('SYNC_API_KEY', '').strip()

load_dotenv()

app = Flask(__name__)

# Permite reflejar cambios de templates sin reinicio manual (util para despliegues por git pull).
templates_auto_reload = os.getenv('TEMPLATES_AUTO_RELOAD', '0').strip().lower() in ('1', 'true', 'yes', 'on')
app.config['TEMPLATES_AUTO_RELOAD'] = templates_auto_reload
app.jinja_env.auto_reload = templates_auto_reload

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


def _require_sync_key():
    if not SYNC_API_KEY:
        return False, (jsonify({'error': 'SYNC_API_KEY no configurado'}), 500)
    provided = request.headers.get('X-API-KEY', '')
    if not provided or not secrets.compare_digest(provided, SYNC_API_KEY):
        return False, (jsonify({'error': 'No autorizado'}), 401)
    return True, None


def _parse_date(value):
    if not value:
        return None
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace('Z', '+00:00')).date()
        except ValueError:
            for fmt in ('%Y-%m-%d', '%Y-%m-%d %H:%M:%S'):
                try:
                    return datetime.strptime(value, fmt).date()
                except ValueError:
                    continue
    return None


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
            
            endpoint = _resolve_post_login_endpoint(usuario)
            if endpoint:
                logger.info(f"[LOGIN] Redirigiendo usuario '{username}' a /{endpoint}")
                return redirect(url_for(endpoint))

            logger.warning(f"[LOGIN] Usuario '{username}' autenticado sin módulos asignados; redirigiendo a /dashboard")
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


def _resolve_post_login_endpoint(user):
    """Choose landing page based on effective module permissions."""
    if not user:
        return None
    if user.es_admin:
        return 'admin'

    if user.has_permission('catalog', 'view'):
        return 'index'
    if user.has_permission('estaciones', 'view'):
        return 'hojas_ruta_list'
    if user.has_permission('mapa', 'view'):
        return 'mapa_maquinas'
    if user.has_permission('hojas', 'view'):
        return 'hojas_ruta_form'
    if user.has_permission('calidad', 'view'):
        return 'control_calidad_list'
    if user.has_permission('entregas', 'view'):
        return 'entregas_module'
    if user.has_permission('almacen', 'view'):
        return 'almacen_module'
    if user.has_permission('facturacion', 'view'):
        return 'facturacion_module'
    if user.has_permission('tickets', 'view'):
        return 'soporte_tecnico'
    if user.has_permission('proveedores', 'view') or user.has_permission('proveedores', 'edit'):
        return 'proveedores'

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


def requires_any_permission(permission_pairs):
    """Allow access if user has at least one permission pair from the list."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            user = get_current_user()
            if not user:
                if request.path.startswith('/api/'):
                    return jsonify({'error': 'Autenticación requerida'}), 401
                return redirect(url_for('login'))

            if not any(user.has_permission(module, action) for module, action in (permission_pairs or [])):
                if request.path.startswith('/api/'):
                    return jsonify({'error': 'Permiso denegado'}), 403
                return render_template('403.html'), 403
            return f(*args, **kwargs)
        return decorated
    return decorator


# Module bundles for admin role-management UI.
ROLE_MODULE_BUNDLES = {
    'catalog': [('catalog', 'view')],
    'admin_catalog': [('catalog', 'view'), ('catalog', 'edit')],
    'hojas_readonly': [('catalog', 'view'), ('hojas', 'view')],
    'hojas_generacion': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'create')],
    'hojas_edicion_basica': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'edit_basico')],
    'hojas_edicion_firmas': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'edit_firmas')],
    'hojas_edicion_planeacion': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'edit_planeacion')],
    'hojas_edicion_estado': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'edit_estado')],
    'hojas_edicion': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'edit')],
    'hojas_eliminar': [('catalog', 'view'), ('hojas', 'view'), ('hojas', 'delete')],
    'estaciones_view': [('catalog', 'view'), ('estaciones', 'view')],
    'estaciones_operate': [('catalog', 'view'), ('estaciones', 'view'), ('estaciones', 'operate')],
    'mapa_view': [('catalog', 'view'), ('mapa', 'view')],
    'calidad_view': [('catalog', 'view'), ('calidad', 'view')],
    'calidad_edit': [('catalog', 'view'), ('calidad', 'view'), ('calidad', 'edit')],
    'entregas_view': [('catalog', 'view'), ('entregas', 'view')],
    'entregas_edit': [('catalog', 'view'), ('entregas', 'view'), ('entregas', 'edit')],
    'almacen_view': [('catalog', 'view'), ('almacen', 'view')],
    'almacen_edit': [('catalog', 'view'), ('almacen', 'view'), ('almacen', 'edit')],
    'facturacion_view': [('catalog', 'view'), ('facturacion', 'view')],
    'facturacion_edit': [('catalog', 'view'), ('facturacion', 'view'), ('facturacion', 'edit')],
    'procesos_view': [('catalog', 'view'), ('procesos', 'view')],
    'proveedores_view': [('catalog', 'view'), ('proveedores', 'view')],
    'proveedores_edit': [('catalog', 'view'), ('proveedores', 'view'), ('proveedores', 'edit')],
    'soporte': [('tickets', 'view')],
    'soporte_edit': [('tickets', 'view'), ('tickets', 'edit'), ('tickets', 'export')],
    # Perfil sugerido: puede operar calidad/estaciones y solo leer hojas de ruta.
    'supervisor_produccion': [
        ('catalog', 'view'),
        ('hojas', 'view'),
        ('estaciones', 'view'),
        ('estaciones', 'operate'),
        ('calidad', 'view'),
        ('calidad', 'edit'),
    ],
}


DEFAULT_PERMISSION_CATALOG = [
    ('catalog', 'view', 'Ver catalogo'),
    ('catalog', 'edit', 'Editar catalogo'),
    ('hojas', 'view', 'Ver hojas de ruta'),
    ('hojas', 'create', 'Crear hojas de ruta'),
    ('hojas', 'edit', 'Editar hojas de ruta (total)'),
    ('hojas', 'delete', 'Eliminar hojas de ruta'),
    ('hojas', 'edit_basico', 'Editar hoja: serie/comentarios'),
    ('hojas', 'edit_firmas', 'Editar hoja: firmas'),
    ('hojas', 'edit_planeacion', 'Editar hoja: planeacion'),
    ('hojas', 'edit_estado', 'Editar hoja: estado'),
    ('hojas', 'edit_field_nombre', 'Editar campo hoja: nombre'),
    ('hojas', 'edit_field_descripcion', 'Editar campo hoja: descripcion'),
    ('hojas', 'edit_field_comentarios', 'Editar campo hoja: comentarios'),
    ('hojas', 'edit_field_firma_ing_jose', 'Editar campo hoja: firma ing jose'),
    ('hojas', 'edit_field_firma_ing_rodrigo', 'Editar campo hoja: firma ing rodrigo'),
    ('hojas', 'edit_field_calidad', 'Editar campo hoja: calidad'),
    ('hojas', 'edit_field_almacen', 'Editar campo hoja: almacen'),
    ('hojas', 'edit_field_orden_trabajo', 'Editar campo hoja: orden de trabajo'),
    ('hojas', 'edit_field_cantidad_piezas', 'Editar campo hoja: cantidad de piezas'),
    ('hojas', 'edit_field_estado', 'Editar campo hoja: estado'),
    ('estaciones', 'view', 'Ver estaciones T'),
    ('estaciones', 'operate', 'Operar estaciones/maquinas'),
    ('mapa', 'view', 'Ver mapa de maquinas'),
    ('calidad', 'view', 'Ver control de calidad'),
    ('calidad', 'edit', 'Registrar/editar revision de calidad'),
    ('entregas', 'view', 'Ver módulo de entregas'),
    ('entregas', 'edit', 'Operar módulo de entregas'),
    ('almacen', 'view', 'Ver módulo de almacén'),
    ('almacen', 'edit', 'Operar módulo de almacén'),
    ('facturacion', 'view', 'Ver módulo de facturación'),
    ('facturacion', 'edit', 'Operar módulo de facturación'),
    ('procesos', 'view', 'Ver procesos y claves'),
    ('proveedores', 'view', 'Ver proveedores'),
    ('proveedores', 'edit', 'Editar proveedores'),
    ('tickets', 'view', 'Ver tickets'),
    ('tickets', 'edit', 'Editar tickets'),
    ('tickets', 'export', 'Exportar tickets'),
]


HOJA_FIELD_GROUP_ACTIONS = {
    'estado': 'edit_estado',
    'nombre': 'edit_basico',
    'descripcion': 'edit_basico',
    'comentarios': 'edit_basico',
    'firma_ing_jose': 'edit_firmas',
    'firma_ing_rodrigo': 'edit_firmas',
    'calidad': 'edit_planeacion',
    'almacen': 'edit_planeacion',
    'orden_trabajo': 'edit_planeacion',
    'cantidad_piezas': 'edit_planeacion',
}


HOJA_FIELD_SPECIFIC_ACTIONS = {
    'estado': 'edit_field_estado',
    'nombre': 'edit_field_nombre',
    'descripcion': 'edit_field_descripcion',
    'comentarios': 'edit_field_comentarios',
    'firma_ing_jose': 'edit_field_firma_ing_jose',
    'firma_ing_rodrigo': 'edit_field_firma_ing_rodrigo',
    'calidad': 'edit_field_calidad',
    'almacen': 'edit_field_almacen',
    'orden_trabajo': 'edit_field_orden_trabajo',
    'cantidad_piezas': 'edit_field_cantidad_piezas',
}


def _role_modules_from_permissions(role):
    perm_set = {(p.module, p.action) for p in (role.permissions or [])}
    modules = []
    for module_id, required_perms in ROLE_MODULE_BUNDLES.items():
        if all(rp in perm_set for rp in required_perms):
            modules.append(module_id)
    return modules


def _apply_role_modules(role, modules):
    selected = set(modules or [])
    required = set()
    for module_id in selected:
        for perm_pair in ROLE_MODULE_BUNDLES.get(module_id, []):
            required.add(perm_pair)

    # Preserve unrelated permissions and ensure required ones are present.
    existing = {(p.module, p.action): p for p in (role.permissions or [])}
    current_perms = list(role.permissions or [])

    for module, action in required:
        if (module, action) in existing:
            continue
        perm = Permission.query.filter_by(module=module, action=action).first()
        if not perm:
            perm = Permission(module=module, action=action, descripcion=f'{module}:{action}')
            db.session.add(perm)
            db.session.flush()
        current_perms.append(perm)

    # Remove permissions managed by bundles if not currently selected.
    bundle_pairs = {pair for pairs in ROLE_MODULE_BUNDLES.values() for pair in pairs}
    filtered = []
    for p in current_perms:
        pair = (p.module, p.action)
        if pair in bundle_pairs and pair not in required:
            continue
        filtered.append(p)

    role.permissions = filtered


def _get_or_create_permission(module, action):
    perm = Permission.query.filter_by(module=module, action=action).first()
    if perm:
        return perm
    perm = Permission(module=module, action=action, descripcion=f'{module}:{action}')
    db.session.add(perm)
    db.session.flush()
    return perm


def _ensure_default_permissions():
    """Create baseline permissions so admin UI can assign fine-grained access."""
    created_any = False
    for module, action, descripcion in DEFAULT_PERMISSION_CATALOG:
        perm = Permission.query.filter_by(module=module, action=action).first()
        if perm:
            continue
        db.session.add(Permission(module=module, action=action, descripcion=descripcion))
        created_any = True
    if created_any:
        db.session.commit()


def _check_field_level_permissions(user, module, payload, field_actions, broad_action='edit'):
    """Return denied fields list for payload updates in a module."""
    denied = []
    for field, required_actions in (field_actions or {}).items():
        if field not in (payload or {}):
            continue
        if user.has_permission(module, broad_action):
            continue
        actions_list = required_actions if isinstance(required_actions, (list, tuple, set)) else [required_actions]
        if any(user.has_permission(module, action) for action in actions_list):
            continue
        denied.append(field)
    return denied


def _hoja_ready_for_signatures(hoja):
    """Validate that hoja is fully completed and quality-approved for non-admin signatures."""
    estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).all()
    if not estaciones:
        return False, 'La hoja no tiene procesos para validar.'

    for est in estaciones:
        if (est.estado or '').lower() != 'completada':
            return False, 'Todos los procesos deben estar completados antes de autorizar firmas.'

    for est in estaciones:
        notas = est.notas or ''
        m = re.search(r'STATUS=(QC_OK|QC_NOK)', notas)
        if not m:
            return False, 'Falta liberar procesos en calidad (QC) antes de autorizar firmas.'
        if m.group(1) != 'QC_OK':
            return False, 'Existen procesos con rechazo en calidad. No se puede autorizar la hoja.'

    return True, None


def _permissions_from_modules_and_ids(modules, permission_ids):
    """Resolve final permission set from module bundles and explicit permission IDs."""
    final_pairs = set()

    for module_id in (modules or []):
        for module, action in ROLE_MODULE_BUNDLES.get(module_id, []):
            final_pairs.add((module, action))

    if permission_ids:
        explicit_perms = Permission.query.filter(Permission.id.in_(permission_ids)).all()
        for p in explicit_perms:
            final_pairs.add((p.module, p.action))

    resolved = []
    seen = set()
    for module, action in sorted(final_pairs):
        perm = _get_or_create_permission(module, action)
        pair = (perm.module, perm.action)
        if pair in seen:
            continue
        seen.add(pair)
        resolved.append(perm)
    return resolved

# ==================== DASHBOARD / HOME CENTRAL ====================

@app.route('/dashboard')
@login_required
def dashboard():
    """Dashboard central - cada usuario ve su panel según permisos."""
    user = get_current_user()
    if not user:
        return redirect(url_for('login'))

    endpoint = _resolve_post_login_endpoint(user)
    if endpoint and endpoint != 'dashboard':
        return redirect(url_for(endpoint))

    has_any_module = bool(user and user.role and user.role.permissions)
    return render_template('dashboard.html', user=user, has_any_module=has_any_module)

# ==================== RUTAS FRONTEND ====================

@app.route('/')
@login_required
@requires_permission('catalog', 'view')
def index():
    """Página principal - Catálogo (privado)"""
    return render_template('index.html')


@app.route('/producto/<int:producto_id>')
@login_required
def producto_detalle(producto_id):
    producto = Producto.query.get_or_404(producto_id)
    # Traer proveedores y precios relacionados
    proveedores = []
    def _pp_date_key(pp):
        return pp.fecha_precio or datetime.min.date()
    proveedores_ordenados = sorted(producto.proveedores, key=_pp_date_key, reverse=True)
    for pp in proveedores_ordenados:
        prov = pp.proveedor.to_dict() if pp.proveedor else None
        historial = [h.to_dict() for h in pp.historial_precios]
        proveedores.append({
            'asignacion_id': pp.id,
            'proveedor': prov,
            'precio_proveedor': pp.precio_proveedor,
            'fecha_precio': pp.fecha_precio.isoformat() if pp.fecha_precio else None,
            'cantidad_minima': pp.cantidad_minima,
            'divisa': pp.divisa,
            'historial_precios': historial
        })
    ultima_compra = proveedores[0] if proveedores else None
    return render_template('producto_detalle.html', producto=producto, proveedores=proveedores, ultima_compra=ultima_compra)


@app.route('/control_calidad')
@login_required
@requires_any_permission([('calidad', 'view'), ('catalog', 'view')])
def control_calidad_list():
    """Lista de hojas de ruta con procesos completados pendientes de validación en calidad."""

    def qc_status(estacion):
        notas = estacion.notas or ''
        m = re.search(r'STATUS=(QC_OK|QC_NOK)', notas)
        return m.group(1) if m else None

    hojas = HojaRuta.query.order_by(HojaRuta.fecha_creacion.desc()).all()
    hojas_qc = []
    for hoja in hojas:
        estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden.asc()).all()
        completadas = [e for e in estaciones if (e.estado or '').lower() == 'completada']
        if not completadas:
            continue

        reviewed = 0
        rechazadas = 0
        for e in completadas:
            status = qc_status(e)
            if status in ('QC_OK', 'QC_NOK'):
                reviewed += 1
            if status == 'QC_NOK':
                rechazadas += 1

        pendientes = max(0, len(completadas) - reviewed)
        finalizada_qc = len(completadas) > 0 and pendientes == 0
        certificado_disponible = finalizada_qc
        hojas_qc.append({
            'id': hoja.id,
            'serie': hoja.nombre,
            'clave': hoja.pn,
            'calidad': hoja.calidad,
            'piezas': hoja.cantidad_piezas,
            'estado': hoja.estado,
            'procesos_completados': len(completadas),
            'procesos_revisados': reviewed,
            'procesos_pendientes_qc': pendientes,
            'procesos_rechazados_qc': rechazadas,
            'finalizada_qc': finalizada_qc,
            'certificado_disponible': certificado_disponible,
            'fecha': hoja.fecha_creacion,
        })

    # Prioridad: hojas con pendientes QC arriba.
    hojas_qc = sorted(
        hojas_qc,
        key=lambda h: (0 if h['procesos_pendientes_qc'] > 0 else 1, -(h['procesos_pendientes_qc']), h['fecha'] or datetime.min),
        reverse=False,
    )

    return render_template('control_calidad_list.html', hojas_qc=hojas_qc)


@app.route('/control_calidad/hoja/<int:hoja_id>', methods=['GET', 'POST'])
@login_required
@requires_any_permission([('calidad', 'view'), ('catalog', 'view')])
def control_calidad_hoja(hoja_id):
    """Revisión de calidad por hoja de ruta y por proceso completado."""
    hoja = HojaRuta.query.get_or_404(hoja_id)
    user = get_current_user()

    def qc_status(estacion):
        notas = estacion.notas or ''
        m = re.search(r'STATUS=(QC_OK|QC_NOK)', notas)
        return m.group(1) if m else None

    def qc_clean_block(notas_text):
        src = notas_text or ''
        # Reemplaza bloque QC previo para evitar crecimiento infinito de notas.
        return re.sub(r'\n?\[QC_REVIEW_START\].*?\[QC_REVIEW_END\]\n?', '\n', src, flags=re.S).strip()

    def qc_parse_review(estacion):
        notas_text = estacion.notas or ''
        status = qc_status(estacion)
        block_match = re.search(r'\[QC_REVIEW_START\](.*?)\[QC_REVIEW_END\]', notas_text, flags=re.S)
        block = block_match.group(1) if block_match else ''

        def _extract(field, default=''):
            m = re.search(rf'^{field}=(.*)$', block, flags=re.M)
            return m.group(1).strip() if m else default

        scrap_raw = _extract('SCRAP_PIEZAS', '0')
        try:
            scrap_piezas = int(scrap_raw)
        except Exception:
            scrap_piezas = 0
        if scrap_piezas < 0:
            scrap_piezas = 0

        return {
            'status': status,
            'scrap_piezas': scrap_piezas,
            'observaciones': _extract('OBSERVACIONES', ''),
        }

    def qc_extract_lote_inicial(comentarios_text):
        src = comentarios_text or ''
        m = re.search(r'^LOTE_INICIAL=(\d+)$', src, flags=re.M)
        if not m:
            return None
        try:
            return max(0, int(m.group(1)))
        except Exception:
            return None

    informe_guardado = False
    error_guardado = None

    def _is_checked(field_name):
        value = request.form.get(field_name)
        if value is None:
            return False
        return str(value).strip().lower() in ('1', 'true', 'on', 'yes', 'si', 'ok')

    if request.method == 'POST':
        if not (user and (user.has_permission('calidad', 'edit') or user.has_permission('catalog', 'edit'))):
            error_guardado = 'Permiso denegado para editar control de calidad'
        else:
            estacion_id = request.form.get('estacion_id', type=int)
            resultado = (request.form.get('resultado') or '').strip().lower()
            observaciones = (request.form.get('observaciones') or '').strip()
            scrap_piezas = request.form.get('scrap_piezas', type=int)
            if scrap_piezas is None:
                scrap_piezas = 0

            estacion = EstacionTrabajo.query.filter_by(id=estacion_id, hoja_ruta_id=hoja.id).first()
            if not estacion:
                error_guardado = 'Proceso no encontrado para esta hoja'
            elif (estacion.estado or '').lower() != 'completada':
                error_guardado = 'Solo se pueden validar procesos completados'
            elif resultado not in ('aprobado', 'rechazado'):
                error_guardado = 'Selecciona un resultado válido (Aprobado/Rechazado)'
            elif scrap_piezas < 0:
                error_guardado = 'Scrap inválido: no puede ser negativo'
            else:
                # Checklist estándar para refacciones (sinfines, engranes, etc.)
                check_dimensional = _is_checked('chk_dimensional')
                check_visual = _is_checked('chk_visual')
                check_rebaba = _is_checked('chk_rebaba')
                check_material = _is_checked('chk_material')
                check_ajuste = _is_checked('chk_ajuste')
                check_limpieza = _is_checked('chk_limpieza')

                status_tag = 'QC_OK' if resultado == 'aprobado' else 'QC_NOK'
                usuario_qc = session.get('user') or 'sistema'
                ahora = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

                bloque = (
                    "[QC_REVIEW_START]\n"
                    f"STATUS={status_tag}\n"
                    f"USUARIO={usuario_qc}\n"
                    f"FECHA={ahora}\n"
                    f"DIMENSIONAL={'OK' if check_dimensional else 'NO'}\n"
                    f"VISUAL={'OK' if check_visual else 'NO'}\n"
                    f"REBABA={'OK' if check_rebaba else 'NO'}\n"
                    f"MATERIAL={'OK' if check_material else 'NO'}\n"
                    f"AJUSTE={'OK' if check_ajuste else 'NO'}\n"
                    f"LIMPIEZA={'OK' if check_limpieza else 'NO'}\n"
                    f"SCRAP_PIEZAS={scrap_piezas}\n"
                    f"OBSERVACIONES={observaciones}\n"
                    "[QC_REVIEW_END]"
                )

                base_notas = qc_clean_block(estacion.notas)
                estacion.notas = (base_notas + "\n" + bloque).strip() if base_notas else bloque
                estacion.firma_supervisor = status_tag
                estacion.operador = usuario_qc

                # Estado de hoja por consolidación QC de procesos completados
                completadas = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id, estado='completada').all()
                reviews = [qc_parse_review(e) for e in completadas]
                statuses = [r['status'] for r in reviews]
                pendientes = any(s not in ('QC_OK', 'QC_NOK') for s in statuses)
                hay_rechazo = any(s == 'QC_NOK' for s in statuses)

                # Lote base fijo para evitar descuentos acumulados por re-ediciones.
                lote_inicial = qc_extract_lote_inicial(hoja.materia_prima)
                if lote_inicial is None:
                    try:
                        lote_inicial = max(0, int(hoja.cantidad_piezas or 0))
                    except Exception:
                        lote_inicial = 0

                if pendientes:
                    hoja.aprobada = False
                    hoja.rechazada = False
                else:
                    hoja.aprobada = not hay_rechazo
                    hoja.rechazada = hay_rechazo

                if hoja.aprobada and not hoja.rechazada:
                    total_scrap = sum(max(0, int(r['scrap_piezas'] or 0)) for r in reviews)
                    if lote_inicial > 0:
                        total_scrap = min(total_scrap, lote_inicial)
                    cantidad_final = max(lote_inicial - total_scrap, 0)
                    hoja.cantidad_piezas = cantidad_final
                    hoja.scrap = str(total_scrap)

                    detalles = []
                    for est, rev in zip(completadas, reviews):
                        scrap_est = max(0, int(rev['scrap_piezas'] or 0))
                        if scrap_est <= 0:
                            continue
                        etiqueta = (est.centro_trabajo or est.operacion or f'Estacion {est.orden}').strip()
                        detalles.append(f"P{est.orden} - {etiqueta}: {scrap_est}")

                    detalles_txt = '; '.join(detalles) if detalles else 'Sin scrap por proceso.'
                    fecha_resumen = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
                    bloque_scrap = (
                        "[QC_SCRAP_SUMMARY_START]\n"
                        f"LOTE_INICIAL={lote_inicial}\n"
                        f"TOTAL_SCRAP={total_scrap}\n"
                        f"LOTE_FINAL={cantidad_final}\n"
                        f"DETALLE={detalles_txt}\n"
                        f"ACTUALIZADO_POR={usuario_qc}\n"
                        f"FECHA={fecha_resumen}\n"
                        "[QC_SCRAP_SUMMARY_END]"
                    )

                    base_comentarios = _qc_strip_scrap_summary(hoja.materia_prima)
                    hoja.materia_prima = (
                        (base_comentarios + "\n\n" + bloque_scrap).strip()
                        if base_comentarios else bloque_scrap
                    )
                else:
                    # Si aun no queda aprobada, quitar resumen previo para evitar inconsistencias visuales.
                    base_comentarios = _qc_strip_scrap_summary(hoja.materia_prima)
                    if base_comentarios != (hoja.materia_prima or '').strip():
                        hoja.materia_prima = base_comentarios or None
                    if lote_inicial > 0:
                        hoja.cantidad_piezas = lote_inicial
                    hoja.scrap = None

                try:
                    db.session.commit()
                    informe_guardado = True
                except Exception:
                    db.session.rollback()
                    logger.exception('[QC] Error guardando revision de calidad')
                    error_guardado = 'Ocurrio un error al guardar la revision. Intenta de nuevo.'

    estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden.asc()).all()
    procesos_completados = []
    lote_referencia = qc_extract_lote_inicial(hoja.materia_prima)
    if lote_referencia is None:
        try:
            lote_referencia = max(0, int(hoja.cantidad_piezas or 0))
        except Exception:
            lote_referencia = 0

    for e in estaciones:
        if (e.estado or '').lower() != 'completada':
            continue
        review = qc_parse_review(e)
        procesos_completados.append({
            'id': e.id,
            'orden': e.orden,
            'centro_trabajo': e.centro_trabajo,
            'operacion': e.operacion,
            'status_qc': review['status'],
            'scrap_piezas': review['scrap_piezas'],
            'notas': e.notas,
            'fecha_finalizacion': e.fecha_finalizacion,
        })

    pendientes_qc = sum(1 for p in procesos_completados if p['status_qc'] not in ('QC_OK', 'QC_NOK'))
    qc_finalizada = len(procesos_completados) > 0 and pendientes_qc == 0
    certificado_disponible = qc_finalizada

    return render_template(
        'control_calidad_detalle.html',
        hoja=hoja,
        procesos=procesos_completados,
        lote_referencia=lote_referencia,
        pendientes_qc=pendientes_qc,
        qc_finalizada=qc_finalizada,
        certificado_disponible=certificado_disponible,
        informe_guardado=informe_guardado,
        error_guardado=error_guardado,
    )


@app.route('/control_calidad/hoja/<int:hoja_id>/certificado')
@login_required
@requires_any_permission([('calidad', 'view'), ('catalog', 'view')])
def control_calidad_certificado(hoja_id):
    """Certificado imprimible de control de calidad por hoja de ruta."""
    hoja = HojaRuta.query.get_or_404(hoja_id)
    estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden.asc()).all()
    completadas = [e for e in estaciones if (e.estado or '').lower() == 'completada']
    reviews = [_qc_parse_review_block(e.notas) for e in completadas]

    qc_finalizada = bool(completadas) and all(r.get('status') in ('QC_OK', 'QC_NOK') for r in reviews)
    if not qc_finalizada:
        return redirect(url_for('control_calidad_hoja', hoja_id=hoja.id))

    checklist_fields = ('dimensional', 'visual', 'rebaba', 'material', 'ajuste', 'limpieza')
    checklist_global = {
        f: bool(reviews) and all(bool(r.get(f)) for r in reviews)
        for f in checklist_fields
    }

    defectos = []
    for est, rev in zip(completadas, reviews):
        status = rev.get('status')
        scrap_piezas = int(rev.get('scrap_piezas') or 0)
        observaciones = (rev.get('observaciones') or '').strip()

        detalle_partes = []
        if observaciones:
            detalle_partes.append(observaciones)
        if scrap_piezas > 0:
            detalle_partes.append(f"Scrap en proceso: {scrap_piezas}")

        if status == 'QC_NOK' or scrap_piezas > 0 or observaciones:
            defecto_detalle = ' | '.join(detalle_partes) if detalle_partes else 'No conforme detectado en inspeccion.'
            etiqueta_proceso = (est.centro_trabajo or est.operacion or f'Proceso {est.orden}').strip()
            defectos.append({
                'proceso': f"P{est.orden} - {etiqueta_proceso}",
                'resultado': 'RECHAZADO' if status == 'QC_NOK' else 'APROBADO',
                'detalle': defecto_detalle,
            })

    comentarios_usuario = _qc_strip_scrap_summary(hoja.materia_prima)
    scrap_qc = _qc_parse_scrap_summary(hoja.materia_prima)

    fecha_qc = ''
    qc_user = ''
    if reviews:
        ult = reviews[-1]
        fecha_qc = ult.get('fecha') or ''
        qc_user = ult.get('usuario') or ''

    fecha_emision = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    qc_aprobada = all(r.get('status') == 'QC_OK' for r in reviews)

    return render_template(
        'control_calidad_certificado.html',
        hoja=hoja,
        fecha_emision=fecha_emision,
        fecha_qc=fecha_qc,
        qc_user=qc_user,
        checklist_global=checklist_global,
        defectos=defectos,
        comentarios_usuario=comentarios_usuario,
        scrap_qc=scrap_qc,
        qc_aprobada=qc_aprobada,
    )


@app.route('/control_calidad/<int:maquina_id>')
@login_required
@requires_any_permission([('calidad', 'view'), ('catalog', 'view')])
def control_calidad_legacy_maquina(maquina_id):
    """Compatibilidad con links antiguos de Control Calidad por maquina."""
    return redirect(url_for('control_calidad_list'))


# ==================== FLUJO TEMPORAL: ENTREGAS -> ALMACEN -> ENTREGAS(LISTA) -> FACTURACION ====================

LOGISTICA_IMG_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}


def _logistica_username():
    return (session.get('user') or 'sistema').strip()


def _logistica_allowed_image(filename):
    if not filename or '.' not in filename:
        return False
    ext = filename.rsplit('.', 1)[-1].lower().strip()
    return ext in LOGISTICA_IMG_EXTENSIONS


def _sync_flujo_parciales(flujo: HojaRutaFlujoLogistica, hoja: HojaRuta = None):
    """Sincroniza totales/pendientes/porcentaje para entregas parciales."""
    if not flujo:
        return

    hoja_ref = hoja or flujo.hoja_ruta
    total = int(flujo.cantidad_total_piezas or 0)
    if total <= 0 and hoja_ref and hoja_ref.cantidad_piezas:
        total = int(hoja_ref.cantidad_piezas or 0)
    if total < 0:
        total = 0

    entregado = int(flujo.cantidad_entregada or 0)
    if entregado < 0:
        entregado = 0
    if total > 0 and entregado > total:
        entregado = total

    flujo.cantidad_total_piezas = total
    flujo.cantidad_entregada = entregado
    flujo.cantidad_pendiente = max(total - entregado, 0)
    flujo.porcentaje_entregado = round((entregado / total) * 100, 2) if total > 0 else 0.0
    flujo.estado_parciales = 'todas' if total > 0 and entregado == total else 'pendientes'


@app.route('/entregas')
@login_required
@requires_any_permission([('entregas', 'view'), ('catalog', 'edit')])
def entregas_module():
    hojas = HojaRuta.query.order_by(HojaRuta.fecha_creacion.desc()).all()
    pendientes_entregas = (
        HojaRutaFlujoLogistica.query
        .filter_by(estado='entregas')
        .order_by(HojaRutaFlujoLogistica.fecha_actualizacion.desc())
        .all()
    )
    listas_facturacion = (
        HojaRutaFlujoLogistica.query
        .filter_by(estado='entregas_lista_facturacion')
        .order_by(HojaRutaFlujoLogistica.fecha_actualizacion.desc())
        .all()
    )
    historial_entregas = (
        EntregaRegistro.query
        .order_by(EntregaRegistro.fecha_creacion.desc())
        .limit(80)
        .all()
    )
    return render_template(
        'entregas_module.html',
        hojas=hojas,
        pendientes_entregas=pendientes_entregas,
        listas_facturacion=listas_facturacion,
        historial_entregas=historial_entregas,
    )


@app.route('/api/logistica/entregas/agregar', methods=['POST'])
@login_required
@requires_any_permission([('entregas', 'edit'), ('catalog', 'edit')])
def api_logistica_entregas_agregar():
    data = request.get_json() or {}
    hoja_id = data.get('hoja_id')
    try:
        hoja_id = int(hoja_id)
    except Exception:
        return jsonify({'error': 'hoja_id inválido'}), 400

    hoja = HojaRuta.query.get(hoja_id)
    if not hoja:
        return jsonify({'error': 'Hoja de ruta no encontrada'}), 404

    item = HojaRutaFlujoLogistica.query.filter_by(hoja_ruta_id=hoja_id).first()
    if item:
        if item.estado in ('entregas', 'entregas_lista_facturacion'):
            return jsonify({'ok': True, 'message': 'La hoja ya está en la bandeja de Entregas.'})
        if item.estado in ('almacen', 'facturacion'):
            return jsonify({'error': f'La hoja ya fue transferida a {item.estado}.'}), 409
        if item.estado == 'finalizada':
            return jsonify({'error': 'La hoja ya fue finalizada en Facturación.'}), 409

    item = HojaRutaFlujoLogistica(
        hoja_ruta_id=hoja.id,
        estado='entregas',
        creado_por=_logistica_username(),
        actualizado_por=_logistica_username(),
    )
    db.session.add(item)
    db.session.flush()
    db.session.add(EntregaRegistro(
        hoja_ruta_id=hoja.id,
        flujo_id=item.id,
        accion='agregada_en_entregas',
        usuario=_logistica_username(),
    ))
    db.session.commit()
    return jsonify({'ok': True, 'item': item.to_dict()})


@app.route('/entregas/mover_almacen/<int:item_id>', methods=['POST'])
@login_required
@requires_any_permission([('entregas', 'edit'), ('catalog', 'edit')])
def entregas_mover_almacen(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado != 'entregas':
        return redirect(url_for('entregas_module'))

    hoja = item.hoja_ruta
    _sync_flujo_parciales(item, hoja=hoja)

    if (item.cantidad_total_piezas or 0) <= 0:
        flash('La hoja no tiene cantidad total de piezas válida para envío.', 'error')
        return redirect(url_for('entregas_module'))

    if item.cantidad_entregada != item.cantidad_total_piezas:
        flash(f'No todas las piezas han sido entregadas. Entregado: {item.cantidad_entregada}/{item.cantidad_total_piezas}', 'error')
        return redirect(url_for('entregas_module'))

    item.estado = 'almacen'
    item.estado_parciales = 'todas'
    item.actualizado_por = _logistica_username()
    db.session.add(EntregaRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        accion='enviada_a_almacen',
        notas=f'Entregas parciales completadas: {item.cantidad_entregada} de {item.cantidad_total_piezas} piezas (100%)',
        usuario=_logistica_username(),
    ))
    db.session.commit()
    return redirect(url_for('entregas_module'))


@app.route('/entregas/mover_facturacion/<int:item_id>', methods=['POST'])
@login_required
@requires_any_permission([('entregas', 'edit'), ('catalog', 'edit')])

def entregas_mover_facturacion(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado != 'entregas_lista_facturacion':
        return redirect(url_for('entregas_module'))

    _sync_flujo_parciales(item, hoja=item.hoja_ruta)
    if item.cantidad_entregada != item.cantidad_total_piezas:
        return redirect(url_for('entregas_module'))

    item.estado = 'facturacion'
    item.actualizado_por = _logistica_username()
    db.session.add(EntregaRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        accion='enviada_a_facturacion',
        usuario=_logistica_username(),
    ))
    db.session.commit()
    return redirect(url_for('entregas_module'))



@app.route('/entregas/quitar/<int:item_id>', methods=['POST'])
@login_required
@requires_any_permission([('entregas', 'edit'), ('catalog', 'edit')])
def entregas_quitar_item(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado == 'entregas':
        db.session.delete(item)
        db.session.commit()
    return redirect(url_for('entregas_module'))

            _sync_flujo_parciales(flujo, hoja=hoja)
            if (flujo.cantidad_total_piezas or 0) <= 0:
                return jsonify({'error': 'La hoja no tiene cantidad total de piezas válida'}), 409
    
            cantidad_pendiente = int(flujo.cantidad_pendiente or 0)
            if cantidad_entregada > cantidad_pendiente:
                return jsonify({
                    'error': f'No puedes entregar {cantidad_entregada} piezas. Pendiente: {cantidad_pendiente}',
                    'cantidad_pendiente': cantidad_pendiente,
                }), 400
    
            entrega = EntregaParcial(
                flujo_id=flujo.id,
                hoja_ruta_id=hoja.id,
                cantidad_entregada=cantidad_entregada,
                usuario_entrega=_logistica_username(),
                notas=notas,
            )
            db.session.add(entrega)
    
            flujo.cantidad_entregada += cantidad_entregada
            _sync_flujo_parciales(flujo, hoja=hoja)
            flujo.actualizado_por = _logistica_username()
    
            db.session.add(EntregaRegistro(
                hoja_ruta_id=hoja.id,
                flujo_id=flujo.id,
                accion='entrega_parcial_registrada',
                usuario=_logistica_username(),
                notas=f'Entregadas {cantidad_entregada} piezas. Pendiente: {flujo.cantidad_pendiente} ({flujo.porcentaje_entregado:.1f}%)',
            ))
    
            db.session.commit()
    
            return jsonify({
                'ok': True,
                'entrega': entrega.to_dict(),
                'flujo': flujo.to_dict(),
            }), 201


        @app.route('/api/entregas/<int:hoja_id>/parciales', methods=['GET'])
        @login_required
        @requires_any_permission([('entregas', 'view'), ('entregas', 'edit'), ('catalog', 'edit')])
        def api_obtener_entregas_parciales(hoja_id):
            """Obtiene todas las entregas parciales de una hoja de ruta."""
            hoja = HojaRuta.query.get(hoja_id)
            if not hoja:
                return jsonify({'error': 'Hoja de ruta no encontrada'}), 404
    
            entregas = EntregaParcial.query.filter_by(hoja_ruta_id=hoja_id).order_by(EntregaParcial.fecha_entrega.desc()).all()
    
            return jsonify({
                'ok': True,
                'hoja_id': hoja_id,
                'entregas': [e.to_dict() for e in entregas],
                'total_registros': len(entregas),
            }), 200


        @app.route('/api/entregas/parcial/<int:parcial_id>', methods=['DELETE'])
        @login_required
        @requires_any_permission([('entregas', 'edit'), ('catalog', 'edit')])
        def api_eliminar_entrega_parcial(parcial_id):
            """Elimina una entrega parcial (deshace la entrega)."""
            entrega = EntregaParcial.query.get(parcial_id)
            if not entrega:
                return jsonify({'error': 'Entrega parcial no encontrada'}), 404
    
            flujo = entrega.flujo_logistica
            hoja = entrega.hoja_ruta

            if not flujo or flujo.estado != 'entregas':
                return jsonify({'error': 'Solo puedes deshacer entregas parciales cuando la hoja está en Entregas'}), 409

            _sync_flujo_parciales(flujo, hoja=hoja)
            if entrega.cantidad_entregada > (flujo.cantidad_entregada or 0):
                return jsonify({'error': 'La entrega parcial no se puede deshacer por inconsistencia de cantidades'}), 409

            flujo.cantidad_entregada -= entrega.cantidad_entregada
            _sync_flujo_parciales(flujo, hoja=hoja)
            flujo.actualizado_por = _logistica_username()
    
            db.session.add(EntregaRegistro(
                hoja_ruta_id=hoja.id,
                flujo_id=flujo.id,
                accion='entrega_parcial_eliminada',
                usuario=_logistica_username(),
                notas=f'Se eliminó entrega de {entrega.cantidad_entregada} piezas. Nueva situación - Entregado: {flujo.cantidad_entregada}, Pendiente: {flujo.cantidad_pendiente}',
            ))
    
            db.session.delete(entrega)
            db.session.commit()
    
            return jsonify({
                'ok': True,
                'message': 'Entrega parcial eliminada',
                'flujo': flujo.to_dict(),
            }), 200
        db.session.commit()
    return redirect(url_for('entregas_module'))


@app.route('/almacen')
@login_required
@requires_any_permission([('almacen', 'view'), ('catalog', 'edit')])
def almacen_module():
    pendientes_almacen = (
        HojaRutaFlujoLogistica.query
        .filter_by(estado='almacen')
        .order_by(HojaRutaFlujoLogistica.fecha_actualizacion.desc())
                return redirect(url_for('entregas_module'))
        .all()
@requires_any_permission([('almacen', 'edit'), ('catalog', 'edit')])
            _sync_flujo_parciales(item, hoja=item.hoja_ruta)
            if item.cantidad_entregada != item.cantidad_total_piezas:
                return redirect(url_for('entregas_module'))
def almacen_recibir_item(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado != 'almacen':
        return redirect(url_for('almacen_module'))

    recepcion_id = (request.form.get('recepcion_id') or '').strip()
    entregado = request.form.get('entregado') == 'on'
    captura = request.files.get('captura_recepcion')

    if not entregado or not recepcion_id:
        return redirect(url_for('almacen_module'))

    if not captura or not captura.filename:
        return redirect(url_for('almacen_module'))

    if not _logistica_allowed_image(captura.filename):
        return redirect(url_for('almacen_module'))

    ext = captura.filename.rsplit('.', 1)[-1].lower().strip()
    nombre = secure_filename(f"recepcion_{item.hoja_ruta_id}_{uuid.uuid4().hex}.{ext}")
    rel_dir = os.path.join('logistica_recepciones')
    abs_dir = os.path.join(app.config['UPLOAD_FOLDER'], rel_dir)
    os.makedirs(abs_dir, exist_ok=True)
    abs_path = os.path.join(abs_dir, nombre)
    captura.save(abs_path)

    item.almacen_validado = True
    item.almacen_recepcion_id = recepcion_id
    item.almacen_captura_path = f"{rel_dir}/{nombre}".replace('\\', '/')
    # Almacén solo recepciona/libera y devuelve a Entregas como lista para enviar a Facturación.
    item.estado = 'entregas_lista_facturacion'
    item.actualizado_por = _logistica_username()

    db.session.add(AlmacenRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        recepcion_id=recepcion_id,
        captura_path=item.almacen_captura_path,
        validado=True,
        usuario=_logistica_username(),
        notas='Recepción validada en almacén y liberada para Entregas.',
    ))
    db.session.add(EntregaRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        accion='lista_para_facturacion',
        usuario=_logistica_username(),
        notas=f'Recepción {recepcion_id} validada en almacén.',
    ))

    db.session.commit()
    return redirect(url_for('almacen_module'))


@app.route('/almacen/regresar_entregas/<int:item_id>', methods=['POST'])
@login_required
@requires_any_permission([('almacen', 'edit'), ('catalog', 'edit')])
def almacen_regresar_entregas(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado != 'almacen':
        return redirect(url_for('almacen_module'))

    motivo = (request.form.get('motivo_regreso') or '').strip()
    if not motivo:
        motivo = 'Datos incompletos o recepción no válida en almacén.'

    item.estado = 'entregas'
    item.actualizado_por = _logistica_username()

    db.session.add(AlmacenRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        recepcion_id=item.almacen_recepcion_id,
        captura_path=item.almacen_captura_path,
        validado=False,
        usuario=_logistica_username(),
        notas=f'Devuelta a Entregas: {motivo}',
    ))
    db.session.add(EntregaRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        accion='devuelta_desde_almacen',
        usuario=_logistica_username(),
        notas=motivo,
    ))

    db.session.commit()
    return redirect(url_for('almacen_module'))


@app.route('/facturacion')
@login_required
@requires_any_permission([('facturacion', 'view'), ('catalog', 'edit')])
def facturacion_module():
    pendientes_facturacion = (
        HojaRutaFlujoLogistica.query
        .filter_by(estado='facturacion')
        .order_by(HojaRutaFlujoLogistica.fecha_actualizacion.desc())
        .all()
    )
    finalizadas = (
        HojaRutaFlujoLogistica.query
        .filter_by(estado='finalizada')
        .order_by(HojaRutaFlujoLogistica.fecha_actualizacion.desc())
        .limit(50)
        .all()
    )
    historial_facturacion = (
        FacturacionRegistro.query
        .order_by(FacturacionRegistro.fecha_creacion.desc())
        .limit(80)
        .all()
    )
    return render_template(
        'facturacion_module.html',
        pendientes_facturacion=pendientes_facturacion,
        finalizadas=finalizadas,
        historial_facturacion=historial_facturacion,
    )


@app.route('/facturacion/aprobar/<int:item_id>', methods=['POST'])
@login_required
@requires_any_permission([('facturacion', 'edit'), ('catalog', 'edit')])
def facturacion_aprobar_item(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado != 'facturacion':
        return redirect(url_for('facturacion_module'))

    aprobado = request.form.get('aprobado_facturacion') == 'on'
    if not aprobado:
        return redirect(url_for('facturacion_module'))

    item.facturacion_aprobado = True
    item.facturacion_aprobado_por = _logistica_username()
    item.facturacion_aprobado_en = datetime.utcnow()
    item.estado = 'finalizada'
    item.actualizado_por = _logistica_username()

    db.session.add(FacturacionRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        aprobado=True,
        usuario=_logistica_username(),
        fecha_aprobacion=item.facturacion_aprobado_en,
        notas='Hoja liberada por facturación.',
    ))
    db.session.commit()
    return redirect(url_for('facturacion_module'))


@app.route('/facturacion/regresar_entregas/<int:item_id>', methods=['POST'])
@login_required
@requires_any_permission([('facturacion', 'edit'), ('catalog', 'edit')])
def facturacion_regresar_entregas(item_id):
    item = HojaRutaFlujoLogistica.query.get_or_404(item_id)
    if item.estado != 'facturacion':
        return redirect(url_for('facturacion_module'))

    motivo = (request.form.get('motivo_regreso') or '').strip()
    if not motivo:
        motivo = 'Documentación o recepción no corresponde para facturación.'

    item.estado = 'entregas'
    item.actualizado_por = _logistica_username()

    db.session.add(FacturacionRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        aprobado=False,
        usuario=_logistica_username(),
        notas=f'Devuelta a Entregas: {motivo}',
        fecha_aprobacion=None,
    ))
    db.session.add(EntregaRegistro(
        hoja_ruta_id=item.hoja_ruta_id,
        flujo_id=item.id,
        accion='devuelta_desde_facturacion',
        usuario=_logistica_username(),
        notas=motivo,
    ))

    db.session.commit()
    return redirect(url_for('facturacion_module'))


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
@requires_any_permission([('estaciones', 'view'), ('catalog', 'view')])
def hojas_ruta_list():
    """Lista de máquinas con sus hojas de ruta activas y estado de producción."""
    maquinas = Máquina.query.all()
    hojas_activas = HojaRuta.query.filter(
        HojaRuta.maquina_id.isnot(None),
        HojaRuta.estado.in_(['activa', 'pausada'])
    ).order_by(HojaRuta.fecha_creacion.desc()).all()
    # Preferir 'activa' sobre 'pausada'; en caso de duplicados por maquina, quedarse con la primera encontrada.
    hoja_activa_por_maquina: dict = {}
    for h in hojas_activas:
        existing = hoja_activa_por_maquina.get(h.maquina_id)
        if existing is None:
            hoja_activa_por_maquina[h.maquina_id] = h
        elif existing.estado != 'activa' and h.estado == 'activa':
            hoja_activa_por_maquina[h.maquina_id] = h

    # Regla operativa: sincronizar activo con la presencia de hoja activa asignada.
    estado_maquina_changed = False
    for maq in maquinas:
        tiene_hoja = maq.id in hoja_activa_por_maquina
        activo_actual = bool(getattr(maq, 'activo', False))
        if tiene_hoja and not activo_actual:
            maq.activo = True
            estado_maquina_changed = True
        elif not tiene_hoja and activo_actual:
            maq.activo = False
            estado_maquina_changed = True

    if estado_maquina_changed:
        try:
            db.session.commit()
        except Exception:
            db.session.rollback()

    # Orden operativo por tipo y consecutivo (#01, #02, ...)
    tipo_priority = {
        'CNC': 1,
        'TORNO': 2,
        'FRESADORA': 3,
        'TALADRO': 4,
        'CEPILLO': 5,
        'ESCOPLO': 6,
    }

    def maquina_sort_key(m):
        tipo = (getattr(m, 'tipo', None) or '').strip().upper()
        nombre = (getattr(m, 'nombre', None) or '').strip().upper()

        match_num = re.search(r'#\s*(\d+)', nombre)
        numero = int(match_num.group(1)) if match_num else 9999

        base = re.sub(r'#\s*\d+', '', nombre).strip()
        tipo_ref = tipo or base
        prioridad = tipo_priority.get(tipo_ref, 99)

        return (prioridad, tipo_ref, numero, nombre)

    maquinas = sorted(maquinas, key=maquina_sort_key)
    
    # Hojas pendientes de asignar: solo las que aún tienen trabajo por hacer.
    # 'completada' se excluye intencionalmente: si todos los procesos terminaron
    # la hoja no necesita asignarse a ninguna máquina.
    hojas_pendientes = HojaRuta.query.filter(
        HojaRuta.maquina_id.is_(None),
        HojaRuta.estado.in_(['activa', 'pausada'])
    ).order_by(HojaRuta.fecha_creacion.asc()).all()

    # Obtener hoja activa para cada máquina
    maquinas_data = []
    for maq in maquinas:
        hoja_activa = hoja_activa_por_maquina.get(maq.id)
        estacion_actual = None
        tiempo_real = None
        if hoja_activa:
            estacion_actual = EstacionTrabajo.query.filter_by(
                hoja_ruta_id=hoja_activa.id, 
                estado='en_curso'
            ).order_by(EstacionTrabajo.orden).first()
            if hoja_activa.fecha_salida:
                elapsed = _working_seconds_between(hoja_activa.fecha_salida, datetime.utcnow())
                tiempo_real = _format_seconds_to_hms(elapsed)
        
        maquinas_data.append({
            'id': maq.id,
            'nombre': maq.nombre,
            'descripcion': maq.descripcion,
            'imagen_url': maq.imagen_url,
            'hoja_activa': hoja_activa.to_dict() if hoja_activa else None,
            'activo': getattr(maq, 'activo', False),
            'estacion_actual': estacion_actual.nombre if estacion_actual else 'Sin producción',
            'tiempo_real': tiempo_real,
            'tipo': getattr(maq, 'tipo', None),
            'plantilla_default': getattr(maq, 'plantilla_default', None)
        })

    pendientes_data = []
    pending_state_changed = False
    for h in hojas_pendientes:
        estaciones_h = EstacionTrabajo.query.filter_by(hoja_ruta_id=h.id).order_by(EstacionTrabajo.orden.asc()).all()
        if _sync_hoja_estado_with_checks(h, estaciones=estaciones_h):
            pending_state_changed = True
        pendientes_data.append({
            'id': h.id,
            'serie': h.nombre,
            'clave': h.pn,
            'estado': h.estado,
            'cantidad_piezas': h.cantidad_piezas,
            'tiempo_total': h.total_tiempo,
            'fecha_creacion': h.fecha_creacion.isoformat() if h.fecha_creacion else None,
            'estaciones': [
                {
                    'id': e.id,
                    'orden': e.orden,
                    'operacion': e.operacion,
                    'estado': e.estado,
                }
                for e in estaciones_h
            ],
        })

    if pending_state_changed:
        try:
            db.session.commit()
        except Exception:
            db.session.rollback()

    # Hojas liberadas por Facturación (estado='finalizada' en flujo logístico)
    facturadas_flujos = HojaRutaFlujoLogistica.query.filter_by(estado='finalizada').all()
    facturadas_info = {
        f.hoja_ruta_id: {
            'aprobado_por': f.facturacion_aprobado_por or '',
            'aprobado_en': f.facturacion_aprobado_en.strftime('%d/%m/%Y %H:%M') if f.facturacion_aprobado_en else ''
        }
        for f in facturadas_flujos
    }

    resp = make_response(render_template(
        'hojas_ruta_list.html',
        maquinas=maquinas_data,
        hojas_pendientes=pendientes_data,
        facturadas_info=facturadas_info
    ))
    # Evita que navegador/proxy muestren HTML viejo tras deploy.
    resp.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    resp.headers['Pragma'] = 'no-cache'
    resp.headers['Expires'] = '0'
    return resp


@app.route('/mapa_maquinas')
@login_required
@requires_any_permission([('mapa', 'view'), ('catalog', 'view')])
def mapa_maquinas():
    """Vista de mapa de maquinas con estado en tiempo real."""
    return render_template('mapa_maquinas.html')


@app.route('/api/mapa_maquinas')
@login_required
@requires_any_permission([('mapa', 'view'), ('catalog', 'view')])
def api_mapa_maquinas():
    """Datos para el mapa de maquinas (estado, hoja activa, pieza, tiempo)."""
    todas_maquinas = Máquina.query.order_by(Máquina.nombre.asc()).all()
    hojas_activas = HojaRuta.query.filter(
        HojaRuta.maquina_id.isnot(None),
        HojaRuta.estado.in_(['activa', 'pausada'])
    ).order_by(HojaRuta.fecha_creacion.desc()).all()
    hoja_activa_por_maquina: dict = {}
    for h in hojas_activas:
        existing = hoja_activa_por_maquina.get(h.maquina_id)
        if existing is None:
            hoja_activa_por_maquina[h.maquina_id] = h
        elif existing.estado != 'activa' and h.estado == 'activa':
            hoja_activa_por_maquina[h.maquina_id] = h

    # Regla operativa: sin hoja activa asignada => maquina desactivada por default.
    estado_maquina_changed = False
    for maq in todas_maquinas:
        if maq.id not in hoja_activa_por_maquina and bool(getattr(maq, 'activo', False)):
            maq.activo = False
            estado_maquina_changed = True

    if estado_maquina_changed:
        try:
            db.session.commit()
        except Exception:
            db.session.rollback()

    maquinas = [m for m in todas_maquinas if bool(getattr(m, 'activo', False))]
    data = []
    now_dt = datetime.utcnow()

    window_hour_start = now_dt - timedelta(hours=1)
    window_day_start = now_dt.replace(hour=0, minute=0, second=0, microsecond=0)
    window_week_start = (window_day_start - timedelta(days=window_day_start.weekday())).replace(hour=0, minute=0, second=0, microsecond=0)

    productive_hour = 0
    productive_day = 0
    productive_week = 0

    def _bounded_seconds(start_dt, end_dt, window_start, window_end):
        if not start_dt or not end_dt:
            return 0
        bounded_start = max(start_dt, window_start)
        bounded_end = min(end_dt, window_end)
        if bounded_end <= bounded_start:
            return 0
        return int((bounded_end - bounded_start).total_seconds())

    for idx, maq in enumerate(maquinas):
        hoja_activa = hoja_activa_por_maquina.get(maq.id)
        estacion_actual = None
        tiempo_objetivo = None
        tiempo_transcurrido = None
        tiempo_restante = None
        proceso_culminado = False
        progreso_pct = 0
        tiempo_proceso_pieza = None
        if hoja_activa:
            estacion_actual = EstacionTrabajo.query.filter_by(
                hoja_ruta_id=hoja_activa.id,
                estado='en_curso'
            ).order_by(EstacionTrabajo.orden).first()

            if estacion_actual:
                cantidad = max(1, int(hoja_activa.cantidad_piezas or 0))
                sec_por_pieza = _station_seconds(estacion_actual)
                objetivo_sec = max(0, sec_por_pieza * cantidad)

                inicio = estacion_actual.fecha_inicio or hoja_activa.fecha_salida
                transcurrido_sec = _working_seconds_between(inicio, datetime.utcnow()) if inicio else 0
                restante_sec = max(0, objetivo_sec - transcurrido_sec)

                if sec_por_pieza > 0:
                    tiempo_proceso_pieza = _format_seconds_to_hms(sec_por_pieza)
                if objetivo_sec > 0:
                    tiempo_objetivo = _format_seconds_to_hms(objetivo_sec)
                    tiempo_transcurrido = _format_seconds_to_hms(transcurrido_sec)
                    tiempo_restante = _format_seconds_to_hms(restante_sec)
                    proceso_culminado = restante_sec <= 0
                    progreso_pct = min(100, int((transcurrido_sec * 100) / objetivo_sec))

            # Eficiencia planta: sumar tiempo productivo real por estaciones de la hoja activa.
            estaciones_hoja = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja_activa.id).all()
            for est in estaciones_hoja:
                start_ref = est.fecha_inicio
                if not start_ref and (est.estado or '').lower() == 'en_curso':
                    start_ref = hoja_activa.fecha_salida
                if not start_ref:
                    continue

                estado_est = (est.estado or '').lower()
                if estado_est == 'en_curso':
                    interval_end = now_dt
                elif estado_est == 'completada' and est.fecha_finalizacion:
                    interval_end = est.fecha_finalizacion
                else:
                    continue

                if interval_end <= start_ref:
                    continue

                # KPI de eficiencia en tiempo real: usar ventana continua para evitar 0 artificial por cortes de horario.
                productive_hour += _bounded_seconds(start_ref, interval_end, window_hour_start, now_dt)
                productive_day += _bounded_seconds(start_ref, interval_end, window_day_start, now_dt)
                productive_week += _bounded_seconds(start_ref, interval_end, window_week_start, now_dt)

        if hoja_activa:
            if estacion_actual:
                estado_code = 'produciendo'
                estado_label = 'En curso'
            else:
                estado_code = 'activa'
                estado_label = 'Activa'
        else:
            estado_code = 'sin_hoja'
            estado_label = 'Sin hoja'

        data.append({
            'id': maq.id,
            'nombre': maq.nombre,
            'descripcion': maq.descripcion,
            'tipo': maq.tipo,
            'plantilla_default': maq.plantilla_default,
            'activo': bool(getattr(maq, 'activo', False)),
            'pos_x': getattr(maq, 'pos_x', None),
            'pos_y': getattr(maq, 'pos_y', None),
            'estado_code': estado_code,
            'estado_label': estado_label,
            'estacion_actual': estacion_actual.nombre if estacion_actual else None,
            'hoja_serie': hoja_activa.nombre if hoja_activa else None,
            'pieza': hoja_activa.pn if hoja_activa else None,
            'tiempo_total': hoja_activa.total_tiempo if hoja_activa else None,
            'fecha_termino': hoja_activa.fecha_termino.isoformat() if (hoja_activa and hoja_activa.fecha_termino) else None,
            'tiempo_proceso_pieza': tiempo_proceso_pieza,
            'tiempo_objetivo_proceso': tiempo_objetivo,
            'tiempo_transcurrido_proceso': tiempo_transcurrido,
            'tiempo_restante_proceso': tiempo_restante,
            'proceso_culminado': proceso_culminado,
            'progreso_proceso_pct': progreso_pct,
            'estacion_actual_id': estacion_actual.id if estacion_actual else None,
        })

    # Eficiencia de planta: capacidad base sobre TODAS las maquinas registradas,
    # no solo las activas, para evitar 100% engañoso cuando trabaja una sola.
    machine_count = max(1, len(todas_maquinas))
    available_hour = machine_count * int((now_dt - window_hour_start).total_seconds())
    available_day = machine_count * int((now_dt - window_day_start).total_seconds())
    available_week = machine_count * int((now_dt - window_week_start).total_seconds())

    def _pct(prod, avail):
        if avail <= 0:
            return 0
        return round((prod * 100.0) / avail, 1)

    eficiencia_planta = {
        'hora': {
            'porcentaje': _pct(productive_hour, available_hour),
            'productivo_hms': _format_seconds_to_hms(productive_hour),
            'disponible_hms': _format_seconds_to_hms(available_hour),
            'maquinas_base': machine_count,
        },
        'dia': {
            'porcentaje': _pct(productive_day, available_day),
            'productivo_hms': _format_seconds_to_hms(productive_day),
            'disponible_hms': _format_seconds_to_hms(available_day),
            'maquinas_base': machine_count,
        },
        'semana': {
            'porcentaje': _pct(productive_week, available_week),
            'productivo_hms': _format_seconds_to_hms(productive_week),
            'disponible_hms': _format_seconds_to_hms(available_week),
            'maquinas_base': machine_count,
        },
    }

    return jsonify({'maquinas': data, 'eficiencia_planta': eficiencia_planta})


@app.route('/hojas_ruta_form')
@login_required
@requires_any_permission([('hojas', 'view'), ('catalog', 'view')])
def hojas_ruta_form():
    """Formulario simplificado para crear hojas de ruta de produccion."""
    almacenes = ['AlmacenPT', 'AlmacenMP', 'Maquinaria']
    # Listado completo para consulta
    hojas = HojaRuta.query.order_by(HojaRuta.fecha_creacion.desc()).all()

    hoja_ids = [h.id for h in hojas]
    flujos_facturacion = HojaRutaFlujoLogistica.query.filter(
        HojaRutaFlujoLogistica.hoja_ruta_id.in_(hoja_ids),
        HojaRutaFlujoLogistica.estado == 'finalizada'
    ).all() if hoja_ids else []
    facturacion_por_hoja = {f.hoja_ruta_id: f for f in flujos_facturacion}

    registros_facturacion = FacturacionRegistro.query.filter(
        FacturacionRegistro.hoja_ruta_id.in_(hoja_ids)
    ).order_by(
        FacturacionRegistro.fecha_aprobacion.desc().nullslast(),
        FacturacionRegistro.fecha_creacion.desc()
    ).all() if hoja_ids else []
    ultimo_registro_facturacion = {}
    for registro in registros_facturacion:
        if registro.hoja_ruta_id not in ultimo_registro_facturacion:
            ultimo_registro_facturacion[registro.hoja_ruta_id] = registro

    historial_cargas_por_hoja = {}
    if hoja_ids and _ensure_hoja_cargas_historial_table():
        historial_cargas = HojaRutaCargaPiezasHistorial.query.filter(
            HojaRutaCargaPiezasHistorial.hoja_ruta_id.in_(hoja_ids)
        ).order_by(
            HojaRutaCargaPiezasHistorial.fecha_creacion.desc(),
            HojaRutaCargaPiezasHistorial.id.desc()
        ).all()
        for item in historial_cargas:
            historial_cargas_por_hoja.setdefault(item.hoja_ruta_id, []).append(_serialize_hoja_carga_historial(item))

    claves_all = ClaveProducto.query.all()
    claves_idx = {
        (str(c.clave or '').strip().upper()): c
        for c in claves_all
        if str(c.clave or '').strip()
    }

    hojas_data = []
    for h in hojas:
        flujo_fact = facturacion_por_hoja.get(h.id)
        registro_fact = ultimo_registro_facturacion.get(h.id)
        qr_payload = f"HRID:{h.id};SERIE:{h.nombre or ''}"
        descripcion_clave = _resolve_clave_descripcion_by_pn(h.pn)
        clave_obj = claves_idx.get(str(h.pn or '').strip().upper())
        comentarios_bruto = _clean_nullable_text(h.materia_prima)
        scrap_summary = _qc_parse_scrap_summary(comentarios_bruto)
        comentarios_val = _qc_strip_scrap_summary(comentarios_bruto)
        hojas_data.append({
            'id': h.id,
            'maquina_id': h.maquina_id,
            'serie': h.nombre,
            'qr_payload': qr_payload,
            'clave': h.pn,
            'clave_id': clave_obj.id if clave_obj else None,
            'descripcion_clave': descripcion_clave,
            'calidad': h.calidad,
            'almacen': h.almacen,
            'orden_trabajo': h.orden_trabajo_hr,
            'comentarios': comentarios_val,
            'scrap_qc': scrap_summary,
            'firma_ing_jose': h.supervisor,
            'firma_ing_rodrigo': h.operador,
            'estado': h.estado,
            'liberada_facturacion': bool(flujo_fact),
            'facturacion_aprobado_por': (flujo_fact.facturacion_aprobado_por if flujo_fact else None),
            'facturacion_aprobado_en': (flujo_fact.facturacion_aprobado_en.isoformat() if flujo_fact and flujo_fact.facturacion_aprobado_en else None),
            'facturacion_registro_estado': (
                'APROBADA' if registro_fact and registro_fact.aprobado else 'REGRESADA'
            ) if registro_fact else None,
            'facturacion_registro_usuario': registro_fact.usuario if registro_fact else None,
            'facturacion_registro_fecha': (
                registro_fact.fecha_aprobacion.isoformat()
                if registro_fact and registro_fact.fecha_aprobacion
                else (registro_fact.fecha_creacion.isoformat() if registro_fact and registro_fact.fecha_creacion else None)
            ),
            'facturacion_registro_notas': registro_fact.notas if registro_fact else None,
            'cantidad_piezas': h.cantidad_piezas,
            'historial_cargas': historial_cargas_por_hoja.get(h.id, []),
            'fecha_salida': h.fecha_salida.isoformat() if h.fecha_salida else None,
            'fecha_creacion': h.fecha_creacion.isoformat() if h.fecha_creacion else None,
        })
    return render_template('hojas_ruta_form.html', hojas=hojas_data, almacenes=almacenes)


@app.route('/hoja/<int:hoja_id>')
@login_required
@requires_any_permission([('hojas', 'view'), ('catalog', 'view'), ('entregas', 'view'), ('almacen', 'view'), ('facturacion', 'view')])
def hoja_ruta_ver(hoja_id):
    """Vista independiente para ver una hoja por ID, sin requerir máquina."""
    hoja = HojaRuta.query.get_or_404(hoja_id)
    h = hoja.to_dict()
    comentarios_bruto = _clean_nullable_text(h.get('materia_prima'))
    h['comentarios_usuario'] = _qc_strip_scrap_summary(comentarios_bruto)
    h['scrap_qc'] = _qc_parse_scrap_summary(comentarios_bruto)
    h['descripcion_clave'] = _resolve_clave_descripcion_by_pn(hoja.pn)
    h['qr_payload'] = f"HRID:{hoja.id};SERIE:{hoja.nombre or ''}"
    h['qr_deeplink'] = request.url_root.rstrip('/') + f"/hoja/{hoja.id}"
    estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden).all()
    h['estaciones'] = [e.to_dict() for e in estaciones]
    return render_template('hoja_ruta_ver.html', hoja=h)


@app.route('/api/hojas_ruta/resolver_codigo', methods=['POST'])
@login_required
@requires_any_permission([('hojas', 'view'), ('catalog', 'view')])
def api_resolver_codigo_hoja_ruta():
    """Resuelve texto escaneado (QR/codigo) a una hoja de ruta."""
    data = request.get_json() or {}
    raw_value = (data.get('value') or '').strip()
    if not raw_value:
        return jsonify({'error': 'Codigo vacio'}), 400

    value = raw_value.strip()
    upper_value = value.upper()

    hoja_id = None

    # 1) URL tipo /hoja/<id>
    m_url = re.search(r'/hoja/(\d+)', value)
    if m_url:
        hoja_id = int(m_url.group(1))

    # 2) Payload tipo HRID:<id>
    if hoja_id is None:
        m_hrid = re.search(r'HRID\s*[:=]\s*(\d+)', upper_value)
        if m_hrid:
            hoja_id = int(m_hrid.group(1))

    # 3) Si viene solo el numero
    if hoja_id is None and value.isdigit():
        hoja_id = int(value)

    hoja = None
    if hoja_id is not None:
        hoja = HojaRuta.query.get(hoja_id)

    # 4) Fallback por serie exacta
    if hoja is None:
        hoja = HojaRuta.query.filter_by(nombre=value).first()

    if hoja is None:
        return jsonify({'error': 'No se encontro hoja para el codigo escaneado'}), 404

    return jsonify({
        'ok': True,
        'hoja': {
            'id': hoja.id,
            'serie': hoja.nombre,
            'clave': hoja.pn,
            'estado': hoja.estado,
            'maquina_id': hoja.maquina_id,
        }
    }), 200


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

    # Hojas liberadas por Facturación para esta máquina
    hoja_ids = [h['id'] for h in hojas_data]
    facturadas_flujos = HojaRutaFlujoLogistica.query.filter(
        HojaRutaFlujoLogistica.hoja_ruta_id.in_(hoja_ids),
        HojaRutaFlujoLogistica.estado == 'finalizada'
    ).all() if hoja_ids else []
    facturadas_info = {
        f.hoja_ruta_id: {
            'aprobado_por': f.facturacion_aprobado_por or '',
            'aprobado_en': f.facturacion_aprobado_en.strftime('%d/%m/%Y %H:%M') if f.facturacion_aprobado_en else ''
        }
        for f in facturadas_flujos
    }

    return render_template('hojas_ruta_detalle.html', maquina=maquina, hojas=hojas_data, facturadas_info=facturadas_info)


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
@requires_any_permission([('hojas', 'create'), ('catalog', 'edit')])
def api_crear_hoja_ruta():
    """Crear una hoja de ruta con formato simplificado y procesos desde la clave."""
    data = request.get_json() or {}
    clave_id = data.get('clave_id')
    calidad = (data.get('calidad') or '').strip()
    almacen = (data.get('almacen') or '').strip()
    orden_trabajo = (data.get('orden_trabajo') or '').strip()
    comentarios = (data.get('comentarios') or '').strip()
    firma_ing_jose = (data.get('firma_ing_jose') or '').strip()
    firma_ing_rodrigo = (data.get('firma_ing_rodrigo') or '').strip()
    cantidad_piezas = data.get('cantidad_piezas')
    user = get_current_user()

    firma_jose_aut = firma_ing_jose.upper() == 'AUTORIZADO'
    firma_rodrigo_aut = firma_ing_rodrigo.upper() == 'AUTORIZADO'
    if (firma_jose_aut or firma_rodrigo_aut) and not (user and user.es_admin):
        return jsonify({
            'error': 'Solo admin puede autorizar firmas al crear una hoja nueva.',
            'firmas_forzadas': True,
        }), 403

    if not clave_id:
        return jsonify({'error': 'clave_id requerido'}), 400
    if not calidad:
        return jsonify({'error': 'calidad requerida'}), 400
    if not almacen:
        return jsonify({'error': 'almacen requerido'}), 400
    if not cantidad_piezas or cantidad_piezas <= 0:
        return jsonify({'error': 'cantidad_piezas debe ser mayor a 0'}), 400

    # Obtener la clave y sus procesos
    clave = ClaveProducto.query.get(clave_id)
    if not clave:
        return jsonify({'error': 'Clave no encontrada'}), 404

    # Politica de duplicados por clave (configurable)
    # none/off/allow: permite crear hojas aunque ya exista la clave (default).
    # active: bloquea si existe hoja activa/pausada con la misma clave.
    # day: bloquea si ya existe hoja de esa clave creada hoy.
    # week: bloquea si ya existe hoja de esa clave creada en la semana actual.
    duplicate_scope = (os.getenv('HOJA_RUTA_DUPLICATE_SCOPE', 'none') or 'none').strip().lower()
    if duplicate_scope in ('active', 'day', 'week'):
        existing_q = HojaRuta.query.filter(HojaRuta.pn == clave.clave)
        if duplicate_scope == 'day':
            now_dt = datetime.utcnow()
            day_start = now_dt.replace(hour=0, minute=0, second=0, microsecond=0)
            existing_q = existing_q.filter(HojaRuta.fecha_creacion >= day_start)
        elif duplicate_scope == 'week':
            now_dt = datetime.utcnow()
            day_start = now_dt.replace(hour=0, minute=0, second=0, microsecond=0)
            week_start = day_start - timedelta(days=day_start.weekday())
            existing_q = existing_q.filter(HojaRuta.fecha_creacion >= week_start)
        else:
            existing_q = existing_q.filter(HojaRuta.estado.in_(['activa', 'pausada']))

        hoja_existente = existing_q.order_by(HojaRuta.fecha_creacion.desc()).first()
        if hoja_existente:
            return jsonify({
                'error': 'Ya existe una hoja de ruta con esta clave.',
                'code': 'duplicate_clave',
                'scope': duplicate_scope,
                'existing_hoja': {
                    'id': hoja_existente.id,
                    'folio': hoja_existente.nombre,
                    'fecha': hoja_existente.fecha_creacion.isoformat() if hoja_existente.fecha_creacion else None,
                    'estado': hoja_existente.estado,
                }
            }), 409

    maquina_id = int(data.get('maquina_id')) if data.get('maquina_id') else None
    if maquina_id:
        hoja_ocupada = HojaRuta.query.filter(
            HojaRuta.maquina_id == maquina_id,
            HojaRuta.estado.in_(['activa', 'pausada'])
        ).first()
        if hoja_ocupada:
            return jsonify({
                'error': 'La máquina ya tiene una hoja activa o pausada. Retira la hoja actual antes de crear una nueva.',
                'code': 'machine_busy',
                'existing_hoja': {
                    'id': hoja_ocupada.id,
                    'folio': hoja_ocupada.nombre,
                    'estado': hoja_ocupada.estado,
                }
            }), 409

    veces_previas_maquina = 0
    if maquina_id:
        veces_previas_maquina = HojaRuta.query.filter_by(maquina_id=maquina_id, pn=clave.clave).count()

    procesos = ClaveProceso.query.filter_by(clave_id=clave_id).order_by(ClaveProceso.orden).all()
    if not procesos:
        return jsonify({'error': 'La clave seleccionada no tiene procesos definidos'}), 400

    try:
        fecha_actual = datetime.utcnow()
        maquina = Máquina.query.get(int(data.get('maquina_id'))) if data.get('maquina_id') else None
        descripcion_hoja = _resolve_clave_descripcion_by_pn(clave.clave)
        audit_username = _current_username_for_audit(user)

        hoja = HojaRuta(
            maquina_id=maquina_id,
            nombre='PENDIENTE_SERIE',
            descripcion=descripcion_hoja,
            estado='activa',
            producto=clave.nombre,
            calidad=calidad,
            pn=clave.clave,
            revision=None,
            fecha_salida=fecha_actual,
            cantidad_piezas=int(cantidad_piezas),
            orden_trabajo_hr=orden_trabajo or None,
            orden_trabajo_pt=None,
            almacen=almacen,
            no_sin_orden=None,
            materia_prima=(comentarios or '').strip() or None,
            total_tiempo=None,
            dias_a_laborar=None,
            fecha_termino=None,
            aprobada=False,
            rechazada=False,
            scrap=None,
            retrabajo=None,
            supervisor=firma_ing_jose or None,
            operador=firma_ing_rodrigo or None,
            eficiencia=None,
        )
        db.session.add(hoja)
        db.session.flush()

        # Serie automatica: HR-YYYYMMDD-CLAVE-####
        clave_segura = ''.join(ch for ch in (clave.clave or '') if ch.isalnum())[:10] or 'CLAVE'
        hoja.nombre = f"HR-{fecha_actual.strftime('%Y%m%d')}-{clave_segura}-{hoja.id:04d}"

        estaciones_creadas = []
        for idx, cp in enumerate(procesos, start=1):
            estacion = EstacionTrabajo(
                hoja_ruta_id=hoja.id,
                nombre=f"{cp.operacion or cp.proceso.operacion or cp.proceso.nombre}",
                pro_c=str(idx),
                centro_trabajo=cp.centro_trabajo or cp.proceso.centro_trabajo or '',
                operacion=cp.operacion or cp.proceso.operacion or cp.proceso.nombre or '',
                orden=cp.orden,
                t_e=cp.t_e or cp.proceso.tiempo_estimado or '',
                t_tct=cp.t_tct or '',
                t_tco=cp.t_tco or '',
                t_to=cp.t_to or '',
                total_piezas=None,
                operador=None,
                eficiencia=None,
                firma_supervisor=None,
                estado='pendiente'
            )
            db.session.add(estacion)
            estaciones_creadas.append(estacion)

        _apply_hoja_time_plan(
            hoja,
            estaciones_creadas,
            maquina_tipo=maquina.tipo if maquina else None,
            fallback_total_time=hoja.total_tiempo,
        )
        _registrar_carga_piezas_hoja(hoja, 0, int(cantidad_piezas), audit_username, origen='creacion')

        db.session.commit()
        logger.info(
            f"[HOJAS_RUTA] Nueva hoja creada {hoja.nombre} ({hoja.id}) con {len(procesos)} estaciones para clave {clave.clave}"
        )
        result = hoja.to_dict()
        result['ya_paso_por_maquina'] = veces_previas_maquina > 0
        result['veces_previas_maquina'] = veces_previas_maquina
        return jsonify(result), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error creando hoja de ruta: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/hojas_ruta/<int:hoja_id>', methods=['PUT'])
@login_required
@requires_any_permission([('hojas', 'edit'), ('catalog', 'edit')])
def api_actualizar_hoja_ruta(hoja_id):
    """Actualizar campos editables de una hoja de ruta."""
    hoja = HojaRuta.query.get_or_404(hoja_id)
    data = request.get_json() or {}

    user = get_current_user()
    hoja_field_permissions = {
        field: [HOJA_FIELD_SPECIFIC_ACTIONS[field], HOJA_FIELD_GROUP_ACTIONS[field]]
        for field in HOJA_FIELD_GROUP_ACTIONS
    }
    denied_fields = _check_field_level_permissions(
        user=user,
        module='hojas',
        payload=data,
        field_actions=hoja_field_permissions,
        broad_action='edit',
    )
    if denied_fields and not user.has_permission('catalog', 'edit'):
        return jsonify({
            'error': 'No tienes permiso para editar algunos campos',
            'denied_fields': denied_fields,
        }), 403

    firma_jose_in = (data.get('firma_ing_jose') or '').strip() if 'firma_ing_jose' in data else None
    firma_rodrigo_in = (data.get('firma_ing_rodrigo') or '').strip() if 'firma_ing_rodrigo' in data else None
    wants_authorize = (
        (firma_jose_in is not None and firma_jose_in.upper() == 'AUTORIZADO') or
        (firma_rodrigo_in is not None and firma_rodrigo_in.upper() == 'AUTORIZADO')
    )

    if wants_authorize and not (user and user.es_admin):
        ready, reason = _hoja_ready_for_signatures(hoja)
        if not ready:
            return jsonify({
                'error': reason or 'No se puede autorizar la hoja en este momento.',
                'requires_admin_override': True,
            }), 409
    
    if 'estado' in data:
        hoja.estado = data['estado']
    if 'clave_id' in data and data.get('clave_id') is not None:
        try:
            clave_id = int(data.get('clave_id'))
        except Exception:
            return jsonify({'error': 'clave_id inválido'}), 400

        if clave_id <= 0:
            return jsonify({'error': 'clave_id inválido'}), 400

        clave_obj = ClaveProducto.query.get(clave_id)
        if not clave_obj:
            return jsonify({'error': 'Clave no encontrada'}), 404

        hoja.pn = clave_obj.clave
        hoja.producto = _clean_nullable_text(clave_obj.nombre) or clave_obj.clave
        hoja.descripcion = _resolve_clave_descripcion_by_pn(clave_obj.clave)
    if 'nombre' in data:
        hoja.nombre = data['nombre']
    if 'descripcion' in data:
        hoja.descripcion = data['descripcion']
    if 'comentarios' in data:
        comentarios_usuario = (data.get('comentarios') or '').strip()
        scrap_block = _qc_extract_scrap_block(hoja.materia_prima)
        if scrap_block:
            hoja.materia_prima = (
                (comentarios_usuario + "\n\n" + scrap_block).strip()
                if comentarios_usuario else scrap_block
            )
        else:
            hoja.materia_prima = comentarios_usuario or None
    if 'firma_ing_jose' in data:
        hoja.supervisor = (data.get('firma_ing_jose') or '').strip() or None
    if 'firma_ing_rodrigo' in data:
        hoja.operador = (data.get('firma_ing_rodrigo') or '').strip() or None
    if 'calidad' in data:
        hoja.calidad = (data.get('calidad') or '').strip() or None
    if 'almacen' in data:
        hoja.almacen = (data.get('almacen') or '').strip() or None
    if 'orden_trabajo' in data:
        hoja.orden_trabajo_hr = (data.get('orden_trabajo') or '').strip() or None
    if 'cantidad_piezas' in data:
        try:
            cantidad = int(data.get('cantidad_piezas') or 0)
        except Exception:
            return jsonify({'error': 'cantidad_piezas inválida'}), 400
        if cantidad <= 0:
            return jsonify({'error': 'cantidad_piezas debe ser mayor a 0'}), 400
        cantidad_anterior = int(hoja.cantidad_piezas or 0)
        hoja.cantidad_piezas = cantidad
        _registrar_carga_piezas_hoja(hoja, cantidad_anterior, cantidad, _current_username_for_audit(user), origen='edicion')

    # Regla de negocio: descripcion de hoja siempre proviene de la clave actual.
    if hoja.pn:
        hoja.descripcion = _resolve_clave_descripcion_by_pn(hoja.pn)

    estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden).all()
    maquina = Máquina.query.get(hoja.maquina_id) if hoja.maquina_id else None
    _apply_hoja_time_plan(
        hoja,
        estaciones,
        maquina_tipo=maquina.tipo if maquina else None,
        fallback_total_time=hoja.total_tiempo,
    )
    
    db.session.commit()
    logger.info(f"[HOJAS_RUTA] Hoja actualizada: {hoja_id}")
    return jsonify(hoja.to_dict()), 200


@app.route('/api/claves_procesos', methods=['GET'])
@login_required
@requires_any_permission([('hojas', 'view'), ('catalog', 'view')])
def api_claves_procesos():
    """Obtener todas las claves con sus procesos y tiempo total T/O."""
    try:
        claves = ClaveProducto.query.filter_by(activo=True).order_by(ClaveProducto.clave.asc()).all()
        result = []
        for clave in claves:
            try:
                # Obtener todos los procesos de la clave ordenados
                procesos = ClaveProceso.query.filter_by(clave_id=clave.id).order_by(ClaveProceso.orden).all()

                # El T/O es el del último proceso (suma acumulada)
                tiempo_to = "00:00:00"
                if procesos:
                    # Buscar el último proceso que tenga T/O
                    for cp in reversed(procesos):
                        if cp.t_to:
                            tiempo_to = cp.t_to
                            break

                procesos_payload = []
                for p in procesos:
                    try:
                        base = p.to_dict()
                        base['proceso_descripcion'] = (p.proceso.descripcion if getattr(p, 'proceso', None) else '') or ''
                        procesos_payload.append(base)
                    except Exception as p_err:
                        logger.warning(f"Proceso invalido en clave_id={clave.id}, proceso_id={getattr(p, 'id', '?')}: {p_err}")

                result.append({
                    'id': clave.id,
                    'clave': clave.clave,
                    'nombre': _clean_nullable_text(clave.nombre) or clave.clave,
                    'notas': _clean_nullable_text(getattr(clave, 'notas', None)),
                    'tiempo_to': tiempo_to,
                    'procesos': procesos_payload,
                })
            except Exception as clave_err:
                logger.warning(f"Clave invalida omitida clave_id={getattr(clave, 'id', '?')}: {clave_err}")
                continue
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error obteniendo claves/procesos: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/estaciones', methods=['POST'])
@login_required
@requires_any_permission([('hojas', 'edit'), ('catalog', 'edit')])
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
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
def api_aprobar_ot():
    data = request.get_json() or {}
    maquina_id = data.get('maquina_id')
    ot = data.get('orden_trabajo')
    # Sólo registramos en logs por ahora
    logger.info(f"[PRODUCCION] OT aprobada para maquina={maquina_id} OT={ot}")
    return jsonify({'ok': True, 'message': 'OT aprobada'}), 200


@app.route('/api/maquinas/<int:maquina_id>/activar', methods=['POST'])
@login_required
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
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
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
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


@app.route('/api/maquinas/<int:maquina_id>/paro_mantenimiento', methods=['POST'])
@login_required
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
def api_paro_mantenimiento(maquina_id):
    """Poner máquina en paro por mantenimiento (desactivada)."""
    maq = Máquina.query.get_or_404(maquina_id)
    try:
        maq.activo = False
        db.session.commit()
        logger.info(f"[MAQUINA] Paro mantenimiento maquina {maquina_id}")
        return jsonify({'ok': True, 'maquina_id': maquina_id, 'activo': False, 'motivo': 'mantenimiento'}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error en paro mantenimiento: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo registrar el paro por mantenimiento'}), 500


@app.route('/api/maquinas/<int:maquina_id>/asignar_hoja', methods=['POST'])
@login_required
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
def api_asignar_hoja_maquina(maquina_id):
    """Asignar hoja de ruta pendiente (sin máquina) a una máquina."""
    maq = Máquina.query.get_or_404(maquina_id)
    data = request.get_json() or {}
    hoja_id = data.get('hoja_id')
    start_estacion_id = data.get('start_estacion_id')
    if not hoja_id:
        return jsonify({'error': 'hoja_id requerido'}), 400

    hoja = HojaRuta.query.get_or_404(int(hoja_id))
    if hoja.maquina_id and hoja.maquina_id != maq.id:
        return jsonify({'error': 'La hoja ya está asignada a otra máquina'}), 409

    activa_actual = HojaRuta.query.filter_by(maquina_id=maq.id, estado='activa').first()
    if activa_actual and activa_actual.id != hoja.id:
        return jsonify({'error': 'La máquina ya tiene una hoja activa asignada'}), 409

    try:
        hoja.maquina_id = maq.id
        if not hoja.fecha_salida:
            hoja.fecha_salida = datetime.utcnow()
        hoja.estado = 'activa'
        maq.activo = True  # Activar la máquina al recibir una hoja

        estaciones = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).order_by(EstacionTrabajo.orden).all()
        now_ref = datetime.utcnow()

        # Modo temporal: permitir iniciar desde un proceso avanzado al asignar.
        if start_estacion_id:
            try:
                start_estacion_id = int(start_estacion_id)
            except Exception:
                return jsonify({'error': 'start_estacion_id invalido'}), 400

            objetivo = next((e for e in estaciones if e.id == start_estacion_id), None)
            if not objetivo:
                return jsonify({'error': 'El proceso inicial seleccionado no pertenece a la hoja'}), 409

            for e in estaciones:
                if (e.orden or 0) < (objetivo.orden or 0):
                    # Adelanto temporal: asumir completados los anteriores.
                    e.estado = 'completada'
                    if not e.fecha_inicio:
                        e.fecha_inicio = now_ref
                    if not e.fecha_finalizacion:
                        e.fecha_finalizacion = now_ref

                    # Enviar automaticamente a calidad como pendiente de revision.
                    notas_src = e.notas or ''
                    has_qc_status = re.search(r'STATUS=(QC_OK|QC_NOK)', notas_src or '') is not None
                    if not has_qc_status:
                        qc_pending_block = (
                            "[AUTO_ADVANCE_START]\n"
                            "STATUS=QC_PENDING\n"
                            "ORIGEN=Adelanto_Proceso_Asignacion\n"
                            f"FECHA={now_ref.strftime('%Y-%m-%d %H:%M:%S')}\n"
                            "NOTA=Proceso marcado como completado por adelanto temporal; requiere revision de Calidad.\n"
                            "[AUTO_ADVANCE_END]"
                        )
                        e.notas = (notas_src.strip() + "\n" + qc_pending_block).strip() if notas_src else qc_pending_block
                elif e.id == objetivo.id:
                    e.estado = 'en_curso'
                    if not e.fecha_inicio:
                        e.fecha_inicio = now_ref
                    e.fecha_finalizacion = None
                else:
                    if (e.estado or '').lower() != 'completada':
                        e.estado = 'pendiente'
                        e.fecha_finalizacion = None

            # Mantener hoja en espera de liberacion QC (no auto-liberar por adelanto).
            hoja.aprobada = False
            hoja.rechazada = False
        else:
            # Si no hay proceso en curso, arrancar el siguiente pendiente al asignar.
            en_curso = next((e for e in estaciones if (e.estado or '').lower() == 'en_curso'), None)
            if not en_curso:
                siguiente = next((e for e in estaciones if (e.estado or 'pendiente').lower() != 'completada'), None)
                if siguiente:
                    siguiente.estado = 'en_curso'
                    if not siguiente.fecha_inicio:
                        siguiente.fecha_inicio = now_ref

        _apply_hoja_time_plan(
            hoja,
            estaciones,
            maquina_tipo=maq.tipo,
            fallback_total_time=hoja.total_tiempo,
        )

        db.session.commit()
        logger.info(f"[HOJAS_RUTA] Hoja {hoja.id} asignada a maquina {maquina_id}")
        return jsonify({'success': True, 'hoja': hoja.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error asignando hoja a maquina: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo asignar la hoja a la máquina'}), 500


@app.route('/api/maquinas/<int:maquina_id>/retirar_hoja', methods=['POST'])
@login_required
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
def api_retirar_hoja_maquina(maquina_id):
    """Retirar/desasignar hoja activa de la máquina y devolverla a pendientes."""
    maq = Máquina.query.get_or_404(maquina_id)
    data = request.get_json() or {}
    hoja_id = data.get('hoja_id')

    if hoja_id:
        hoja = HojaRuta.query.get_or_404(int(hoja_id))
        if hoja.maquina_id != maq.id:
            return jsonify({'error': 'La hoja no pertenece a esta máquina'}), 409
    else:
        hoja = HojaRuta.query.filter_by(maquina_id=maq.id, estado='activa').order_by(HojaRuta.fecha_creacion.desc()).first()
        if not hoja:
            return jsonify({'error': 'No hay hoja activa asignada a esta máquina'}), 404

    try:
        hoja.estado = 'activa'
        hoja.maquina_id = None
        # Al volver a pendientes, reiniciar ventanas de tiempo para futura reasignacion.
        hoja.fecha_salida = None
        hoja.fecha_termino = None
        db.session.commit()
        logger.info(f"[HOJAS_RUTA] Hoja {hoja.id} retirada de maquina {maquina_id}")
        return jsonify({'success': True, 'hoja': hoja.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error retirando hoja de maquina: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo retirar la hoja de la máquina'}), 500


@app.route('/api/estaciones/<int:estacion_id>/check_proceso', methods=['POST'])
@login_required
@requires_any_permission([('estaciones', 'operate'), ('catalog', 'edit')])
def api_check_proceso_estacion(estacion_id):
    """Marcar/desmarcar proceso de estación y avanzar automáticamente al siguiente pendiente."""
    estacion = EstacionTrabajo.query.get_or_404(estacion_id)
    hoja = HojaRuta.query.get_or_404(estacion.hoja_ruta_id)
    data = request.get_json() or {}
    completada = bool(data.get('completada', False))

    try:
        ahora = datetime.utcnow()

        if completada:
            if not estacion.fecha_inicio:
                estacion.fecha_inicio = ahora
            estacion.estado = 'completada'
            estacion.fecha_finalizacion = ahora

            # Limpiar cualquier en_curso previo para mantener un solo proceso activo.
            otras_en_curso = EstacionTrabajo.query.filter(
                EstacionTrabajo.hoja_ruta_id == hoja.id,
                EstacionTrabajo.id != estacion.id,
                EstacionTrabajo.estado == 'en_curso'
            ).all()
            for e in otras_en_curso:
                e.estado = 'pendiente'

            siguiente = EstacionTrabajo.query.filter(
                EstacionTrabajo.hoja_ruta_id == hoja.id,
                EstacionTrabajo.estado == 'pendiente'
            ).order_by(EstacionTrabajo.orden.asc()).first()
            if siguiente:
                siguiente.estado = 'en_curso'
                if not siguiente.fecha_inicio:
                    siguiente.fecha_inicio = ahora
            else:
                # No auto-cerrar hoja: puede requerir pasar por otras maquinas/procesos.
                hoja.estado = 'activa'
                hoja.fecha_termino = None

        else:
            estacion.estado = 'pendiente'
            estacion.fecha_finalizacion = None

            # Si se reabre un proceso, la hoja vuelve a activa.
            hoja.estado = 'activa'
            hoja.fecha_termino = None

            en_curso = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id, estado='en_curso').first()
            if not en_curso:
                proximo = EstacionTrabajo.query.filter(
                    EstacionTrabajo.hoja_ruta_id == hoja.id,
                    EstacionTrabajo.estado == 'pendiente'
                ).order_by(EstacionTrabajo.orden.asc()).first()
                if proximo:
                    proximo.estado = 'en_curso'
                    if not proximo.fecha_inicio:
                        proximo.fecha_inicio = ahora

        if not hoja.fecha_salida:
            hoja.fecha_salida = ahora

        # Sincronizar estado final segun checks reales.
        _sync_hoja_estado_with_checks(hoja, now_dt=ahora)

        db.session.commit()

        pendientes = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id, estado='pendiente').count()
        completadas = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id, estado='completada').count()
        total = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).count()

        return jsonify({
            'success': True,
            'estacion': estacion.to_dict(),
            'hoja': {'id': hoja.id, 'estado': hoja.estado, 'fecha_termino': hoja.fecha_termino.isoformat() if hoja.fecha_termino else None},
            'resumen': {'total': total, 'completadas': completadas, 'pendientes': pendientes}
        }), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error marcando proceso estacion={estacion_id}: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo actualizar el proceso'}), 500


@app.route('/api/hojas_ruta/<int:hoja_id>', methods=['DELETE'])
@login_required
@requires_any_permission([('hojas', 'delete'), ('catalog', 'edit')])
def api_eliminar_hoja_ruta(hoja_id):
    """Eliminar una hoja de ruta. Solo permite borrar hojas no asignadas a maquina."""
    hoja = HojaRuta.query.get_or_404(hoja_id)

    if hoja.maquina_id is not None:
        return jsonify({'error': 'No puedes eliminar una hoja asignada a una maquina. Primero desasignala.'}), 409

    try:
        db.session.delete(hoja)
        db.session.commit()
        logger.info(f"[HOJAS_RUTA] Hoja eliminada: {hoja_id}")
        return jsonify({'success': True, 'id': hoja_id}), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error eliminando hoja {hoja_id}: {e}", exc_info=True)
        return jsonify({'error': 'No se pudo eliminar la hoja de ruta'}), 500


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
        maquina_id_int = int(maquina_id)
    except Exception:
        return jsonify({'error': 'maquina_id inválido'}), 400

    hoja_ocupada = HojaRuta.query.filter(
        HojaRuta.maquina_id == maquina_id_int,
        HojaRuta.estado.in_(['activa', 'pausada'])
    ).first()
    if hoja_ocupada:
        return jsonify({'error': 'La máquina ya tiene una hoja activa o pausada. Retira la hoja actual antes de agregar otra.'}), 409

    veces_previas_maquina = HojaRuta.query.filter_by(maquina_id=maquina_id_int, pn=clave).count()

    try:
        nombre = f"Producción {clave}"
        maquina = Máquina.query.get(maquina_id_int)
        hoja = HojaRuta(
            maquina_id=maquina_id_int,
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

        estaciones_creadas = []

        # Preferir procesos por clave (modulo procesos y claves)
        clave_obj = ClaveProducto.query.filter_by(clave=clave).first()
        if clave_obj:
            procesos = ClaveProceso.query.filter_by(clave_id=clave_obj.id).order_by(ClaveProceso.orden).all()
            for idx, cp in enumerate(procesos, start=1):
                est = EstacionTrabajo(
                    hoja_ruta_id=hoja.id,
                    nombre=f"{cp.operacion or cp.proceso.operacion or cp.proceso.nombre}",
                    pro_c=str(idx),
                    centro_trabajo=cp.centro_trabajo or cp.proceso.centro_trabajo or '',
                    operacion=cp.operacion or cp.proceso.operacion or cp.proceso.nombre or '',
                    orden=cp.orden,
                    t_e=cp.t_e or cp.proceso.tiempo_estimado or '',
                    t_tct=cp.t_tct or '',
                    t_tco=cp.t_tco or '',
                    t_to=cp.t_to or '',
                    estado='pendiente'
                )
                db.session.add(est)
                estaciones_creadas.append(est)

        # Fallback: plantillas por tipo si la clave no existe o no tiene procesos
        if not estaciones_creadas:
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
                estaciones_creadas.append(est)

        _apply_hoja_time_plan(
            hoja,
            estaciones_creadas,
            maquina_tipo=maquina.tipo if maquina else None,
            fallback_total_time=tiempo_total,
        )

        db.session.commit()
        logger.info(f"[PRODUCCION] Hoja creada {hoja.id} para maquina {maquina_id} con {len(estaciones_creadas)} procesos")
        return jsonify({
            'success': True,
            'hoja': hoja.to_dict(),
            'ya_paso_por_maquina': veces_previas_maquina > 0,
            'veces_previas_maquina': veces_previas_maquina
        }), 201
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
    _ensure_default_permissions()
    perms = Permission.query.order_by(Permission.module, Permission.action).all()
    return jsonify({'permissions': [p.to_dict() for p in perms]})


@app.route('/api/roles')
@login_required
def api_list_roles():
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403
    _ensure_default_permissions()
    roles = Role.query.order_by(Role.name).all()
    data = []
    for r in roles:
        item = r.to_dict()
        item['description'] = item.get('descripcion')
        item['modules'] = _role_modules_from_permissions(r)
        data.append(item)
    return jsonify({'roles': data})


@app.route('/api/roles', methods=['POST'])
@login_required
def api_create_role():
    if not is_admin_user():
        return jsonify({'error': 'Permiso denegado'}), 403

    _ensure_default_permissions()

    payload = request.get_json() or {}
    name = (payload.get('name') or '').strip()
    description = (payload.get('description') or payload.get('descripcion') or '').strip() or None
    modules = payload.get('modules', []) or []
    permission_ids = payload.get('permission_ids', []) or []

    if not name:
        return jsonify({'error': 'name requerido'}), 400

    existing = Role.query.filter_by(name=name).first()
    if existing:
        return jsonify({'error': 'Ya existe un role con ese nombre'}), 409

    role = Role(name=name, descripcion=description)
    role.permissions = _permissions_from_modules_and_ids(modules, permission_ids)
    db.session.add(role)
    db.session.commit()

    role_data = role.to_dict()
    role_data['description'] = role_data.get('descripcion')
    role_data['modules'] = _role_modules_from_permissions(role)
    return jsonify({'ok': True, 'role': role_data}), 201


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
    _ensure_default_permissions()
    payload = request.get_json() or {}
    modules = payload.get('modules', [])
    permission_ids = payload.get('permission_ids')
    role = Role.query.get_or_404(role_id)

    # If explicit permission IDs are provided, fully synchronize role permissions.
    if permission_ids is not None:
        role.permissions = _permissions_from_modules_and_ids(modules, permission_ids)
    else:
        _apply_role_modules(role, modules)

    db.session.add(role)
    db.session.commit()
    role_data = role.to_dict()
    role_data['description'] = role_data.get('descripcion')
    role_data['modules'] = _role_modules_from_permissions(role)
    return jsonify({'ok': True, 'role': role_data})


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
    custom_role_name = (data.get('custom_role_name') or '').strip()
    custom_role_description = (data.get('custom_role_description') or '').strip() or None
    modules = data.get('modules', []) or []
    permission_ids = data.get('permission_ids', []) or []
    es_admin = bool(data.get('es_admin', False))
    if not username or not password:
        return jsonify({'error': 'username y password requeridos'}), 400
    if Usuario.query.filter_by(username=username).first():
        return jsonify({'error': 'username ya existe'}), 409
    u = Usuario(username=username, correo=correo, es_admin=es_admin, activo=True)
    u.set_password(password)

    wants_custom_profile = bool(modules or permission_ids or custom_role_name)
    if role_name and wants_custom_profile:
        return jsonify({'error': 'Usa role existente o perfil personalizado, no ambos al mismo tiempo'}), 400

    if wants_custom_profile:
        role_target_name = custom_role_name or f'perfil_{username}'
        if Role.query.filter_by(name=role_target_name).first():
            return jsonify({'error': f'Ya existe un role con nombre {role_target_name}'}), 409
        role = Role(name=role_target_name, descripcion=custom_role_description or f'Perfil personalizado de {username}')
        role.permissions = _permissions_from_modules_and_ids(modules, permission_ids)
        db.session.add(role)
        db.session.flush()
        u.role = role
    elif role_name:
        role = Role.query.filter_by(name=role_name).first()
        if role:
            u.role = role

    db.session.add(u)
    db.session.commit()
    user_data = u.to_dict()
    user_data['role'] = u.role.name if u.role else None
    return jsonify({'ok': True, 'user': user_data}), 201


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
@requires_permission('catalog', 'view')
def proveedores():
    """Página de gestión de proveedores"""
    return render_template('proveedores.html')
@app.route('/reportar')
def reportar_incidencia():
    """Página pública para reportar incidencias (sin login)"""
    return render_template('reportar_incidencia.html')

@app.route('/soporte')
@login_required
@requires_permission('tickets', 'view')
def soporte_tecnico():
    """Panel de ingenieros para gestionar tickets de soporte"""
    return render_template('soporte_tecnico.html')


# ========== Paneles de Tickets (rutas asignadas) ===========
@app.route('/tickets')
@login_required
@requires_permission('tickets', 'view')
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
    ultimo_pp = None
    if p.proveedores:
        def _pp_key(pp):
            return pp.fecha_precio or datetime.min.date()
        try:
            ultimo_pp = max(p.proveedores, key=_pp_key)
        except ValueError:
            ultimo_pp = None
    return {
        'id': p.id,
        'clave': p.clave,
        'nombre': p.nombre,
        'descripcion': p.descripcion,
        'precio': p.precio,
        'divisa_venta': p.divisa_venta,
        'cantidad': p.cantidad,
        'imagen_url': p.imagen_url,
        'categoria': p.categoria,
        'unidad': p.unidad,
        'linea': p.linea,
        'clasificacion': p.clasificacion,
        'clasificacion_departamento': p.clasificacion_departamento,
        'divisa_ultima': ultimo_pp.divisa if ultimo_pp else None,
        'precio_compra_ultimo': ultimo_pp.precio_proveedor if ultimo_pp else None,
        'proveedor_ultimo': ultimo_pp.proveedor.nombre if ultimo_pp and ultimo_pp.proveedor else None,
        'fecha_precio_ultimo': ultimo_pp.fecha_precio.isoformat() if ultimo_pp and ultimo_pp.fecha_precio else None
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
        clasificacion = request.args.get('clasificacion', '').lower()

        productos_q = Producto.query
        if query:
            productos_q = productos_q.filter(
                db.or_(
                    Producto.nombre.ilike(f'%{query}%'),
                    Producto.descripcion.ilike(f'%{query}%'),
                    Producto.clave.ilike(f'%{query}%')
                )
            )
        if categoria:
            productos_q = productos_q.filter(Producto.categoria.ilike(f'%{categoria}%'))
        if clasificacion:
            productos_q = productos_q.filter(Producto.clasificacion.ilike(f'%{clasificacion}%'))

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
                Producto.descripcion.ilike(f'%{query}%'),
                Producto.clave.ilike(f'%{query}%')
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


@app.route('/api/procesos/importar-excel', methods=['POST'])
@login_required
def importar_procesos_excel():
    """Inicia importación asíncrona de claves/procesos desde Excel/CSV."""
    if not is_admin_user():
        return jsonify({'error': 'Solo admins pueden importar procesos'}), 403

    if 'file' not in request.files:
        return jsonify({'error': 'No se encontró archivo'}), 400

    file = request.files['file']
    if not file or file.filename == '':
        return jsonify({'error': 'Archivo vacío'}), 400

    filename = secure_filename(file.filename)
    ext = os.path.splitext(filename)[1].lower()
    if ext not in ('.xlsx', '.xls', '.csv'):
        return jsonify({'error': 'Formato no soportado. Usa .xlsx, .xls o .csv'}), 400

    sheet = (request.form.get('sheet') or '').strip()
    imports_dir = os.path.join('uploads', 'imports')
    os.makedirs(imports_dir, exist_ok=True)

    tmp_name = f"procesos_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}{ext}"
    saved_path = os.path.join(imports_dir, tmp_name)
    abs_saved_path = os.path.abspath(saved_path)
    job_id = uuid.uuid4().hex

    try:
        file.save(abs_saved_path)

        _set_procesos_import_job(
            job_id,
            status='queued',
            filename=filename,
            created_at=datetime.utcnow().isoformat(),
            output='',
        )

        worker = threading.Thread(
            target=_run_procesos_import_job,
            args=(job_id, filename, abs_saved_path, sheet),
            daemon=True,
        )
        worker.start()

        return jsonify({
            'ok': True,
            'job_id': job_id,
            'mensaje': 'Importación iniciada'
        }), 202
    except Exception as e:
        try:
            if os.path.exists(abs_saved_path):
                os.remove(abs_saved_path)
        except Exception:
            pass
        logger.error(f"[IMPORT_PROCESOS] Excepción importando {filename}: {e}")
        return jsonify({'error': f'Error procesando importación: {str(e)}'}), 500


@app.route('/api/procesos/importar-excel/status/<job_id>', methods=['GET'])
@login_required
def importar_procesos_excel_status(job_id):
    if not is_admin_user():
        return jsonify({'error': 'Solo admins pueden consultar importaciones'}), 403

    job = _get_procesos_import_job(job_id)

    if not job:
        return jsonify({'error': 'Job no encontrado'}), 404

    return jsonify(job), 200


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


# ==================== SYNC PRECIOS COMPRA (PLANTA) ====================

@app.route('/api/precios_compra_sync', methods=['POST'])
def precios_compra_sync():
    ok, err = _require_sync_key()
    if not ok:
        return err

    payload = request.get_json(silent=True)
    if payload is None:
        return jsonify({'error': 'JSON requerido'}), 400

    items = payload
    if isinstance(payload, dict):
        items = payload.get('items', [])

    if not isinstance(items, list):
        return jsonify({'error': 'Formato invalido, se espera lista'}), 400

    stats = {
        'creados_producto': 0,
        'creados_proveedor': 0,
        'actualizados_precio': 0,
        'creados_historial': 0,
        'ignorados': 0,
        'errores': 0,
        'errores_muestra': []
    }

    for idx, item in enumerate(items, start=1):
        try:
            product_key = (item.get('ProductKey') or item.get('product_key') or '').strip()
            descripcion = (item.get('Description') or item.get('descripcion') or '').strip()
            proveedor_nombre = (item.get('BusinessEntityName') or item.get('proveedor') or '').strip()
            precio = item.get('UnitPrice') if 'UnitPrice' in item else item.get('precio')
            divisa = (item.get('Currency') or item.get('Divisa') or item.get('divisa') or '').strip()
            fecha_documento = _parse_date(item.get('DateDocument') or item.get('fecha_documento'))

            if not product_key or precio is None:
                stats['ignorados'] += 1
                continue

            # Enforce column sizes
            if len(product_key) > 100:
                product_key = product_key[:100]
            if len(proveedor_nombre) > 255:
                proveedor_nombre = proveedor_nombre[:255]
            if len(divisa) > 10:
                divisa = divisa[:10]

            try:
                precio = float(precio)
            except (TypeError, ValueError):
                stats['errores'] += 1
                continue
            if not math.isfinite(precio):
                stats['errores'] += 1
                continue

            producto = Producto.query.filter_by(clave=product_key).first()
            if not producto:
                producto = Producto(
                    clave=product_key,
                    nombre=descripcion or product_key,
                    descripcion=descripcion,
                    precio=precio,
                    cantidad=0,
                    categoria='Compras'
                )
                db.session.add(producto)
                stats['creados_producto'] += 1

            proveedor = None
            if proveedor_nombre:
                proveedor = Proveedor.query.filter_by(nombre=proveedor_nombre).first()
                if not proveedor:
                    proveedor = Proveedor(nombre=proveedor_nombre)
                    db.session.add(proveedor)
                    stats['creados_proveedor'] += 1

            if not proveedor:
                stats['ignorados'] += 1
                continue

            asignacion = ProductoProveedor.query.filter_by(
                producto_id=producto.id,
                proveedor_id=proveedor.id
            ).first()

            if not asignacion:
                asignacion = ProductoProveedor(
                    producto_id=producto.id,
                    proveedor_id=proveedor.id,
                    precio_proveedor=precio,
                    fecha_precio=fecha_documento or datetime.utcnow().date(),
                    divisa=divisa or None,
                    cantidad_minima=1
                )
                db.session.add(asignacion)
                stats['actualizados_precio'] += 1
            else:
                if fecha_documento and asignacion.fecha_precio and fecha_documento < asignacion.fecha_precio:
                    # Only fill divisa if missing, do not downgrade price/date
                    if divisa and not asignacion.divisa:
                        asignacion.divisa = divisa
                        stats['actualizados_precio'] += 1
                    else:
                        stats['ignorados'] += 1
                    continue
                asignacion.precio_proveedor = precio
                if fecha_documento:
                    asignacion.fecha_precio = fecha_documento
                if divisa:
                    asignacion.divisa = divisa
                stats['actualizados_precio'] += 1

            fecha_hist = fecha_documento or asignacion.fecha_precio or datetime.utcnow().date()
            existente_hist = HistorialPreciosProveedor.query.filter_by(
                producto_proveedor_id=asignacion.id,
                precio=precio,
                fecha_precio=fecha_hist
            ).first()
            if not existente_hist:
                db.session.add(HistorialPreciosProveedor(
                    producto_proveedor_id=asignacion.id,
                    precio=precio,
                    fecha_precio=fecha_hist,
                    notas='sync_planta',
                    divisa=divisa or None
                ))
                stats['creados_historial'] += 1

        except Exception as e:
            try:
                db.session.rollback()
            except Exception:
                pass
            stats['errores'] += 1
            if len(stats['errores_muestra']) < 5:
                stats['errores_muestra'].append(str(e))
            continue

    db.session.commit()
    return jsonify({'ok': True, 'stats': stats})

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
        divisa = data.get('divisa')
        
        # Crear nuevo registro de precio histórico
        nuevo_precio = HistorialPreciosProveedor(
            producto_proveedor_id=asignacion.id,
            precio=float(data.get('precio')),
            fecha_precio=fecha_precio,
            notas=data.get('notas', ''),
            divisa=divisa
        )
        
        # Actualizar el precio actual en ProductoProveedor
        asignacion.precio_proveedor = float(data.get('precio'))
        asignacion.fecha_precio = fecha_precio
        if divisa:
            asignacion.divisa = divisa
        
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
        clave = _clean_nullable_text(request.form.get('clave', ''))
        nombre = _clean_nullable_text(request.form.get('nombre', ''))
        notas = _clean_nullable_text(request.form.get('notas', ''))
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
