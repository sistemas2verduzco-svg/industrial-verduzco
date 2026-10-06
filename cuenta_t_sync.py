"""Cuenta T por cliente desde Odoo 18 (solo lectura).

Consume `verduzco.cuenta.t.wizard.api_cuenta_t`, que ya entrega la Cuenta T
armada (secciones > documentos > aplicaciones). Aquí no se recalcula nada:
solo se guarda por cliente y se sobrescribe completa en cada sincronización.
"""
import json
import logging
import os
import threading
from datetime import date, datetime
from typing import Dict, Iterable, List, Optional

from odoo_client import OdooClient, OdooError

logger = logging.getLogger(__name__)

ENV_PREFIX = 'CUENTA_T_ODOO_'
WIZARD_MODEL = 'verduzco.cuenta.t.wizard'
CLIENTES_DOMAIN = [['customer_rank', '>', 0], ['parent_id', '=', False]]
ODOO_INVOICE_PATH = '/odoo/action-account.action_move_out_invoice_type/{move_id}'

ORDEN_SECCIONES = [
    'CON ORDEN DE VENTA',
    'FACTURA DIRECTA (sin pedido)',
    'OTROS CARGOS',
    'ABONOS SIN APLICAR',
]

_SYNC_LOCK = threading.Lock()
_LAST_RUN: Dict[str, object] = {}


def _env_int(name: str, default: int, minimum: int = 1) -> int:
    try:
        return max(minimum, int(os.getenv(name, str(default)) or default))
    except Exception:
        return default


def _env_date(name: str) -> Optional[date]:
    raw = (os.getenv(name) or '').strip()
    if not raw:
        return None
    try:
        return datetime.strptime(raw, '%Y-%m-%d').date()
    except Exception:
        logger.warning('Cuenta T: %s=%r no es fecha YYYY-MM-DD; se ignora', name, raw)
        return None


def batch_size() -> int:
    return min(50, _env_int('CUENTA_T_BATCH_SIZE', 25))


def periodo_default():
    return _env_date('CUENTA_T_DATE_FROM'), _env_date('CUENTA_T_DATE_TO')


def is_configured() -> bool:
    return OdooClient.is_configured(ENV_PREFIX)


def get_client() -> OdooClient:
    return OdooClient.from_env(ENV_PREFIX)


def odoo_base_url() -> str:
    return (os.getenv(f'{ENV_PREFIX}URL') or os.getenv('ODOO_URL') or '').strip().rstrip('/')


def odoo_move_url(move_id) -> str:
    base = odoo_base_url()
    if not base or not move_id:
        return ''
    return base + ODOO_INVOICE_PATH.format(move_id=int(move_id))


def last_run() -> Dict[str, object]:
    return dict(_LAST_RUN)


def is_running() -> bool:
    return _SYNC_LOCK.locked()


def fetch_clientes(client: OdooClient) -> List[Dict]:
    out: List[Dict] = []
    offset = 0
    page = 500
    while True:
        rows = client.search_read(
            'res.partner',
            CLIENTES_DOMAIN,
            ['id', 'name', 'ref', 'vat'],
            limit=page,
            offset=offset,
            order='name asc, id asc',
        )
        out.extend(rows or [])
        if not rows or len(rows) < page:
            break
        offset += page
    return out


def resolver_cliente_comercial(client: OdooClient, partner_id: int) -> Optional[int]:
    rows = client.search_read('res.partner', [['id', '=', int(partner_id)]],
                              ['commercial_partner_id'], limit=1)
    if not rows:
        return None
    comm = rows[0].get('commercial_partner_id')
    if isinstance(comm, (list, tuple)) and comm:
        return int(comm[0])
    return int(partner_id)


def _call_api(client: OdooClient, partner_ids: List[int],
              date_from: Optional[date], date_to: Optional[date]) -> List[Dict]:
    kwargs = {
        'date_from': date_from.isoformat() if date_from else False,
        'date_to': date_to.isoformat() if date_to else False,
        'company_ids': False,
        'solo_abiertas': False,
    }
    res = client.execute_kw(WIZARD_MODEL, 'api_cuenta_t', [list(partner_ids)], kwargs)
    if not isinstance(res, list):
        raise OdooError(f'Respuesta inesperada de api_cuenta_t: {type(res).__name__}')
    return res


def _num(value) -> float:
    try:
        return float(value or 0.0)
    except Exception:
        return 0.0


def _txt(value) -> str:
    if value in (None, False):
        return ''
    return str(value)


def _limpiar_linea(raw: Dict) -> Dict:
    return {
        'fecha': _txt(raw.get('fecha')),
        'documento': _txt(raw.get('documento')),
        'move_id': int(raw.get('move_id') or 0) or None,
        'tipo': _txt(raw.get('tipo')),
        'concepto': _txt(raw.get('concepto')),
        'pedido': _txt(raw.get('pedido')),
        'empresa': _txt(raw.get('empresa')),
        'cargo': _num(raw.get('cargo')),
        'abono': _num(raw.get('abono')),
        'saldo': _num(raw.get('saldo')),
        'estado': _txt(raw.get('estado')),
        'bandera': _txt(raw.get('bandera')),
    }


def _limpiar_secciones(secciones) -> List[Dict]:
    out = []
    for sec in secciones or []:
        docs = []
        for doc in sec.get('documentos') or []:
            item = _limpiar_linea(doc)
            item['aplicaciones'] = [_limpiar_linea(a) for a in (doc.get('aplicaciones') or [])]
            docs.append(item)
        out.append({'nombre': _txt(sec.get('nombre')), 'documentos': docs})
    return out


def _guardar_resultado(db, Model, data: Dict, now: datetime,
                       date_from: Optional[date], date_to: Optional[date]) -> int:
    cliente_id = int(data.get('cliente_id') or 0)
    if not cliente_id:
        raise ValueError('api_cuenta_t regresó un cliente sin cliente_id')
    row = Model.query.filter_by(cliente_id=cliente_id).first()
    if row is None:
        row = Model(cliente_id=cliente_id)
        db.session.add(row)
    row.cliente = _txt(data.get('cliente'))[:255]
    row.clave = _txt(data.get('clave'))[:80]
    row.rfc = _txt(data.get('rfc'))[:40]
    row.moneda = _txt(data.get('moneda'))[:10]
    row.total_cargos = _num(data.get('total_cargos'))
    row.total_abonos = _num(data.get('total_abonos'))
    row.saldo = _num(data.get('saldo'))
    row.saldo_texto = _txt(data.get('saldo_texto'))[:60]
    row.secciones_json = json.dumps(_limpiar_secciones(data.get('secciones')), ensure_ascii=False)
    row.periodo_desde = date_from
    row.periodo_hasta = date_to
    row.synced_at = now
    row.last_attempt_at = now
    row.last_error = None
    row.last_error_at = None
    return cliente_id


def _marcar_error(db, Model, partner_ids: Iterable[int], mensaje: str, now: datetime,
                  nombres: Optional[Dict[int, Dict]] = None) -> None:
    nombres = nombres or {}
    for pid in partner_ids:
        row = Model.query.filter_by(cliente_id=int(pid)).first()
        if row is None:
            info = nombres.get(int(pid)) or {}
            row = Model(
                cliente_id=int(pid),
                cliente=_txt(info.get('name'))[:255] or None,
                clave=_txt(info.get('ref'))[:80] or None,
                rfc=_txt(info.get('vat'))[:40] or None,
            )
            db.session.add(row)
        row.last_attempt_at = now
        row.last_error = (mensaje or 'Error desconocido')[:2000]
        row.last_error_at = now


def sync_cuentas(db, Model, partner_ids: Optional[List[int]] = None, trigger: str = 'manual',
                 date_from: Optional[date] = None, date_to: Optional[date] = None,
                 wait: bool = True) -> Dict:
    """Sincroniza la Cuenta T. Sin `partner_ids` trae todos los clientes de Odoo.

    Debe llamarse dentro de un app_context. Nunca escribe en Odoo.
    """
    full = not partner_ids
    if full and not _SYNC_LOCK.acquire(blocking=wait):
        return {'ok': False, 'skipped': True, 'error': 'Ya hay una sincronización de Cuentas T en curso.'}
    started = datetime.utcnow()
    summary: Dict[str, object] = {
        'ok': True, 'trigger': trigger, 'started_at': started.isoformat(),
        'clientes': 0, 'actualizados': 0, 'errores': 0, 'error': None,
    }
    try:
        if date_from is None and date_to is None:
            date_from, date_to = periodo_default()
        try:
            client = get_client()
        except Exception as exc:
            summary.update(ok=False, error=str(exc))
            if partner_ids:
                _marcar_error(db, Model, partner_ids, str(exc), started)
                db.session.commit()
            return summary

        nombres: Dict[int, Dict] = {}
        if partner_ids:
            ids = [int(p) for p in partner_ids if p]
        else:
            try:
                clientes = fetch_clientes(client)
            except Exception as exc:
                summary.update(ok=False, error=f'No se pudo leer la lista de clientes: {exc}')
                return summary
            nombres = {int(c['id']): c for c in clientes}
            ids = list(nombres.keys())
        summary['clientes'] = len(ids)

        size = batch_size()
        for i in range(0, len(ids), size):
            lote = ids[i:i + size]
            now = datetime.utcnow()
            try:
                resultados = _call_api(client, lote, date_from, date_to)
                pendientes = [lote]
            except Exception as exc:
                logger.warning('Cuenta T: lote %s falló (%s); reintento uno por uno', lote[:3], exc)
                resultados = []
                pendientes = [[pid] for pid in lote]
                if len(lote) == 1:
                    _marcar_error(db, Model, lote, str(exc), now, nombres)
                    summary['errores'] = int(summary['errores']) + 1
                    db.session.commit()
                    continue

            if resultados:
                for data in resultados:
                    _guardar_resultado(db, Model, data, now, date_from, date_to)
                    summary['actualizados'] = int(summary['actualizados']) + 1
                db.session.commit()
                continue

            if pendientes == [lote]:
                # Lote sin movimientos: Odoo regresa lista vacía si no hay clientes válidos.
                continue

            for single in pendientes:
                now = datetime.utcnow()
                try:
                    for data in _call_api(client, single, date_from, date_to):
                        _guardar_resultado(db, Model, data, now, date_from, date_to)
                        summary['actualizados'] = int(summary['actualizados']) + 1
                except Exception as exc:
                    db.session.rollback()
                    _marcar_error(db, Model, single, str(exc), now, nombres)
                    summary['errores'] = int(summary['errores']) + 1
                db.session.commit()

        if summary['errores'] and not summary['actualizados']:
            summary['ok'] = False
            summary['error'] = summary['error'] or 'Odoo regresó error en todos los clientes.'
        return summary
    except Exception as exc:
        db.session.rollback()
        logger.exception('Cuenta T: error en sincronización')
        summary.update(ok=False, error=str(exc))
        return summary
    finally:
        summary['finished_at'] = datetime.utcnow().isoformat()
        if full:
            _LAST_RUN.clear()
            _LAST_RUN.update(summary)
            _SYNC_LOCK.release()


def secciones_de(row) -> List[Dict]:
    try:
        secciones = json.loads(row.secciones_json or '[]')
    except Exception:
        return []
    orden = {nombre: i for i, nombre in enumerate(ORDEN_SECCIONES)}
    return sorted(secciones, key=lambda s: orden.get(s.get('nombre'), len(orden)))
