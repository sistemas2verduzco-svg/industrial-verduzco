#!/usr/bin/env bash
set -euo pipefail

# run_tests.sh
# Automatiza: crear .venv, instalar dependencias (opcional), instalar pip deps y ejecutar pytest.
# Uso:
#   # Ejecutar con instalación de paquetes del sistema (requerirá sudo/root):
#   sudo ./run_tests.sh
#   # O ejecutar sin instalar paquetes del sistema (menos intrusivo):
#   ./run_tests.sh --no-system
# Salida: test-results.txt en la raíz del proyecto

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

NO_SYSTEM=0
while [[ ${1:-} != "" ]]; do
  case "$1" in
    --no-system) NO_SYSTEM=1; shift ;;
    -h|--help) echo "Usage: $0 [--no-system]"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Paso 1: comprobar python3
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 no encontrado. Instala python3 en el sistema." >&2
  exit 2
fi

# Paso 2: crear venv si no existe
if [[ ! -d ".venv" ]]; then
  echo "Creando virtualenv .venv..."
  python3 -m venv .venv
fi

# Paso 3: (opcional) instalar dependencias del sistema necesarias para compilación
if [[ $NO_SYSTEM -eq 0 ]]; then
  echo "Instalando paquetes del sistema necesarios (requerirá apt). Si no quieres esto, reejecuta con --no-system"
  if [[ $EUID -ne 0 ]]; then
    echo "Usando sudo para apt-get...";
    sudo apt-get update
    sudo apt-get install -y build-essential python3-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libopenjp2-7-dev pkg-config libtiff5-dev tk-dev libpq-dev
  else
    apt-get update
    apt-get install -y build-essential python3-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libopenjp2-7-dev pkg-config libtiff5-dev tk-dev libpq-dev
  fi
else
  echo "Saltando instalación de paquetes del sistema (--no-system)."
fi

# Paso 4: activar venv e instalar pip deps mínimas
echo "Activando virtualenv..."
# shellcheck disable=SC1091
source .venv/bin/activate

echo "Actualizando pip, setuptools y wheel..."
python -m pip install --upgrade pip setuptools wheel

# Intentar instalar todos los requirements; si falla, caeremos a modo 'mínimo' para tests
if [[ -f requirements.txt ]]; then
  echo "Intentando pip install -r requirements.txt ..."
  if python -m pip install -r requirements.txt; then
    echo "requirements.txt instalado correctamente"
  else
    echo "WARNING: pip install -r requirements.txt falló. Instalando dependencias mínimas para tests..."
    python -m pip install Flask Flask-SQLAlchemy pytest pytest-flask
  fi
else
  echo "No existe requirements.txt: instalando dependencias mínimas para tests..."
  python -m pip install Flask Flask-SQLAlchemy pytest pytest-flask
fi

# Forzamos DATABASE_URL a sqlite local para evitar conectar a Postgres al importar app
export DATABASE_URL='sqlite:///test_db.sqlite'

# Ejecutar pytest
echo "Ejecutando pytest..."
pytest test_api.py -v | tee test-results.txt || true

RET=${PIPESTATUS[0]}

if [[ $RET -eq 0 ]]; then
  echo "\n=== TESTS PASADOS ==="
  tail -n 50 test-results.txt
else
  echo "\n=== TESTS FALLARON (exit code $RET) ==="
  tail -n 200 test-results.txt
fi

# Dejar virtualenv activo para inspección adicional
echo "Hecho. La salida quedó en test-results.txt. El virtualenv .venv está activado."
exit $RET
