#!/usr/bin/env python3
"""
Script para registrar ingenieros en el sistema de tickets
Uso: python registrar_ingenieros.py
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db
from models import Usuario

def registrar_ingenieros():
    """Registra los 3 ingenieros de sistemas"""
    
    with app.app_context():
        # Datos de los ingenieros
        ingenieros_data = [
            {
                'username': 'ing_carlos',
                'correo': 'carlos@company.com',
                'password': 'ing_carlos123',
                'especialidad': 'Redes y Servidores',
            },
            {
                'username': 'ing_maria',
                'correo': 'maria@company.com',
                'password': 'ing_maria123',
                'especialidad': 'Hardware e Impresoras',
            },
            {
                'username': 'ing_jorge',
                'correo': 'jorge@company.com',
                'password': 'ing_jorge123',
                'especialidad': 'Software y Bases de Datos',
            }
        ]
        
        for ing_data in ingenieros_data:
            # Verificar si usuario existe
            usuario = Usuario.query.filter_by(username=ing_data['username']).first()
            
            if not usuario:
                # Crear usuario ingeniero
                usuario = Usuario(
                    username=ing_data['username'],
                    correo=ing_data['correo'],
                    es_admin=False,
                    activo=True
                )
                usuario.set_password(ing_data['password'])
                db.session.add(usuario)
                db.session.commit()
                print(f"✓ Ingeniero '{ing_data['username']}' creado ({ing_data['especialidad']})")
                print(f"  • Usuario: {ing_data['username']}")
                print(f"  • Contraseña: {ing_data['password']}")
                print(f"  • Email: {ing_data['correo']}")
                print()
            else:
                print(f"ℹ Usuario '{ing_data['username']}' ya existe")
        
        print("\n✅ Registro de ingenieros completado")
        print("\n📋 Credenciales de acceso:")
        print("URL: http://localhost:5000/login")
        for ing_data in ingenieros_data:
            print(f"  • {ing_data['username']} / {ing_data['password']}")

if __name__ == '__main__':
    registrar_ingenieros()
