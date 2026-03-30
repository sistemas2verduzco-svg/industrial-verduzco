import os
import sys
import json
import math
from datetime import datetime

import pyodbc
import requests


CONTPAQ_PEDIDOS_QUERY = """
SELECT
    h.DocumentID,
    h.DocFolio,
    h.BusinessEntityName,
    h.Title,
    h.PeriodWeek,
    h.DateDocument,
    COALESCE(depotDoc.DepotName, h.DepotName, '') AS Sucursal
FROM dbo.vwLBSDocCustomerOrderAllModules h
LEFT JOIN dbo.docDocumentExtra dxe ON h.DocumentID = dxe.DocumentID
LEFT JOIN dbo.orgDepot depotDoc ON dxe.BusinessEntityDepotID = depotDoc.DepotID
WHERE h.ModuleID = 967
  AND h.BusinessEntityName = ?
  AND h.DateDocument >= ?
  AND (h.DocFolio LIKE 'P-%' OR h.DocFolio LIKE 'D%')
"""

CONTPAQ_PEDIDOS_DETALLE_QUERY = """
SELECT
    h.DocumentID,
    h.DocFolio,
    h.BusinessEntityName,
    h.Title,
    h.PeriodWeek,
    h.DateDocument,
    COALESCE(depotDoc.DepotName, h.DepotName, '') AS Sucursal,
    i.LineNumber,
    i.ProductKey,
    i.Description,
    i.Quantity,
    i.UnitPrice
FROM dbo.vwLBSDocCustomerOrderAllModules h
INNER JOIN dbo.docDocumentItem i ON h.DocumentID = i.DocumentID
LEFT JOIN dbo.docDocumentExtra dxe ON h.DocumentID = dxe.DocumentID
LEFT JOIN dbo.orgDepot depotDoc ON dxe.BusinessEntityDepotID = depotDoc.DepotID
WHERE i.DeletedOn IS NULL
  AND h.ModuleID = 967
  AND h.BusinessEntityName = ?
  AND h.DateDocument >= ?
  AND (h.DocFolio LIKE 'P-%' OR h.DocFolio LIKE 'D%')
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
  AND be.OfficialName = ?
  AND d.DateDocument >= ?
"""

CONTPAQ_REMISIONES_DETALLE_QUERY = """
SELECT
    h.DocumentID,
    h.DocFolio,
    h.BusinessEntityName,
    h.DateDocument,
    i.LineNumber,
    i.ProductKey,
    i.Description,
    i.Quantity,
    i.CostPrice
FROM dbo.vwLBSDocCustomerDeliveryAllModules h
INNER JOIN dbo.docDocumentItem i ON h.DocumentID = i.DocumentID
WHERE i.DeletedOn IS NULL
  AND h.ModuleID = 157
  AND h.BusinessEntityName = ?
  AND h.DateDocument >= ?
"""


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


def serialize_value(v):
    if isinstance(v, datetime):
        return v.isoformat()
    if isinstance(v, float):
        if not math.isfinite(v):
            return 0
    return v


def to_jsonable_rows(rows):
    out = []
    for row in rows:
        clean = {}
        for k, v in row.items():
            clean[k] = serialize_value(v)
        out.append(clean)
    return out


def main():
    cloud_url = os.getenv('CONTPAQ_CLOUD_PUSH_URL', '').strip()
    api_key = os.getenv('SYNC_API_KEY', '').strip()
    customer = os.getenv('CONTPAQ_CUSTOMER_NAME', 'RUTH VERDUZCO SANTOS').strip()
    start_date = os.getenv('CONTPAQ_START_DATE', '2025-01-01').strip()

    if not cloud_url:
        raise RuntimeError('Falta CONTPAQ_CLOUD_PUSH_URL.')
    if not api_key:
        raise RuntimeError('Falta SYNC_API_KEY para autenticacion con nube.')

    params = (customer, start_date)

    conn = connect_sqlserver()
    try:
        payload = {
            'pedidos': to_jsonable_rows(fetch_rows(conn, CONTPAQ_PEDIDOS_QUERY, params)),
            'pedidos_detalle': to_jsonable_rows(fetch_rows(conn, CONTPAQ_PEDIDOS_DETALLE_QUERY, params)),
            'remisiones': to_jsonable_rows(fetch_rows(conn, CONTPAQ_REMISIONES_QUERY, params)),
            'remisiones_detalle': to_jsonable_rows(fetch_rows(conn, CONTPAQ_REMISIONES_DETALLE_QUERY, params)),
        }
    finally:
        conn.close()

    response = requests.post(
        cloud_url,
        headers={'Content-Type': 'application/json', 'X-API-KEY': api_key},
        data=json.dumps(payload),
        timeout=120,
    )

    if response.status_code >= 400:
        print('Error push:', response.status_code, response.text)
        return 1

    print('Push exitoso:', response.text)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print('Fallo sync agent:', str(exc))
        sys.exit(1)
