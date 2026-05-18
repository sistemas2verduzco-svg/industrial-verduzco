revision = '20260518_hoja_en_produccion'
down_revision = '20260326_hojas_ruta_nueva'
branch_labels = None
depends_on = None
"""
Migration: Agregar campo hoja_en_produccion a hojas_ruta_entrega
Fecha: 2026-05-18
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    op.add_column(
        'hojas_ruta_entrega',
        sa.Column('hoja_en_produccion', sa.Boolean(), nullable=False, server_default=sa.false())
    )
    op.alter_column('hojas_ruta_entrega', 'hoja_en_produccion', server_default=None)


def downgrade():
    op.drop_column('hojas_ruta_entrega', 'hoja_en_produccion')
