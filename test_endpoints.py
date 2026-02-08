import sys, json, requests
sys.path.insert(0, '/app')
from app import app, db
from models import Máquina

# Prueba directa de endpoints
print("=== PRUEBA DE ENDPOINTS ===")
with app.app_context():
    # Ver estado inicial
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"Estado inicial DB: activo={maq.activo}")
    
# Usar test client
client = app.test_client()

# Desactivar
print("\n1. Llamada a /api/maquinas/2/desactivar...")
response = client.post('/api/maquinas/2/desactivar')
print(f"   Status: {response.status_code}")
print(f"   Response: {response.get_json()}")

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"   Estado en DB: activo={maq.activo}")

# Activar
print("\n2. Llamada a /api/maquinas/2/activar...")
response = client.post('/api/maquinas/2/activar')
print(f"   Status: {response.status_code}")
print(f"   Response: {response.get_json()}")

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"   Estado en DB: activo={maq.activo}")

print("\n=== PRUEBA COMPLETADA ===")
