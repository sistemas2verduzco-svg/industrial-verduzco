#!/usr/bin/env python
"""
Script para crear las tablas de Hojas de Ruta y Estaciones de Trabajo.
Ejecutar después de tener los modelos actualizados.
"""
import sys
sys.path.insert(0, '.')

from app import app, db
from models import HojaRuta, EstacionTrabajo

def create_tables():
    with app.app_context():
        print("Creando tablas para Hojas de Ruta y Estaciones de Trabajo...")
        try:
            # Crear solo las tablas nuevas
            HojaRuta.__table__.create(db.engine, checkfirst=True)
            EstacionTrabajo.__table__.create(db.engine, checkfirst=True)
            print("✓ Tablas creadas exitosamente")
        except Exception as e:
            print(f"✗ Error al crear tablas: {e}")
            return False
        return True

if __name__ == '__main__':
    if create_tables():
        print("\nLas tablas están listas. Ahora puedes usar el módulo de Hojas de Ruta.")
        sys.exit(0)
    else:
        sys.exit(1)
