-- Tablas para almacenar notas de venta relacionadas a pedidos de CONTPAQ

CREATE TABLE IF NOT EXISTS contpaq_notas_venta (
    id SERIAL PRIMARY KEY,
    document_id BIGINT NOT NULL UNIQUE,
    source_document_id BIGINT,
    destination_document_id BIGINT,
    doc_folio VARCHAR(80) NOT NULL,
    cliente VARCHAR(255),
    sucursal VARCHAR(255),
    fecha_documento TIMESTAMP,
    subtotal DOUBLE PRECISION,
    total DOUBLE PRECISION,
    total_paid DOUBLE PRECISION,
    total_invoice_paid DOUBLE PRECISION,
    total_invoice_balance DOUBLE PRECISION,
    balance DOUBLE PRECISION,
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_contpaq_notas_venta_document_id ON contpaq_notas_venta (document_id);
CREATE INDEX IF NOT EXISTS ix_contpaq_notas_venta_source_document_id ON contpaq_notas_venta (source_document_id);
CREATE INDEX IF NOT EXISTS ix_contpaq_notas_venta_destination_document_id ON contpaq_notas_venta (destination_document_id);
CREATE INDEX IF NOT EXISTS ix_contpaq_notas_venta_doc_folio ON contpaq_notas_venta (doc_folio);
CREATE INDEX IF NOT EXISTS ix_contpaq_notas_venta_cliente ON contpaq_notas_venta (cliente);
CREATE INDEX IF NOT EXISTS ix_contpaq_notas_venta_fecha_documento ON contpaq_notas_venta (fecha_documento);

ALTER TABLE contpaq_sync_runs
    ADD COLUMN IF NOT EXISTS notas_venta_upserted INTEGER NOT NULL DEFAULT 0;
