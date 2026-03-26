-- Agregar columnas a hojas_ruta_flujo_logistica para entregas parciales
ALTER TABLE hojas_ruta_flujo_logistica 
ADD COLUMN IF NOT EXISTS cantidad_total_piezas INTEGER,
ADD COLUMN IF NOT EXISTS cantidad_entregada INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS cantidad_pendiente INTEGER,
ADD COLUMN IF NOT EXISTS porcentaje_entregado FLOAT DEFAULT 0.0,
ADD COLUMN IF NOT EXISTS estado_parciales VARCHAR(30) DEFAULT 'pendientes';

-- Crear tabla entregas_parciales para registrar cada entrega parcial
CREATE TABLE IF NOT EXISTS entregas_parciales (
    id SERIAL PRIMARY KEY,
    flujo_id INTEGER NOT NULL REFERENCES hojas_ruta_flujo_logistica(id) ON DELETE CASCADE,
    hoja_ruta_id INTEGER NOT NULL REFERENCES hojas_ruta(id) ON DELETE CASCADE,
    cantidad_entregada INTEGER NOT NULL,
    usuario_entrega VARCHAR(120) NOT NULL,
    notas TEXT,
    fecha_entrega TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_entregas_parciales_flujo_id ON entregas_parciales(flujo_id);
CREATE INDEX IF NOT EXISTS idx_entregas_parciales_hoja_ruta_id ON entregas_parciales(hoja_ruta_id);
CREATE INDEX IF NOT EXISTS idx_entregas_parciales_fecha_entrega ON entregas_parciales(fecha_entrega);
