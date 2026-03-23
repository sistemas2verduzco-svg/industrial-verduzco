#!/usr/bin/env python3
"""CLI script to create default roles and permissions and assign them to users.
Run with: python assign_permissions.py
"""
from models import db, Role, Permission, Usuario
from app import app

with app.app_context():
    # Definir módulos y acciones estándar
    modules = [
        ('users', 'Usuarios'),
        ('roles', 'Roles'),
        ('dashboard', 'Dashboard'),
        ('reports', 'Reportes'),
        ('settings', 'Configuraciones'),
        ('notifications', 'Notificaciones'),
        ('tickets', 'Tickets'),
        ('catalog', 'Catálogo'),
        ('products', 'Productos'),
        ('suppliers', 'Proveedores'),
        ('clients', 'Clientes'),
        ('orders', 'Órdenes'),
        ('inventory', 'Inventario'),
        ('purchases', 'Compras'),
        ('sales', 'Ventas'),
        ('logs', 'Bitácora'),
        ('profile', 'Perfil'),
        ('plantillas', 'Plantillas'),
        ('maquinas', 'Máquinas'),
        ('hojas_ruta', 'Hojas de Ruta'),
        ('almacen', 'Almacén'),
        ('facturacion', 'Facturación'),
        ('historial', 'Historial'),
    ]
    actions = [
        ('view', 'Ver'),
        ('create', 'Crear'),
        ('update', 'Editar'),
        ('delete', 'Eliminar'),
    ]
    perms = []
    for module, module_desc in modules:
        for action, action_desc in actions:
            desc = f"{action_desc} {module_desc}"
            perms.append((module, action, desc))

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


    # Crear roles
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
    viewer_role = Role.query.filter_by(name='viewer').first()
    if not viewer_role:
        viewer_role = Role(name='viewer', descripcion='Solo lectura')
        db.session.add(viewer_role)
        print('Creando role viewer')

    db.session.commit()

    # Asignar permisos a roles
    # admin: todos los permisos
    admin_role.permissions = Permission.query.all()
    # support: solo tickets y reportes (ver, crear, editar)
    support_perms = []
    for module in ['tickets', 'reports']:
        for action in ['view', 'create', 'update']:
            p = Permission.query.filter_by(module=module, action=action).first()
            if p:
                support_perms.append(p)
    support_role.permissions = support_perms
    # viewer: solo ver todos los módulos
    viewer_perms = [Permission.query.filter_by(module=module, action='view').first() for module, _ in modules]
    viewer_role.permissions = [p for p in viewer_perms if p]

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
