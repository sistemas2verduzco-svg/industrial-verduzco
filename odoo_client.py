"""
Cliente de Odoo (XML-RPC) para Industrias Verduzco.

Se conecta a una instancia de Odoo usando la API estandar XML-RPC, que funciona
en Odoo 12 a 18 sin librerias extra (usa xmlrpc.client de la stdlib).

Toda la configuracion se lee de variables de entorno para no exponer credenciales
en el repo (mismo patron que SYNC_API_KEY / CONTPAQ_*):

    ODOO_URL        URL base, ej. https://miempresa.odoo.com
    ODOO_DB         Nombre de la base de datos
    ODOO_USERNAME   Usuario / email de login
    ODOO_PASSWORD   Contrasena del usuario  (o usa ODOO_API_KEY)
    ODOO_API_KEY    API key de Odoo (recomendado; tiene prioridad sobre password)
    ODOO_TIMEOUT    Timeout en segundos para llamadas RPC (default 30)

Modelos configurables (por si tu Odoo usa nombres distintos):
    ODOO_MODEL_SALE_ORDER   default 'sale.order'
    ODOO_MODEL_WORK_ORDER   default 'mrp.production'   (orden de fabricacion / OT)
    ODOO_MODEL_BOM          default 'mrp.bom'

Uso tipico:
    client = OdooClient.from_env()
    info = client.test_connection()
    pedidos = client.search_read('sale.order', [['state', '=', 'sale']],
                                 ['name', 'partner_id', 'amount_total'], limit=10)
"""
from __future__ import annotations

import os
import socket
import xmlrpc.client
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse


class OdooError(Exception):
    """Error de conexion o de llamada a Odoo."""


def _clean(value: Optional[str]) -> str:
    return (value or '').strip()


def _derive_db_from_url(url: str) -> str:
    """Deduce el nombre de la base desde el subdominio (Odoo Online *.odoo.com).

    Ej: https://miempresa.odoo.com -> 'miempresa'. Para dominios propios devuelve
    el primer segmento del host como mejor aproximacion.
    """
    host = urlparse(_clean(url)).hostname or ''
    if not host:
        return ''
    parts = host.split('.')
    if len(parts) >= 3 and parts[-2] == 'odoo' and parts[-1] == 'com':
        return parts[0]
    return parts[0] if parts else ''


class OdooClient:
    def __init__(
        self,
        url: str,
        db: str,
        username: str,
        secret: str,
        *,
        timeout: int = 30,
        model_sale_order: str = 'sale.order',
        model_work_order: str = 'mrp.production',
        model_bom: str = 'mrp.bom',
    ) -> None:
        self.url = _clean(url).rstrip('/')
        self.db = _clean(db)
        self.username = _clean(username)
        self.secret = secret or ''
        self.timeout = max(5, int(timeout or 30))
        self.model_sale_order = _clean(model_sale_order) or 'sale.order'
        self.model_work_order = _clean(model_work_order) or 'mrp.production'
        self.model_bom = _clean(model_bom) or 'mrp.bom'
        self._uid: Optional[int] = None
        self._common: Optional[xmlrpc.client.ServerProxy] = None
        self._models: Optional[xmlrpc.client.ServerProxy] = None

    # ------------------------------------------------------------------ #
    # Construccion desde entorno
    # ------------------------------------------------------------------ #
    @classmethod
    def from_env(cls) -> 'OdooClient':
        url = _clean(os.getenv('ODOO_URL'))
        db = _clean(os.getenv('ODOO_DB')) or _derive_db_from_url(url)
        username = _clean(os.getenv('ODOO_USERNAME'))
        secret = _clean(os.getenv('ODOO_API_KEY')) or _clean(os.getenv('ODOO_PASSWORD'))
        if not url or not db or not username or not secret:
            missing = [
                name for name, val in (
                    ('ODOO_URL', url),
                    ('ODOO_DB (no se pudo deducir del URL)', db),
                    ('ODOO_USERNAME', username),
                    ('ODOO_API_KEY/ODOO_PASSWORD', secret),
                ) if not val
            ]
            raise OdooError(
                'Configuracion de Odoo incompleta. Faltan: ' + ', '.join(missing)
            )
        try:
            timeout = int(os.getenv('ODOO_TIMEOUT', '30') or '30')
        except Exception:
            timeout = 30
        return cls(
            url=url,
            db=db,
            username=username,
            secret=secret,
            timeout=timeout,
            model_sale_order=os.getenv('ODOO_MODEL_SALE_ORDER', 'sale.order'),
            model_work_order=os.getenv('ODOO_MODEL_WORK_ORDER', 'mrp.production'),
            model_bom=os.getenv('ODOO_MODEL_BOM', 'mrp.bom'),
        )

    @staticmethod
    def is_configured() -> bool:
        url = _clean(os.getenv('ODOO_URL'))
        db = _clean(os.getenv('ODOO_DB')) or _derive_db_from_url(url)
        username = _clean(os.getenv('ODOO_USERNAME'))
        secret = _clean(os.getenv('ODOO_API_KEY')) or _clean(os.getenv('ODOO_PASSWORD'))
        return bool(url and db and username and secret)

    # ------------------------------------------------------------------ #
    # Conexion / autenticacion
    # ------------------------------------------------------------------ #
    def _proxy(self, path: str) -> xmlrpc.client.ServerProxy:
        endpoint = f'{self.url}/xmlrpc/2/{path}'
        return xmlrpc.client.ServerProxy(endpoint, allow_none=True)

    def list_databases(self) -> List[str]:
        """Intenta listar las bases de datos del servidor (servicio 'db').

        Muchos Odoo lo deshabilitan (list_db = False); en ese caso lanza OdooError.
        """
        prev = socket.getdefaulttimeout()
        socket.setdefaulttimeout(self.timeout)
        try:
            db_proxy = self._proxy('db')
            result = db_proxy.list()
            return [str(x) for x in (result or [])]
        except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as exc:
            raise OdooError(f'No se pudo listar bases de datos: {exc}') from exc
        finally:
            socket.setdefaulttimeout(prev)

    def version(self) -> Dict[str, Any]:
        prev = socket.getdefaulttimeout()
        socket.setdefaulttimeout(self.timeout)
        try:
            if self._common is None:
                self._common = self._proxy('common')
            return self._common.version()
        except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as exc:
            raise OdooError(f'No se pudo contactar Odoo en {self.url}: {exc}') from exc
        finally:
            socket.setdefaulttimeout(prev)

    def authenticate(self) -> int:
        if self._uid:
            return self._uid
        prev = socket.getdefaulttimeout()
        socket.setdefaulttimeout(self.timeout)
        try:
            if self._common is None:
                self._common = self._proxy('common')
            uid = self._common.authenticate(self.db, self.username, self.secret, {})
            if not uid:
                raise OdooError(
                    'Autenticacion rechazada por Odoo. Revisa ODOO_DB, '
                    'ODOO_USERNAME y ODOO_API_KEY/ODOO_PASSWORD.'
                )
            self._uid = int(uid)
            self._models = self._proxy('object')
            return self._uid
        except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as exc:
            raise OdooError(f'Error autenticando con Odoo: {exc}') from exc
        finally:
            socket.setdefaulttimeout(prev)

    # ------------------------------------------------------------------ #
    # Llamadas genericas
    # ------------------------------------------------------------------ #
    def execute_kw(self, model: str, method: str, args: List[Any],
                   kwargs: Optional[Dict[str, Any]] = None) -> Any:
        uid = self.authenticate()
        prev = socket.getdefaulttimeout()
        socket.setdefaulttimeout(self.timeout)
        try:
            assert self._models is not None
            return self._models.execute_kw(
                self.db, uid, self.secret, model, method, args, kwargs or {}
            )
        except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as exc:
            raise OdooError(f'Error en {model}.{method}: {exc}') from exc
        finally:
            socket.setdefaulttimeout(prev)

    def search_read(self, model: str, domain: Optional[List[Any]] = None,
                    fields: Optional[List[str]] = None, *, limit: int = 0,
                    offset: int = 0, order: Optional[str] = None) -> List[Dict[str, Any]]:
        kwargs: Dict[str, Any] = {'fields': fields or []}
        if limit:
            kwargs['limit'] = int(limit)
        if offset:
            kwargs['offset'] = int(offset)
        if order:
            kwargs['order'] = order
        return self.execute_kw(model, 'search_read', [domain or []], kwargs)

    def fields_get(self, model: str) -> Dict[str, Any]:
        return self.execute_kw(
            model, 'fields_get', [],
            {'attributes': ['string', 'type', 'relation', 'required']},
        )

    def model_exists(self, model: str) -> bool:
        try:
            rows = self.search_read(
                'ir.model', [['model', '=', model]], ['model'], limit=1
            )
            return bool(rows)
        except OdooError:
            return False

    # ------------------------------------------------------------------ #
    # Diagnostico
    # ------------------------------------------------------------------ #
    def test_connection(self) -> Dict[str, Any]:
        """Verifica conexion + login y reporta estado de los modelos clave."""
        result: Dict[str, Any] = {
            'ok': False,
            'url': self.url,
            'db': self.db,
            'username': self.username,
        }
        ver = self.version()
        result['server_version'] = ver.get('server_version')
        result['protocol_version'] = ver.get('protocol_version')
        result['uid'] = self.authenticate()
        result['models'] = {
            'sale_order': {
                'name': self.model_sale_order,
                'exists': self.model_exists(self.model_sale_order),
            },
            'work_order': {
                'name': self.model_work_order,
                'exists': self.model_exists(self.model_work_order),
            },
            'bom': {
                'name': self.model_bom,
                'exists': self.model_exists(self.model_bom),
            },
        }
        result['ok'] = True
        return result

    def discover(self, model: str, *, sample: int = 1) -> Dict[str, Any]:
        """Devuelve los campos del modelo y un registro de ejemplo (para mapear)."""
        fields = self.fields_get(model)
        sample_rows = self.search_read(
            model, [], list(fields.keys()), limit=max(1, int(sample)), order='id desc'
        )
        return {'model': model, 'fields': fields, 'sample': sample_rows}
