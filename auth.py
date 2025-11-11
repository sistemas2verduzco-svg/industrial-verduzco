"""
Módulo de autenticación y utilidades de seguridad
"""
from werkzeug.security import generate_password_hash, check_password_hash
import os

class AuthManager:
    """Gestor de autenticación para el panel admin"""
    
    def __init__(self):
        # Credenciales por defecto (CAMBIAR EN PRODUCCIÓN)
        self.admin_username = os.getenv('ADMIN_USER', 'admin')
        self.admin_password_hash = generate_password_hash(
            os.getenv('ADMIN_PASSWORD', 'admin123')
        )
    
    def verify_credentials(self, username, password):
        """Verifica si las credenciales son correctas"""
        return (
            username == self.admin_username and 
            check_password_hash(self.admin_password_hash, password)
        )
    
    @staticmethod
    def generate_hash(password):
        """Genera hash seguro de contraseña"""
        return generate_password_hash(password)
