-- =============================================================================
-- MIGRACION ADITIVA / SEGURA PARA PRODUCCION
-- Materias primas de fabricacion (Hojas de ruta Entregas)
-- Fecha: 2026-08-19
--
-- QUE HACE:
--   1) Crea catalogo_materias_primas SI NO EXISTE
--   2) Crea hojas_ruta_entrega_materias_primas SI NO EXISTE
--   3) Agrega catalogo_mp_id SI NO EXISTE (nullable, no reescribe filas)
--
-- QUE NO HACE (a proposito):
--   - NO DROP TABLE / DROP COLUMN
--   - NO TRUNCATE
--   - NO UPDATE de hojas existentes
--   - NO toca hojas_ruta_entrega ni hojas_ruta_nueva
--   - NO toca la columna materia_prima (esa es de comentarios/QC)
--   - NO borra claves de producto ni procesos
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

CREATE TABLE IF NOT EXISTS hojas_ruta_entrega_materias_primas (
    id SERIAL PRIMARY KEY,
    hoja_ruta_id INTEGER NOT NULL REFERENCES hojas_ruta_entrega(id),
    catalogo_mp_id INTEGER NULL,
    clave_producto_id INTEGER NULL,
    clave VARCHAR(100) NOT NULL,
    nombre VARCHAR(255) NULL,
    orden INTEGER NOT NULL DEFAULT 0,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_hoja_entrega_mp_hoja_ruta_id
    ON hojas_ruta_entrega_materias_primas (hoja_ruta_id);

CREATE INDEX IF NOT EXISTS ix_hoja_entrega_mp_catalogo_mp_id
    ON hojas_ruta_entrega_materias_primas (catalogo_mp_id);

ALTER TABLE hojas_ruta_entrega_materias_primas
    ADD COLUMN IF NOT EXISTS catalogo_mp_id INTEGER;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_hoja_entrega_mp_clave'
    ) THEN
        ALTER TABLE hojas_ruta_entrega_materias_primas
            ADD CONSTRAINT uq_hoja_entrega_mp_clave UNIQUE (hoja_ruta_id, clave);
    END IF;
END $$;

COMMIT;
