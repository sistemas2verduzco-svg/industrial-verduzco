#!/usr/bin/env python
"""
Crear tablas detalladas para Hojas de Ruta y Estaciones (v2).
Ejecutar dentro del contenedor: `python create_hojas_ruta_tables_v2.py`
"""
import sys
import os
sys.path.insert(0, '.')

from app import app
from models import db
from sqlalchemy import text

SQL = '''
DROP TABLE IF EXISTS estaciones_trabajo CASCADE;
DROP TABLE IF EXISTS hojas_ruta CASCADE;

CREATE TABLE hojas_ruta (
    id SERIAL PRIMARY KEY,
    maquina_id INTEGER NOT NULL REFERENCES maquinas(id),
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'activa',
    producto VARCHAR(255),
    calidad VARCHAR(255),
    pn VARCHAR(255),
    fecha_salida TIMESTAMP,
    cantidad_piezas INTEGER,
    orden_trabajo_hr VARCHAR(100),
    orden_trabajo_pt VARCHAR(100),
    almacen VARCHAR(100),
    no_sin_orden VARCHAR(100),
    materia_prima VARCHAR(255),
    total_tiempo VARCHAR(50),
    dias_a_laborar NUMERIC,
    fecha_termino TIMESTAMP,
    aprobada BOOLEAN DEFAULT FALSE,
    rechazada BOOLEAN DEFAULT FALSE,
    scrap BOOLEAN DEFAULT FALSE,
    retrabajo BOOLEAN DEFAULT FALSE,
    supervisor VARCHAR(200),
    operador VARCHAR(200),
    eficiencia REAL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estaciones_trabajo (
    id SERIAL PRIMARY KEY,
    hoja_ruta_id INTEGER NOT NULL REFERENCES hojas_ruta(id) ON DELETE CASCADE,
    pro_c VARCHAR(50),
    centro_trabajo VARCHAR(100),
    operacion TEXT NOT NULL,
    orden INTEGER DEFAULT 0,
    t_e VARCHAR(20),
    t_tct VARCHAR(20),
    t_tco VARCHAR(20),
    t_to VARCHAR(20),
    total_piezas INTEGER,
    operador VARCHAR(200),
    eficiencia REAL,
    firma_supervisor VARCHAR(200),
    estado VARCHAR(20) DEFAULT 'pendiente',
    fecha_inicio TIMESTAMP,
    fecha_finalizacion TIMESTAMP,
    notas TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
'''

def run():
    with app.app_context():
        conn = db.engine.connect()
        try:
            conn.execute(text(SQL))
            print('Tablas creadas o ya existían (hojas_ruta, estaciones_trabajo).')
        except Exception as e:
            print('Error creando tablas:', e)
        finally:
            conn.close()

if __name__ == '__main__':
    run()
