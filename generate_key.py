from cryptography.fernet import Fernet

KEY_FILE = 'encryption.key'

def main():
    key = Fernet.generate_key()
    with open(KEY_FILE, 'wb') as f:
        f.write(key)
    print('Encryption key generated and saved to', KEY_FILE)
    print('You can also set ENCRYPTION_KEY env var with this value:')
    print(key.decode())

if __name__ == '__main__':
    main()
