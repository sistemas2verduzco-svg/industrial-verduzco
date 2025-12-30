#!/usr/bin/env python
"""
Crear tabla para plantillas de estaciones.
Ejecutar dentro del contenedor: `python create_plantillas_estaciones.py`
"""
import sys
import os
sys.path.insert(0, '.')

from app import app
from models import db
from sqlalchemy import text

SQL = '''
CREATE TABLE IF NOT EXISTS plantillas_estaciones (
    id SERIAL PRIMARY KEY,
    plantilla_nombre VARCHAR(255),
    maquina_tipo VARCHAR(100),
    pro_c VARCHAR(50),
    centro_trabajo VARCHAR(100),
    operacion TEXT NOT NULL,
    orden INTEGER DEFAULT 0,
    t_e VARCHAR(20),
    t_tct VARCHAR(20),
    t_tco VARCHAR(20),
    t_to VARCHAR(20),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
'''


def run():
    with app.app_context():
        conn = db.engine.connect()
        try:
            conn.execute(text(SQL))
            conn.commit()
            print('Tabla plantillas_estaciones creada o ya existía.')
        except Exception as e:
            print('Error creando tabla plantillas_estaciones:', e)
        finally:
            conn.close()


if __name__ == '__main__':
    run()
