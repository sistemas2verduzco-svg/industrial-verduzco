#!/usr/bin/env python
"""
Agregar columna tipo a la tabla maquinas.
Ejecutar dentro del contenedor: `python add_tipo_to_maquinas.py`
"""
import sys
import os
sys.path.insert(0, '.')

from app import app
from models import db
from sqlalchemy import text

SQL = '''
ALTER TABLE maquinas ADD COLUMN IF NOT EXISTS tipo VARCHAR(100) DEFAULT NULL;
'''


def run():
    with app.app_context():
        conn = db.engine.connect()
        try:
            conn.execute(text(SQL))
            conn.commit()
            print('Columna tipo agregada a la tabla maquinas.')
        except Exception as e:
            print('Error agregando columna tipo:', e)
        finally:
            conn.close()


if __name__ == '__main__':
    run()
