-- Tablas para OTs de compra pendientes de CONTPAQ (solo lectura + asignacion local)

CREATE TABLE IF NOT EXISTS contpaq_supplier_ots (
    id SERIAL PRIMARY KEY,
    document_id BIGINT NOT NULL UNIQUE,
    doc_folio VARCHAR(80) NOT NULL,
    serie VARCHAR(20),
    proveedor VARCHAR(255),
    sucursal VARCHAR(255),
    titulo VARCHAR(255),
    fecha_documento TIMESTAMP,
    fecha_entrega TIMESTAMP,
    comentarios TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_doc_folio ON contpaq_supplier_ots (doc_folio);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_serie ON contpaq_supplier_ots (serie);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_proveedor ON contpaq_supplier_ots (proveedor);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_sucursal ON contpaq_supplier_ots (sucursal);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_fecha_documento ON contpaq_supplier_ots (fecha_documento);

CREATE TABLE IF NOT EXISTS contpaq_supplier_ots_detalle (
    id SERIAL PRIMARY KEY,
    ot_id INTEGER NOT NULL REFERENCES contpaq_supplier_ots(id) ON DELETE CASCADE,
    document_id BIGINT NOT NULL,
    product_id BIGINT,
    product_key VARCHAR(120) NOT NULL,
    product_name TEXT,
    qty_ordered DOUBLE PRECISION,
    qty_delivered DOUBLE PRECISION,
    qty_to_receive DOUBLE PRECISION,
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_contpaq_supplier_ot_clave UNIQUE (document_id, product_key)
);

CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_detalle_ot_id ON contpaq_supplier_ots_detalle (ot_id);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_detalle_document_id ON contpaq_supplier_ots_detalle (document_id);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_detalle_product_id ON contpaq_supplier_ots_detalle (product_id);
CREATE INDEX IF NOT EXISTS ix_contpaq_supplier_ots_detalle_product_key ON contpaq_supplier_ots_detalle (product_key);

CREATE TABLE IF NOT EXISTS hojas_ruta_entrega_ot_asignaciones (
    id SERIAL PRIMARY KEY,
    hoja_ruta_id INTEGER NOT NULL REFERENCES hojas_ruta_entrega(id) ON DELETE CASCADE,
    supplier_ot_detalle_id INTEGER NOT NULL REFERENCES contpaq_supplier_ots_detalle(id) ON DELETE CASCADE,
    document_id BIGINT NOT NULL,
    doc_folio VARCHAR(80) NOT NULL,
    product_key VARCHAR(120) NOT NULL,
    qty_assigned DOUBLE PRECISION NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_by VARCHAR(120),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    released_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_hoja ON hojas_ruta_entrega_ot_asignaciones (hoja_ruta_id);
CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_detalle ON hojas_ruta_entrega_ot_asignaciones (supplier_ot_detalle_id);
CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_document_id ON hojas_ruta_entrega_ot_asignaciones (document_id);
CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_doc_folio ON hojas_ruta_entrega_ot_asignaciones (doc_folio);
CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_product_key ON hojas_ruta_entrega_ot_asignaciones (product_key);
CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_status ON hojas_ruta_entrega_ot_asignaciones (status);
CREATE INDEX IF NOT EXISTS ix_hr_ot_asig_created_at ON hojas_ruta_entrega_ot_asignaciones (created_at);
