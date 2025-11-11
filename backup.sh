#!/bin/bash
# Script de backup automático para PostgreSQL
# Este script se ejecuta en el contenedor de la app y hace backup diario de la BD

BACKUP_DIR="/app/backups"
DB_NAME="catalogo_db"
DB_USER="catalogo_user"
DB_HOST="db"
DB_PORT="5432"

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Nombre del archivo de backup con timestamp
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"

# Crear backup
echo "[$(date)] Iniciando backup de PostgreSQL..."
PGPASSWORD="catalogo_pass" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup completado: $BACKUP_FILE"
    
    # Comprimir el backup
    gzip "$BACKUP_FILE"
    echo "[$(date)] Backup comprimido: ${BACKUP_FILE}.gz"
    
    # Mantener solo los últimos 7 días de backups
    find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +7 -delete
    echo "[$(date)] Backups antiguos eliminados (>7 días)"
else
    echo "[$(date)] Error en el backup"
    exit 1
fi
