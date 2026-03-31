#!/usr/bin/env python
"""
Crea tablas NUEVAS para el modulo Maquinaria y Ensamble.
No modifica ni elimina tablas existentes de produccion.

Uso sugerido dentro del contenedor:
python create_maquinaria_ensamble_tables.py
"""
import sys
sys.path.insert(0, '.')

from sqlalchemy import text
from app import app
from models import db

SQL = '''
CREATE TABLE IF NOT EXISTS maquinaria_pedidos (
    id SERIAL PRIMARY KEY,
    folio_interno VARCHAR(80) NOT NULL UNIQUE,
    contpaq_document_id BIGINT,
    cliente VARCHAR(255),
    clave_maquina VARCHAR(120) NOT NULL,
    descripcion_maquina VARCHAR(255),
    cantidad INTEGER NOT NULL DEFAULT 1,
    estado VARCHAR(40) NOT NULL DEFAULT 'abierto',
    fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maquinaria_boms (
    id SERIAL PRIMARY KEY,
    clave_maquina VARCHAR(120) NOT NULL UNIQUE,
    nombre_maquina VARCHAR(255) NOT NULL,
    version VARCHAR(40),
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    notas TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maquinaria_bom_componentes (
    id SERIAL PRIMARY KEY,
    bom_id INTEGER NOT NULL REFERENCES maquinaria_boms(id) ON DELETE CASCADE,
    codigo_componente VARCHAR(120) NOT NULL,
    nombre_componente VARCHAR(255) NOT NULL,
    cantidad DOUBLE PRECISION NOT NULL DEFAULT 1,
    unidad VARCHAR(30),
    proceso_base VARCHAR(120),
    notas TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maquinaria_ordenes_trabajo (
    id SERIAL PRIMARY KEY,
    folio_ot VARCHAR(80) NOT NULL UNIQUE,
    pedido_id INTEGER REFERENCES maquinaria_pedidos(id),
    clave_maquina VARCHAR(120) NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 1,
    estado VARCHAR(40) NOT NULL DEFAULT 'planeacion',
    fecha_objetivo TIMESTAMP,
    notas TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maquinaria_calidad_registros (
    id SERIAL PRIMARY KEY,
    folio_ot VARCHAR(80) NOT NULL,
    funcionalidad_ok BOOLEAN NOT NULL DEFAULT FALSE,
    seguridad_ok BOOLEAN NOT NULL DEFAULT FALSE,
    acabado_ok BOOLEAN NOT NULL DEFAULT FALSE,
    observaciones TEXT,
    evaluado_por VARCHAR(120),
    fecha_evaluacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maquinaria_series (
    id SERIAL PRIMARY KEY,
    serie VARCHAR(120) NOT NULL UNIQUE,
    clave_maquina VARCHAR(120) NOT NULL,
    anio INTEGER,
    pedido_id INTEGER REFERENCES maquinaria_pedidos(id),
    orden_trabajo_id INTEGER REFERENCES maquinaria_ordenes_trabajo(id),
    estado VARCHAR(40) NOT NULL DEFAULT 'ensamble',
    notas TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maquinaria_almacen_resguardos (
    id SERIAL PRIMARY KEY,
    serie_id INTEGER NOT NULL REFERENCES maquinaria_series(id) ON DELETE CASCADE,
    ubicacion VARCHAR(120) NOT NULL,
    estatus VARCHAR(40) NOT NULL DEFAULT 'resguardo',
    fecha_ingreso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_salida TIMESTAMP,
    observaciones TEXT
);

CREATE INDEX IF NOT EXISTS idx_maq_pedidos_clave ON maquinaria_pedidos(clave_maquina);
CREATE INDEX IF NOT EXISTS idx_maq_ot_clave ON maquinaria_ordenes_trabajo(clave_maquina);
CREATE INDEX IF NOT EXISTS idx_maq_series_clave ON maquinaria_series(clave_maquina);
'''


def run():
    with app.app_context():
        conn = db.engine.connect()
        try:
            conn.execute(text(SQL))
            conn.commit()
            print('OK: tablas de Maquinaria y Ensamble creadas/verificadas.')
        except Exception as exc:
            print('ERROR creando tablas:', exc)
            conn.rollback()
        finally:
            conn.close()


if __name__ == '__main__':
    run()
