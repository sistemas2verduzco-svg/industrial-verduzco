import os
import re
import sys
import shutil

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from app import app
from models import db, Producto

ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.gif', '.webp'}


def _normalize_clave(text):
    if text is None:
        return ''
    value = str(text).strip().upper()
    value = value.replace(' ', '')
    return value


def _safe_filename(name):
    value = re.sub(r'[^A-Z0-9._-]+', '', name.upper())
    return value or 'imagen'


def import_imagenes(source_dir, dest_dir, only_missing=False):
    source_dir = os.path.abspath(source_dir)
    dest_dir = os.path.abspath(dest_dir)
    os.makedirs(dest_dir, exist_ok=True)

    stats = {
        'copiados': 0,
        'actualizados': 0,
        'sin_producto': 0,
        'ext_no_valida': 0,
        'omitidos': 0,
    }

    with app.app_context():
        productos = Producto.query.filter(Producto.clave != None).all()
        productos_por_clave = {p.clave.strip().upper(): p for p in productos if p.clave}

        for root, _, files in os.walk(source_dir):
            for filename in files:
                ext = os.path.splitext(filename)[1].lower()
                if ext not in ALLOWED_EXTENSIONS:
                    stats['ext_no_valida'] += 1
                    continue

                stem = os.path.splitext(filename)[0]
                clave = _normalize_clave(stem)
                if not clave:
                    stats['sin_producto'] += 1
                    continue

                producto = productos_por_clave.get(clave)
                if not producto:
                    stats['sin_producto'] += 1
                    continue

                if only_missing and producto.imagen_url:
                    stats['omitidos'] += 1
                    continue

                dest_name = _safe_filename(clave) + ext
                src_path = os.path.join(root, filename)
                dest_path = os.path.join(dest_dir, dest_name)
                shutil.copy2(src_path, dest_path)
                stats['copiados'] += 1

                producto.imagen_url = f"/uploads/productos/{dest_name}"
                stats['actualizados'] += 1

        db.session.commit()

    return stats


def main():
    source_dir = sys.argv[1] if len(sys.argv) > 1 else 'imagenes productos'
    dest_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.join('uploads', 'productos')
    only_missing = '--only-missing' in sys.argv

    stats = import_imagenes(source_dir, dest_dir, only_missing=only_missing)
    print('Import terminado:', stats)


if __name__ == '__main__':
    main()
