-- Migración para agregar entregas parciales (segura - verificar columnas)
-- Ejecutar: psql -U usuario -d basedatos -f migrations/add_entregas_parciales_v2.sql

-- Agregar columnas a hojas_ruta_flujo_logistica si no existen
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hojas_ruta_flujo_logistica' AND column_name='cantidad_total_piezas') THEN
        ALTER TABLE hojas_ruta_flujo_logistica ADD COLUMN cantidad_total_piezas INTEGER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hojas_ruta_flujo_logistica' AND column_name='cantidad_entregada') THEN
        ALTER TABLE hojas_ruta_flujo_logistica ADD COLUMN cantidad_entregada INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hojas_ruta_flujo_logistica' AND column_name='cantidad_pendiente') THEN
        ALTER TABLE hojas_ruta_flujo_logistica ADD COLUMN cantidad_pendiente INTEGER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hojas_ruta_flujo_logistica' AND column_name='porcentaje_entregado') THEN
        ALTER TABLE hojas_ruta_flujo_logistica ADD COLUMN porcentaje_entregado FLOAT DEFAULT 0.0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hojas_ruta_flujo_logistica' AND column_name='estado_parciales') THEN
        ALTER TABLE hojas_ruta_flujo_logistica ADD COLUMN estado_parciales VARCHAR(30) DEFAULT 'pendientes';
    END IF;
END $$;

-- Crear tabla entregas_parciales si no existe
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

-- Crear índices si no existen
CREATE INDEX IF NOT EXISTS idx_entregas_parciales_flujo_id ON entregas_parciales(flujo_id);
CREATE INDEX IF NOT EXISTS idx_entregas_parciales_hoja_ruta_id ON entregas_parciales(hoja_ruta_id);
CREATE INDEX IF NOT EXISTS idx_entregas_parciales_fecha_entrega ON entregas_parciales(fecha_entrega);

-- Mensaje de confirmación
SELECT 'Migración completada: entregas parciales agregadas.' AS resultado;
