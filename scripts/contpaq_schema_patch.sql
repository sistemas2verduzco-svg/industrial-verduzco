BEGIN;

ALTER TABLE IF EXISTS contpaq_sync_runs
    ADD COLUMN IF NOT EXISTS message TEXT,
    ADD COLUMN IF NOT EXISTS pedido_detalles_upserted INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS remision_detalles_upserted INTEGER NOT NULL DEFAULT 0;

ALTER TABLE IF EXISTS contpaq_pedidos
    ADD COLUMN IF NOT EXISTS serie VARCHAR(10),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'contpaq_pedidos'
          AND column_name = 'periodo_semana'
          AND data_type <> 'character varying'
    ) THEN
        ALTER TABLE contpaq_pedidos
            ALTER COLUMN periodo_semana TYPE VARCHAR(30)
            USING periodo_semana::text;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'product_key'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'clave_producto'
    ) THEN
        ALTER TABLE contpaq_pedidos_detalle RENAME COLUMN product_key TO clave_producto;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'description'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'descripcion'
    ) THEN
        ALTER TABLE contpaq_pedidos_detalle RENAME COLUMN description TO descripcion;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'quantity'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'cantidad'
    ) THEN
        ALTER TABLE contpaq_pedidos_detalle RENAME COLUMN quantity TO cantidad;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'unit_price'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_pedidos_detalle' AND column_name = 'precio_unitario'
    ) THEN
        ALTER TABLE contpaq_pedidos_detalle RENAME COLUMN unit_price TO precio_unitario;
    END IF;
END $$;

ALTER TABLE IF EXISTS contpaq_pedidos_detalle
    ADD COLUMN IF NOT EXISTS pedido_id INTEGER,
    ADD COLUMN IF NOT EXISTS total_partida DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_contpaq_pedidos_detalle_pedido'
    ) THEN
        ALTER TABLE contpaq_pedidos_detalle
            ADD CONSTRAINT fk_contpaq_pedidos_detalle_pedido
            FOREIGN KEY (pedido_id) REFERENCES contpaq_pedidos(id) ON DELETE CASCADE;
    END IF;
END $$;

ALTER TABLE IF EXISTS contpaq_remisiones
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'product_key'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'clave_producto'
    ) THEN
        ALTER TABLE contpaq_remisiones_detalle RENAME COLUMN product_key TO clave_producto;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'description'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'descripcion'
    ) THEN
        ALTER TABLE contpaq_remisiones_detalle RENAME COLUMN description TO descripcion;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'quantity'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'cantidad'
    ) THEN
        ALTER TABLE contpaq_remisiones_detalle RENAME COLUMN quantity TO cantidad;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'cost_price'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contpaq_remisiones_detalle' AND column_name = 'precio_unitario'
    ) THEN
        ALTER TABLE contpaq_remisiones_detalle RENAME COLUMN cost_price TO precio_unitario;
    END IF;
END $$;

ALTER TABLE IF EXISTS contpaq_remisiones_detalle
    ADD COLUMN IF NOT EXISTS remision_id INTEGER,
    ADD COLUMN IF NOT EXISTS total_partida DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_contpaq_remisiones_detalle_remision'
    ) THEN
        ALTER TABLE contpaq_remisiones_detalle
            ADD CONSTRAINT fk_contpaq_remisiones_detalle_remision
            FOREIGN KEY (remision_id) REFERENCES contpaq_remisiones(id) ON DELETE CASCADE;
    END IF;
END $$;

COMMIT;