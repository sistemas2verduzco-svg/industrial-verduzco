#!/usr/bin/env python3
"""
Script para agregar nuevas máquinas a la aplicación.
Uso: python add_machine.py <comando> [args]
Ejemplo: python add_machine.py add "Fresadora CNC" "Máquina de fresado" "cnc" "Plantilla_CNC"
"""

import sys
from dotenv import load_dotenv
from models import db, Máquina
from app import app

load_dotenv()

def agregar_maquina(nombre, descripcion=None, tipo=None, plantilla_default=None):
    """Agrega una nueva máquina a la BD"""
    with app.app_context():
        # Verificar si la máquina ya existe
        if Máquina.query.filter_by(nombre=nombre).first():
            print(f"❌ Error: La máquina '{nombre}' ya existe.")
            return False
        
        # Crear nueva máquina
        nueva_maquina = Máquina(
            nombre=nombre,
            descripcion=descripcion,
            tipo=tipo,
            plantilla_default=plantilla_default
        )
        
        try:
            db.session.add(nueva_maquina)
            db.session.commit()
            print(f"✅ Máquina '{nombre}' creada exitosamente.")
            print(f"   - ID: {nueva_maquina.id}")
            print(f"   - Tipo: {tipo or 'N/A'}")
            print(f"   - Plantilla: {plantilla_default or 'N/A'}")
            print(f"   - Descripción: {descripcion or 'N/A'}")
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Error al crear máquina: {e}")
            return False

def listar_maquinas():
    """Lista todas las máquinas"""
    with app.app_context():
        maquinas = Máquina.query.all()
        if not maquinas:
            print("No hay máquinas registradas.")
            return
        
        print("\n🔧 Máquinas registradas:")
        print("-" * 80)
        print(f"{'ID':3} | {'Nombre':25} | {'Tipo':15} | {'Plantilla':20}")
        print("-" * 80)
        for m in maquinas:
            print(f"{m.id:3} | {m.nombre:25} | {m.tipo or 'N/A':15} | {m.plantilla_default or 'N/A':20}")
        print("-" * 80)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: python add_machine.py <comando> [args]")
        print("\nComandos:")
        print("  add <nombre> [descripcion] [tipo] [plantilla]  - Agregar máquina")
        print("    Ejemplo: python add_machine.py add 'Fresadora CNC' 'Máquina de fresado' cnc 'Plantilla_CNC'")
        print("  list                                            - Listar máquinas")
        sys.exit(1)
    
    comando = sys.argv[1]
    
    if comando == 'add':
        if len(sys.argv) < 3:
            print("❌ Error: Falta el nombre de la máquina")
            print("Uso: python add_machine.py add <nombre> [descripcion] [tipo] [plantilla]")
            sys.exit(1)
        
        nombre = sys.argv[2]
        descripcion = sys.argv[3] if len(sys.argv) > 3 else None
        tipo = sys.argv[4] if len(sys.argv) > 4 else None
        plantilla_default = sys.argv[5] if len(sys.argv) > 5 else None
        
        agregar_maquina(nombre, descripcion, tipo, plantilla_default)
    
    elif comando == 'list':
        listar_maquinas()
    
    else:
        print(f"❌ Comando desconocido: {comando}")
        sys.exit(1)
