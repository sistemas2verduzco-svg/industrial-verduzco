-- Empaque360 → MES: espejo de pedidos / cajas / pesos para portal de clientes
-- Ejecutar en PostgreSQL (catalogo_db) si create_all / ensure no corre solo.

CREATE TABLE IF NOT EXISTS empaque_pedidos (
    id SERIAL PRIMARY KEY,
    external_order_number VARCHAR(80) NOT NULL UNIQUE,
    order_date_utc TIMESTAMP NULL,
    customer_code VARCHAR(80) NOT NULL,
    customer_name VARCHAR(255) NULL,
    source_sales_order_id BIGINT NULL,
    last_activity_utc TIMESTAMP NULL,
    synced_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_empaque_pedidos_customer_code ON empaque_pedidos (customer_code);
CREATE INDEX IF NOT EXISTS ix_empaque_pedidos_order_date ON empaque_pedidos (order_date_utc);
CREATE INDEX IF NOT EXISTS ix_empaque_pedidos_last_activity ON empaque_pedidos (last_activity_utc);

CREATE TABLE IF NOT EXISTS empaque_pedido_items (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES empaque_pedidos(id) ON DELETE CASCADE,
    external_order_number VARCHAR(80) NOT NULL,
    source_line_number INTEGER NOT NULL DEFAULT 0,
    product_code VARCHAR(80) NOT NULL,
    product_name VARCHAR(255) NULL,
    quantity_ordered DOUBLE PRECISION NOT NULL DEFAULT 0,
    unit_weight_kg DOUBLE PRECISION NOT NULL DEFAULT 0,
    CONSTRAINT uq_empaque_pedido_item_line UNIQUE (external_order_number, source_line_number, product_code)
);
CREATE INDEX IF NOT EXISTS ix_empaque_pedido_items_pedido_id ON empaque_pedido_items (pedido_id);
CREATE INDEX IF NOT EXISTS ix_empaque_pedido_items_order ON empaque_pedido_items (external_order_number);

CREATE TABLE IF NOT EXISTS empaque_cajas (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES empaque_pedidos(id) ON DELETE CASCADE,
    external_order_number VARCHAR(80) NOT NULL,
    box_code VARCHAR(50) NOT NULL,
    source_packing_box_id BIGINT NULL,
    status INTEGER NOT NULL DEFAULT 1,
    max_weight_kg DOUBLE PRECISION NOT NULL DEFAULT 0,
    current_real_weight_kg DOUBLE PRECISION NOT NULL DEFAULT 0,
    opened_at_utc TIMESTAMP NULL,
    closed_at_utc TIMESTAMP NULL,
    CONSTRAINT uq_empaque_caja_order_box UNIQUE (external_order_number, box_code)
);
CREATE INDEX IF NOT EXISTS ix_empaque_cajas_pedido_id ON empaque_cajas (pedido_id);
CREATE INDEX IF NOT EXISTS ix_empaque_cajas_order ON empaque_cajas (external_order_number);
CREATE INDEX IF NOT EXISTS ix_empaque_cajas_box_code ON empaque_cajas (box_code);

CREATE TABLE IF NOT EXISTS empaque_movimientos (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES empaque_pedidos(id) ON DELETE CASCADE,
    external_order_number VARCHAR(80) NOT NULL,
    source_box_movement_id BIGINT NOT NULL UNIQUE,
    box_code VARCHAR(50) NOT NULL,
    product_code VARCHAR(80) NOT NULL,
    product_name VARCHAR(255) NULL,
    quantity_captured DOUBLE PRECISION NOT NULL DEFAULT 0,
    unit_weight_kg DOUBLE PRECISION NOT NULL DEFAULT 0,
    real_weight_kg DOUBLE PRECISION NOT NULL DEFAULT 0,
    observed_weight_per_piece_kg DOUBLE PRECISION NOT NULL DEFAULT 0,
    operator_name VARCHAR(120) NULL,
    captured_at_utc TIMESTAMP NULL
);
CREATE INDEX IF NOT EXISTS ix_empaque_movimientos_pedido_id ON empaque_movimientos (pedido_id);
CREATE INDEX IF NOT EXISTS ix_empaque_movimientos_order ON empaque_movimientos (external_order_number);
CREATE INDEX IF NOT EXISTS ix_empaque_movimientos_box ON empaque_movimientos (box_code);

CREATE TABLE IF NOT EXISTS empaque_lineas_progreso (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES empaque_pedidos(id) ON DELETE CASCADE,
    external_order_number VARCHAR(80) NOT NULL,
    product_code VARCHAR(80) NOT NULL,
    source_line_number INTEGER NOT NULL DEFAULT 0,
    quantity_ordered DOUBLE PRECISION NOT NULL DEFAULT 0,
    quantity_packed DOUBLE PRECISION NOT NULL DEFAULT 0,
    updated_at_utc TIMESTAMP NULL,
    CONSTRAINT uq_empaque_progreso_line UNIQUE (external_order_number, product_code, source_line_number)
);
CREATE INDEX IF NOT EXISTS ix_empaque_lineas_progreso_pedido_id ON empaque_lineas_progreso (pedido_id);
CREATE INDEX IF NOT EXISTS ix_empaque_lineas_progreso_order ON empaque_lineas_progreso (external_order_number);

CREATE TABLE IF NOT EXISTS empaque_seguimiento_logs (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(80) NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    ip_cliente VARCHAR(64) NULL,
    user_agent TEXT NULL,
    resultado VARCHAR(40) NOT NULL DEFAULT 'invalido'
);
CREATE INDEX IF NOT EXISTS ix_empaque_seguimiento_logs_customer ON empaque_seguimiento_logs (customer_code);
CREATE INDEX IF NOT EXISTS ix_empaque_seguimiento_logs_fecha ON empaque_seguimiento_logs (fecha_hora);
CREATE INDEX IF NOT EXISTS ix_empaque_seguimiento_logs_resultado ON empaque_seguimiento_logs (resultado);
