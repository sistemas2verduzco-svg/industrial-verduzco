#!/usr/bin/env python3
"""
Agente local Empaque360 → nube MES.

Lee MySQL empaqueops (servidor físico / LAN) y hace POST a:
  POST {EMPAQUE_CLOUD_PUSH_URL}  con header X-API-KEY: SYNC_API_KEY

Uso típico (cron cada 1-5 min en la planta):
  python3 scripts/empaque_sync_agent.py

Variables (.env junto al script o entorno):
  EMPAQUE_MYSQL_HOST=192.168.0.6
  EMPAQUE_MYSQL_PORT=3307
  EMPAQUE_MYSQL_DATABASE=empaqueops
  EMPAQUE_MYSQL_USER=empaque_app
  EMPAQUE_MYSQL_PASSWORD=***
  SYNC_API_KEY=***
  EMPAQUE_CLOUD_PUSH_URL=https://controlcalidad360.site/api/empaque/sync/push
  EMPAQUE_LOOKBACK_DAYS=45          # pedidos con actividad reciente
  EMPAQUE_CHUNK_ORDERS=80           # pedidos por push
  EMPAQUE_REQUEST_TIMEOUT=180
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timedelta
from decimal import Decimal

import requests

try:
    import pymysql
except ImportError:
    print('Falta pymysql. Instala con: pip install pymysql')
    sys.exit(1)


def load_env_file():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    for env_path in (
        os.path.join(script_dir, '.env'),
        os.path.join(os.path.dirname(script_dir), '.env'),
    ):
        if not os.path.exists(env_path):
            continue
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


def json_default(value):
    if isinstance(value, datetime):
        return value.strftime('%Y-%m-%d %H:%M:%S')
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, bytes):
        return value.decode('utf-8', errors='replace')
    raise TypeError(f'Tipo no serializable: {type(value)}')


def connect_mysql():
    host = os.getenv('EMPAQUE_MYSQL_HOST', '').strip()
    port = int(os.getenv('EMPAQUE_MYSQL_PORT', '3307') or '3307')
    database = os.getenv('EMPAQUE_MYSQL_DATABASE', 'empaqueops').strip()
    user = os.getenv('EMPAQUE_MYSQL_USER', '').strip()
    password = os.getenv('EMPAQUE_MYSQL_PASSWORD', '')
    if not host or not user:
        raise RuntimeError('Faltan EMPAQUE_MYSQL_HOST / EMPAQUE_MYSQL_USER')
    return pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=20,
        read_timeout=120,
        write_timeout=120,
    )


def fetch_all(conn, sql, params=None):
    with conn.cursor() as cur:
        cur.execute(sql, params or ())
        return list(cur.fetchall() or [])


def select_order_numbers(conn, lookback_days):
    since = datetime.utcnow() - timedelta(days=max(1, lookback_days))
    rows = fetch_all(
        conn,
        """
        SELECT DISTINCT o.ExternalOrderNumber
        FROM SalesOrders o
        LEFT JOIN BoxMovements m ON m.ExternalOrderNumber = o.ExternalOrderNumber
        LEFT JOIN PackingBoxes b ON b.ExternalOrderNumber = o.ExternalOrderNumber
        LEFT JOIN PackingLineProgress p ON p.ExternalOrderNumber = o.ExternalOrderNumber
        WHERE o.OrderDateUtc >= %s
           OR m.CapturedAtUtc >= %s
           OR b.UpdatedAtUtc >= %s
           OR p.UpdatedAtUtc >= %s
        ORDER BY o.ExternalOrderNumber
        """,
        (since, since, since, since),
    )
    return [r['ExternalOrderNumber'] for r in rows if r.get('ExternalOrderNumber')]


def build_orders_payload(conn, order_numbers):
    if not order_numbers:
        return []

    placeholders = ','.join(['%s'] * len(order_numbers))
    orders = fetch_all(
        conn,
        f"""
        SELECT SalesOrderId, ExternalOrderNumber, OrderDateUtc, CustomerCode, CustomerName
        FROM SalesOrders
        WHERE ExternalOrderNumber IN ({placeholders})
        """,
        tuple(order_numbers),
    )
    items = fetch_all(
        conn,
        f"""
        SELECT
            o.ExternalOrderNumber,
            i.SourceLineNumber,
            i.ProductCode,
            IFNULL(i.ProductName, '') AS ProductName,
            i.QuantityOrdered,
            i.UnitWeightFromContpaqiKg
        FROM SalesOrderItems i
        INNER JOIN SalesOrders o ON o.SalesOrderId = i.SalesOrderId
        WHERE o.ExternalOrderNumber IN ({placeholders})
        ORDER BY o.ExternalOrderNumber, i.SourceLineNumber, i.ProductCode
        """,
        tuple(order_numbers),
    )
    boxes = fetch_all(
        conn,
        f"""
        SELECT
            PackingBoxId, BoxCode, ExternalOrderNumber, MaxWeightKg, CurrentRealWeightKg,
            Status, OpenedAtUtc, ClosedAtUtc, UpdatedAtUtc
        FROM PackingBoxes
        WHERE ExternalOrderNumber IN ({placeholders})
        ORDER BY ExternalOrderNumber, BoxCode, PackingBoxId
        """,
        tuple(order_numbers),
    )
    movements = fetch_all(
        conn,
        f"""
        SELECT
            m.BoxMovementId,
            m.BoxCode,
            m.ExternalOrderNumber,
            m.ProductCode,
            IFNULL((
                SELECT i.ProductName
                FROM SalesOrderItems i
                INNER JOIN SalesOrders o ON o.SalesOrderId = i.SalesOrderId
                WHERE o.ExternalOrderNumber = m.ExternalOrderNumber
                  AND i.ProductCode = m.ProductCode
                ORDER BY i.SourceLineNumber
                LIMIT 1
            ), '') AS ProductName,
            m.QuantityCaptured,
            m.UnitWeightFromContpaqiKg,
            m.RealMovementWeightKg,
            m.ObservedWeightPerPieceKg,
            m.OperatorName,
            m.CapturedAtUtc
        FROM BoxMovements m
        WHERE m.ExternalOrderNumber IN ({placeholders})
        ORDER BY m.ExternalOrderNumber, m.CapturedAtUtc, m.BoxMovementId
        """,
        tuple(order_numbers),
    )
    progress = fetch_all(
        conn,
        f"""
        SELECT
            ExternalOrderNumber, ProductCode, SourceLineNumber,
            QuantityOrdered, QuantityPacked, UpdatedAtUtc
        FROM PackingLineProgress
        WHERE ExternalOrderNumber IN ({placeholders})
        """,
        tuple(order_numbers),
    )

    items_by = {}
    for row in items:
        items_by.setdefault(row['ExternalOrderNumber'], []).append(row)
    boxes_by = {}
    for row in boxes:
        boxes_by.setdefault(row['ExternalOrderNumber'], []).append(row)
    movs_by = {}
    for row in movements:
        movs_by.setdefault(row['ExternalOrderNumber'], []).append(row)
    prog_by = {}
    for row in progress:
        prog_by.setdefault(row['ExternalOrderNumber'], []).append(row)

    payload_orders = []
    for order in orders:
        number = order['ExternalOrderNumber']
        movs = movs_by.get(number, [])
        last_activity = order.get('OrderDateUtc')
        for m in movs:
            cap = m.get('CapturedAtUtc')
            if cap and (not last_activity or cap > last_activity):
                last_activity = cap
        for b in boxes_by.get(number, []):
            upd = b.get('UpdatedAtUtc') or b.get('ClosedAtUtc') or b.get('OpenedAtUtc')
            if upd and (not last_activity or upd > last_activity):
                last_activity = upd

        payload_orders.append({
            'SalesOrderId': order.get('SalesOrderId'),
            'ExternalOrderNumber': number,
            'OrderDateUtc': order.get('OrderDateUtc'),
            'CustomerCode': str(order.get('CustomerCode') or '').strip(),
            'CustomerName': order.get('CustomerName'),
            'LastActivityUtc': last_activity,
            'items': items_by.get(number, []),
            'cajas': boxes_by.get(number, []),
            'movimientos': movs,
            'progreso': prog_by.get(number, []),
        })
    return payload_orders


def chunked(seq, size):
    for i in range(0, len(seq), size):
        yield seq[i:i + size]


def main():
    load_env_file()

    cloud_url = os.getenv('EMPAQUE_CLOUD_PUSH_URL', '').strip()
    api_key = os.getenv('SYNC_API_KEY', '').strip()
    lookback_days = max(1, int(os.getenv('EMPAQUE_LOOKBACK_DAYS', '45') or '45'))
    chunk_orders = max(1, int(os.getenv('EMPAQUE_CHUNK_ORDERS', '80') or '80'))
    timeout = max(60, int(os.getenv('EMPAQUE_REQUEST_TIMEOUT', '180') or '180'))

    if not cloud_url:
        raise RuntimeError('Falta EMPAQUE_CLOUD_PUSH_URL')
    if not api_key:
        raise RuntimeError('Falta SYNC_API_KEY')

    conn = connect_mysql()
    try:
        order_numbers = select_order_numbers(conn, lookback_days)
        print(f'Pedidos candidatos ({lookback_days}d): {len(order_numbers)}')
        if not order_numbers:
            print('Nada que sincronizar.')
            return 0

        total_stats = {
            'pedidos_upserted': 0,
            'items_upserted': 0,
            'cajas_upserted': 0,
            'movimientos_upserted': 0,
            'progreso_upserted': 0,
        }

        for batch in chunked(order_numbers, chunk_orders):
            pedidos = build_orders_payload(conn, batch)
            # Filtrar sin clave de cliente
            pedidos = [p for p in pedidos if p.get('CustomerCode')]
            print(f'Push lote de {len(pedidos)} pedidos...')
            if not pedidos:
                continue

            response = requests.post(
                cloud_url,
                headers={'Content-Type': 'application/json', 'X-API-KEY': api_key},
                data=json.dumps({'pedidos': pedidos}, default=json_default),
                timeout=timeout,
            )
            if response.status_code >= 400:
                print('Error push:', response.status_code, response.text[:1000])
                return 1

            body = response.json() if response.content else {}
            stats = body.get('stats') or {}
            print('OK', json.dumps(stats, ensure_ascii=False))
            for key in total_stats:
                total_stats[key] += int(stats.get(key) or 0)

        print('Total:', json.dumps(total_stats, ensure_ascii=False))
        return 0
    finally:
        conn.close()


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERROR: {exc}')
        raise
