# --- IMPORTS INICIO ---
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from crypto_utils import encrypt_text, decrypt_text
db = SQLAlchemy()
# --- FIN IMPORTS INICIO ---
# ==================== NUEVO MODELO PARA HOJAS DE RUTA NUEVAS ====================
class HojaRutaNueva(db.Model):
    """Hojas de ruta NUEVAS, independientes del módulo legacy."""
    __tablename__ = 'hojas_ruta_nueva'
    id = db.Column(db.Integer, primary_key=True)
    maquina_id = db.Column(db.Integer, db.ForeignKey('maquinas.id'), nullable=True)
    nombre = db.Column(db.String(255), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    estado = db.Column(db.String(20), default='activa')
    producto = db.Column(db.String(255), nullable=True)
    calidad = db.Column(db.String(255), nullable=True)
    pn = db.Column(db.String(255), nullable=True)
    revision = db.Column(db.String(100), nullable=True)
    fecha_salida = db.Column(db.DateTime, nullable=True)
    cantidad_piezas = db.Column(db.Integer, nullable=True)
    orden_trabajo_hr = db.Column(db.String(100), nullable=True)
    orden_trabajo_pt = db.Column(db.String(100), nullable=True)
    almacen = db.Column(db.String(100), nullable=True)
    no_sin_orden = db.Column(db.String(100), nullable=True)
    materia_prima = db.Column(db.String(255), nullable=True)
    total_tiempo = db.Column(db.String(50), nullable=True)
    dias_a_laborar = db.Column(db.Float, nullable=True)
    fecha_termino = db.Column(db.DateTime, nullable=True)
    aprobada = db.Column(db.Boolean, default=False)
    rechazada = db.Column(db.Boolean, default=False)
    scrap = db.Column(db.String(255), nullable=True)
    retrabajo = db.Column(db.String(255), nullable=True)
    supervisor = db.Column(db.String(200), nullable=True)
    operador = db.Column(db.String(200), nullable=True)
    eficiencia = db.Column(db.Float, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    maquina = db.relationship('Máquina', backref='hojas_ruta_nueva')

    def to_dict(self):
        return {
            'id': self.id,
            'maquina_id': self.maquina_id,
            'nombre': self.nombre,
            'descripcion': self.descripcion,
            'producto': self.producto,
            'calidad': self.calidad,
            'pn': self.pn,
            'revision': self.revision,
            'fecha_salida': self.fecha_salida.isoformat() if self.fecha_salida else None,
            'cantidad_piezas': self.cantidad_piezas,
            'orden_trabajo_hr': self.orden_trabajo_hr,
            'orden_trabajo_pt': self.orden_trabajo_pt,
            'almacen': self.almacen,
            'no_sin_orden': self.no_sin_orden,
            'materia_prima': self.materia_prima,
            'total_tiempo': self.total_tiempo,
            'dias_a_laborar': self.dias_a_laborar,
            'fecha_termino': self.fecha_termino.isoformat() if self.fecha_termino else None,
            'aprobada': self.aprobada,
            'rechazada': self.rechazada,
            'scrap': self.scrap,
            'retrabajo': self.retrabajo,
            'supervisor': self.supervisor,
            'operador': self.operador,
            'eficiencia': self.eficiencia,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None,
        }


class Usuario(db.Model):
    __tablename__ = 'usuarios'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False, unique=True)
    password_hash = db.Column(db.String(255), nullable=False)
    # Encrypted reversible password for admin-only viewing (Fernet)
    encrypted_password = db.Column(db.Text, nullable=True)
    correo = db.Column(db.String(255), nullable=True, unique=True)
    es_admin = db.Column(db.Boolean, default=False)
    activo = db.Column(db.Boolean, default=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    activo = db.Column(db.Boolean, default=False)
    # Role-based permissions
    role_id = db.Column(db.Integer, db.ForeignKey('roles.id'), nullable=True)
    role = db.relationship('Role', backref='usuarios')
    
    def set_password(self, password):
        """Genera hash seguro de contraseña"""
        self.password_hash = generate_password_hash(password)
        try:
            # guardar también versión encriptada para que admin pueda recuperarla
            self.encrypted_password = encrypt_text(password)
        except Exception:
            # si no hay key disponible, no interrumpir (mantener hashing)
            self.encrypted_password = None
    
    def check_password(self, password):
        """Verifica si la contraseña es correcta"""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'correo': self.correo,
            'es_admin': self.es_admin,
            'activo': self.activo,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_actualizacion': self.fecha_actualizacion.isoformat(),
            'role': self.role.name if getattr(self, 'role', None) else None,
        }

    def decrypt_password(self):
        """Return decrypted plaintext password (may raise if key missing)."""
        if not self.encrypted_password:
            return None
        try:
            return decrypt_text(self.encrypted_password)
        except Exception:
            return None

    def has_permission(self, module, action):
        """Check whether the user (via role) has a given permission."""
        if self.es_admin:
            return True
        if not self.role:
            return False
        for p in self.role.permissions:
            if p.module == module and p.action == action:
                return True
        return False

class Proveedor(db.Model):
    __tablename__ = 'proveedores'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(255), nullable=False, unique=True)
    telefono = db.Column(db.String(20), nullable=True)
    rfc = db.Column(db.String(13), nullable=True)
    domicilio = db.Column(db.Text, nullable=True)
    correo = db.Column(db.String(255), nullable=True)
    contacto = db.Column(db.String(255), nullable=True)
    notas = db.Column(db.Text, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relación con ProductoProveedor
    productos = db.relationship('ProductoProveedor', backref='proveedor', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'nombre': self.nombre,
            'telefono': self.telefono,
            'rfc': self.rfc,
            'domicilio': self.domicilio,
            'correo': self.correo,
            'contacto': self.contacto,
            'notas': self.notas,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_actualizacion': self.fecha_actualizacion.isoformat()
        }



class EntregaParcial(db.Model):
    """Registra entregas parciales de una hoja de ruta al módulo de entregas."""
    __tablename__ = 'entregas_parciales'

    id = db.Column(db.Integer, primary_key=True)
    flujo_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_flujo_logistica.id'), nullable=False, index=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, index=True)
    
    cantidad_entregada = db.Column(db.Integer, nullable=False)
    usuario_entrega = db.Column(db.String(120), nullable=False)
    notas = db.Column(db.Text, nullable=True)
    
    fecha_entrega = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    hoja_ruta = db.relationship('HojaRutaEntrega', backref='entregas_parciales', foreign_keys=[hoja_ruta_id])
    
    def to_dict(self):
        return {
            'id': self.id,
            'flujo_id': self.flujo_id,
            'hoja_ruta_id': self.hoja_ruta_id,
            'cantidad_entregada': self.cantidad_entregada,
            'usuario_entrega': self.usuario_entrega,
            'notas': self.notas,
            'fecha_entrega': self.fecha_entrega.isoformat() if self.fecha_entrega else None,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
        }

class HojaRutaImpresionParcial(db.Model):
    """Registro de impresiones parciales (solo para fines de impresion) de hojas ENTREGAS."""
    __tablename__ = 'hojas_ruta_impresiones_parciales'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, index=True)
    cantidad_impresa = db.Column(db.Integer, nullable=False)
    usuario = db.Column(db.String(120), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    hoja_ruta = db.relationship('HojaRutaEntrega', backref='impresiones_parciales')

    def to_dict(self):
        return {
            'id': self.id,
            'hoja_ruta_id': self.hoja_ruta_id,
            'cantidad_impresa': self.cantidad_impresa,
            'usuario': self.usuario,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
        }
# Role / Permission models
role_permissions = db.Table('role_permissions',
    db.Column('role_id', db.Integer, db.ForeignKey('roles.id'), primary_key=True),
    db.Column('permission_id', db.Integer, db.ForeignKey('permissions.id'), primary_key=True)
)


class Role(db.Model):
    __tablename__ = 'roles'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    descripcion = db.Column(db.String(255), nullable=True)

    permissions = db.relationship('Permission', secondary=role_permissions, backref='roles')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'descripcion': self.descripcion,
            'permissions': [p.to_dict() for p in self.permissions]
        }


class Permission(db.Model):
    __tablename__ = 'permissions'

    id = db.Column(db.Integer, primary_key=True)
    module = db.Column(db.String(100), nullable=False)
    action = db.Column(db.String(50), nullable=False)  # e.g., view, edit, delete, export
    descripcion = db.Column(db.String(255), nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'module': self.module,
            'action': self.action,
            'descripcion': self.descripcion
        }

class Producto(db.Model):
    __tablename__ = 'productos'
    
    id = db.Column(db.Integer, primary_key=True)
    clave = db.Column(db.String(100), nullable=True, unique=True)
    nombre = db.Column(db.String(255), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    precio = db.Column(db.Float, nullable=False)
    divisa_venta = db.Column(db.String(10), nullable=True)
    cantidad = db.Column(db.Integer, default=0)
    imagen_url = db.Column(db.String(500), nullable=True)
    categoria = db.Column(db.String(100), nullable=True)
    unidad = db.Column(db.String(50), nullable=True)
    linea = db.Column(db.String(50), nullable=True)
    clasificacion = db.Column(db.String(100), nullable=True)
    clasificacion_departamento = db.Column(db.String(150), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relación con ProductoProveedor
    proveedores = db.relationship('ProductoProveedor', backref='producto', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        ultimo_pp = None
        if self.proveedores:
            def _pp_key(pp):
                return pp.fecha_precio or datetime.min.date()
            try:
                ultimo_pp = max(self.proveedores, key=_pp_key)
            except ValueError:
                ultimo_pp = None
        return {
            'id': self.id,
            'clave': self.clave,
            'nombre': self.nombre,
            'descripcion': self.descripcion,
            'precio': self.precio,
            'divisa_venta': self.divisa_venta,
            'cantidad': self.cantidad,
            'imagen_url': self.imagen_url,
            'categoria': self.categoria,
            'unidad': self.unidad,
            'linea': self.linea,
            'clasificacion': self.clasificacion,
            'clasificacion_departamento': self.clasificacion_departamento,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None,
            'divisa_ultima': ultimo_pp.divisa if ultimo_pp else None,
            'precio_compra_ultimo': ultimo_pp.precio_proveedor if ultimo_pp else None,
            'proveedor_ultimo': ultimo_pp.proveedor.nombre if ultimo_pp and ultimo_pp.proveedor else None,
            'fecha_precio_ultimo': ultimo_pp.fecha_precio.isoformat() if ultimo_pp and ultimo_pp.fecha_precio else None,
            'proveedores': [pp.to_dict() for pp in self.proveedores]
        }

class ProductoProveedor(db.Model):
    __tablename__ = 'producto_proveedor'
    
    id = db.Column(db.Integer, primary_key=True)
    producto_id = db.Column(db.Integer, db.ForeignKey('productos.id'), nullable=False)
    proveedor_id = db.Column(db.Integer, db.ForeignKey('proveedores.id'), nullable=False)
    precio_proveedor = db.Column(db.Float, nullable=False)
    fecha_precio = db.Column(db.Date, default=datetime.utcnow)
    divisa = db.Column(db.String(10), nullable=True)
    cantidad_minima = db.Column(db.Integer, default=1)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relación con HistorialPreciosProveedor
    historial_precios = db.relationship('HistorialPreciosProveedor', backref='asignacion', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'producto_id': self.producto_id,
            'proveedor_id': self.proveedor_id,
            'proveedor': self.proveedor.to_dict() if self.proveedor else None,
            'precio_proveedor': self.precio_proveedor,
            'fecha_precio': self.fecha_precio.isoformat() if self.fecha_precio else None,
            'divisa': self.divisa,
            'cantidad_minima': self.cantidad_minima,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'historial_precios': [hp.to_dict() for hp in self.historial_precios]
        }

class HistorialPreciosProveedor(db.Model):
    __tablename__ = 'historial_precios_proveedor'
    
    id = db.Column(db.Integer, primary_key=True)
    producto_proveedor_id = db.Column(db.Integer, db.ForeignKey('producto_proveedor.id'), nullable=False)
    precio = db.Column(db.Float, nullable=False)
    fecha_precio = db.Column(db.Date, nullable=False)
    notas = db.Column(db.Text, nullable=True)
    divisa = db.Column(db.String(10), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'producto_proveedor_id': self.producto_proveedor_id,
            'precio': self.precio,
            'fecha_precio': self.fecha_precio.isoformat() if self.fecha_precio else None,
            'notas': self.notas,
            'divisa': self.divisa,
            'fecha_creacion': self.fecha_creacion.isoformat()
        }


class Ticket(db.Model):
    """Tickets de incidencias - Sistema de Soporte Técnico"""
    __tablename__ = 'tickets'
    
    id = db.Column(db.Integer, primary_key=True)
    numero_ticket = db.Column(db.String(20), unique=True, nullable=False)
    titulo = db.Column(db.String(255), nullable=False)
    descripcion = db.Column(db.Text, nullable=False)
    nombre_solicitante = db.Column(db.String(100), nullable=False)  # Quién reporta (no login)
    email_solicitante = db.Column(db.String(100), nullable=True)
    departamento = db.Column(db.String(100), nullable=True)
    
    # Asignación a ingeniero
    ingeniero_id = db.Column(db.Integer, db.ForeignKey('usuarios.id'), nullable=True)  # Usuario que lo tomó
    
    # Estados
    estado = db.Column(db.String(20), default='nuevo')  # nuevo, en_progreso, resuelto
    prioridad = db.Column(db.String(20), default='media')  # baja, media, alta, critica
    categoria = db.Column(db.String(100), nullable=True)
    
    # Fechas
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_asignacion = db.Column(db.DateTime, nullable=True)
    fecha_resolucion = db.Column(db.DateTime, nullable=True)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relación con comentarios
    comentarios = db.relationship('ComentarioTicket', backref='ticket', lazy=True, cascade='all, delete-orphan')
    ingeniero = db.relationship('Usuario', backref='tickets_asignados')
    
    def to_dict(self):
        return {
            'id': self.id,
            'numero_ticket': self.numero_ticket,
            'titulo': self.titulo,
            'descripcion': self.descripcion,
            'nombre_solicitante': self.nombre_solicitante,
            'email_solicitante': self.email_solicitante,
            'departamento': self.departamento,
            'ingeniero_id': self.ingeniero_id,
            'ingeniero_nombre': self.ingeniero.username if self.ingeniero else None,
            'estado': self.estado,
            'prioridad': self.prioridad,
            'categoria': self.categoria,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_asignacion': self.fecha_asignacion.isoformat() if self.fecha_asignacion else None,
            'fecha_resolucion': self.fecha_resolucion.isoformat() if self.fecha_resolucion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat(),
            'comentarios': [c.to_dict() for c in self.comentarios]
        }


class ComentarioTicket(db.Model):
    """Comentarios y evidencia en tickets"""
    __tablename__ = 'comentarios_tickets'
    
    id = db.Column(db.Integer, primary_key=True)
    ticket_id = db.Column(db.Integer, db.ForeignKey('tickets.id'), nullable=False)
    ingeniero_id = db.Column(db.Integer, db.ForeignKey('usuarios.id'), nullable=False)
    contenido = db.Column(db.Text, nullable=False)
    imagen_url = db.Column(db.String(500), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    
    ingeniero = db.relationship('Usuario', backref='comentarios_tickets')
    
    def to_dict(self):
        return {
            'id': self.id,
            'ticket_id': self.ticket_id,
            'ingeniero_nombre': self.ingeniero.username,
            'contenido': self.contenido,
            'imagen_url': self.imagen_url,
            'fecha_creacion': self.fecha_creacion.isoformat()
        }


class AccessLog(db.Model):
    __tablename__ = 'access_logs'

    id = db.Column(db.Integer, primary_key=True)
    ip = db.Column(db.String(100), nullable=True)
    username = db.Column(db.String(100), nullable=True)
    path = db.Column(db.String(500), nullable=False)
    method = db.Column(db.String(10), nullable=False)
    user_agent = db.Column(db.String(500), nullable=True)
    referer = db.Column(db.String(500), nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'ip': self.ip,
            'username': self.username,
            'path': self.path,
            'method': self.method,
            'user_agent': self.user_agent,
            'referer': self.referer,
            'timestamp': self.timestamp.isoformat()
        }


class QCReport(db.Model):
    """Informe de control de calidad para una máquina."""
    __tablename__ = 'qc_reports'

    id = db.Column(db.Integer, primary_key=True)
    maquina_id = db.Column(db.Integer, db.ForeignKey('maquinas.id'), nullable=False)
    usuario = db.Column(db.String(100), nullable=True)
    observaciones = db.Column(db.Text, nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    # Relación con items
    items = db.relationship('QCItem', backref='report', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'maquina_id': self.maquina_id,
            'usuario': self.usuario,
            'observaciones': self.observaciones,
            'timestamp': self.timestamp.isoformat(),
            'items': [i.to_dict() for i in self.items]
        }


class QCItem(db.Model):
    """Item del checklist asociado a un QCReport."""
    __tablename__ = 'qc_items'

    id = db.Column(db.Integer, primary_key=True)
    report_id = db.Column(db.Integer, db.ForeignKey('qc_reports.id'), nullable=False)
    nombre = db.Column(db.String(200), nullable=False)
    checked = db.Column(db.Boolean, default=False)
    evidence_url = db.Column(db.String(500), nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'report_id': self.report_id,
            'nombre': self.nombre,
            'checked': self.checked,
            'evidence_url': self.evidence_url
        }


class QCProduccionRegistro(db.Model):
    """Control de calidad para piezas/lotes de producción (independiente del QC de maquinaria)."""
    __tablename__ = 'qc_estaciones'

    id = db.Column(db.Integer, primary_key=True)
    maquina_id = db.Column(db.Integer, db.ForeignKey('maquinas.id'), nullable=False)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=True)
    clave_pieza = db.Column(db.String(255), nullable=False)
    lote = db.Column(db.String(255), nullable=True)
    cantidad_inspeccionada = db.Column(db.Integer, nullable=True)
    cantidad_aprobada = db.Column(db.Integer, nullable=True)
    cantidad_rechazada = db.Column(db.Integer, nullable=True)
    resultado = db.Column(db.String(50), nullable=False)  # aprobado / rechazado
    notas = db.Column(db.Text, nullable=True)
    mediciones = db.Column(db.JSON, nullable=True)  # lista/dict de mediciones opcionales
    usuario = db.Column(db.String(100), nullable=True)
    creado_en = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'maquina_id': self.maquina_id,
            'hoja_ruta_id': self.hoja_ruta_id,
            'clave_pieza': self.clave_pieza,
            'lote': self.lote,
            'cantidad_inspeccionada': self.cantidad_inspeccionada,
            'cantidad_aprobada': self.cantidad_aprobada,
            'cantidad_rechazada': self.cantidad_rechazada,
            'resultado': self.resultado,
            'notas': self.notas,
            'mediciones': self.mediciones,
            'usuario': self.usuario,
            'creado_en': self.creado_en.isoformat() if self.creado_en else None
        }


class Máquina(db.Model):
    """Máquinas que requieren control de calidad (independiente de productos)."""
    __tablename__ = 'maquinas'

    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(255), nullable=False, unique=True)
    descripcion = db.Column(db.Text, nullable=True)
    imagen_url = db.Column(db.String(500), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    # Tipo de la máquina (ej: fresadora, torno, cnc) - usado para seleccionar plantillas
    tipo = db.Column(db.String(100), nullable=True)
    # Plantilla por defecto asignada a la máquina (nombre de plantilla)
    plantilla_default = db.Column(db.String(255), nullable=True)
    activo = db.Column(db.Boolean, default=True)
    # Posición en el mapa (px) para la vista de planta
    pos_x = db.Column(db.Integer, nullable=True)
    pos_y = db.Column(db.Integer, nullable=True)

    # Relaciones
    componentes = db.relationship('ComponenteMáquina', backref='maquina', lazy=True, cascade='all, delete-orphan')
    reportes = db.relationship('QCReport', backref='maquina_obj', lazy=True, cascade='all, delete-orphan', foreign_keys='QCReport.maquina_id')

    def to_dict(self):
        return {
            'id': self.id,
            'nombre': self.nombre,
            'plantilla_default': self.plantilla_default,
            'tipo': self.tipo,
            'descripcion': self.descripcion,
            'imagen_url': self.imagen_url,
            'pos_x': self.pos_x,
            'pos_y': self.pos_y,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_actualizacion': self.fecha_actualizacion.isoformat(),
            'activo': self.activo,
            'componentes': [c.to_dict() for c in self.componentes]
        }


class ComponenteMáquina(db.Model):
    """Componentes estándar de una máquina para el checklist QC."""
    __tablename__ = 'componentes_maquinas'

    id = db.Column(db.Integer, primary_key=True)
    maquina_id = db.Column(db.Integer, db.ForeignKey('maquinas.id'), nullable=False)
    nombre = db.Column(db.String(200), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    orden = db.Column(db.Integer, default=0)

    def to_dict(self):
        return {
            'id': self.id,
            'maquina_id': self.maquina_id,
            'nombre': self.nombre,
            'descripcion': self.descripcion,
            'orden': self.orden
        }


class HojaRutaEntrega(db.Model):
    """Hojas de ruta de producción para máquinas (ENTREGAS, legacy)."""
    __tablename__ = 'hojas_ruta_entrega'
    id = db.Column(db.Integer, primary_key=True)
    maquina_id = db.Column(db.Integer, db.ForeignKey('maquinas.id'), nullable=True)
    nombre = db.Column(db.String(255), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    estado = db.Column(db.String(20), default='activa')
    producto = db.Column(db.String(255), nullable=True)
    calidad = db.Column(db.String(255), nullable=True)
    pn = db.Column(db.String(255), nullable=True)
    revision = db.Column(db.String(100), nullable=True)
    fecha_salida = db.Column(db.DateTime, nullable=True)
    cantidad_piezas = db.Column(db.Integer, nullable=True)
    orden_trabajo_hr = db.Column(db.String(100), nullable=True)
    orden_trabajo_pt = db.Column(db.String(100), nullable=True)
    almacen = db.Column(db.String(100), nullable=True)
    no_sin_orden = db.Column(db.String(100), nullable=True)
    materia_prima = db.Column(db.String(255), nullable=True)
    total_tiempo = db.Column(db.String(50), nullable=True)
    dias_a_laborar = db.Column(db.Float, nullable=True)
    fecha_termino = db.Column(db.DateTime, nullable=True)
    aprobada = db.Column(db.Boolean, default=False)
    rechazada = db.Column(db.Boolean, default=False)
    scrap = db.Column(db.String(255), nullable=True)
    retrabajo = db.Column(db.String(255), nullable=True)
    supervisor = db.Column(db.String(200), nullable=True)
    operador = db.Column(db.String(200), nullable=True)
    eficiencia = db.Column(db.Float, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    # Relaciones
    maquina = db.relationship('Máquina', backref='hojas_ruta_entrega')
    estaciones = db.relationship('EstacionTrabajo', backref='hoja_ruta_entrega', lazy=True, cascade='all, delete-orphan')
    historial_cargas = db.relationship(
        'HojaRutaCargaPiezasHistorial',
        backref='hoja_ruta_entrega',
        lazy=True,
        cascade='all, delete-orphan',
        order_by='desc(HojaRutaCargaPiezasHistorial.fecha_creacion)'
    )

    def to_dict(self):
        return {
            'id': self.id,
            'maquina_id': self.maquina_id,
            'nombre': self.nombre,
            'descripcion': self.descripcion,
            'producto': self.producto,
            'calidad': self.calidad,
            'pn': self.pn,
            'revision': self.revision,
            'fecha_salida': self.fecha_salida.isoformat() if self.fecha_salida else None,
            'cantidad_piezas': self.cantidad_piezas,
            'orden_trabajo_hr': self.orden_trabajo_hr,
            'orden_trabajo_pt': self.orden_trabajo_pt,
            'almacen': self.almacen,
            'no_sin_orden': self.no_sin_orden,
            'materia_prima': self.materia_prima,
            'total_tiempo': self.total_tiempo,
            'dias_a_laborar': self.dias_a_laborar,
            'fecha_termino': self.fecha_termino.isoformat() if self.fecha_termino else None,
            'aprobada': self.aprobada,
            'rechazada': self.rechazada,
            'scrap': self.scrap,
            'retrabajo': self.retrabajo,
            'supervisor': self.supervisor,
            'operador': self.operador,
            'eficiencia': self.eficiencia,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_actualizacion': self.fecha_actualizacion.isoformat(),
            'estaciones': [e.to_dict() for e in self.estaciones]
        }


class HojaRutaCargaPiezasHistorial(db.Model):
    """Historial de cambios de cantidad de piezas por hoja de ruta."""
    __tablename__ = 'hojas_ruta_cargas_historial'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, index=True)
    cantidad_anterior = db.Column(db.Integer, nullable=False, default=0)
    cantidad_cambio = db.Column(db.Integer, nullable=False, default=0)
    cantidad_nueva = db.Column(db.Integer, nullable=False, default=0)
    tipo_movimiento = db.Column(db.String(30), nullable=False, default='ajuste')
    usuario = db.Column(db.String(120), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    def to_dict(self):
        return {
            'id': self.id,
            'hoja_ruta_id': self.hoja_ruta_id,
            'cantidad_anterior': self.cantidad_anterior,
            'cantidad_cambio': self.cantidad_cambio,
            'cantidad_nueva': self.cantidad_nueva,
            'tipo_movimiento': self.tipo_movimiento,
            'usuario': self.usuario,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
        }


class HojaRutaFlujoLogistica(db.Model):
    """Flujo temporal de entrega/recepción/facturación sin borrar la hoja base."""
    __tablename__ = 'hojas_ruta_flujo_logistica'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, unique=True)

    # entregas | almacen | entregas_lista_facturacion | facturacion | finalizada
    estado = db.Column(db.String(30), nullable=False, default='entregas', index=True)

    creado_por = db.Column(db.String(120), nullable=True)
    actualizado_por = db.Column(db.String(120), nullable=True)

    # Campos de recepción en almacén
    almacen_validado = db.Column(db.Boolean, nullable=False, default=False)
    almacen_recepcion_id = db.Column(db.String(120), nullable=True)
    almacen_captura_path = db.Column(db.String(500), nullable=True)

    # Campos de aprobación en facturación
    facturacion_aprobado = db.Column(db.Boolean, nullable=False, default=False)
    facturacion_aprobado_por = db.Column(db.String(120), nullable=True)
    facturacion_aprobado_en = db.Column(db.DateTime, nullable=True)

    # Campos de entregas parciales
    cantidad_total_piezas = db.Column(db.Integer, nullable=True)
    cantidad_entregada = db.Column(db.Integer, default=0, nullable=False)
    cantidad_pendiente = db.Column(db.Integer, nullable=True)
    porcentaje_entregado = db.Column(db.Float, default=0.0, nullable=False)
    estado_parciales = db.Column(db.String(30), default='pendientes', nullable=False)

    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    hoja_ruta = db.relationship('HojaRutaEntrega', backref=db.backref('flujo_logistica', uselist=False))

    entregas_parciales = db.relationship('EntregaParcial', backref='flujo_logistica', lazy=True, cascade='all, delete-orphan')
    def to_dict(self):
        return {
            'id': self.id,
            'hoja_ruta_id': self.hoja_ruta_id,
            'estado': self.estado,
            'creado_por': self.creado_por,
            'actualizado_por': self.actualizado_por,
            'almacen_validado': self.almacen_validado,
            'almacen_recepcion_id': self.almacen_recepcion_id,
            'almacen_captura_path': self.almacen_captura_path,
            'facturacion_aprobado': self.facturacion_aprobado,
            'facturacion_aprobado_por': self.facturacion_aprobado_por,
            'facturacion_aprobado_en': self.facturacion_aprobado_en.isoformat() if self.facturacion_aprobado_en else None,
                        'cantidad_total_piezas': self.cantidad_total_piezas,
                        'cantidad_entregada': self.cantidad_entregada,
                        'cantidad_pendiente': self.cantidad_pendiente,
                        'porcentaje_entregado': round(self.porcentaje_entregado, 2) if self.porcentaje_entregado else 0.0,
                        'estado_parciales': self.estado_parciales,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None,
        }


class EntregaRegistro(db.Model):
    """Bitácora propia del módulo Entregas."""
    __tablename__ = 'entregas_registros'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, index=True)
    flujo_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_flujo_logistica.id'), nullable=True, index=True)
    accion = db.Column(db.String(80), nullable=False)  # agregada_en_entregas | enviada_a_almacen | lista_para_facturacion | enviada_a_facturacion
    usuario = db.Column(db.String(120), nullable=True)
    notas = db.Column(db.Text, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    hoja_ruta = db.relationship('HojaRutaEntrega', backref='entregas_registros')
    flujo = db.relationship('HojaRutaFlujoLogistica', backref='entregas_registros')


class AlmacenRegistro(db.Model):
    """Bitácora propia del módulo Almacén."""
    __tablename__ = 'almacen_registros'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, index=True)
    flujo_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_flujo_logistica.id'), nullable=True, index=True)
    recepcion_id = db.Column(db.String(120), nullable=True)
    captura_path = db.Column(db.String(500), nullable=True)
    validado = db.Column(db.Boolean, nullable=False, default=False)
    usuario = db.Column(db.String(120), nullable=True)
    notas = db.Column(db.Text, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    hoja_ruta = db.relationship('HojaRutaEntrega', backref='almacen_registros')
    flujo = db.relationship('HojaRutaFlujoLogistica', backref='almacen_registros')


class FacturacionRegistro(db.Model):
    """Bitácora propia del módulo Facturación."""
    __tablename__ = 'facturacion_registros'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False, index=True)
    flujo_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_flujo_logistica.id'), nullable=True, index=True)
    aprobado = db.Column(db.Boolean, nullable=False, default=False)
    usuario = db.Column(db.String(120), nullable=True)
    notas = db.Column(db.Text, nullable=True)
    fecha_aprobacion = db.Column(db.DateTime, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    hoja_ruta = db.relationship('HojaRutaEntrega', backref='facturacion_registros')
    flujo = db.relationship('HojaRutaFlujoLogistica', backref='facturacion_registros')


class EstacionTrabajo(db.Model):
    """Estaciones o pasos dentro de una hoja de ruta, con tiempos por columna según plantilla."""
    __tablename__ = 'estaciones_trabajo'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta_entrega.id'), nullable=False)
    nombre = db.Column(db.String(255), nullable=False)
    pro_c = db.Column(db.String(50), nullable=True)  # PRO C. (número o código)
    centro_trabajo = db.Column(db.String(100), nullable=True)  # C.T.
    operacion = db.Column(db.Text, nullable=False)
    orden = db.Column(db.Integer, default=0)

    # Tiempos en formato string HH:MM:SS según columnas T/E, T/CT, T/CO, T/O
    t_e = db.Column(db.String(20), nullable=True)
    t_tct = db.Column(db.String(20), nullable=True)
    t_tco = db.Column(db.String(20), nullable=True)
    t_to = db.Column(db.String(20), nullable=True)

    total_piezas = db.Column(db.Integer, nullable=True)
    operador = db.Column(db.String(200), nullable=True)
    eficiencia = db.Column(db.Float, nullable=True)
    firma_supervisor = db.Column(db.String(200), nullable=True)

    estado = db.Column(db.String(20), default='pendiente')
    fecha_inicio = db.Column(db.DateTime, nullable=True)
    fecha_finalizacion = db.Column(db.DateTime, nullable=True)
    notas = db.Column(db.Text, nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'hoja_ruta_id': self.hoja_ruta_id,
            'pro_c': self.pro_c or '',
            'centro_trabajo': self.centro_trabajo or '',
            'operacion': self.operacion or '',
            'orden': self.orden,
            't_e': self.t_e or '',
            't_tct': self.t_tct or '',
            't_tco': self.t_tco or '',
            't_to': self.t_to or '',
            'total_piezas': self.total_piezas or '',
            'operador': self.operador or '',
            'eficiencia': self.eficiencia or '',
            'firma_supervisor': self.firma_supervisor or '',
            'estado': self.estado,
            'fecha_inicio': self.fecha_inicio.isoformat() if self.fecha_inicio else '',
            'fecha_finalizacion': self.fecha_finalizacion.isoformat() if self.fecha_finalizacion else '',
            'notas': self.notas or '',
            'fecha_creacion': self.fecha_creacion.isoformat()
        }


class EstacionPlantilla(db.Model):
    """Plantillas reutilizables de estaciones por tipo de máquina."""
    __tablename__ = 'plantillas_estaciones'

    id = db.Column(db.Integer, primary_key=True)
    plantilla_nombre = db.Column(db.String(255), nullable=True)  # nombre del conjunto/template
    maquina_tipo = db.Column(db.String(100), nullable=True)  # ej: fresadora, torno, cnc
    pro_c = db.Column(db.String(50), nullable=True)
    centro_trabajo = db.Column(db.String(100), nullable=True)
    operacion = db.Column(db.Text, nullable=False)
    orden = db.Column(db.Integer, default=0)
    t_e = db.Column(db.String(20), nullable=True)
    t_tct = db.Column(db.String(20), nullable=True)
    t_tco = db.Column(db.String(20), nullable=True)
    t_to = db.Column(db.String(20), nullable=True)

    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'plantilla_nombre': self.plantilla_nombre,
            'maquina_tipo': self.maquina_tipo,
            'pro_c': self.pro_c,
            'centro_trabajo': self.centro_trabajo,
            'operacion': self.operacion,
            'orden': self.orden,
            't_e': self.t_e,
            't_tct': self.t_tct,
            't_tco': self.t_tco,
            't_to': self.t_to,
            'fecha_creacion': self.fecha_creacion.isoformat()
        }


# ==================== PROCESOS Y CLAVES (CATÁLOGO DE PRODUCCIÓN) ====================

class ProcesoCatalogo(db.Model):
    __tablename__ = 'procesos_catalogo'

    id = db.Column(db.Integer, primary_key=True)
    # Ya no se exige clave/código; se deja opcional
    codigo = db.Column(db.String(50), nullable=True)
    nombre = db.Column(db.String(255), nullable=False)
    # Texto de la operación por defecto (visible en hoja)
    operacion = db.Column(db.Text, nullable=True)
    descripcion = db.Column(db.Text, nullable=True)
    centro_trabajo = db.Column(db.String(100), nullable=True)
    # Tiempo estimado por defecto (T/E)
    tiempo_estimado = db.Column(db.String(20), nullable=True)
    activo = db.Column(db.Boolean, default=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

    # Relación con claves
    claves = db.relationship('ClaveProceso', backref='proceso', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'codigo': self.codigo,
            'nombre': self.nombre,
            'operacion': self.operacion,
            'descripcion': self.descripcion,
            'centro_trabajo': self.centro_trabajo,
            'tiempo_estimado': self.tiempo_estimado,
            'activo': self.activo,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
        }


class ClaveProducto(db.Model):
    __tablename__ = 'claves_producto'

    id = db.Column(db.Integer, primary_key=True)
    clave = db.Column(db.String(100), nullable=False, unique=True)
    nombre = db.Column(db.String(255), nullable=True)
    notas = db.Column(db.Text, nullable=True)
    activo = db.Column(db.Boolean, default=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

    procesos = db.relationship('ClaveProceso', backref='clave', lazy=True, cascade='all, delete-orphan', order_by='ClaveProceso.orden')

    def to_dict(self, include_procesos=False):
        data = {
            'id': self.id,
            'clave': self.clave,
            'nombre': self.nombre,
            'notas': self.notas,
            'activo': self.activo,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
        }
        if include_procesos:
            data['procesos'] = [p.to_dict() for p in self.procesos]
        return data


class ClaveProceso(db.Model):
    __tablename__ = 'clave_procesos'

    id = db.Column(db.Integer, primary_key=True)
    clave_id = db.Column(db.Integer, db.ForeignKey('claves_producto.id'), nullable=False)
    proceso_id = db.Column(db.Integer, db.ForeignKey('procesos_catalogo.id'), nullable=False)
    orden = db.Column(db.Integer, default=0)
    # Overrides por clave/producto
    centro_trabajo = db.Column(db.String(100), nullable=True)
    operacion = db.Column(db.Text, nullable=True)
    # Tiempos por columna (formato HH:MM:SS)
    t_e = db.Column(db.String(20), nullable=True)
    t_tct = db.Column(db.String(20), nullable=True)
    t_tco = db.Column(db.String(20), nullable=True)
    t_to = db.Column(db.String(20), nullable=True)
    # Back-compat
    tiempo_estimado = db.Column(db.String(20), nullable=True)
    notas = db.Column(db.Text, nullable=True)

    __table_args__ = (
        db.UniqueConstraint('clave_id', 'proceso_id', name='uq_clave_proceso_unico'),
    )

    def to_dict(self):
        return {
            'id': self.id,
            'clave_id': self.clave_id,
            'proceso_id': self.proceso_id,
            'proceso_codigo': self.proceso.codigo if getattr(self, 'proceso', None) else None,
            'proceso_nombre': self.proceso.nombre if getattr(self, 'proceso', None) else None,
            'orden': self.orden,
            'centro_trabajo': self.centro_trabajo,
            'operacion': self.operacion,
            't_e': self.t_e,
            't_tct': self.t_tct,
            't_tco': self.t_tco,
            't_to': self.t_to,
            'tiempo_estimado': self.tiempo_estimado,
            'notas': self.notas,
        }


class ContpaqSyncRun(db.Model):
    __tablename__ = 'contpaq_sync_runs'

    id = db.Column(db.Integer, primary_key=True)
    started_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    finished_at = db.Column(db.DateTime, nullable=True)
    status = db.Column(db.String(20), nullable=False, default='running')
    message = db.Column(db.Text, nullable=True)
    pedidos_upserted = db.Column(db.Integer, nullable=False, default=0)
    pedido_detalles_upserted = db.Column(db.Integer, nullable=False, default=0)
    remisiones_upserted = db.Column(db.Integer, nullable=False, default=0)
    remision_detalles_upserted = db.Column(db.Integer, nullable=False, default=0)

    def to_dict(self):
        return {
            'id': self.id,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'finished_at': self.finished_at.isoformat() if self.finished_at else None,
            'status': self.status,
            'message': self.message,
            'pedidos_upserted': self.pedidos_upserted,
            'pedido_detalles_upserted': self.pedido_detalles_upserted,
            'remisiones_upserted': self.remisiones_upserted,
            'remision_detalles_upserted': self.remision_detalles_upserted,
        }


class ContpaqPedido(db.Model):
    __tablename__ = 'contpaq_pedidos'

    id = db.Column(db.Integer, primary_key=True)
    document_id = db.Column(db.BigInteger, nullable=False, unique=True, index=True)
    doc_folio = db.Column(db.String(80), nullable=False, index=True)
    serie = db.Column(db.String(10), nullable=True, index=True)
    cliente = db.Column(db.String(255), nullable=True, index=True)
    sucursal = db.Column(db.String(255), nullable=True, index=True)
    titulo = db.Column(db.String(255), nullable=True, index=True)
    periodo_semana = db.Column(db.String(30), nullable=True, index=True)
    fecha_documento = db.Column(db.DateTime, nullable=True, index=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    detalles = db.relationship('ContpaqPedidoDetalle', backref='pedido', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'document_id': self.document_id,
            'doc_folio': self.doc_folio,
            'serie': self.serie,
            'cliente': self.cliente,
            'sucursal': self.sucursal,
            'titulo': self.titulo,
            'periodo_semana': self.periodo_semana,
            'fecha_documento': self.fecha_documento.isoformat() if self.fecha_documento else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class ContpaqPedidoDetalle(db.Model):
    __tablename__ = 'contpaq_pedidos_detalle'

    id = db.Column(db.Integer, primary_key=True)
    pedido_id = db.Column(db.Integer, db.ForeignKey('contpaq_pedidos.id'), nullable=False, index=True)
    document_id = db.Column(db.BigInteger, nullable=False, index=True)
    line_number = db.Column(db.Integer, nullable=False, default=0)
    clave_producto = db.Column(db.String(120), nullable=True, index=True)
    descripcion = db.Column(db.Text, nullable=True)
    cantidad = db.Column(db.Float, nullable=True)
    precio_unitario = db.Column(db.Float, nullable=True)
    total_partida = db.Column(db.Float, nullable=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        db.UniqueConstraint('document_id', 'line_number', name='uq_contpaq_pedido_linea'),
    )

    def to_dict(self):
        return {
            'id': self.id,
            'pedido_id': self.pedido_id,
            'document_id': self.document_id,
            'line_number': self.line_number,
            'clave_producto': self.clave_producto,
            'descripcion': self.descripcion,
            'cantidad': self.cantidad,
            'precio_unitario': self.precio_unitario,
            'total_partida': self.total_partida,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class ContpaqRemision(db.Model):
    __tablename__ = 'contpaq_remisiones'

    id = db.Column(db.Integer, primary_key=True)
    document_id = db.Column(db.BigInteger, nullable=False, unique=True, index=True)
    source_document_id = db.Column(db.BigInteger, nullable=True, index=True)
    doc_folio = db.Column(db.String(80), nullable=False, index=True)
    cliente = db.Column(db.String(255), nullable=True, index=True)
    sucursal = db.Column(db.String(255), nullable=True, index=True)
    fecha_documento = db.Column(db.DateTime, nullable=True, index=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    detalles = db.relationship('ContpaqRemisionDetalle', backref='remision', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'document_id': self.document_id,
            'source_document_id': self.source_document_id,
            'doc_folio': self.doc_folio,
            'cliente': self.cliente,
            'sucursal': self.sucursal,
            'fecha_documento': self.fecha_documento.isoformat() if self.fecha_documento else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class ContpaqRemisionDetalle(db.Model):
    __tablename__ = 'contpaq_remisiones_detalle'

    id = db.Column(db.Integer, primary_key=True)
    remision_id = db.Column(db.Integer, db.ForeignKey('contpaq_remisiones.id'), nullable=False, index=True)
    document_id = db.Column(db.BigInteger, nullable=False, index=True)
    line_number = db.Column(db.Integer, nullable=False, default=0)
    clave_producto = db.Column(db.String(120), nullable=True, index=True)
    descripcion = db.Column(db.Text, nullable=True)
    cantidad = db.Column(db.Float, nullable=True)
    precio_unitario = db.Column(db.Float, nullable=True)
    total_partida = db.Column(db.Float, nullable=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        db.UniqueConstraint('document_id', 'line_number', name='uq_contpaq_remision_linea'),
    )

    def to_dict(self):
        return {
            'id': self.id,
            'remision_id': self.remision_id,
            'document_id': self.document_id,
            'line_number': self.line_number,
            'clave_producto': self.clave_producto,
            'descripcion': self.descripcion,
            'cantidad': self.cantidad,
            'precio_unitario': self.precio_unitario,
            'total_partida': self.total_partida,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class ContpaqSucursalIndice(db.Model):
    __tablename__ = 'contpaq_sucursales_indice'

    id = db.Column(db.Integer, primary_key=True)
    semana = db.Column(db.String(80), nullable=True, index=True)
    sucursal = db.Column(db.String(255), nullable=True, index=True)
    clave_producto = db.Column(db.String(120), nullable=True, index=True)
    descripcion = db.Column(db.Text, nullable=True)
    cantidad = db.Column(db.String(40), nullable=True, index=True)
    folio = db.Column(db.String(120), nullable=True, index=True)
    fecha_documento = db.Column(db.String(80), nullable=True)
    source_filename = db.Column(db.String(255), nullable=True)
    imported_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    raw_payload = db.Column(db.Text, nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'semana': self.semana,
            'sucursal': self.sucursal,
            'clave_producto': self.clave_producto,
            'descripcion': self.descripcion,
            'cantidad': self.cantidad,
            'folio': self.folio,
            'fecha_documento': self.fecha_documento,
            'source_filename': self.source_filename,
            'imported_at': self.imported_at.isoformat() if self.imported_at else None,
        }


class ContpaqPrecioPublico(db.Model):
    __tablename__ = 'contpaq_precios_publicos'

    id = db.Column(db.Integer, primary_key=True)
    clave_producto = db.Column(db.String(120), nullable=False, index=True, unique=True)
    precio_publico = db.Column(db.Float, nullable=True)
    source_filename = db.Column(db.String(255), nullable=True)
    source_sheet = db.Column(db.String(120), nullable=True)
    imported_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    raw_payload = db.Column(db.Text, nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'clave_producto': self.clave_producto,
            'precio_publico': self.precio_publico,
            'source_filename': self.source_filename,
            'source_sheet': self.source_sheet,
            'imported_at': self.imported_at.isoformat() if self.imported_at else None,
        }


class MaquinariaPedido(db.Model):
    __tablename__ = 'maquinaria_pedidos'

    id = db.Column(db.Integer, primary_key=True)
    folio_interno = db.Column(db.String(80), nullable=False, unique=True, index=True)
    contpaq_document_id = db.Column(db.BigInteger, nullable=True, index=True)
    cliente = db.Column(db.String(255), nullable=True, index=True)
    clave_maquina = db.Column(db.String(120), nullable=False, index=True)
    descripcion_maquina = db.Column(db.String(255), nullable=True)
    cantidad = db.Column(db.Integer, nullable=False, default=1)
    estado = db.Column(db.String(40), nullable=False, default='abierto', index=True)
    fecha_pedido = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    notas = db.Column(db.Text, nullable=True)
    created_by = db.Column(db.String(100), nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'folio_interno': self.folio_interno,
            'contpaq_document_id': self.contpaq_document_id,
            'cliente': self.cliente,
            'clave_maquina': self.clave_maquina,
            'descripcion_maquina': self.descripcion_maquina,
            'cantidad': self.cantidad,
            'estado': self.estado,
            'fecha_pedido': self.fecha_pedido.isoformat() if self.fecha_pedido else None,
            'notas': self.notas,
            'created_by': self.created_by,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class MaquinariaContpaqPedido(db.Model):
    __tablename__ = 'maquinaria_contpaq_pedidos'

    id = db.Column(db.Integer, primary_key=True)
    document_id = db.Column(db.BigInteger, nullable=False, unique=True, index=True)
    owned_business_entity_id = db.Column(db.BigInteger, nullable=True, index=True)
    folio = db.Column(db.String(120), nullable=False, index=True)
    serie = db.Column(db.String(20), nullable=True, index=True)
    business_entity_name = db.Column(db.String(255), nullable=True, index=True)
    depot_name = db.Column(db.String(255), nullable=True, index=True)
    date_document = db.Column(db.DateTime, nullable=True, index=True)
    date_doc_delivery = db.Column(db.DateTime, nullable=True, index=True)
    title = db.Column(db.String(255), nullable=True, index=True)
    sales_rep = db.Column(db.String(255), nullable=True)
    currency = db.Column(db.String(40), nullable=True)
    rate = db.Column(db.Float, nullable=True)
    subtotal = db.Column(db.Float, nullable=True)
    total = db.Column(db.Float, nullable=True)
    total_tax = db.Column(db.Float, nullable=True)
    total_discount = db.Column(db.Float, nullable=True)
    total_retention = db.Column(db.Float, nullable=True)
    total_cost = db.Column(db.Float, nullable=True)
    comments = db.Column(db.Text, nullable=True)
    payment_term_name = db.Column(db.String(255), nullable=True)
    language_name = db.Column(db.String(255), nullable=True)
    cost_center_name = db.Column(db.String(255), nullable=True)
    cost_center_category = db.Column(db.String(255), nullable=True)
    period_month = db.Column(db.String(30), nullable=True, index=True)
    period_week = db.Column(db.String(30), nullable=True, index=True)
    period_year = db.Column(db.String(10), nullable=True, index=True)
    period_quarter = db.Column(db.String(30), nullable=True)
    campaign_name = db.Column(db.String(255), nullable=True)
    campaign_id = db.Column(db.BigInteger, nullable=True)
    intl_symbol = db.Column(db.String(20), nullable=True)
    total_invoiced = db.Column(db.Float, nullable=True)
    total_invoice_paid = db.Column(db.Float, nullable=True)
    total_invoice_balance = db.Column(db.Float, nullable=True)
    invoiced = db.Column(db.Integer, nullable=True)
    status_delivery_id = db.Column(db.BigInteger, nullable=True)
    status_delivery = db.Column(db.String(120), nullable=True, index=True)
    total_paid = db.Column(db.Float, nullable=True)
    balance = db.Column(db.Float, nullable=True)
    globalizado = db.Column(db.Boolean, nullable=True)
    rfc_cliente = db.Column(db.String(40), nullable=True)
    metodo_pago = db.Column(db.String(20), nullable=True)
    forma_pago = db.Column(db.String(20), nullable=True)
    tipo_facturacion = db.Column(db.String(120), nullable=True)
    invoice_document_id = db.Column(db.BigInteger, nullable=True)
    sucursal = db.Column(db.String(255), nullable=True, index=True)
    printed = db.Column(db.Boolean, nullable=False, default=False)
    validated = db.Column(db.Boolean, nullable=False, default=False)
    cancelled = db.Column(db.Boolean, nullable=False, default=False)
    deleted = db.Column(db.Boolean, nullable=False, default=False)
    in_use = db.Column(db.Boolean, nullable=False, default=False)
    auth1 = db.Column(db.Boolean, nullable=False, default=False)
    auth2 = db.Column(db.Boolean, nullable=False, default=False)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    detalles = db.relationship('MaquinariaContpaqPedidoDetalle', backref='pedido', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'document_id': self.document_id,
            'folio': self.folio,
            'serie': self.serie,
            'business_entity_name': self.business_entity_name,
            'sucursal': self.sucursal,
            'date_document': self.date_document.isoformat() if self.date_document else None,
            'date_doc_delivery': self.date_doc_delivery.isoformat() if self.date_doc_delivery else None,
            'title': self.title,
            'subtotal': self.subtotal,
            'total': self.total,
            'status_delivery': self.status_delivery,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class MaquinariaContpaqPedidoDetalle(db.Model):
    __tablename__ = 'maquinaria_contpaq_pedidos_detalle'

    id = db.Column(db.Integer, primary_key=True)
    pedido_id = db.Column(db.Integer, db.ForeignKey('maquinaria_contpaq_pedidos.id'), nullable=False, index=True)
    document_id = db.Column(db.BigInteger, nullable=False, index=True)
    line_number = db.Column(db.Integer, nullable=False, default=0)
    quantity = db.Column(db.Float, nullable=True)
    product_id = db.Column(db.BigInteger, nullable=True)
    product_key = db.Column(db.String(120), nullable=True, index=True)
    description = db.Column(db.Text, nullable=True)
    discount_perc = db.Column(db.Float, nullable=True)
    tax_perc = db.Column(db.Float, nullable=True)
    tax_type_name = db.Column(db.String(120), nullable=True)
    unit_price = db.Column(db.Float, nullable=True)
    total_item = db.Column(db.Float, nullable=True)
    unit = db.Column(db.String(40), nullable=True)
    clave_unidad = db.Column(db.String(40), nullable=True)
    coef_unit = db.Column(db.Float, nullable=True)
    period_week = db.Column(db.String(30), nullable=True, index=True)
    period_month = db.Column(db.String(30), nullable=True, index=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        db.UniqueConstraint('document_id', 'line_number', name='uq_maquinaria_contpaq_pedido_linea'),
    )

    def to_dict(self):
        return {
            'id': self.id,
            'pedido_id': self.pedido_id,
            'document_id': self.document_id,
            'line_number': self.line_number,
            'quantity': self.quantity,
            'product_id': self.product_id,
            'product_key': self.product_key,
            'description': self.description,
            'discount_perc': self.discount_perc,
            'tax_perc': self.tax_perc,
            'tax_type_name': self.tax_type_name,
            'unit_price': self.unit_price,
            'total_item': self.total_item,
            'unit': self.unit,
            'clave_unidad': self.clave_unidad,
            'coef_unit': self.coef_unit,
            'period_week': self.period_week,
            'period_month': self.period_month,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class MaquinariaBOM(db.Model):
    __tablename__ = 'maquinaria_boms'

    id = db.Column(db.Integer, primary_key=True)
    clave_maquina = db.Column(db.String(120), nullable=False, unique=True, index=True)
    nombre_maquina = db.Column(db.String(255), nullable=False)
    version = db.Column(db.String(40), nullable=True)
    estado = db.Column(db.String(30), nullable=False, default='activo', index=True)
    notas = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    componentes = db.relationship('MaquinariaBOMComponente', backref='bom', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'clave_maquina': self.clave_maquina,
            'nombre_maquina': self.nombre_maquina,
            'version': self.version,
            'estado': self.estado,
            'notas': self.notas,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class MaquinariaBOMComponente(db.Model):
    __tablename__ = 'maquinaria_bom_componentes'

    id = db.Column(db.Integer, primary_key=True)
    bom_id = db.Column(db.Integer, db.ForeignKey('maquinaria_boms.id'), nullable=False, index=True)
    codigo_componente = db.Column(db.String(120), nullable=False, index=True)
    nombre_componente = db.Column(db.String(255), nullable=False)
    cantidad = db.Column(db.Float, nullable=False, default=1)
    unidad = db.Column(db.String(30), nullable=True)
    proceso_base = db.Column(db.String(120), nullable=True)
    notas = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'bom_id': self.bom_id,
            'codigo_componente': self.codigo_componente,
            'nombre_componente': self.nombre_componente,
            'cantidad': self.cantidad,
            'unidad': self.unidad,
            'proceso_base': self.proceso_base,
            'notas': self.notas,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }


class MaquinariaOrdenTrabajo(db.Model):
    __tablename__ = 'maquinaria_ordenes_trabajo'

    id = db.Column(db.Integer, primary_key=True)
    folio_ot = db.Column(db.String(80), nullable=False, unique=True, index=True)
    pedido_id = db.Column(db.Integer, db.ForeignKey('maquinaria_pedidos.id'), nullable=True, index=True)
    clave_maquina = db.Column(db.String(120), nullable=False, index=True)
    cantidad = db.Column(db.Integer, nullable=False, default=1)
    estado = db.Column(db.String(40), nullable=False, default='planeacion', index=True)
    fecha_objetivo = db.Column(db.DateTime, nullable=True)
    notas = db.Column(db.Text, nullable=True)
    created_by = db.Column(db.String(100), nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    pedido = db.relationship('MaquinariaPedido', backref='ordenes_trabajo')

    def to_dict(self):
        return {
            'id': self.id,
            'folio_ot': self.folio_ot,
            'pedido_id': self.pedido_id,
            'clave_maquina': self.clave_maquina,
            'cantidad': self.cantidad,
            'estado': self.estado,
            'fecha_objetivo': self.fecha_objetivo.isoformat() if self.fecha_objetivo else None,
            'notas': self.notas,
            'created_by': self.created_by,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


class MaquinariaCalidadRegistro(db.Model):
    __tablename__ = 'maquinaria_calidad_registros'

    id = db.Column(db.Integer, primary_key=True)
    folio_ot = db.Column(db.String(80), nullable=False, index=True)
    funcionalidad_ok = db.Column(db.Boolean, nullable=False, default=False)
    seguridad_ok = db.Column(db.Boolean, nullable=False, default=False)
    acabado_ok = db.Column(db.Boolean, nullable=False, default=False)
    observaciones = db.Column(db.Text, nullable=True)
    evaluado_por = db.Column(db.String(120), nullable=True)
    fecha_evaluacion = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)

    def to_dict(self):
        return {
            'id': self.id,
            'folio_ot': self.folio_ot,
            'funcionalidad_ok': self.funcionalidad_ok,
            'seguridad_ok': self.seguridad_ok,
            'acabado_ok': self.acabado_ok,
            'observaciones': self.observaciones,
            'evaluado_por': self.evaluado_por,
            'fecha_evaluacion': self.fecha_evaluacion.isoformat() if self.fecha_evaluacion else None,
        }


class MaquinariaSerie(db.Model):
    __tablename__ = 'maquinaria_series'

    id = db.Column(db.Integer, primary_key=True)
    serie = db.Column(db.String(120), nullable=False, unique=True, index=True)
    clave_maquina = db.Column(db.String(120), nullable=False, index=True)
    anio = db.Column(db.Integer, nullable=True, index=True)
    pedido_id = db.Column(db.Integer, db.ForeignKey('maquinaria_pedidos.id'), nullable=True, index=True)
    orden_trabajo_id = db.Column(db.Integer, db.ForeignKey('maquinaria_ordenes_trabajo.id'), nullable=True, index=True)
    estado = db.Column(db.String(40), nullable=False, default='ensamble', index=True)
    notas = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    pedido = db.relationship('MaquinariaPedido', backref='series')
    orden_trabajo = db.relationship('MaquinariaOrdenTrabajo', backref='series')

    def to_dict(self):
        return {
            'id': self.id,
            'serie': self.serie,
            'clave_maquina': self.clave_maquina,
            'anio': self.anio,
            'pedido_id': self.pedido_id,
            'orden_trabajo_id': self.orden_trabajo_id,
            'estado': self.estado,
            'notas': self.notas,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }


class MaquinariaAlmacenResguardo(db.Model):
    __tablename__ = 'maquinaria_almacen_resguardos'

    id = db.Column(db.Integer, primary_key=True)
    serie_id = db.Column(db.Integer, db.ForeignKey('maquinaria_series.id'), nullable=False, index=True)
    ubicacion = db.Column(db.String(120), nullable=False)
    estatus = db.Column(db.String(40), nullable=False, default='resguardo', index=True)
    fecha_ingreso = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    fecha_salida = db.Column(db.DateTime, nullable=True, index=True)
    observaciones = db.Column(db.Text, nullable=True)

    serie_rel = db.relationship('MaquinariaSerie', backref='resguardos')

    def to_dict(self):
        return {
            'id': self.id,
            'serie_id': self.serie_id,
            'ubicacion': self.ubicacion,
            'estatus': self.estatus,
            'fecha_ingreso': self.fecha_ingreso.isoformat() if self.fecha_ingreso else None,
            'fecha_salida': self.fecha_salida.isoformat() if self.fecha_salida else None,
            'observaciones': self.observaciones,
        }
