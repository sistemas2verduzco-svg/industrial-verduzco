"""
Sincronizacion de Odoo -> base local (Maquinaria y Ensamble).

Trae de Odoo:
  - Pedidos de venta (sale.order + sale.order.line)  -> OdooPedidoVenta(+lineas)
  - Ordenes de compra (purchase.order + lineas)       -> OdooOrdenCompra(+lineas)
    (internamente se tratan como Ordenes de Trabajo)

No relaciona pedidos con ordenes de compra; solo almacena la informacion.
La sincronizacion es incremental por write_date (solo trae lo que cambio).

Se ejecuta dentro de un app_context de Flask (lo provee el caller).
"""
from __future__ import annotations

import logging
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

from models import (
    db,
    OdooSyncRun,
    OdooPedidoVenta,
    OdooPedidoVentaLinea,
    OdooOrdenCompra,
    OdooOrdenCompraLinea,
)
from odoo_client import OdooClient, OdooError

logger = logging.getLogger(__name__)

HEADER_BATCH = 200
LINE_BATCH = 300
# Pequeno traslape para no perder registros por diferencia de relojes.
WATERMARK_OVERLAP = timedelta(minutes=2)


# --------------------------------------------------------------------------- #
# Helpers de parseo de valores Odoo
# --------------------------------------------------------------------------- #
def _m2o_id(value: Any) -> Optional[int]:
    if isinstance(value, (list, tuple)) and value:
        try:
            return int(value[0])
        except Exception:
            return None
    return None


def _m2o_name(value: Any) -> Optional[str]:
    if isinstance(value, (list, tuple)) and len(value) >= 2:
        return str(value[1]).strip()
    return None


def _to_float(value: Any) -> Optional[float]:
    if value is None or value is False or value == '':
        return None
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _to_dt(value: Any) -> Optional[datetime]:
    if not value or value is True:
        return None
    text = str(value).strip()
    if not text:
        return None
    for fmt in ('%Y-%m-%d %H:%M:%S', '%Y-%m-%d'):
        try:
            return datetime.strptime(text, fmt)
        except ValueError:
            continue
    return None


def _clip(value: Any, max_len: int) -> Optional[str]:
    if value is None or value is False:
        return None
    text = str(value).strip()
    if not text:
        return None
    return text[:max_len] if max_len and len(text) > max_len else text


# --------------------------------------------------------------------------- #
# Lectura paginada
# --------------------------------------------------------------------------- #
def _fetch_all(client: OdooClient, model: str, domain: List[Any],
               fields: List[str], *, order: str = 'write_date asc',
               batch: int = HEADER_BATCH) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    offset = 0
    while True:
        chunk = client.search_read_safe(
            model, domain, fields, limit=batch, offset=offset, order=order
        )
        if not chunk:
            break
        rows.extend(chunk)
        if len(chunk) < batch:
            break
        offset += batch
    return rows


def _fetch_lines_for_orders(client: OdooClient, model: str, order_ids: List[int],
                            fields: List[str]) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    for i in range(0, len(order_ids), LINE_BATCH):
        chunk_ids = order_ids[i:i + LINE_BATCH]
        rows.extend(_fetch_all(
            client, model, [['order_id', 'in', chunk_ids]], fields,
            order='order_id asc, sequence asc, id asc', batch=LINE_BATCH,
        ))
    return rows


def _build_product_code_map(client: OdooClient,
                            product_ids: List[int]) -> Dict[int, str]:
    """Mapea product.product id -> default_code (la 'clave' del producto/maquina)."""
    code_map: Dict[int, str] = {}
    ids = [pid for pid in set(product_ids) if pid]
    for i in range(0, len(ids), LINE_BATCH):
        chunk = ids[i:i + LINE_BATCH]
        try:
            rows = client.search_read_safe(
                'product.product', [['id', 'in', chunk]],
                ['id', 'default_code'], limit=LINE_BATCH,
            )
        except OdooError:
            rows = []
        for r in rows:
            code = (r.get('default_code') or '')
            if code and code is not True:
                code_map[int(r['id'])] = str(code).strip()
    return code_map


def _watermark(model_cls) -> Optional[str]:
    """Mayor write_date ya almacenado, como string Odoo, menos un traslape."""
    last = db.session.query(db.func.max(model_cls.odoo_write_date)).scalar()
    if not last:
        return None
    return (last - WATERMARK_OVERLAP).strftime('%Y-%m-%d %H:%M:%S')


# --------------------------------------------------------------------------- #
# Sync de pedidos de venta
# --------------------------------------------------------------------------- #
SALE_FIELDS = [
    'id', 'name', 'partner_id', 'date_order', 'commitment_date', 'validity_date',
    'state', 'amount_untaxed', 'amount_tax', 'amount_total', 'currency_id',
    'user_id', 'company_id', 'warehouse_id', 'x_studio_sucursal_2',
    'x_studio_titulo', 'client_order_ref', 'origin', 'note', 'write_date',
]
SALE_LINE_FIELDS = [
    'id', 'order_id', 'sequence', 'product_id', 'name', 'product_uom_qty',
    'qty_delivered', 'price_unit', 'price_subtotal', 'price_total',
    'product_uom', 'write_date',
]


def _sync_pedidos_venta(client: OdooClient) -> Dict[str, int]:
    stats = {'pedidos': 0, 'lineas': 0}
    watermark = _watermark(OdooPedidoVenta)
    domain: List[Any] = [['write_date', '>=', watermark]] if watermark else []
    headers = _fetch_all(client, client.model_sale_order, domain, SALE_FIELDS)
    if not headers:
        return stats

    id_to_local: Dict[int, OdooPedidoVenta] = {}
    for row in headers:
        odoo_id = int(row['id'])
        ped = OdooPedidoVenta.query.filter_by(odoo_id=odoo_id).first()
        if not ped:
            ped = OdooPedidoVenta(odoo_id=odoo_id)
            db.session.add(ped)
        ped.name = _clip(row.get('name'), 120)
        ped.partner_odoo_id = _m2o_id(row.get('partner_id'))
        ped.partner_name = _clip(_m2o_name(row.get('partner_id')), 255)
        ped.date_order = _to_dt(row.get('date_order'))
        ped.commitment_date = _to_dt(row.get('commitment_date'))
        ped.validity_date = _to_dt(row.get('validity_date'))
        ped.state = _clip(row.get('state'), 40)
        ped.amount_untaxed = _to_float(row.get('amount_untaxed'))
        ped.amount_tax = _to_float(row.get('amount_tax'))
        ped.amount_total = _to_float(row.get('amount_total'))
        ped.currency = _clip(_m2o_name(row.get('currency_id')), 20)
        ped.sales_rep = _clip(_m2o_name(row.get('user_id')), 255)
        ped.company = _clip(_m2o_name(row.get('company_id')), 255)
        ped.warehouse = _clip(_m2o_name(row.get('warehouse_id')), 255)
        sucursal = row.get('x_studio_sucursal_2')
        ped.sucursal = _clip(sucursal if sucursal and sucursal is not True else None, 255)
        ped.titulo = _clip(row.get('x_studio_titulo'), 255)
        ped.client_order_ref = _clip(row.get('client_order_ref'), 255)
        ped.origin = _clip(row.get('origin'), 255)
        ped.comments = _clip(row.get('note'), 100000)
        ped.odoo_write_date = _to_dt(row.get('write_date'))
        ped.synced_at = datetime.utcnow()
        id_to_local[odoo_id] = ped
        stats['pedidos'] += 1

    db.session.flush()

    order_ids = list(id_to_local.keys())
    lines = _fetch_lines_for_orders(client, 'sale.order.line', order_ids, SALE_LINE_FIELDS)
    code_map = _build_product_code_map(
        client, [_m2o_id(l.get('product_id')) for l in lines]
    )
    for row in lines:
        line_id = int(row['id'])
        order_id = _m2o_id(row.get('order_id'))
        parent = id_to_local.get(order_id)
        if not parent:
            continue
        ln = OdooPedidoVentaLinea.query.filter_by(odoo_id=line_id).first()
        if not ln:
            ln = OdooPedidoVentaLinea(odoo_id=line_id)
            db.session.add(ln)
        ln.pedido_id = parent.id
        ln.odoo_order_id = order_id
        ln.sequence = int(row.get('sequence') or 0)
        prod_id = _m2o_id(row.get('product_id'))
        ln.product_odoo_id = prod_id
        ln.product_key = _clip(code_map.get(prod_id) or _m2o_name(row.get('product_id')), 120)
        ln.product_name = _clip(_m2o_name(row.get('product_id')), 500)
        ln.description = _clip(row.get('name'), 100000)
        ln.product_uom_qty = _to_float(row.get('product_uom_qty'))
        ln.qty_delivered = _to_float(row.get('qty_delivered'))
        ln.price_unit = _to_float(row.get('price_unit'))
        ln.price_subtotal = _to_float(row.get('price_subtotal'))
        ln.price_total = _to_float(row.get('price_total'))
        ln.unit = _clip(_m2o_name(row.get('product_uom')), 60)
        ln.synced_at = datetime.utcnow()
        stats['lineas'] += 1

    return stats


# --------------------------------------------------------------------------- #
# Sync de ordenes de compra
# --------------------------------------------------------------------------- #
PO_FIELDS = [
    'id', 'name', 'partner_id', 'date_order', 'date_approve', 'date_planned',
    'state', 'amount_untaxed', 'amount_tax', 'amount_total', 'currency_id',
    'origin', 'partner_ref', 'company_id', 'user_id', 'notes', 'write_date',
]
PO_LINE_FIELDS = [
    'id', 'order_id', 'sequence', 'product_id', 'name', 'product_qty',
    'qty_received', 'price_unit', 'price_subtotal', 'price_total',
    'product_uom', 'date_planned', 'write_date',
]


def _sync_ordenes_compra(client: OdooClient) -> Dict[str, int]:
    stats = {'ordenes': 0, 'lineas': 0}
    watermark = _watermark(OdooOrdenCompra)
    domain: List[Any] = [['write_date', '>=', watermark]] if watermark else []
    headers = _fetch_all(client, client.model_purchase_order, domain, PO_FIELDS)
    if not headers:
        return stats

    id_to_local: Dict[int, OdooOrdenCompra] = {}
    for row in headers:
        odoo_id = int(row['id'])
        oc = OdooOrdenCompra.query.filter_by(odoo_id=odoo_id).first()
        if not oc:
            oc = OdooOrdenCompra(odoo_id=odoo_id)
            db.session.add(oc)
        oc.name = _clip(row.get('name'), 120)
        oc.partner_odoo_id = _m2o_id(row.get('partner_id'))
        oc.partner_name = _clip(_m2o_name(row.get('partner_id')), 255)
        oc.date_order = _to_dt(row.get('date_order'))
        oc.date_approve = _to_dt(row.get('date_approve'))
        oc.date_planned = _to_dt(row.get('date_planned'))
        oc.state = _clip(row.get('state'), 40)
        oc.amount_untaxed = _to_float(row.get('amount_untaxed'))
        oc.amount_tax = _to_float(row.get('amount_tax'))
        oc.amount_total = _to_float(row.get('amount_total'))
        oc.currency = _clip(_m2o_name(row.get('currency_id')), 20)
        oc.origin = _clip(row.get('origin'), 255)
        oc.partner_ref = _clip(row.get('partner_ref'), 255)
        oc.company = _clip(_m2o_name(row.get('company_id')), 255)
        oc.user_name = _clip(_m2o_name(row.get('user_id')), 255)
        oc.notes = _clip(row.get('notes'), 100000)
        oc.odoo_write_date = _to_dt(row.get('write_date'))
        oc.synced_at = datetime.utcnow()
        id_to_local[odoo_id] = oc
        stats['ordenes'] += 1

    db.session.flush()

    order_ids = list(id_to_local.keys())
    lines = _fetch_lines_for_orders(client, 'purchase.order.line', order_ids, PO_LINE_FIELDS)
    code_map = _build_product_code_map(
        client, [_m2o_id(l.get('product_id')) for l in lines]
    )
    for row in lines:
        line_id = int(row['id'])
        order_id = _m2o_id(row.get('order_id'))
        parent = id_to_local.get(order_id)
        if not parent:
            continue
        ln = OdooOrdenCompraLinea.query.filter_by(odoo_id=line_id).first()
        if not ln:
            ln = OdooOrdenCompraLinea(odoo_id=line_id)
            db.session.add(ln)
        ln.orden_id = parent.id
        ln.odoo_order_id = order_id
        ln.sequence = int(row.get('sequence') or 0)
        prod_id = _m2o_id(row.get('product_id'))
        ln.product_odoo_id = prod_id
        ln.product_key = _clip(code_map.get(prod_id) or _m2o_name(row.get('product_id')), 120)
        ln.product_name = _clip(_m2o_name(row.get('product_id')), 500)
        ln.description = _clip(row.get('name'), 100000)
        ln.product_qty = _to_float(row.get('product_qty'))
        ln.qty_received = _to_float(row.get('qty_received'))
        ln.price_unit = _to_float(row.get('price_unit'))
        ln.price_subtotal = _to_float(row.get('price_subtotal'))
        ln.price_total = _to_float(row.get('price_total'))
        ln.unit = _clip(_m2o_name(row.get('product_uom')), 60)
        ln.date_planned = _to_dt(row.get('date_planned'))
        ln.synced_at = datetime.utcnow()
        stats['lineas'] += 1

    return stats


# --------------------------------------------------------------------------- #
# Entrada principal
# --------------------------------------------------------------------------- #
def run_odoo_sync(trigger: str = 'manual') -> Dict[str, Any]:
    """Ejecuta una corrida completa de sincronizacion. Debe llamarse dentro de
    un app_context de Flask. Devuelve dict con el resultado y registra OdooSyncRun.
    """
    run = OdooSyncRun(trigger=trigger, status='running', started_at=datetime.utcnow())
    db.session.add(run)
    db.session.commit()

    try:
        if not OdooClient.is_configured():
            raise OdooError('Odoo no esta configurado (faltan variables de entorno).')
        client = OdooClient.from_env()
        client.authenticate()

        ventas = _sync_pedidos_venta(client)
        db.session.commit()
        compras = _sync_ordenes_compra(client)
        db.session.commit()

        run.pedidos_upserted = ventas['pedidos']
        run.pedido_lineas_upserted = ventas['lineas']
        run.ordenes_compra_upserted = compras['ordenes']
        run.orden_compra_lineas_upserted = compras['lineas']
        run.status = 'ok'
        run.message = (
            f"Pedidos: {ventas['pedidos']} (+{ventas['lineas']} lineas) | "
            f"Ordenes compra: {compras['ordenes']} (+{compras['lineas']} lineas)"
        )
        run.finished_at = datetime.utcnow()
        db.session.commit()
        logger.info('[ODOO] Sync OK -> %s', run.message)
        return {'ok': True, 'run': run.to_dict()}
    except Exception as exc:  # noqa: BLE001
        db.session.rollback()
        try:
            run.status = 'error'
            run.message = str(exc)[:2000]
            run.finished_at = datetime.utcnow()
            db.session.commit()
        except Exception:
            db.session.rollback()
        logger.error('[ODOO] Sync ERROR: %s', exc, exc_info=True)
        return {'ok': False, 'error': str(exc), 'run': run.to_dict() if run.id else None}
