revision = '20260819_catalogo_materias_primas'
down_revision = '20260518_hoja_en_produccion'
branch_labels = None
depends_on = None
"""
Migracion ADITIVA:
- catalogo_materias_primas (lista, no es hoja de ruta)
- campo materias_primas_json en hojas_ruta_entrega existente
No crea otra tabla de hojas. Downgrade no borra nada.
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
        ALTER TABLE hojas_ruta_entrega
            ADD COLUMN IF NOT EXISTS materias_primas_json TEXT
    """)


def downgrade():
    # Produccion: no se eliminan tablas ni columnas.
    pass
