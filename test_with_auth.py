import sys
sys.path.insert(0, '/app')
from app import app, db
from models import Máquina

client = app.test_client()

print("=== PRUEBA CON AUTENTICACIÓN ===")

# Login primero
print("\n1. Intento de login...")
response = client.post('/login', data={'username': 'admin', 'password': 'admin'}, follow_redirects=False)
print(f"   Status: {response.status_code}")

# Desactivar
print("\n2. Llamada a /api/maquinas/2/desactivar...")
response = client.post('/api/maquinas/2/desactivar')
print(f"   Status: {response.status_code}")
data = response.get_json()
print(f"   Response: {data}")

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"   Estado en DB: activo={maq.activo}")

# Activar
print("\n3. Llamada a /api/maquinas/2/activar...")
response = client.post('/api/maquinas/2/activar')
print(f"   Status: {response.status_code}")
data = response.get_json()
print(f"   Response: {data}")

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"   Estado en DB: activo={maq.activo}")

print("\n=== PRUEBA COMPLETADA ===")
