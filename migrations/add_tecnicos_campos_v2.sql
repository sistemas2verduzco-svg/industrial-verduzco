-- Migración v2: Nuevos campos para tabla tecnicos
-- Ejecutar: docker exec -i catalogo_db psql -U catalogo_user -d catalogo_db < migrations/add_tecnicos_campos_v2.sql

ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS puesto              VARCHAR(120);
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS nss                 VARCHAR(30);
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS curp                VARCHAR(20);
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS tipo_sangre         VARCHAR(10);
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS alergias            VARCHAR(255);
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS contacto_emergencia VARCHAR(120);
ALTER TABLE tecnicos ADD COLUMN IF NOT EXISTS antiguedad          VARCHAR(60);
