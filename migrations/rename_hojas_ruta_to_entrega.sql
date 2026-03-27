-- Renombrar tabla principal y actualizar claves foráneas
BEGIN;

-- Renombrar tabla principal
ALTER TABLE hojas_ruta RENAME TO hojas_ruta_entrega;

-- Actualizar claves foráneas en estaciones_trabajo
ALTER TABLE estaciones_trabajo DROP CONSTRAINT IF EXISTS estaciones_trabajo_hoja_ruta_id_fkey;
ALTER TABLE estaciones_trabajo RENAME COLUMN hoja_ruta_id TO hoja_ruta_entrega_id;
ALTER TABLE estaciones_trabajo ADD COLUMN hoja_ruta_id INTEGER;
UPDATE estaciones_trabajo SET hoja_ruta_id = hoja_ruta_entrega_id;
ALTER TABLE estaciones_trabajo DROP COLUMN hoja_ruta_entrega_id;
ALTER TABLE estaciones_trabajo ADD CONSTRAINT estaciones_trabajo_hoja_ruta_id_fkey FOREIGN KEY (hoja_ruta_id) REFERENCES hojas_ruta_entrega(id) ON DELETE CASCADE;

-- Actualizar claves foráneas en hojas_ruta_flujo_logistica
ALTER TABLE hojas_ruta_flujo_logistica DROP CONSTRAINT IF EXISTS hojas_ruta_flujo_logistica_hoja_ruta_id_fkey;
ALTER TABLE hojas_ruta_flujo_logistica RENAME COLUMN hoja_ruta_id TO hoja_ruta_entrega_id;
ALTER TABLE hojas_ruta_flujo_logistica ADD COLUMN hoja_ruta_id INTEGER;
UPDATE hojas_ruta_flujo_logistica SET hoja_ruta_id = hoja_ruta_entrega_id;
ALTER TABLE hojas_ruta_flujo_logistica DROP COLUMN hoja_ruta_entrega_id;
ALTER TABLE hojas_ruta_flujo_logistica ADD CONSTRAINT hojas_ruta_flujo_logistica_hoja_ruta_id_fkey FOREIGN KEY (hoja_ruta_id) REFERENCES hojas_ruta_entrega(id);

-- Actualizar claves foráneas en entregas_parciales
ALTER TABLE entregas_parciales DROP CONSTRAINT IF EXISTS entregas_parciales_hoja_ruta_id_fkey;
ALTER TABLE entregas_parciales RENAME COLUMN hoja_ruta_id TO hoja_ruta_entrega_id;
ALTER TABLE entregas_parciales ADD COLUMN hoja_ruta_id INTEGER;
UPDATE entregas_parciales SET hoja_ruta_id = hoja_ruta_entrega_id;
ALTER TABLE entregas_parciales DROP COLUMN hoja_ruta_entrega_id;
ALTER TABLE entregas_parciales ADD CONSTRAINT entregas_parciales_hoja_ruta_id_fkey FOREIGN KEY (hoja_ruta_id) REFERENCES hojas_ruta_entrega(id);

-- Actualizar claves foráneas en hojas_ruta_cargas_historial
ALTER TABLE hojas_ruta_cargas_historial DROP CONSTRAINT IF EXISTS hojas_ruta_cargas_historial_hoja_ruta_id_fkey;
ALTER TABLE hojas_ruta_cargas_historial RENAME COLUMN hoja_ruta_id TO hoja_ruta_entrega_id;
ALTER TABLE hojas_ruta_cargas_historial ADD COLUMN hoja_ruta_id INTEGER;
UPDATE hojas_ruta_cargas_historial SET hoja_ruta_id = hoja_ruta_entrega_id;
ALTER TABLE hojas_ruta_cargas_historial DROP COLUMN hoja_ruta_entrega_id;
ALTER TABLE hojas_ruta_cargas_historial ADD CONSTRAINT hojas_ruta_cargas_historial_hoja_ruta_id_fkey FOREIGN KEY (hoja_ruta_id) REFERENCES hojas_ruta_entrega(id);

COMMIT;