import sys
sys.path.insert(0, '/app')
from app import app, db
from models import Máquina

with app.app_context():
    # Check before
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"ANTES: Máquina 2 activo={maq.activo if maq else 'NOT FOUND'}")
    
    # Call the endpoint logic directly
    if maq:
        maq.activo = False
        db.session.commit()
        print(f"DESPUÉS COMMIT: Máquina 2 activo={maq.activo}")
    
    # Verify by new query
    maq2 = db.session.query(Máquina).filter_by(id=2).first()
    print(f"VERIFICACIÓN: Máquina 2 activo={maq2.activo if maq2 else 'NOT FOUND'}")
