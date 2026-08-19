-- =============================================================================
-- MIGRACION ADITIVA / SEGURA PARA PRODUCCION
-- Materias primas de fabricacion en Hojas de ruta Entregas
-- Fecha: 2026-08-19
--
-- QUE HACE:
--   1) Crea catalogo_materias_primas SI NO EXISTE  (lista de materias primas)
--   2) Agrega el campo materias_primas_json a la hoja de entrega YA EXISTENTE
--
-- QUE NO HACE:
--   - NO crea otra tabla de hojas de ruta
--   - NO DROP / TRUNCATE / UPDATE de hojas
--   - NO toca la columna materia_prima (comentarios/QC)
-- =============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS catalogo_materias_primas (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(255) NULL,
    notas TEXT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NULL
);

CREATE INDEX IF NOT EXISTS ix_catalogo_materias_primas_activo
    ON catalogo_materias_primas (activo);

ALTER TABLE hojas_ruta_entrega
    ADD COLUMN IF NOT EXISTS materias_primas_json TEXT;

COMMIT;
