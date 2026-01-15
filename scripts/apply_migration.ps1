# Script para aplicar migración de scrap/retrabajo en hojas_ruta
# Ejecutar en Windows

Write-Host "=== Aplicando migración: update_scrap_retrabajo.sql ===" -ForegroundColor Cyan

# Conectar por SSH y ejecutar en el servidor
$server = "192.168.1.69"
$user = "grupoverduzco"
$migracion = Get-Content "migrations\update_scrap_retrabajo.sql" -Raw

Write-Host "Conectando a servidor $server..." -ForegroundColor Yellow

ssh ${user}@${server} @"
cd /home/grupoverduzco/Documentos/industrial-verduzco
cat migrations/update_scrap_retrabajo.sql | docker compose exec -T db psql -U postgres -d catalogo_db
docker compose restart app
"@

Write-Host "=== Migración completada ===" -ForegroundColor Green
