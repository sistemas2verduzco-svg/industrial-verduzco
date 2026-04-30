-- Tabla para snapshot de existencias CONTPAQ por sucursal/producto
CREATE TABLE IF NOT EXISTS contpaq_existencias_stock (
    id SERIAL PRIMARY KEY,
    owned_business_entity_id BIGINT NULL,
    product_id BIGINT NULL,
    depot_id BIGINT NULL,
    depot_name VARCHAR(255) NULL,
    depot_type_id INTEGER NULL,
    product_key VARCHAR(120) NULL,
    product_name TEXT NULL,
    category1 VARCHAR(255) NULL,
    category2 VARCHAR(255) NULL,
    unit VARCHAR(60) NULL,
    matrix_key1 VARCHAR(120) NULL,
    matrix_key2 VARCHAR(120) NULL,
    qty_present DOUBLE PRECISION NULL,
    qty_available DOUBLE PRECISION NULL,
    qty_to_deliver_customer DOUBLE PRECISION NULL,
    qty_to_receive_supplier DOUBLE PRECISION NULL,
    qty_on_transit DOUBLE PRECISION NULL,
    qty_to_receive DOUBLE PRECISION NULL,
    qty_max_contpaq DOUBLE PRECISION NULL,
    qty_min_contpaq DOUBLE PRECISION NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_contpaq_existencia_depot_producto_matrix
ON contpaq_existencias_stock (
    depot_id,
    product_id,
    COALESCE(matrix_key1, ''),
    COALESCE(matrix_key2, '')
);

CREATE INDEX IF NOT EXISTS ix_contpaq_existencias_stock_product_key ON contpaq_existencias_stock (product_key);
CREATE INDEX IF NOT EXISTS ix_contpaq_existencias_stock_depot_name ON contpaq_existencias_stock (depot_name);
CREATE INDEX IF NOT EXISTS ix_contpaq_existencias_stock_category1 ON contpaq_existencias_stock (category1);
CREATE INDEX IF NOT EXISTS ix_contpaq_existencias_stock_category2 ON contpaq_existencias_stock (category2);
CREATE INDEX IF NOT EXISTS ix_contpaq_existencias_stock_updated_at ON contpaq_existencias_stock (updated_at);
