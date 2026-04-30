import json
import math
import os
from datetime import date, datetime, timedelta

import pyodbc
import requests


CONTPAQ_EXISTENCIA_QUERY = """
SELECT
    q.OwnedBusinessEntityID,
    q.ProductID,
    q.DepotName,
    q.ProductKey,
    q.ProductName,
    q.DepotID,
    q.QtyPresent,
    q.QtyAvailable,
    q.QtyToDeliverToCustomer,
    q.QtyToReceiveFromSupplier,
    q.QtyOnTransit,
    q.QtyToReceive,
    q.DepotTypeID,
    q.Category1,
    q.Category2,
    q.Unit,
    q.MatrixKey1,
    q.MatrixKey2,
    q.QtyMax,
    q.QtyMinimum
FROM dbo.vwLBSProductQuantityList q
"""


def load_env_file():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(script_dir, 'contpaq_existencia_sync_agent.env')
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


def fetch_rows(conn, query):
    cur = conn.cursor()
    cur.execute(query)
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


def iterate_chunks(rows, size):
    chunk_size = max(200, int(size or 2000))
    for idx in range(0, len(rows), chunk_size):
        yield rows[idx:idx + chunk_size]


def main():
    load_env_file()

    cloud_url = os.getenv('CONTPAQ_EXISTENCIA_CLOUD_PUSH_URL', '').strip()
    api_key = os.getenv('SYNC_API_KEY', '').strip()
    request_timeout = max(60, int(os.getenv('CONTPAQ_REQUEST_TIMEOUT', '300') or '300'))
    chunk_size = max(200, int(os.getenv('CONTPAQ_EXISTENCIA_CHUNK_SIZE', '2500') or '2500'))

    if not cloud_url:
        raise RuntimeError('Falta CONTPAQ_EXISTENCIA_CLOUD_PUSH_URL.')
    if not api_key:
        raise RuntimeError('Falta SYNC_API_KEY para autenticacion con nube.')

    conn = connect_sqlserver()
    try:
        rows = to_jsonable_rows(fetch_rows(conn, CONTPAQ_EXISTENCIA_QUERY))
        print('Registros existencia leidos:', len(rows))
        if not rows:
            print('Sin registros para enviar.')
            return 0

        sent_rows = 0
        sent_chunks = 0
        for chunk in iterate_chunks(rows, chunk_size):
            sent_chunks += 1
            payload = {'existencias': chunk}
            response = requests.post(
                cloud_url,
                headers={'Content-Type': 'application/json', 'X-API-KEY': api_key},
                data=json.dumps(payload),
                timeout=request_timeout,
            )
            if response.status_code >= 400:
                print('Error push existencias:', response.status_code, response.text)
                return 1
            sent_rows += len(chunk)
            print(f'Push chunk {sent_chunks} OK: {len(chunk)} filas')

        print(
            'Sincronizacion existencias completa:',
            json.dumps(
                {
                    'date': date.today().isoformat(),
                    'chunks': sent_chunks,
                    'rows_sent': sent_rows,
                },
                ensure_ascii=False,
            ),
        )
        return 0
    finally:
        conn.close()


if __name__ == '__main__':
    try:
        sys_exit = main()
    except Exception as exc:
        print('ERROR:', str(exc))
        sys_exit = 1
    raise SystemExit(sys_exit)
