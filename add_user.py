#!/usr/bin/env python3
"""
Script para agregar nuevos usuarios a la aplicación.
Uso: python add_user.py <username> <password> [correo] [es_admin]
Ejemplo: python add_user.py juan micontraseña juan@example.com True
"""

import sys
import os
from dotenv import load_dotenv
from models import db, Usuario
from app import app

load_dotenv()

def agregar_usuario(username, password, correo=None, es_admin=False):
    """Agrega un nuevo usuario a la BD"""
    with app.app_context():
        # Verificar si el usuario ya existe
        if Usuario.query.filter_by(username=username).first():
            print(f"❌ Error: El usuario '{username}' ya existe.")
            return False
        
        # Crear nuevo usuario
        nuevo_usuario = Usuario(
            username=username,
            correo=correo,
            es_admin=es_admin,
            activo=True
        )
        nuevo_usuario.set_password(password)
        
        try:
            db.session.add(nuevo_usuario)
            db.session.commit()
            print(f"✅ Usuario '{username}' creado exitosamente.")
            print(f"   - Admin: {es_admin}")
            print(f"   - Correo: {correo or 'N/A'}")
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Error al crear usuario: {e}")
            return False

def listar_usuarios():
    """Lista todos los usuarios"""
    with app.app_context():
        usuarios = Usuario.query.all()
        if not usuarios:
            print("No hay usuarios registrados.")
            return
        
        print("\n📋 Usuarios registrados:")
        print("-" * 60)
        for u in usuarios:
            estado = "✅ Activo" if u.activo else "❌ Inactivo"
            admin_badge = "👑 ADMIN" if u.es_admin else "👤 User"
            print(f"  {u.username:20} | {admin_badge:10} | {estado:10} | {u.correo or 'N/A'}")
        print("-" * 60)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: python add_user.py <comando> [args]")
        print("\nComandos:")
        print("  add <username> <password> [correo] [True/False]  - Agregar usuario")
        print("    Ejemplo: python add_user.py add juan mipass juan@example.com True")
        print("  list                                             - Listar usuarios")
        print("  delete <username>                                - Eliminar usuario")
        sys.exit(1)
    
    comando = sys.argv[1]
    
    if comando == 'add':
        if len(sys.argv) < 4:
            print("❌ Error: Faltan argumentos para 'add'")
            print("Uso: python add_user.py add <username> <password> [correo] [True/False]")
            sys.exit(1)
        
        username = sys.argv[2]
        password = sys.argv[3]
        correo = sys.argv[4] if len(sys.argv) > 4 else None
        es_admin = sys.argv[5].lower() == 'true' if len(sys.argv) > 5 else False
        
        agregar_usuario(username, password, correo, es_admin)
    
    elif comando == 'list':
        listar_usuarios()
    
    elif comando == 'delete':
        if len(sys.argv) < 3:
            print("❌ Error: Falta el username")
            print("Uso: python add_user.py delete <username>")
            sys.exit(1)
        
        username = sys.argv[2]
        with app.app_context():
            usuario = Usuario.query.filter_by(username=username).first()
            if not usuario:
                print(f"❌ Usuario '{username}' no encontrado.")
                sys.exit(1)
            
            try:
                db.session.delete(usuario)
                db.session.commit()
                print(f"✅ Usuario '{username}' eliminado.")
            except Exception as e:
                db.session.rollback()
                print(f"❌ Error al eliminar usuario: {e}")
    
    else:
        print(f"❌ Comando desconocido: {comando}")
        sys.exit(1)
