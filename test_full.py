import sys
sys.path.insert(0, '/app')
from app import app, db
from models import Máquina

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"1. Estado inicial: activo={maq.activo}")
    
    # Activar
    maq.activo = True
    db.session.commit()
    print(f"2. Después de activar: activo={maq.activo}")
    
    # Refresco desde DB
    maq2 = db.session.query(Máquina).filter_by(id=2).first()
    print(f"3. Verificación desde DB (activado): activo={maq2.activo}")
    
    # Desactivar
    maq2.activo = False
    db.session.commit()
    print(f"4. Después de desactivar: activo={maq2.activo}")
    
    # Refresco desde DB
    maq3 = db.session.query(Máquina).filter_by(id=2).first()
    print(f"5. Verificación desde DB (desactivado): activo={maq3.activo}")
