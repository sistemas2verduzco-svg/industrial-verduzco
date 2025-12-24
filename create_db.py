from app import app, db, Usuario

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        # Crear usuario admin por defecto si no existe
        try:
            if not Usuario.query.filter_by(username='admin').first():
                admin_user = Usuario(
                    username='admin',
                    correo='admin@example.com',
                    es_admin=True,
                    activo=True
                )
                admin_user.set_password('admin123')
                db.session.add(admin_user)
                db.session.commit()
                print("✓ Usuario admin por defecto creado.")
        except Exception as e:
            db.session.rollback()
            print(f"ℹ Usuario admin ya existe o error: {e}")
        print('DB inicializada correctamente')
