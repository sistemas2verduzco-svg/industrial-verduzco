#!/usr/bin/env python3
"""Script to delete all users except 'admin'. Run from project root: python delete_nonadmin_users.py
"""
from app import app
from models import db, Usuario

with app.app_context():
    usuarios = Usuario.query.filter(Usuario.username != 'admin').all()
    count = 0
    for u in usuarios:
        print(f"Eliminando usuario: {u.username} (id={u.id})")
        db.session.delete(u)
        count += 1
    db.session.commit()
    print(f"Operación completada. Usuarios eliminados: {count}")
