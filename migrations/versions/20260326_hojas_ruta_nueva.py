"""
Migration: Crear tabla hojas_ruta_nueva para el nuevo módulo independiente
Fecha: 2026-03-26
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    op.create_table(
        'hojas_ruta_nueva',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('maquina_id', sa.Integer, sa.ForeignKey('maquinas.id'), nullable=True),
        sa.Column('nombre', sa.String(255), nullable=False),
        sa.Column('descripcion', sa.Text, nullable=True),
        sa.Column('estado', sa.String(20), default='activa'),
        sa.Column('producto', sa.String(255), nullable=True),
        sa.Column('calidad', sa.String(255), nullable=True),
        sa.Column('pn', sa.String(255), nullable=True),
        sa.Column('revision', sa.String(100), nullable=True),
        sa.Column('fecha_salida', sa.DateTime, nullable=True),
        sa.Column('cantidad_piezas', sa.Integer, nullable=True),
        sa.Column('orden_trabajo_hr', sa.String(100), nullable=True),
        sa.Column('orden_trabajo_pt', sa.String(100), nullable=True),
        sa.Column('almacen', sa.String(100), nullable=True),
        sa.Column('no_sin_orden', sa.String(100), nullable=True),
        sa.Column('materia_prima', sa.String(255), nullable=True),
        sa.Column('total_tiempo', sa.String(50), nullable=True),
        sa.Column('dias_a_laborar', sa.Float, nullable=True),
        sa.Column('fecha_termino', sa.DateTime, nullable=True),
        sa.Column('aprobada', sa.Boolean, default=False),
        sa.Column('rechazada', sa.Boolean, default=False),
        sa.Column('scrap', sa.String(255), nullable=True),
        sa.Column('retrabajo', sa.String(255), nullable=True),
        sa.Column('supervisor', sa.String(200), nullable=True),
        sa.Column('operador', sa.String(200), nullable=True),
        sa.Column('eficiencia', sa.Float, nullable=True),
        sa.Column('fecha_creacion', sa.DateTime, nullable=False, server_default=sa.func.now()),
        sa.Column('fecha_actualizacion', sa.DateTime, nullable=False, server_default=sa.func.now()),
    )

def downgrade():
    op.drop_table('hojas_ruta_nueva')
