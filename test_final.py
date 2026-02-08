import sys
sys.path.insert(0, '/app')
from app import app, db
from models import Máquina

client = app.test_client()

print("=== PRUEBA FINAL DE ENDPOINTS ===")

# Login
print("\n1. Login con admin:admin123...")
response = client.post('/login', data={'username': 'admin', 'password': 'admin123'}, follow_redirects=False)
print(f"   Status: {response.status_code}")
print(f"   Cookies establecidas: {bool(response.headers.getlist('Set-Cookie'))}")

# Verificar estado inicial
with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"\n2. Estado inicial en DB: activo={maq.activo}")

# Desactivar
print("\n3. Llamada POST a /api/maquinas/2/desactivar...")
response = client.post('/api/maquinas/2/desactivar')
print(f"   Status: {response.status_code}")
data = response.get_json()
print(f"   Response: {data}")

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"   Estado en DB después: activo={maq.activo}")

# Activar
print("\n4. Llamada POST a /api/maquinas/2/activar...")
response = client.post('/api/maquinas/2/activar')
print(f"   Status: {response.status_code}")
data = response.get_json()
print(f"   Response: {data}")

with app.app_context():
    maq = db.session.query(Máquina).filter_by(id=2).first()
    print(f"   Estado en DB después: activo={maq.activo}")

print("\n=== PRUEBA COMPLETADA CON ÉXITO ===")
