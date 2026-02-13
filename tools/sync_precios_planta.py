import os
import json
import pyodbc
import requests
from datetime import datetime

API_URL = os.getenv('SYNC_API_URL', 'https://controlcalidad360.site/api/precios_compra_sync')
API_KEY = os.getenv('SYNC_API_KEY', '')

SQL_SERVER = os.getenv('SQLSERVER_HOST', 'SERVIDOR\\INSTANCIA')
SQL_DATABASE = os.getenv('SQLSERVER_DB', 'NOMBRE_DB')
SQL_USER = os.getenv('SQLSERVER_USER', 'USUARIO')
SQL_PASSWORD = os.getenv('SQLSERVER_PASSWORD', 'PASSWORD')

QUERY = """
WITH ultimos AS (
    SELECT
        di.ProductKey,
        di.Description,
        v.BusinessEntityName,
        di.UnitPrice,
        v.DateDocument,
        ROW_NUMBER() OVER (
            PARTITION BY di.ProductKey, v.BusinessEntityName
            ORDER BY v.DateDocument DESC
        ) AS rn
    FROM dbo.vwLBSDocSupplierPOAllModules v
    INNER JOIN dbo.docDocumentItem di ON v.DocumentID = di.DocumentID
    INNER JOIN dbo.engTaxType t ON di.TaxTypeID = t.TaxTypeID
    WHERE di.DeletedOn IS NULL
      AND v.ModuleID = 183
)
SELECT ProductKey, Description, BusinessEntityName, UnitPrice, DateDocument
FROM ultimos
WHERE rn = 1;
"""


def fetch_rows():
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"
        f"Server={SQL_SERVER};"
        f"Database={SQL_DATABASE};"
        f"UID={SQL_USER};PWD={SQL_PASSWORD};"
        "TrustServerCertificate=yes;"
    )
    with pyodbc.connect(conn_str) as conn:
        cur = conn.cursor()
        cur.execute(QUERY)
        columns = [c[0] for c in cur.description]
        rows = []
        for row in cur.fetchall():
            data = dict(zip(columns, row))
            # Normalize datetime to ISO string
            if isinstance(data.get('DateDocument'), datetime):
                data['DateDocument'] = data['DateDocument'].isoformat()
            rows.append(data)
        return rows


def push_rows(items):
    headers = {
        'Content-Type': 'application/json',
        'X-API-KEY': API_KEY
    }
    payload = {'items': items}
    resp = requests.post(API_URL, headers=headers, data=json.dumps(payload), timeout=60)
    resp.raise_for_status()
    return resp.json()


def main():
    if not API_KEY:
        raise SystemExit('SYNC_API_KEY no configurado')

    items = fetch_rows()
    if not items:
        print('Sin datos para sincronizar')
        return

    result = push_rows(items)
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
