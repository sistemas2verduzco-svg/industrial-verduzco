#!/usr/bin/env bash
# Importa claves y procesos desde Excel al modulo "Procesos y Claves".
# Uso:
#   ./scripts/import_procesos_excel.sh /ruta/al/archivo.xlsx [hoja]
# Ejemplos:
#   ./scripts/import_procesos_excel.sh ./data/CLAVES_PROCESOS.xlsx
#   ./scripts/import_procesos_excel.sh ./data/CLAVES_PROCESOS.xlsx "Hoja1"

set -euo pipefail

FILE_PATH="${1:-}"
SHEET_NAME="${2:-}"

if [[ -z "$FILE_PATH" ]]; then
  echo "Uso: ./scripts/import_procesos_excel.sh /ruta/al/archivo.xlsx [hoja]"
  exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "ERROR: No se encontro el archivo: $FILE_PATH"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -n "$SHEET_NAME" ]]; then
  echo "Importando desde archivo: $FILE_PATH (hoja: $SHEET_NAME)"
  python tools/import_procesos.py --file "$FILE_PATH" --sheet "$SHEET_NAME" --overwrite
else
  echo "Importando desde archivo: $FILE_PATH (hoja: primera)"
  python tools/import_procesos.py --file "$FILE_PATH" --overwrite
fi

echo "Importacion finalizada. Revisa el panel /procesos"
