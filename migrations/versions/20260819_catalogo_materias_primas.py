revision = '20260819_catalogo_materias_primas'
down_revision = '20260518_hoja_en_produccion'
branch_labels = None
depends_on = None
"""
Migracion ADITIVA: catalogo de materias primas + tabla puente de hojas Entregas.
No toca hojas_ruta_entrega.materia_prima ni datos de produccion.
Downgrade intencional: no borra nada (produccion).
"""
from alembic import op


def upgrade():
    op.execute("""
        CREATE TABLE IF NOT EXISTS catalogo_materias_primas (
            id SERIAL PRIMARY KEY,
            clave VARCHAR(100) NOT NULL UNIQUE,
            nombre VARCHAR(255) NULL,
            notas TEXT NULL,
            activo BOOLEAN NOT NULL DEFAULT TRUE,
            fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            fecha_actualizacion TIMESTAMP NULL
        )
    """)
    op.execute("""
        CREATE INDEX IF NOT EXISTS ix_catalogo_materias_primas_activo
            ON catalogo_materias_primas (activo)
    """)
    op.execute("""
        CREATE TABLE IF NOT EXISTS hojas_ruta_entrega_materias_primas (
            id SERIAL PRIMARY KEY,
            hoja_ruta_id INTEGER NOT NULL REFERENCES hojas_ruta_entrega(id),
            catalogo_mp_id INTEGER NULL,
            clave_producto_id INTEGER NULL,
            clave VARCHAR(100) NOT NULL,
            nombre VARCHAR(255) NULL,
            orden INTEGER NOT NULL DEFAULT 0,
            fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    op.execute("""
        CREATE INDEX IF NOT EXISTS ix_hoja_entrega_mp_hoja_ruta_id
            ON hojas_ruta_entrega_materias_primas (hoja_ruta_id)
    """)
    op.execute("""
        CREATE INDEX IF NOT EXISTS ix_hoja_entrega_mp_catalogo_mp_id
            ON hojas_ruta_entrega_materias_primas (catalogo_mp_id)
    """)
    op.execute("""
        ALTER TABLE hojas_ruta_entrega_materias_primas
            ADD COLUMN IF NOT EXISTS catalogo_mp_id INTEGER
    """)
    op.execute("""
        DO $$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM pg_constraint WHERE conname = 'uq_hoja_entrega_mp_clave'
            ) THEN
                ALTER TABLE hojas_ruta_entrega_materias_primas
                    ADD CONSTRAINT uq_hoja_entrega_mp_clave UNIQUE (hoja_ruta_id, clave);
            END IF;
        END $$
    """)


def downgrade():
    # Produccion: no se eliminan tablas ni columnas.
    pass
