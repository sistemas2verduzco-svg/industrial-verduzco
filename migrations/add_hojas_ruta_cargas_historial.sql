CREATE TABLE IF NOT EXISTS hojas_ruta_cargas_historial (
    id SERIAL PRIMARY KEY,
    hoja_ruta_id INTEGER NOT NULL REFERENCES hojas_ruta(id) ON DELETE CASCADE,
    cantidad_anterior INTEGER NOT NULL DEFAULT 0,
    cantidad_cambio INTEGER NOT NULL DEFAULT 0,
    cantidad_nueva INTEGER NOT NULL DEFAULT 0,
    tipo_movimiento VARCHAR(30) NOT NULL DEFAULT 'ajuste',
    usuario VARCHAR(120),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_hojas_ruta_cargas_historial_hoja_ruta_id
    ON hojas_ruta_cargas_historial (hoja_ruta_id);

CREATE INDEX IF NOT EXISTS idx_hojas_ruta_cargas_historial_fecha_creacion
    ON hojas_ruta_cargas_historial (fecha_creacion);