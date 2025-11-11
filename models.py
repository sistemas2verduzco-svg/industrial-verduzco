from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

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
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'fecha_actualizacion': self.fecha_actualizacion.isoformat(),
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
