"""
Sincroniza pedidos de Odoo -> MySQL empaqueops (SalesOrders / SalesOrderItems).

Equivalente en nube al Empaque.SyncWorker de planta:
  Odoo sale.order (+ lines) -> tablas que leen Desktop / Ventas / Salida.

Config (env):
  EMPAQUE_MYSQL_HOST / PORT / DATABASE / USER / PASSWORD
  EMPAQUE_ODOO_SYNC_LOOKBACK_DAYS (default 3)
  EMPAQUE_ODOO_ORDER_STATES (default sale,done)  CSV
  ODOO_*  (mismo cliente que el resto del MES)
"""
from __future__ import annotations

import logging
import os
from datetime import date, datetime, timedelta
from typing import Any, Dict, List, Optional, Sequence, Tuple

from odoo_client import OdooClient, OdooError

logger = logging.getLogger(__name__)


def _env(name: str, default: str = '') -> str:
    return (os.getenv(name) or default).strip()


def _mysql_connect():
    try:
        import pymysql
    except ImportError as exc:
        raise RuntimeError(
            'Falta pymysql en la imagen. Corre: docker compose build app && docker compose up -d app'
        ) from exc

    host = _env('EMPAQUE_MYSQL_HOST', 'empaque_db')
    port = int(_env('EMPAQUE_MYSQL_PORT', '3306') or 3306)
    database = _env('EMPAQUE_MYSQL_DATABASE', 'empaqueops')
    user = _env('EMPAQUE_MYSQL_USER', 'empaque_app')
    password = _env('EMPAQUE_MYSQL_PASSWORD', '')
    if not password:
        raise RuntimeError('EMPAQUE_MYSQL_PASSWORD no configurado')
    return pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.Cursor,
        autocommit=False,
    )


def _m2o_id(value: Any) -> Optional[int]:
    if isinstance(value, (list, tuple)) and value:
        try:
            return int(value[0])
        except Exception:
            return None
    if isinstance(value, int):
        return value
    return None


def _m2o_name(value: Any) -> str:
    if isinstance(value, (list, tuple)) and len(value) >= 2:
        return str(value[1] or '').strip()
    return ''


def _to_float(value: Any) -> float:
    if value is None or value is False or value == '':
        return 0.0
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def _to_dt(value: Any) -> datetime:
    if isinstance(value, datetime):
        return value
    text = str(value or '').strip()
    for fmt in ('%Y-%m-%d %H:%M:%S', '%Y-%m-%d'):
        try:
            return datetime.strptime(text, fmt)
        except ValueError:
            continue
    return datetime.utcnow()


def _clip(value: Any, max_len: int) -> str:
    text = str(value or '').strip()
    if not text:
        return ''
    return text[:max_len]


def _order_states() -> List[str]:
    raw = _env('EMPAQUE_ODOO_ORDER_STATES', 'sale,done')
    states = [s.strip() for s in raw.split(',') if s.strip()]
    return states or ['sale', 'done']


def _fetch_orders_for_day(client: OdooClient, day: date) -> List[Dict[str, Any]]:
    day_start = datetime(day.year, day.month, day.day)
    day_end = day_start + timedelta(days=1)
    domain = [
        ['date_order', '>=', day_start.strftime('%Y-%m-%d %H:%M:%S')],
        ['date_order', '<', day_end.strftime('%Y-%m-%d %H:%M:%S')],
        ['state', 'in', _order_states()],
    ]
    return client.search_read_safe(
        'sale.order',
        domain,
        ['id', 'name', 'date_order', 'partner_id'],
        limit=500,
        order='date_order asc, id asc',
    )


def _fetch_order_items(client: OdooClient, order_id: int, order_name: str) -> List[Dict[str, Any]]:
    lines = client.search_read_safe(
        'sale.order.line',
        [['order_id', '=', order_id]],
        ['id', 'sequence', 'product_id', 'name', 'product_uom_qty'],
        limit=2000,
        order='sequence asc, id asc',
    )
    if not lines:
        return []

    product_ids = sorted({
        pid for pid in (_m2o_id(l.get('product_id')) for l in lines) if pid
    })
    products: Dict[int, Tuple[str, float]] = {}
    if product_ids:
        for i in range(0, len(product_ids), 80):
            chunk = product_ids[i:i + 80]
            rows = client.search_read_safe(
                'product.product',
                [['id', 'in', chunk]],
                ['id', 'default_code', 'weight'],
                limit=len(chunk),
            )
            for p in rows or []:
                pid = int(p.get('id') or 0)
                if pid:
                    products[pid] = (
                        str(p.get('default_code') or '').strip(),
                        _to_float(p.get('weight')),
                    )

    items: List[Dict[str, Any]] = []
    for line in lines:
        line_id = int(line.get('id') or 0)
        product_id = _m2o_id(line.get('product_id')) or 0
        code, weight = products.get(product_id, ('', 0.0))
        if not code:
            code = _m2o_name(line.get('product_id')) or f'P{product_id}'
        items.append({
            'source_line_number': line_id,  # id estable de sale.order.line
            'external_order_number': order_name,
            'product_code': _clip(code, 80),
            'product_name': _clip(line.get('name'), 200),
            'quantity_ordered': _to_float(line.get('product_uom_qty')),
            'unit_weight_kg': weight,
        })
    return items


def _upsert_order(cur, order: Dict[str, Any]) -> None:
    partner = order.get('partner_id')
    customer_code = str(_m2o_id(partner) or '').strip()
    customer_name = _clip(_m2o_name(partner), 200)
    external = _clip(order.get('name'), 80)
    if not external:
        return
    cur.execute(
        """
        INSERT INTO SalesOrders
            (ExternalOrderNumber, OrderDateUtc, CustomerCode, CustomerName, ImportedAtUtc)
        VALUES (%s, %s, %s, %s, UTC_TIMESTAMP())
        ON DUPLICATE KEY UPDATE
            OrderDateUtc = VALUES(OrderDateUtc),
            CustomerCode = VALUES(CustomerCode),
            CustomerName = VALUES(CustomerName),
            ImportedAtUtc = UTC_TIMESTAMP()
        """,
        (
            external,
            _to_dt(order.get('date_order')),
            customer_code,
            customer_name,
        ),
    )


def _upsert_items(cur, external_order: str, items: Sequence[Dict[str, Any]]) -> int:
    if not items:
        return 0
    count = 0
    for item in items:
        cur.execute(
            """
            INSERT INTO SalesOrderItems
                (SalesOrderId, SourceLineNumber, ProductCode, ProductName,
                 QuantityOrdered, UnitWeightFromContpaqiKg, ImportedAtUtc)
            SELECT
                so.SalesOrderId,
                %s, %s, %s, %s, %s, UTC_TIMESTAMP()
            FROM SalesOrders so
            WHERE so.ExternalOrderNumber = %s
            ON DUPLICATE KEY UPDATE
                ProductCode = VALUES(ProductCode),
                ProductName = VALUES(ProductName),
                QuantityOrdered = VALUES(QuantityOrdered),
                UnitWeightFromContpaqiKg = VALUES(UnitWeightFromContpaqiKg),
                ImportedAtUtc = UTC_TIMESTAMP()
            """,
            (
                int(item['source_line_number']),
                item['product_code'],
                item['product_name'],
                float(item['quantity_ordered']),
                float(item['unit_weight_kg']),
                external_order,
            ),
        )
        count += 1

    keep_ids = [int(i['source_line_number']) for i in items if int(i['source_line_number'] or 0) > 0]
    if keep_ids:
        placeholders = ','.join(['%s'] * len(keep_ids))
        cur.execute(
            f"""
            DELETE soi
            FROM SalesOrderItems soi
            INNER JOIN SalesOrders so ON so.SalesOrderId = soi.SalesOrderId
            WHERE so.ExternalOrderNumber = %s
              AND soi.SourceLineNumber NOT IN ({placeholders})
            """,
            [external_order, *keep_ids],
        )
    return count


def run_empaque_odoo_sync(trigger: str = 'manual', lookback_days: Optional[int] = None) -> Dict[str, Any]:
    """Importa pedidos Odoo de los últimos N días hacia MySQL empaqueops."""
    lookback = lookback_days
    if lookback is None:
        lookback = max(1, int(_env('EMPAQUE_ODOO_SYNC_LOOKBACK_DAYS', '3') or 3))

    started = datetime.utcnow()
    stats: Dict[str, Any] = {
        'ok': False,
        'trigger': trigger,
        'lookback_days': lookback,
        'orders': 0,
        'items': 0,
        'days': [],
        'started_at': started.isoformat() + 'Z',
    }

    try:
        client = OdooClient.from_env()
    except Exception as exc:
        stats['error'] = f'Odoo config: {exc}'
        logger.error('[EMPAQUE-ODOO] %s', stats['error'])
        return stats

    conn = None
    try:
        conn = _mysql_connect()
        today = date.today()
        with conn.cursor() as cur:
            for offset in range(lookback):
                day = today - timedelta(days=offset)
                day_orders = 0
                day_items = 0
                try:
                    orders = _fetch_orders_for_day(client, day)
                except OdooError as exc:
                    logger.error('[EMPAQUE-ODOO] Odoo día %s: %s', day, exc)
                    stats.setdefault('day_errors', []).append({'day': str(day), 'error': str(exc)})
                    continue

                for order in orders:
                    name = _clip(order.get('name'), 80)
                    if not name:
                        continue
                    _upsert_order(cur, order)
                    order_id = int(order.get('id') or 0)
                    items = _fetch_order_items(client, order_id, name) if order_id else []
                    day_items += _upsert_items(cur, name, items)
                    day_orders += 1

                conn.commit()
                stats['orders'] += day_orders
                stats['items'] += day_items
                stats['days'].append({'day': str(day), 'orders': day_orders, 'items': day_items})
                logger.info(
                    '[EMPAQUE-ODOO] %s trigger=%s day=%s orders=%s items=%s',
                    'OK', trigger, day, day_orders, day_items,
                )

        stats['ok'] = True
        stats['finished_at'] = datetime.utcnow().isoformat() + 'Z'
        return stats
    except Exception as exc:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
        stats['error'] = str(exc)
        stats['finished_at'] = datetime.utcnow().isoformat() + 'Z'
        logger.error('[EMPAQUE-ODOO] Fallo sync: %s', exc, exc_info=True)
        return stats
    finally:
        if conn:
            try:
                conn.close()
            except Exception:
                pass
