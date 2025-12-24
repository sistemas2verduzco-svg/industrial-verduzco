#!/usr/bin/env python3
import argparse
from app import app, db
from models import Máquina, ComponenteMáquina

parser = argparse.ArgumentParser(description='Añadir una máquina y sus componentes')
parser.add_argument('--name', '-n', required=True, help='Nombre de la máquina')
parser.add_argument('--desc', '-d', default='', help='Descripción')
parser.add_argument('--imagen', '-i', default=None, help='URL o ruta de la imagen (opcional)')
parser.add_argument('--components', '-c', default='', help='Lista de componentes separados por comas')
args = parser.parse_args()

with app.app_context():
    m = Máquina(nombre=args.name, descripcion=args.desc, imagen_url=args.imagen)
    db.session.add(m)
    db.session.commit()
    comps = [x.strip() for x in args.components.split(',') if x.strip()]
    for idx, comp in enumerate(comps, start=1):
        cm = ComponenteMáquina(maquina_id=m.id, nombre=comp, descripcion='', orden=idx)
        db.session.add(cm)
    db.session.commit()
    print(f"Máquina creada: id={m.id}, nombre='{m.nombre}'")
    if comps:
        print('Componentes añadidos:')
        for comp in comps:
            print(f" - {comp}")
