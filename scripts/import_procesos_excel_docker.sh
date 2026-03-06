#!/usr/bin/env bash
# Importa claves/procesos desde Excel ejecutando el importador dentro del contenedor app.
# Uso:
#   ./scripts/import_procesos_excel_docker.sh /app/data/archivo.xlsx [hoja]
# Ejemplo:
#   ./scripts/import_procesos_excel_docker.sh /app/uploads/CLAVES_PROCESOS.xlsx
#   ./scripts/import_procesos_excel_docker.sh /app/uploads/CLAVES_PROCESOS.xlsx "Hoja1"

set -euo pipefail

EXCEL_PATH="${1:-}"
SHEET_NAME="${2:-}"

if [[ -z "$EXCEL_PATH" ]]; then
  echo "Uso: ./scripts/import_procesos_excel_docker.sh /app/ruta/archivo.xlsx [hoja]"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker no esta en PATH"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose no esta disponible"
  exit 1
fi

# Verificar que el archivo exista dentro del contenedor
if ! docker compose exec -T app sh -lc "test -f '$EXCEL_PATH'"; then
  echo "ERROR: No existe el archivo dentro del contenedor: $EXCEL_PATH"
  echo "Tip: verifica rutas con: docker compose exec -T app sh -lc 'find /app -maxdepth 4 -type f | grep -Ei \\.xlsx$|\\.xls$'"
  exit 1
fi

if [[ -n "$SHEET_NAME" ]]; then
  echo "Importando (docker) archivo: $EXCEL_PATH hoja: $SHEET_NAME"
  docker compose exec -T app python tools/import_procesos.py --file "$EXCEL_PATH" --sheet "$SHEET_NAME" --overwrite
else
  echo "Importando (docker) archivo: $EXCEL_PATH (hoja 1 por defecto)"
  docker compose exec -T app python tools/import_procesos.py --file "$EXCEL_PATH" --overwrite
fi

echo "Importacion completada. Revisa /procesos"
