#!/usr/bin/env python3
"""Exporta relación claves → procesos desde la BD del MES.

Uso (desde la raíz del proyecto):
  python scripts/export_claves_procesos.py
  python scripts/export_claves_procesos.py --solo-activas
  python scripts/export_claves_procesos.py --formato xlsx --salida claves_procesos.xlsx

Genera:
  - claves_procesos_detalle.csv  (una fila por clave + proceso)
  - claves_procesos_resumen.csv  (una fila por clave, procesos concatenados)
"""
from __future__ import annotations

import argparse
import csv
import os
import sys
from datetime import datetime

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from dotenv import load_dotenv

load_dotenv()

from app import app
from models import ClaveProducto, ClaveProceso


def _text(v):
    return (v or '').strip()


def _rows_detalle(solo_activas: bool):
    q = ClaveProducto.query.order_by(ClaveProducto.clave.asc())
    if solo_activas:
        q = q.filter_by(activo=True)
    claves = q.all()

    rows = []
    for clave in claves:
        procesos = (
            ClaveProceso.query.filter_by(clave_id=clave.id)
            .order_by(ClaveProceso.orden.asc(), ClaveProceso.id.asc())
            .all()
        )
        if not procesos:
            rows.append({
                'clave': clave.clave,
                'descripcion_clave': _text(clave.nombre),
                'notas_clave': _text(clave.notas),
                'clave_activa': 'SI' if clave.activo else 'NO',
                'orden': '',
                'proceso_codigo': '',
                'proceso_nombre': '',
                'proceso_descripcion': '',
                'operacion': '',
                'centro_trabajo': '',
                't_e': '',
                't_tct': '',
                't_tco': '',
                't_to': '',
                'notas_proceso': '',
            })
            continue

        for cp in procesos:
            proc = cp.proceso
            rows.append({
                'clave': clave.clave,
                'descripcion_clave': _text(clave.nombre),
                'notas_clave': _text(clave.notas),
                'clave_activa': 'SI' if clave.activo else 'NO',
                'orden': cp.orden,
                'proceso_codigo': _text(proc.codigo) if proc else '',
                'proceso_nombre': _text(proc.nombre) if proc else '',
                'proceso_descripcion': _text(proc.descripcion) if proc else '',
                'operacion': _text(cp.operacion) or (_text(proc.operacion) if proc else ''),
                'centro_trabajo': _text(cp.centro_trabajo) or (_text(proc.centro_trabajo) if proc else ''),
                't_e': _text(cp.t_e),
                't_tct': _text(cp.t_tct),
                't_tco': _text(cp.t_tco),
                't_to': _text(cp.t_to),
                'notas_proceso': _text(cp.notas),
            })
    return rows


def _rows_resumen(detalle_rows):
    from collections import OrderedDict

    grouped = OrderedDict()
    for row in detalle_rows:
        key = row['clave']
        if key not in grouped:
            grouped[key] = {
                'clave': row['clave'],
                'descripcion_clave': row['descripcion_clave'],
                'notas_clave': row['notas_clave'],
                'clave_activa': row['clave_activa'],
                'total_procesos': 0,
                'procesos': [],
            }
        nombre = row['proceso_nombre']
        if not nombre:
            continue
        orden = row['orden']
        label = f"{orden}. {nombre}" if orden != '' else nombre
        grouped[key]['procesos'].append(label)
        grouped[key]['total_procesos'] += 1

    out = []
    for g in grouped.values():
        out.append({
            'clave': g['clave'],
            'descripcion_clave': g['descripcion_clave'],
            'notas_clave': g['notas_clave'],
            'clave_activa': g['clave_activa'],
            'total_procesos': g['total_procesos'],
            'procesos_secuencia': ' | '.join(g['procesos']),
        })
    return out


def _write_csv(path, rows, fieldnames):
    with open(path, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
        w.writeheader()
        w.writerows(rows)


def _write_xlsx(path, detalle, resumen):
    from openpyxl import Workbook

    wb = Workbook()
    ws1 = wb.active
    ws1.title = 'Detalle'
    detalle_fields = list(detalle[0].keys()) if detalle else []
    ws1.append(detalle_fields)
    for row in detalle:
        ws1.append([row.get(k, '') for k in detalle_fields])

    ws2 = wb.create_sheet('Resumen')
    resumen_fields = list(resumen[0].keys()) if resumen else []
    ws2.append(resumen_fields)
    for row in resumen:
        ws2.append([row.get(k, '') for k in resumen_fields])

    wb.save(path)


def main():
    parser = argparse.ArgumentParser(description='Exportar claves y procesos del MES')
    parser.add_argument('--solo-activas', action='store_true', help='Solo claves activas')
    parser.add_argument(
        '--formato',
        choices=('csv', 'xlsx', 'ambos'),
        default='ambos',
        help='Formato de salida (default: ambos)',
    )
    parser.add_argument(
        '--salida',
        default='',
        help='Prefijo o ruta base (default: claves_procesos_YYYYMMDD)',
    )
    args = parser.parse_args()

    stamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    base = args.salida.strip() or f'claves_procesos_{stamp}'

    with app.app_context():
        detalle = _rows_detalle(args.solo_activas)
        resumen = _rows_resumen(detalle)

    if not detalle:
        print('No hay claves en la base de datos.')
        return 1

    detalle_fields = list(detalle[0].keys())
    resumen_fields = list(resumen[0].keys()) if resumen else []

    if args.formato in ('csv', 'ambos'):
        detalle_path = f'{base}_detalle.csv' if not base.endswith('.csv') else base.replace('.csv', '_detalle.csv')
        resumen_path = f'{base}_resumen.csv' if not base.endswith('.csv') else base.replace('.csv', '_resumen.csv')
        _write_csv(detalle_path, detalle, detalle_fields)
        _write_csv(resumen_path, resumen, resumen_fields)
        print(f'CSV detalle: {detalle_path} ({len(detalle)} filas)')
        print(f'CSV resumen: {resumen_path} ({len(resumen)} claves)')

    if args.formato in ('xlsx', 'ambos'):
        xlsx_path = base if base.endswith('.xlsx') else f'{base}.xlsx'
        _write_xlsx(xlsx_path, detalle, resumen)
        print(f'Excel: {xlsx_path}')

    print('Listo.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
