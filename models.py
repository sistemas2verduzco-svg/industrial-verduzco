from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from crypto_utils import encrypt_text, decrypt_text

db = SQLAlchemy()

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
    nombre = db.Column(db.String(255), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    precio = db.Column(db.Float, nullable=False)
    cantidad = db.Column(db.Integer, default=0)
    imagen_url = db.Column(db.String(500), nullable=True)
    categoria = db.Column(db.String(100), nullable=True)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relación con ProductoProveedor
    proveedores = db.relationship('ProductoProveedor', backref='producto', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'nombre': self.nombre,
            'descripcion': self.descripcion,
            'precio': self.precio,
            'cantidad': self.cantidad,
            'imagen_url': self.imagen_url,
            'categoria': self.categoria,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None,
            'proveedores': [pp.to_dict() for pp in self.proveedores]
        }

class ProductoProveedor(db.Model):
    __tablename__ = 'producto_proveedor'
    
    id = db.Column(db.Integer, primary_key=True)
    producto_id = db.Column(db.Integer, db.ForeignKey('productos.id'), nullable=False)
    proveedor_id = db.Column(db.Integer, db.ForeignKey('proveedores.id'), nullable=False)
    precio_proveedor = db.Column(db.Float, nullable=False)
    fecha_precio = db.Column(db.Date, default=datetime.utcnow)
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
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'producto_proveedor_id': self.producto_proveedor_id,
            'precio': self.precio,
            'fecha_precio': self.fecha_precio.isoformat() if self.fecha_precio else None,
            'notas': self.notas,
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
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta.id'), nullable=True)
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
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_actualizacion': self.fecha_actualizacion.isoformat(),
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


class HojaRuta(db.Model):
    """Hojas de ruta de producción para máquinas."""
    __tablename__ = 'hojas_ruta'
    id = db.Column(db.Integer, primary_key=True)
    maquina_id = db.Column(db.Integer, db.ForeignKey('maquinas.id'), nullable=True)
    nombre = db.Column(db.String(255), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    estado = db.Column(db.String(20), default='activa')  # activa, pausada, completada

    # Campos adicionales según plantilla HOJA DE RUTA
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
    total_tiempo = db.Column(db.String(50), nullable=True)  # formato HH:MM:SS
    dias_a_laborar = db.Column(db.Float, nullable=True)
    fecha_termino = db.Column(db.DateTime, nullable=True)

    aprobada = db.Column(db.Boolean, default=False)
    rechazada = db.Column(db.Boolean, default=False)
    scrap = db.Column(db.Boolean, default=False)
    retrabajo = db.Column(db.Boolean, default=False)

    supervisor = db.Column(db.String(200), nullable=True)
    operador = db.Column(db.String(200), nullable=True)
    eficiencia = db.Column(db.Float, nullable=True)

    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relaciones
    maquina = db.relationship('Máquina', backref='hojas_ruta')
    estaciones = db.relationship('EstacionTrabajo', backref='hoja_ruta', lazy=True, cascade='all, delete-orphan')

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


class EstacionTrabajo(db.Model):
    """Estaciones o pasos dentro de una hoja de ruta, con tiempos por columna según plantilla."""
    __tablename__ = 'estaciones_trabajo'

    id = db.Column(db.Integer, primary_key=True)
    hoja_ruta_id = db.Column(db.Integer, db.ForeignKey('hojas_ruta.id'), nullable=False)
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
            'pro_c': self.pro_c,
            'centro_trabajo': self.centro_trabajo,
            'operacion': self.operacion,
            'orden': self.orden,
            't_e': self.t_e,
            't_tct': self.t_tct,
            't_tco': self.t_tco,
            't_to': self.t_to,
            'total_piezas': self.total_piezas,
            'operador': self.operador,
            'eficiencia': self.eficiencia,
            'firma_supervisor': self.firma_supervisor,
            'estado': self.estado,
            'fecha_inicio': self.fecha_inicio.isoformat() if self.fecha_inicio else None,
            'fecha_finalizacion': self.fecha_finalizacion.isoformat() if self.fecha_finalizacion else None,
            'notas': self.notas,
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
    codigo = db.Column(db.String(50), nullable=False, unique=True)
    nombre = db.Column(db.String(255), nullable=False)
    # Texto de la operación por defecto (visible en hoja)
    operacion = db.Column(db.Text, nullable=True)
    descripcion = db.Column(db.Text, nullable=True)
    centro_trabajo = db.Column(db.String(100), nullable=True)
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
