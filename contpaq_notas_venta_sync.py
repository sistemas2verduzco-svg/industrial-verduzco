#!/usr/bin/env python3

import json
import logging
import os
import sys
from datetime import datetime

import requests
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)


def get_env(name, default=None, required=False):
    value = os.getenv(name, default)
    if isinstance(value, str):
        value = value.strip()
    if required and not value:
        raise RuntimeError(f'Falta variable de entorno {name}')
    return value


def _to_float(value):
    if value is None:
        return 0.0
    try:
        return float(str(value).replace(',', '').strip())
    except Exception:
        return 0.0


def _contpaq_connection():
    try:
        import pyodbc
    except Exception as exc:
        raise RuntimeError('pyodbc no esta instalado. Instala pyodbc en el entorno') from exc

    host = get_env('CONTPAQ_SQLSERVER_HOST', required=True)
    port = get_env('CONTPAQ_SQLSERVER_PORT', '')
    database = get_env('CONTPAQ_SQLSERVER_DATABASE', required=True)
    user = get_env('CONTPAQ_SQLSERVER_USER', required=True)
    password = get_env('CONTPAQ_SQLSERVER_PASSWORD', required=True)
    driver = get_env('CONTPAQ_SQLSERVER_DRIVER', 'ODBC Driver 17 for SQL Server')
    trust_cert = get_env('CONTPAQ_SQLSERVER_TRUST_CERT', 'yes').lower() in ('1', 'true', 'yes', 'on')
    trusted_connection = get_env('CONTPAQ_SQLSERVER_TRUSTED_CONNECTION', '0').lower() in ('1', 'true', 'yes', 'on')

    server = host if not port else f'{host},{port}'
    parts = [
        f'DRIVER={{{driver}}}',
        f'SERVER={server}',
        f'DATABASE={database}',
        f'TrustServerCertificate={"yes" if trust_cert else "no"}',
    ]

    if trusted_connection:
        parts.append('Trusted_Connection=yes')
    else:
        parts.append(f'UID={user}')
        parts.append(f'PWD={password}')

    conn_str = ';'.join(parts)
    return pyodbc.connect(conn_str, timeout=30)


def _fetch_rows(query, params=()):
    conn = _contpaq_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(query, params)
        columns = [column[0] for column in cursor.description]
        rows = []
        for item in cursor.fetchall():
            rows.append(dict(zip(columns, item)))
        return rows
    finally:
        try:
            conn.close()
        except Exception:
            pass


CONTPAQ_PEDIDOS_QUERY = """
SELECT
    d.DocumentID,
    ISNULL(d.FolioPrefix, '') + ISNULL(d.Folio, '') AS DocFolio,
    d.Title,
    d.DateDocument,
    be.OfficialName AS BusinessEntityName,
    CASE WHEN d.CancelledOn IS NULL THEN d.SubTotal ELSE 0 END AS SubTotal,
    CASE WHEN d.CancelledOn IS NULL THEN d.Total ELSE 0 END AS Total
FROM dbo.docDocument d
LEFT JOIN dbo.vwLBSBusinessEntityList be ON d.BusinessEntityID = be.BusinessEntityID
WHERE d.ModuleID = 967
  AND d.DateDocument >= ?
  AND d.DeletedOn IS NULL
  AND d.CancelledOn IS NULL
"""

CONTPAQ_REMISIONES_QUERY = """
SELECT
    d.DocumentID,
    ISNULL(d.FolioPrefix, '') + ISNULL(d.Folio, '') AS DocFolio,
    be.OfficialName AS BusinessEntityName,
    COALESCE(depotDoc.DepotName, dep.DepotName, '') AS Sucursal,
    d.DateDocument,
    d.SourceDocumentID
FROM dbo.docDocument d
LEFT JOIN dbo.vwLBSBusinessEntityList be ON d.BusinessEntityID = be.BusinessEntityID
LEFT JOIN dbo.docDocumentExtra dxe ON d.DocumentID = dxe.DocumentID
LEFT JOIN dbo.orgDepot depotDoc ON dxe.BusinessEntityDepotID = depotDoc.DepotID
LEFT JOIN dbo.orgDepot dep ON d.DepotID = dep.DepotID
WHERE d.ModuleID = 157
  AND d.DateDocument >= ?
  AND d.DeletedOn IS NULL
  AND d.CancelledOn IS NULL
"""

CONTPAQ_NOTAS_VENTA_QUERY = """
SELECT
    d.DocumentID,
    ISNULL(d.FolioPrefix, '') + ISNULL(d.Folio, '') AS DocFolio,
    be.OfficialName AS BusinessEntityName,
    COALESCE(depotDoc.DepotName, dep.DepotName, '') AS Sucursal,
    d.DateDocument,
    d.SourceDocumentID,
    d.DestinationDocumentID,
    CASE WHEN d.CancelledOn IS NULL THEN d.SubTotal ELSE 0 END AS SubTotal,
    CASE WHEN d.CancelledOn IS NULL THEN d.Total ELSE 0 END AS Total,
    CASE WHEN ISNULL(inv.TotalPaid, 0) > 0 THEN inv.TotalPaid ELSE COALESCE(d.TotalPaid, 0) END AS TotalInvoicePaid,
    COALESCE(d.Total, 0) - CASE WHEN ISNULL(inv.TotalPaid, 0) > 0 THEN inv.TotalPaid ELSE COALESCE(d.TotalPaid, 0) END AS TotalInvoiceBalance
FROM dbo.docDocument d
LEFT JOIN dbo.vwLBSBusinessEntityList be ON d.BusinessEntityID = be.BusinessEntityID
LEFT JOIN dbo.docDocumentExtra dxe ON d.DocumentID = dxe.DocumentID
LEFT JOIN dbo.orgDepot depotDoc ON dxe.BusinessEntityDepotID = depotDoc.DepotID
LEFT JOIN dbo.orgDepot dep ON d.DepotID = dep.DepotID
LEFT JOIN dbo.vwLBSDocCustomerSalesTotalInvoiced inv ON d.DocumentID = inv.DocumentID
WHERE d.ModuleID = 158
  AND d.DateDocument >= ?
  AND d.DeletedOn IS NULL
  AND d.CancelledOn IS NULL
"""


def build_payload(start_date):
    pedidos = _fetch_rows(CONTPAQ_PEDIDOS_QUERY, (start_date,))
    pedido_ids = {int(p.get('DocumentID') or 0) for p in pedidos if p.get('DocumentID')}

    remisiones = [
        r for r in _fetch_rows(CONTPAQ_REMISIONES_QUERY, (start_date,))
        if int(r.get('SourceDocumentID') or 0) in pedido_ids
    ]

    notas_venta = []
    for row in _fetch_rows(CONTPAQ_NOTAS_VENTA_QUERY, (start_date,)):
        source_id = int(row.get('SourceDocumentID') or 0)
        destination_id = int(row.get('DestinationDocumentID') or 0)
        if source_id in pedido_ids or destination_id in pedido_ids:
            notas_venta.append(row)

    return {
        'pedidos': pedidos,
        'remisiones': remisiones,
        'notas_venta': notas_venta,
    }


def save_payload(payload, path):
    try:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(payload, f, ensure_ascii=False, indent=2, default=str)
        logger.info(f'Payload guardado en {path}')
    except Exception as exc:
        logger.warning(f'No se pudo guardar payload en {path}: {exc}')


def push_payload(payload):
    url = get_env('CONTPAQ_CLOUD_PUSH_URL')
    api_key = get_env('SYNC_API_KEY')
    if not url or not api_key:
        raise RuntimeError('Faltan CONTPAQ_CLOUD_PUSH_URL o SYNC_API_KEY para enviar el payload')

    headers = {
        'Content-Type': 'application/json',
        'X-API-KEY': api_key,
    }
    response = requests.post(url, json=payload, headers=headers, timeout=300)
    try:
        response.raise_for_status()
    except requests.RequestException as exc:
        raise RuntimeError(f'Error al enviar payload: {exc} ({response.text})') from exc
    return response.json()


def main():
    start_date = get_env('CONTPAQ_START_DATE', '2026-01-01')
    output_path = get_env('CONTPAQ_OUTPUT_JSON_PATH', 'contpaq_notas_venta_payload.json')
    payload = build_payload(start_date)

    logger.info('Pedidos encontrados: %s', len(payload['pedidos']))
    logger.info('Remisiones relacionadas encontradas: %s', len(payload['remisiones']))
    logger.info('Notas de venta relacionadas encontradas: %s', len(payload['notas_venta']))

    save_payload(payload, output_path)

    if get_env('CONTPAQ_CLOUD_PUSH_URL'):
        result = push_payload(payload)
        logger.info('Push completado: %s', result)
    else:
        logger.info('No se configuró CONTPAQ_CLOUD_PUSH_URL; solo se generó el archivo JSON.')


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        logger.error(str(exc))
        sys.exit(1)
