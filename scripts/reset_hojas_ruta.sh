#!/usr/bin/env bash
# Reset de datos del modulo Hojas de Ruta para iniciar desde cero.
# Limpia:
#   - hojas_ruta
#   - estaciones_trabajo
#   - qc_estaciones (registros de QC ligados a hojas)
# Mantiene catalogos base (maquinas, claves, procesos, usuarios, etc).

set -euo pipefail

AUTO_YES=0
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
  AUTO_YES=1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker no esta instalado o no esta en PATH."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose no esta disponible."
  exit 1
fi

echo ""
echo "Se limpiaran tablas de hojas de ruta:"
echo "  - hojas_ruta"
echo "  - estaciones_trabajo"
echo "  - qc_estaciones"
echo ""

if [[ "$AUTO_YES" -ne 1 ]]; then
  read -r -p "Confirma reset total de hojas de ruta (yes/no): " RESP
  if [[ "$RESP" != "yes" ]]; then
    echo "Operacion cancelada."
    exit 0
  fi
fi

echo ""
echo "[1/3] Conteo previo"
docker compose exec -T db psql -U catalogo_user -d catalogo_db -c "
SELECT 'hojas_ruta' AS tabla, COUNT(*) AS total FROM hojas_ruta
UNION ALL
SELECT 'estaciones_trabajo', COUNT(*) FROM estaciones_trabajo
UNION ALL
SELECT 'qc_estaciones', COUNT(*) FROM qc_estaciones;
"

echo ""
echo "[2/3] Limpiando tablas..."
docker compose exec -T db psql -U catalogo_user -d catalogo_db -c "
TRUNCATE TABLE estaciones_trabajo, qc_estaciones, hojas_ruta RESTART IDENTITY CASCADE;
"

echo ""
echo "[3/3] Conteo posterior"
docker compose exec -T db psql -U catalogo_user -d catalogo_db -c "
SELECT 'hojas_ruta' AS tabla, COUNT(*) AS total FROM hojas_ruta
UNION ALL
SELECT 'estaciones_trabajo', COUNT(*) FROM estaciones_trabajo
UNION ALL
SELECT 'qc_estaciones', COUNT(*) FROM qc_estaciones;
"

echo ""
echo "Reset de hojas de ruta completado correctamente."
