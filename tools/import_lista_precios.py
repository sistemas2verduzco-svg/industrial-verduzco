import sys
from decimal import Decimal, InvalidOperation
from openpyxl import load_workbook

from app import app
from models import db, Producto


def _norm_header(value):
    if value is None:
        return ''
    return str(value).strip().upper()


def _to_decimal(value):
    if value is None:
        return None
    if isinstance(value, (int, float, Decimal)):
        return Decimal(str(value))
    text = str(value).strip().replace(',', '')
    if not text:
        return None
    try:
        return Decimal(text)
    except InvalidOperation:
        return None


def import_lista_precios(path, sheet_name='Productos'):
    wb = load_workbook(path, data_only=True)
    if sheet_name not in wb.sheetnames:
        raise ValueError(f"Hoja no encontrada: {sheet_name}")

    ws = wb[sheet_name]
    header_row = list(ws.iter_rows(min_row=2, max_row=2, values_only=True))[0]

    header_map = {}
    for idx, value in enumerate(header_row):
        key = _norm_header(value)
        if key and key not in header_map:
            header_map[key] = idx

    clave_idx = header_map.get('CLAVE')
    precio_idx = header_map.get('PRECIO DE LISTA (1)')

    if clave_idx is None or precio_idx is None:
        raise ValueError('No se encontraron columnas CLAVE y PRECIO DE LISTA (1)')

    stats = {
        'actualizados': 0,
        'no_encontrados': 0,
        'sin_precio': 0,
        'sin_clave': 0,
    }

    with app.app_context():
        for row in ws.iter_rows(min_row=3, values_only=True):
            clave = row[clave_idx] if clave_idx < len(row) else None
            if not clave:
                stats['sin_clave'] += 1
                continue
            clave = str(clave).strip()
            if not clave:
                stats['sin_clave'] += 1
                continue

            precio = row[precio_idx] if precio_idx < len(row) else None
            precio_dec = _to_decimal(precio)
            if precio_dec is None:
                stats['sin_precio'] += 1
                continue

            producto = Producto.query.filter_by(clave=clave).first()
            if not producto:
                stats['no_encontrados'] += 1
                continue

            producto.precio = float(precio_dec)
            stats['actualizados'] += 1

        db.session.commit()

    return stats


def main():
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = 'A002 Lista de precios Master GIV.xlsx'

    stats = import_lista_precios(path)
    print('Import terminado:', stats)


if __name__ == '__main__':
    main()
