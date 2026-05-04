-- Migracion: checks de especialidades para credencial de seguridad
-- Ejecutar: docker exec -i catalogo_db psql -U catalogo_user -d catalogo_db < migrations/add_tecnicos_especialidades_seguridad.sql

ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_alturas BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_maniobras_baja BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_electricos BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_trabajos_caliente BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_espacios_confinados BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_excavaciones BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS esp_maquinaria BOOLEAN NOT NULL DEFAULT FALSE;
