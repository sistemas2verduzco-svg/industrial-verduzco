#!/bin/bash
# Script para aplicar migración de scrap/retrabajo en hojas_ruta
# Ejecutar en el servidor Debian

echo "=== Aplicando migración: update_scrap_retrabajo.sql ==="

# Opción 1: Copiar archivo al contenedor y ejecutar
docker compose cp migrations/update_scrap_retrabajo.sql db:/tmp/migration.sql
docker compose exec db psql -U postgres -d catalogo_db -f /tmp/migration.sql

# Opción 2: Ejecutar directamente con cat
# cat migrations/update_scrap_retrabajo.sql | docker compose exec -T db psql -U postgres -d catalogo_db

echo "=== Migración completada ==="
echo "Reiniciando contenedor app..."
docker compose restart app

echo "=== Listo ==="
