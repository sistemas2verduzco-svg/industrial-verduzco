#!/usr/bin/env python
"""
Clona plantillas para hojas existentes que aún no tengan estaciones.
Ejecutar dentro del contenedor de la app:
  python clone_plantillas_for_existing_hojas.py
"""
import sys
import os
sys.path.insert(0, '.')

from app import app
from models import db, HojaRuta, EstacionTrabajo, EstacionPlantilla, Máquina
from datetime import datetime


def run():
    with app.app_context():
        hojas = HojaRuta.query.order_by(HojaRuta.id.asc()).all()
        total_cloned = 0
        for hoja in hojas:
            count = EstacionTrabajo.query.filter_by(hoja_ruta_id=hoja.id).count()
            if count > 0:
                print(f'Hoja {hoja.id} ya tiene {count} estaciones; salto.')
                continue
            maquina = Máquina.query.get(hoja.maquina_id)
            if not maquina:
                print(f'Hoja {hoja.id}: máquina {hoja.maquina_id} no encontrada; salto.')
                continue
            tipo = maquina.tipo
            if not tipo:
                print(f'Hoja {hoja.id}: máquina {maquina.id} no tiene `tipo`; salto.')
                continue
            plantillas = EstacionPlantilla.query.filter_by(maquina_tipo=tipo).order_by(EstacionPlantilla.orden).all()
            if not plantillas:
                print(f'Hoja {hoja.id}: no hay plantillas para tipo "{tipo}"; salto.')
                continue
            for p in plantillas:
                est = EstacionTrabajo(
                    hoja_ruta_id=hoja.id,
                    pro_c=p.pro_c,
                    centro_trabajo=p.centro_trabajo,
                    operacion=p.operacion,
                    orden=p.orden,
                    t_e=p.t_e,
                    t_tct=p.t_tct,
                    t_tco=p.t_tco,
                    t_to=p.t_to,
                    fecha_creacion=datetime.utcnow()
                )
                db.session.add(est)
                total_cloned += 1
            try:
                db.session.commit()
                print(f'Hoja {hoja.id}: clonadas {len(plantillas)} estaciones de plantilla "{plantillas[0].plantilla_nombre}".')
            except Exception as e:
                db.session.rollback()
                print(f'Hoja {hoja.id}: error al commit: {e}')
        print(f'Terminado. Total estaciones clonadas: {total_cloned}')

if __name__ == '__main__':
    run()
