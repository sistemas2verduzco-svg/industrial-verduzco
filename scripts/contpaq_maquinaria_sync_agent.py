import os
import sys
import json
import math
from datetime import datetime, date, timedelta

import pyodbc
import requests


CONTPAQ_MAQUINARIA_PEDIDOS_QUERY = """
SELECT
    dbo.docDocument.OwnedBusinessEntityID,
    dbo.docDocument.DocumentID,
    dbo.vwLBSBusinessEntityList.OfficialName AS BusinessEntityName,
    dbo.orgDepot.DepotName,
    ISNULL(dbo.docDocument.FolioPrefix, '') + ISNULL(dbo.docDocument.Folio, '') AS DocFolio,
    LTRIM(dbo.FORMAT(dbo.docDocument.DateDocument, N'YYYY-MM-DD')) AS DateDocument,
    dbo.docDocument.DateDocDelivery,
    dbo.docDocument.Title,
    dbo.vwLBSContactList.ContactName AS SalesRep,
    dbo.engRefCurrency.Currency,
    dbo.docDocument.Rate,
    CASE WHEN [docDocument].[CancelledOn] IS NULL THEN [docDocument].[SubTotal] ELSE 0 END AS SubTotal,
    CASE WHEN [docDocument].[CancelledOn] IS NULL THEN [docDocument].[Total] ELSE 0 END AS Total,
    CASE WHEN [docDocument].[CancelledOn] IS NULL THEN [docDocument].[TotalTax] ELSE 0 END AS TotalTax,
    dbo.docDocument.TotalDiscount,
    dbo.docDocument.TotalRetention,
    dbo.docDocument.TotalCost,
    CASE WHEN [docDocument].[PrintedOn] IS NULL THEN 0 ELSE 1 END AS Printed,
    CASE WHEN [docDocument].[ValidatedOn] IS NULL THEN 0 ELSE 1 END AS Validated,
    CASE WHEN [docDocument].[CancelledOn] IS NULL THEN 0 ELSE 1 END AS Cancelled,
    CASE WHEN [docDocument].[DeletedOn] IS NULL THEN 0 ELSE 1 END AS Deleted,
    CASE WHEN [docDocument].[UserID] > 0 THEN 1 ELSE 0 END AS InUse,
    dbo.docDocument.Comments,
    dbo.engPaymentTerm.PaymentTermName,
    dbo.vwcboLanguage.Value AS LanguageName,
    dbo.vwcboCostCenter.Value AS CostCenterName,
    dbo.vwcboCostCenter.ComboCategoryName AS CostCenterCategory,
    dbo.FORMAT(dbo.docDocument.DateDocument, N'yyyy mm') AS PeriodMonth,
    dbo.FORMAT(dbo.docDocument.DateDocument, N'yyyy ww') AS PeriodWeek,
    dbo.FORMAT(dbo.docDocument.DateDocument, N'yyyy') AS PeriodYear,
    dbo.FORMAT(dbo.docDocument.DateDocument, N'yyyy q') AS PeriodQuarter,
    dbo.orgCampaign.CampaignName,
    dbo.docDocument.CampaignID,
    dbo.engRefCurrency.IntlSymbol,
    dbo.vwLBSDocCustomerSalesTotalInvoiced.TotalInvoiced,
    CASE WHEN (ISNULL([vwLBSDocCustomerSalesTotalInvoiced].[TotalPaid], 0)) > 0 THEN [vwLBSDocCustomerSalesTotalInvoiced].[TotalPaid] ELSE [docDocument].[TotalPaid] END AS TotalInvoicePaid,
    dbo.docDocument.Total - CASE WHEN (ISNULL([vwLBSDocCustomerSalesTotalInvoiced].[TotalPaid], 0)) > 0 THEN [vwLBSDocCustomerSalesTotalInvoiced].[TotalPaid] ELSE [docDocument].[TotalPaid] END AS TotalInvoiceBalance,
    CASE WHEN (ISNULL([TotalInvoiced], 0)) > [Total] THEN 3 ELSE CASE WHEN (ISNULL([TotalInvoiced], 0)) = 0 THEN 0 ELSE CASE WHEN ABS((ISNULL([TotalInvoiced], 0)) - [Total]) < 1 THEN 2 ELSE 1 END END END AS Invoiced,
    dbo.docDocument.StatusDeliveryID,
    dbo.vwcboStatusDelivery.Value AS StatusDelivery,
    dbo.docDocument.TotalPaid,
    dbo.docDocument.Balance,
    dbo.docDocument.Globalized AS Globalizado,
    dbo.vwLBSBusinessEntityList.OfficialNumber AS RFC_Cliente,
    dbo.docDocumentCFD.MetodoPago,
    dbo.docDocumentCFD.FormaPago,
    dbo.vwLBSDocumentosTipoFacturacion.TipoFacturacion,
    dbo.vwLBSDocumentosTipoFacturacion.InvoiceDocumentID,
    depotDoc.DepotName AS Sucursal,
    CASE WHEN [docDocument].[AuthorizedOn] IS NOT NULL THEN 1 ELSE 0 END AS Auth1,
    CASE WHEN [docDocument].[Authorized2On] IS NOT NULL THEN 1 ELSE 0 END AS Auth2
FROM dbo.docDocument
LEFT OUTER JOIN dbo.vwLBSDocumentosTipoFacturacion ON dbo.docDocument.DocumentID = dbo.vwLBSDocumentosTipoFacturacion.DocumentID
LEFT OUTER JOIN dbo.vwLBSDocCustomerTicketsInvoiced ON dbo.docDocument.DocumentID = dbo.vwLBSDocCustomerTicketsInvoiced.DocumentID
LEFT OUTER JOIN dbo.docDocumentTax ON dbo.docDocument.DocumentID = dbo.docDocumentTax.DocumentID
LEFT OUTER JOIN dbo.docDocumentCFD ON dbo.docDocument.DocumentID = dbo.docDocumentCFD.DocumentID
LEFT OUTER JOIN dbo.vwcboStatusDelivery ON dbo.docDocument.StatusDeliveryID = dbo.vwcboStatusDelivery.ID
LEFT OUTER JOIN dbo.orgDepot ON dbo.docDocument.DepotID = dbo.orgDepot.DepotID
LEFT OUTER JOIN dbo.engRefCurrency ON dbo.docDocument.CurrencyID = dbo.engRefCurrency.CurrencyID
LEFT OUTER JOIN dbo.engPaymentTerm ON dbo.docDocument.PaymentTermID = dbo.engPaymentTerm.PaymentTermID
LEFT OUTER JOIN dbo.vwcboLanguage ON dbo.docDocument.LanguageID = dbo.vwcboLanguage.ID
LEFT OUTER JOIN dbo.vwcboCostCenter ON dbo.docDocument.CostCenterID = dbo.vwcboCostCenter.ID
LEFT OUTER JOIN dbo.orgCampaign ON dbo.docDocument.CampaignID = dbo.orgCampaign.CampaignID
LEFT OUTER JOIN dbo.vwLBSBusinessEntityList ON dbo.docDocument.BusinessEntityID = dbo.vwLBSBusinessEntityList.BusinessEntityID
LEFT OUTER JOIN dbo.vwLBSContactList ON dbo.docDocument.SalesRepContactID = dbo.vwLBSContactList.ContactID
LEFT OUTER JOIN dbo.vwLBSDocCustomerSalesTotalInvoiced ON dbo.docDocument.DocumentID = dbo.vwLBSDocCustomerSalesTotalInvoiced.DocumentID
LEFT OUTER JOIN dbo.docDocumentExtra ON dbo.docDocument.DocumentID = dbo.docDocumentExtra.DocumentID
LEFT OUTER JOIN dbo.orgDepot AS depotDoc ON dbo.docDocumentExtra.BusinessEntityDepotID = depotDoc.DepotID
WHERE dbo.docDocument.ModuleID = 967
  AND dbo.docDocument.DateDocument >= ?
  AND dbo.docDocument.DateDocument < ?
  AND ISNULL(dbo.docDocument.FolioPrefix, '') = 'E'
  AND ISNULL(dbo.vwcboStatusDelivery.Value, '') = 'NO ENTREGADO'
"""

CONTPAQ_MAQUINARIA_PEDIDOS_DETALLE_QUERY = """
SELECT
    dbo.vwLBSDocCustomerOrderAllModules.OwnedBusinessEntityID,
    dbo.vwLBSDocCustomerOrderAllModules.DocumentID,
    dbo.vwLBSDocCustomerOrderAllModules.BusinessEntityName,
    dbo.vwLBSDocCustomerOrderAllModules.DepotName,
    dbo.vwLBSDocCustomerOrderAllModules.DocFolio,
    dbo.vwLBSDocCustomerOrderAllModules.DateDocument,
    dbo.vwLBSDocCustomerOrderAllModules.Title,
    dbo.vwLBSDocCustomerOrderAllModules.SubTotal,
    dbo.vwLBSDocCustomerOrderAllModules.Total,
    dbo.vwLBSDocCustomerOrderAllModules.Deleted,
    dbo.vwLBSDocCustomerOrderAllModules.Cancelled,
    dbo.docDocumentItem.Quantity,
    dbo.docDocumentItem.ProductID,
    dbo.docDocumentItem.ProductKey,
    dbo.docDocumentItem.Description,
    dbo.docDocumentItem.DiscountPerc,
    dbo.docDocumentItem.TaxPerc,
    dbo.engTaxType.TaxTypeName,
    dbo.docDocumentItem.UnitPrice,
    dbo.docDocumentItem.Total AS TotalItem,
    dbo.docDocumentItem.LineNumber,
    dbo.docDocumentItem.Unit,
    dbo.docDocumentItem.ClaveUnidad,
    dbo.docDocumentItem.CoefUnit,
    dbo.vwLBSDocCustomerOrderAllModules.PeriodWeek,
    dbo.vwLBSDocCustomerOrderAllModules.PeriodMonth
FROM dbo.vwLBSDocCustomerOrderAllModules
INNER JOIN dbo.docDocumentItem ON dbo.vwLBSDocCustomerOrderAllModules.DocumentID = dbo.docDocumentItem.DocumentID
INNER JOIN dbo.engTaxType ON dbo.docDocumentItem.TaxTypeID = dbo.engTaxType.TaxTypeID
LEFT JOIN dbo.vwcboStatusDelivery ON dbo.vwLBSDocCustomerOrderAllModules.StatusDeliveryID = dbo.vwcboStatusDelivery.ID
WHERE dbo.docDocumentItem.DeletedOn IS NULL
  AND dbo.vwLBSDocCustomerOrderAllModules.ModuleID = 967
  AND dbo.vwLBSDocCustomerOrderAllModules.DateDocument >= ?
  AND dbo.vwLBSDocCustomerOrderAllModules.DateDocument < ?
  AND dbo.vwLBSDocCustomerOrderAllModules.DocFolio LIKE 'E%'
  AND ISNULL(dbo.vwcboStatusDelivery.Value, '') = 'NO ENTREGADO'
"""


def load_env_file():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(script_dir, 'contpaq_maquinaria_sync_agent.env')
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
    payload = []
    for row in rows:
        payload.append({key: serialize_value(value) for key, value in row.items()})
    return payload


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
        'maquinaria_pedidos': to_jsonable_rows(fetch_rows(conn, CONTPAQ_MAQUINARIA_PEDIDOS_QUERY, params)),
        'maquinaria_pedidos_detalle': to_jsonable_rows(fetch_rows(conn, CONTPAQ_MAQUINARIA_PEDIDOS_DETALLE_QUERY, params)),
    }


def main():
    load_env_file()

    cloud_url = os.getenv('CONTPAQ_MAQUINARIA_CLOUD_PUSH_URL', '').strip()
    api_key = os.getenv('SYNC_API_KEY', '').strip()
    start_date = parse_iso_date(os.getenv('CONTPAQ_MAQUINARIA_START_DATE', '2025-06-01'), 'CONTPAQ_MAQUINARIA_START_DATE')
    end_date = parse_iso_date(os.getenv('CONTPAQ_END_DATE'), 'CONTPAQ_END_DATE', date.today().isoformat())
    chunk_days = max(1, int(os.getenv('CONTPAQ_CHUNK_DAYS', '31') or '31'))
    request_timeout = max(60, int(os.getenv('CONTPAQ_REQUEST_TIMEOUT', '300') or '300'))

    if not cloud_url:
        raise RuntimeError('Falta CONTPAQ_MAQUINARIA_CLOUD_PUSH_URL.')
    if not api_key:
        raise RuntimeError('Falta SYNC_API_KEY para autenticacion con nube.')
    if end_date < start_date:
        raise RuntimeError('CONTPAQ_END_DATE no puede ser menor que CONTPAQ_MAQUINARIA_START_DATE.')

    conn = connect_sqlserver()
    try:
        total_windows = 0
        total_sent = {
            'maquinaria_pedidos': 0,
            'maquinaria_pedidos_detalle': 0,
        }

        for window_start, window_end in iterate_windows(start_date, end_date, chunk_days):
            total_windows += 1
            payload = build_payload(conn, window_start, window_end)
            counts = {key: len(value) for key, value in payload.items()}

            print('Ventana maquinaria', f'{window_start.isoformat()} -> {window_end.isoformat()}:', json.dumps(counts, ensure_ascii=False))

            if not any(counts.values()):
                print('Sin datos de maquinaria en esta ventana, se omite push.')
                continue

            response = requests.post(
                cloud_url,
                headers={'Content-Type': 'application/json', 'X-API-KEY': api_key},
                data=json.dumps(payload),
                timeout=request_timeout,
            )

            if response.status_code >= 400:
                print('Error push maquinaria:', response.status_code, response.text)
                return 1

            for key, value in counts.items():
                total_sent[key] += value

            print('Push exitoso maquinaria:', response.text)
    finally:
        conn.close()

    print('Sincronizacion maquinaria completa:', json.dumps({'desde': start_date.isoformat(), 'hasta': end_date.isoformat(), 'ventanas': total_windows, **total_sent}, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print('Fallo sync maquinaria agent:', str(exc))
        sys.exit(1)
