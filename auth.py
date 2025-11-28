"""
Módulo de autenticación y utilidades de seguridad
"""
from werkzeug.security import generate_password_hash, check_password_hash
import os

class AuthManager(object):
    """Gestor de autenticación para el panel admin"""

    def __init__(self, db=None):
        """
        Inicializa el gestor de autenticación.
        Si db es None, usa credenciales hardcodeadas (fallback).
        Si db es proporcionado, usa la tabla de usuarios.
        """
        self.db = db
        self.admin_username = os.getenv('ADMIN_USER', 'admin')
        self.admin_password_hash = generate_password_hash(
            os.getenv('ADMIN_PASSWORD', 'admin123')
        )

    def verify_credentials(self, username, password):
        """Verifica si las credenciales son correctas"""
        # Si la BD está disponible, usar tabla de usuarios
        if self.db:
            try:
                from models import Usuario
                usuario = Usuario.query.filter_by(username=username, activo=True).first()
                if usuario and usuario.check_password(password):
                    return True
                return False
            except Exception as e:
                print(f"Error verificando en BD: {e}")
                # Si hay error en BD, no caer a fallback - retornar False
                return False
        
        # Fallback: credenciales hardcodeadas (para compatibilidad)
        return (
            username == self.admin_username and
            check_password_hash(self.admin_password_hash, password)
        )

    @staticmethod
    def generate_hash(password):
        """Genera hash seguro de contraseña"""
        return generate_password_hash(password)
