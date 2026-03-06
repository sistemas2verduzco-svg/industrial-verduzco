#!/usr/bin/env bash
# Elimina claves compuestas (con '/') del modulo procesos y claves.
# Uso:
#   ./scripts/remove_composite_claves.sh [--yes]

set -euo pipefail

AUTO_YES=0
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
  AUTO_YES=1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker no esta en PATH"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose no disponible"
  exit 1
fi

echo "Se eliminaran claves con formato compuesto (con '/')."
echo "Afecta tablas: claves_producto y clave_procesos."

if [[ "$AUTO_YES" -ne 1 ]]; then
  read -r -p "Confirma eliminacion (yes/no): " RESP
  if [[ "$RESP" != "yes" ]]; then
    echo "Operacion cancelada."
    exit 0
  fi
fi

echo "\n[1/3] Conteo previo"
docker compose exec -T db psql -U catalogo_user -d catalogo_db -c "
SELECT COUNT(*) AS claves_compuestas FROM claves_producto WHERE clave LIKE '%/%';
"

echo "\n[2/3] Eliminando claves compuestas"
docker compose exec -T db psql -U catalogo_user -d catalogo_db -c "
DELETE FROM clave_procesos
WHERE clave_id IN (
  SELECT id FROM claves_producto WHERE clave LIKE '%/%'
);

DELETE FROM claves_producto
WHERE clave LIKE '%/%';
"

echo "\n[3/3] Conteo posterior"
docker compose exec -T db psql -U catalogo_user -d catalogo_db -c "
SELECT COUNT(*) AS claves_compuestas FROM claves_producto WHERE clave LIKE '%/%';
"

echo "\nLimpieza completada."
