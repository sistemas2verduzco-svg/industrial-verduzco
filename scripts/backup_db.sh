#!/bin/bash
# Simple backup script for PostgreSQL database
# Usage: ./scripts/backup_db.sh /path/to/backup/folder
# Supports running inside a Docker setup (uses docker compose if DB service name is 'db')

set -euo pipefail
BACKUP_DIR=${1:-"./backups"}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="backup_${TIMESTAMP}.sql"
mkdir -p "$BACKUP_DIR"

# If running inside Docker Compose environment where DB service is 'db'
if docker compose ps db >/dev/null 2>&1; then
  echo "Detected docker compose node 'db' - using docker exec pg_dump"
  docker compose exec -T db pg_dump -U catalogo_user catalogo_db > "$BACKUP_DIR/$FILENAME"
else
  # Try local pg_dump using DATABASE_URL
  if [ -z "${DATABASE_URL:-}" ]; then
    echo "DATABASE_URL not set. Provide it or run inside docker compose with service 'db'."
    exit 1
  fi
  echo "Using local pg_dump"
  # Parse DATABASE_URL like postgresql://user:pass@host:port/dbname
  export PGPASSWORD=$(echo "$DATABASE_URL" | sed -n 's|postgresql://[^:]*:\([^@]*\)@.*|\1|p')
  PGUSER=$(echo "$DATABASE_URL" | sed -n 's|postgresql://\([^:]*\):.*|\1|p')
  PGHOST=$(echo "$DATABASE_URL" | sed -n 's|postgresql://[^@]*@\([^:/]*\).*|\1|p')
  PGPORT=$(echo "$DATABASE_URL" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
  PGDB=$(echo "$DATABASE_URL" | sed -n 's|.*/\([^/?]*\).*|\1|p')
  pg_dump -h "$PGHOST" -U "$PGUSER" -p "$PGPORT" -F p -d "$PGDB" > "$BACKUP_DIR/$FILENAME"
fi

echo "Backup saved to $BACKUP_DIR/$FILENAME"
