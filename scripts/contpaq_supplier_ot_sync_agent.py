import json
import math
import os
from datetime import date, datetime, timedelta

import pyodbc
import requests


CONTPAQ_SUPPLIER_OT_QUERY = """
SELECT
    d.DocumentID,
    ISNULL(d.FolioPrefix, '') + ISNULL(d.Folio, '') AS DocFolio,
    be.OfficialName AS BusinessEntityName,
    COALESCE(depotDoc.DepotName, dep.DepotName, '') AS DepotName,
    d.DateDocument,
    d.DateDocDelivery,
    d.Title,
    d.Comments
FROM dbo.docDocument d
LEFT JOIN dbo.vwLBSBusinessEntityList be ON d.BusinessEntityID = be.BusinessEntityID
LEFT JOIN dbo.docDocumentExtra dxe ON d.DocumentID = dxe.DocumentID
LEFT JOIN dbo.orgDepot depotDoc ON dxe.BusinessEntityDepotID = depotDoc.DepotID
LEFT JOIN dbo.orgDepot dep ON d.DepotID = dep.DepotID
WHERE d.ModuleID = 183
  AND d.DateDocument >= ?
  AND d.DateDocument < ?
  AND (ISNULL(d.FolioPrefix, '') + ISNULL(d.Folio, '')) LIKE 'OT%'
"""


CONTPAQ_SUPPLIER_OT_DETALLE_QUERY = """
SELECT
    p.DocumentID,
    p.DocFolio,
    p.BusinessEntityName,
    p.DepotName,
    p.DateDocument,
    p.Title,
    d.ProductID,
    d.ProductKey,
    d.ProductName,
    d.QtyOrdered,
    d.QtyDelivered,
    d.QtyToBeDelivered
FROM dbo.vwLBSDocSupplierPOAllModules p
INNER JOIN dbo.vwLBSProductsToDeliver d ON p.DocumentID = d.DocumentID
WHERE d.QtyToBeDelivered > 0
  AND p.ModuleID = 183
  AND p.DateDocument >= ?
  AND p.DateDocument < ?
  AND p.DocFolio LIKE 'OT%'
"""


def load_env_file():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(script_dir, 'contpaq_supplier_ot_sync_agent.env')
    if not os.path.exists(env_path):
        env_path = os.path.join(script_dir, '.env')
    if not os.path.exists(env_path):
        return

    with open(env_path, 'r', encoding='utf-8') as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue
            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key and key not in os.environ:
                os.environ[key] = value


def connect_sqlserver():
    host = os.getenv('CONTPAQ_SQLSERVER_HOST', '').strip()
    port = os.getenv('CONTPAQ_SQLSERVER_PORT', '1433').strip()
    database = os.getenv('CONTPAQ_SQLSERVER_DATABASE', '').strip()
    user = os.getenv('CONTPAQ_SQLSERVER_USER', '').strip()
    password = os.getenv('CONTPAQ_SQLSERVER_PASSWORD', '').strip()
    driver = os.getenv('CONTPAQ_SQLSERVER_DRIVER', 'ODBC Driver 17 for SQL Server').strip()
    trust_cert = os.getenv('CONTPAQ_SQLSERVER_TRUST_CERT', 'yes').strip().lower() in ('1', 'true', 'yes', 'on')

    if not host or not database or not user or not password:
        raise RuntimeError('Faltan variables CONTPAQ_SQLSERVER_* requeridas.')

    server = f"{host},{port}" if port else host
    conn_str = ';'.join([
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        f"UID={user}",
        f"PWD={password}",
        f"TrustServerCertificate={'yes' if trust_cert else 'no'}",
    ])
    return pyodbc.connect(conn_str, timeout=30)


def fetch_rows(conn, query, params):
    cur = conn.cursor()
    cur.execute(query, params)
    cols = [d[0] for d in cur.description]
    rows = []
    for rec in cur.fetchall():
        rows.append(dict(zip(cols, rec)))
    return rows


def serialize_value(value):
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, float) and not math.isfinite(value):
        return 0
    return value


def to_jsonable_rows(rows):
    return [{k: serialize_value(v) for k, v in row.items()} for row in rows]


def parse_iso_date(raw_value, env_name, default_value=None):
    raw = str(raw_value or default_value or '').strip()
    if not raw:
        raise RuntimeError(f'Falta {env_name}. Usa formato YYYY-MM-DD.')
    try:
        return datetime.strptime(raw, '%Y-%m-%d').date()
    except ValueError as exc:
        raise RuntimeError(f'{env_name} invalida: {raw}. Usa formato YYYY-MM-DD.') from exc


def iterate_windows(start_date, end_date, chunk_days):
    current = start_date
    span_days = max(1, int(chunk_days or 1))
    while current <= end_date:
        window_end = min(end_date, current + timedelta(days=span_days - 1))
        yield current, window_end
        current = window_end + timedelta(days=1)


def build_payload(conn, window_start, window_end):
    end_exclusive = window_end + timedelta(days=1)
    params = (window_start.isoformat(), end_exclusive.isoformat())
    return {
        'supplier_purchase_orders': to_jsonable_rows(fetch_rows(conn, CONTPAQ_SUPPLIER_OT_QUERY, params)),
        'supplier_purchase_order_details': to_jsonable_rows(fetch_rows(conn, CONTPAQ_SUPPLIER_OT_DETALLE_QUERY, params)),
    }


def main():
    load_env_file()

    cloud_url = os.getenv('CONTPAQ_SUPPLIER_OT_CLOUD_PUSH_URL', '').strip()
    api_key = os.getenv('SYNC_API_KEY', '').strip()
    start_date = parse_iso_date(os.getenv('CONTPAQ_SUPPLIER_OT_START_DATE', '2025-01-01'), 'CONTPAQ_SUPPLIER_OT_START_DATE')
    end_date = parse_iso_date(os.getenv('CONTPAQ_END_DATE'), 'CONTPAQ_END_DATE', date.today().isoformat())
    chunk_days = max(1, int(os.getenv('CONTPAQ_CHUNK_DAYS', '31') or '31'))
    request_timeout = max(60, int(os.getenv('CONTPAQ_REQUEST_TIMEOUT', '300') or '300'))

    if not cloud_url:
        raise RuntimeError('Falta CONTPAQ_SUPPLIER_OT_CLOUD_PUSH_URL.')
    if not api_key:
        raise RuntimeError('Falta SYNC_API_KEY para autenticacion con nube.')
    if end_date < start_date:
        raise RuntimeError('CONTPAQ_END_DATE no puede ser menor que CONTPAQ_SUPPLIER_OT_START_DATE.')

    conn = connect_sqlserver()
    try:
        total_windows = 0
        total_sent = {
            'supplier_purchase_orders': 0,
            'supplier_purchase_order_details': 0,
        }

        for window_start, window_end in iterate_windows(start_date, end_date, chunk_days):
            total_windows += 1
            payload = build_payload(conn, window_start, window_end)
            counts = {key: len(value) for key, value in payload.items()}

            print('Ventana OT proveedor', f"{window_start.isoformat()} -> {window_end.isoformat()}:", json.dumps(counts, ensure_ascii=False))

            if not any(counts.values()):
                print('Sin datos OT en esta ventana, se omite push.')
                continue

            response = requests.post(
                cloud_url,
                headers={'Content-Type': 'application/json', 'X-API-KEY': api_key},
                data=json.dumps(payload),
                timeout=request_timeout,
            )

            if response.status_code >= 400:
                print('Error push OT:', response.status_code, response.text)
                return 1

            for key, value in counts.items():
                total_sent[key] += value

            print('Push OT exitoso:', response.text)
    finally:
        conn.close()

    print('Sincronizacion OT completa:', json.dumps({'desde': start_date.isoformat(), 'hasta': end_date.isoformat(), 'ventanas': total_windows, **total_sent}, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    try:
        sys_exit = main()
    except Exception as exc:
        print('ERROR:', str(exc))
        sys_exit = 1
    raise SystemExit(sys_exit)
