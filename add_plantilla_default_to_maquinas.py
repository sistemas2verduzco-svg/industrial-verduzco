#!/usr/bin/env python
"""
Agregar columna plantilla_default a la tabla maquinas.
Ejecutar dentro del contenedor: `python add_plantilla_default_to_maquinas.py`
"""
import sys
import os
sys.path.insert(0, '.')

from app import app
from models import db
from sqlalchemy import text

SQL = '''
ALTER TABLE maquinas ADD COLUMN IF NOT EXISTS plantilla_default VARCHAR(255) DEFAULT NULL;
'''


def run():
    with app.app_context():
        conn = db.engine.connect()
        try:
            conn.execute(text(SQL))
            conn.commit()
            print('Columna plantilla_default agregada a la tabla maquinas.')
        except Exception as e:
            print('Error agregando columna plantilla_default:', e)
        finally:
            conn.close()


if __name__ == '__main__':
    run()
