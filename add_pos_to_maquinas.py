#!/usr/bin/env python
"""
Agregar columnas pos_x y pos_y a la tabla maquinas.
Ejecutar dentro del contenedor: `python add_pos_to_maquinas.py`
"""
import sys
import os
sys.path.insert(0, '.')

from app import app
from models import db
from sqlalchemy import text

SQL = '''
ALTER TABLE maquinas ADD COLUMN IF NOT EXISTS pos_x INTEGER;
ALTER TABLE maquinas ADD COLUMN IF NOT EXISTS pos_y INTEGER;
'''


def run():
    with app.app_context():
        conn = db.engine.connect()
        try:
            conn.execute(text(SQL))
            conn.commit()
            print('Columnas pos_x y pos_y agregadas a la tabla maquinas.')
        except Exception as e:
            print('Error agregando columnas pos_x/pos_y:', e)
        finally:
            conn.close()


if __name__ == '__main__':
    run()
