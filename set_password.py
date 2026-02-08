import sys
sys.path.insert(0, '/app')
from app import app, db
from models import Usuario

with app.app_context():
    admin = db.session.query(Usuario).filter_by(username='admin').first()
    if admin:
        admin.set_password('admin123')
        db.session.commit()
        print("Contraseña de admin actualizada a 'admin123'")
    else:
        print("Usuario admin no encontrado")
