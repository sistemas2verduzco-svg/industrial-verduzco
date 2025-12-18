import os
from cryptography.fernet import Fernet

KEY_FILE = 'encryption.key'

def get_key_bytes():
    key = os.getenv('ENCRYPTION_KEY')
    if key:
        if isinstance(key, str):
            return key.encode()
        return key
    if os.path.exists(KEY_FILE):
        with open(KEY_FILE, 'rb') as f:
            return f.read().strip()
    return None

def get_fernet():
    key = get_key_bytes()
    if not key:
        raise RuntimeError('Encryption key not found. Set ENCRYPTION_KEY or create encryption.key with generate_key.py')
    return Fernet(key)

def encrypt_text(plaintext: str) -> str:
    if plaintext is None:
        return None
    f = get_fernet()
    return f.encrypt(plaintext.encode()).decode()

def decrypt_text(token: str) -> str:
    if token is None:
        return None
    f = get_fernet()
    return f.decrypt(token.encode()).decode()
