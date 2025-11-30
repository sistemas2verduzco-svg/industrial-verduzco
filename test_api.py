"""
Tests de API para el Catálogo Web
Ejecutar con: pytest test_api.py -v
"""
import pytest
import json
from app import app, db, Usuario
from models import Producto, Proveedor


@pytest.fixture
def client():
    """Configurar cliente de prueba"""
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.app_context():
        db.create_all()
        # app.py ya crea el usuario admin en el app_context(), no duplicar aquí

    with app.test_client() as client:
        yield client

    with app.app_context():
        db.session.remove()
        db.drop_all()
class TestAuthentication:
    """Tests de Autenticación"""
    
    def test_login_page_get(self, client):
        """✓ GET /login debe retornar 200"""
        response = client.get('/login')
        assert response.status_code == 200
        assert b'Admin' in response.data
    
    def test_login_success(self, client):
        """✓ POST /login con credenciales correctas"""
        response = client.post('/login', data={
            'username': 'admin',
            'password': 'admin123'
        }, follow_redirects=True)
        assert response.status_code == 200
        # Verifica que fue redirigido al admin
        assert b'Admin' in response.data or response.request.path == '/admin'
    
    def test_login_invalid_credentials(self, client):
        """✓ POST /login con credenciales incorrectas"""
        response = client.post('/login', data={
            'username': 'admin',
            'password': 'wrongpassword'
        })
        assert response.status_code == 401
        assert b'Credenciales inv' in response.data or b'inv' in response.data
    
    def test_login_user_not_found(self, client):
        """✓ POST /login con usuario no existente"""
        response = client.post('/login', data={
            'username': 'noexiste',
            'password': 'anypassword'
        })
        assert response.status_code == 401
    
    def test_logout(self, client):
        """✓ GET /logout debe limpiar sesión"""
        # Primero loguear
        client.post('/login', data={
            'username': 'admin',
            'password': 'admin123'
        })
        # Luego logout
        response = client.get('/logout', follow_redirects=True)
        assert response.status_code == 200


class TestPublicEndpoints:
    """Tests de Endpoints Públicos"""
    
    def test_catalogo_consulta_public(self, client):
        """✓ GET /catalogo_consulta sin login"""
        response = client.get('/catalogo_consulta')
        assert response.status_code == 200
    
    def test_public_productos_search(self, client):
        """✓ GET /public/productos/buscar sin autenticación"""
        response = client.get('/public/productos/buscar?q=test')
        assert response.status_code == 200
        assert response.content_type == 'application/json'


class TestProtectedEndpoints:
    """Tests de Endpoints Protegidos"""
    
    def test_index_requires_login(self, client):
        """✓ GET / sin login redirige a /login"""
        response = client.get('/')
        assert response.status_code == 302  # Redirect
        assert '/login' in response.location
    
    def test_admin_requires_login(self, client):
        """✓ GET /admin sin login redirige a /login"""
        response = client.get('/admin')
        assert response.status_code == 302
        assert '/login' in response.location
    
    def test_proveedores_requires_login(self, client):
        """✓ GET /proveedores sin login redirige a /login"""
        response = client.get('/proveedores')
        assert response.status_code == 302
        assert '/login' in response.location
    
    def test_index_with_login(self, client):
        """✓ GET / con login funciona"""
        # Loguear
        client.post('/login', data={
            'username': 'admin',
            'password': 'admin123'
        })
        # Acceder a página protegida
        response = client.get('/')
        assert response.status_code == 200
    
    def test_admin_with_login(self, client):
        """✓ GET /admin con login funciona"""
        client.post('/login', data={
            'username': 'admin',
            'password': 'admin123'
        })
        response = client.get('/admin')
        assert response.status_code == 200


class TestAPIEndpoints:
    """Tests de APIs JSON"""
    
    def test_api_productos_sin_auth(self, client):
        """✓ GET /api/productos sin autenticación falla"""
        response = client.get('/api/productos')
        assert response.status_code == 401
    
    def test_api_productos_con_auth(self, client):
        """✓ GET /api/productos con autenticación"""
        # Loguear
        client.post('/login', data={
            'username': 'admin',
            'password': 'admin123'
        })
        # Acceder a API
        response = client.get('/api/productos')
        assert response.status_code == 200
        assert response.content_type == 'application/json'
    
    def test_api_proveedores_sin_auth(self, client):
        """✓ GET /api/proveedores sin autenticación falla"""
        response = client.get('/api/proveedores')
        assert response.status_code == 401
    
    def test_api_proveedores_con_auth(self, client):
        """✓ GET /api/proveedores con autenticación"""
        client.post('/login', data={
            'username': 'admin',
            'password': 'admin123'
        })
        response = client.get('/api/proveedores')
        assert response.status_code == 200
        assert response.content_type == 'application/json'
    
    def test_public_buscar_productos(self, client):
        """✓ GET /public/productos/buscar sin autenticación"""
        response = client.get('/public/productos/buscar?q=')
        assert response.status_code == 200
        assert response.content_type == 'application/json'


class TestErrorHandling:
    """Tests de Manejo de Errores"""
    
    def test_404_not_found(self, client):
        """✓ GET a ruta no existente retorna 404"""
        response = client.get('/ruta-que-no-existe')
        assert response.status_code == 404
    
    def test_favicon_404(self, client):
        """✓ GET /favicon.ico es normal que sea 404"""
        response = client.get('/favicon.ico')
        assert response.status_code == 404
    
    def test_rate_limiting_excessive_attempts(self, client):
        """✓ Rate limiting después de 5 intentos fallidos"""
        for i in range(6):
            response = client.post('/login', data={
                'username': 'admin',
                'password': 'wrong'
            })
        # El 6to intento debe ser bloqueado (429)
        assert response.status_code == 429


if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
