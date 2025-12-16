#!/usr/bin/env python3
"""CLI script to create default roles and permissions and assign them to users.
Run with: python assign_permissions.py
"""
from models import db, Role, Permission, Usuario
from app import app

with app.app_context():
    # Create permissions
    perms = [
        ('tickets', 'view', 'Ver tickets'),
        ('tickets', 'edit', 'Editar tickets'),
        ('tickets', 'export', 'Exportar tickets a Excel'),
        ('catalog', 'view', 'Ver catálogo'),
        ('catalog', 'edit', 'Editar catálogo'),
    ]
    perm_objs = []
    for module, action, desc in perms:
        p = Permission.query.filter_by(module=module, action=action).first()
        if not p:
            p = Permission(module=module, action=action, descripcion=desc)
            db.session.add(p)
            print(f"Creando permiso: {module}:{action}")
        else:
            print(f"Permiso ya existe: {module}:{action}")
        perm_objs.append(p)

    # Create roles
    admin_role = Role.query.filter_by(name='admin').first()
    if not admin_role:
        admin_role = Role(name='admin', descripcion='Administrador completo')
        db.session.add(admin_role)
        print('Creando role admin')
    support_role = Role.query.filter_by(name='support').first()
    if not support_role:
        support_role = Role(name='support', descripcion='Ingeniero de soporte')
        db.session.add(support_role)
        print('Creando role support')

    db.session.commit()

    # Attach permissions to roles
    # admin gets everything
    admin_role.permissions = Permission.query.all()
    # support gets tickets view/edit/export
    support_role.permissions = [Permission.query.filter_by(module='tickets', action='view').first(),
                                Permission.query.filter_by(module='tickets', action='edit').first(),
                                Permission.query.filter_by(module='tickets', action='export').first()]

    db.session.commit()

    # Assign support role to known engineer users (if exist)
    engineers = ['ing_carlos', 'ing_maria', 'ing_jorge']
    for username in engineers:
        u = Usuario.query.filter_by(username=username).first()
        if u:
            u.role = support_role
            print(f'Asignando role support a {username}')
        else:
            print(f'Usuario {username} no encontrado; saltando')

    db.session.commit()
    print('Operación completada.')
