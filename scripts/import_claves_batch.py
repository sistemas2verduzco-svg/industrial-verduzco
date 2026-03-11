#!/usr/bin/env python3
"""Importador masivo de claves y secuencias de procesos.

Uso:
  python scripts/import_claves_batch.py scripts/import_claves_batch_template.json

Formato esperado (JSON):
{
  "groups": [
    {
      "keys": [
        {"clave": "ABC-001", "nombre": "Pieza A", "notas": ""},
        {"clave": "ABC-002", "nombre": "Pieza B", "notas": ""}
      ],
      "processes": [
        {
          "orden": 1,
          "centro_trabajo": "TORNO",
          "operacion": "DESBASTE",
          "t_e": "00:03:20",
          "t_tct": "",
          "t_tco": "",
          "t_to": "",
          "tiempo_estimado": "00:03:20",
          "notas": ""
        }
      ]
    },
    {
      "keys": [
        {"clave": "XYZ-100", "nombre": "Pieza C", "notas": ""}
      ],
      "copy_processes_from_key": "ABC-001"
    }
  ]
}
"""

import json
import sys
from datetime import datetime

from app import app
from models import db, ClaveProducto, ClaveProceso, ProcesoCatalogo


def _norm(v):
    return (v or "").strip()


def _upsert_catalog_process(proc):
    ct = _norm(proc.get("centro_trabajo"))
    oper = _norm(proc.get("operacion"))
    nombre = _norm(proc.get("nombre")) or oper or "Operacion"
    te = _norm(proc.get("t_e")) or _norm(proc.get("tiempo_estimado"))
    descripcion = _norm(proc.get("descripcion"))

    q = ProcesoCatalogo.query.filter_by(
        centro_trabajo=ct,
        operacion=oper,
        nombre=nombre,
    ).first()
    if q:
        if te and not q.tiempo_estimado:
            q.tiempo_estimado = te
        if descripcion and not q.descripcion:
            q.descripcion = descripcion
        return q

    p = ProcesoCatalogo(
        codigo=None,
        nombre=nombre,
        operacion=oper,
        descripcion=descripcion,
        centro_trabajo=ct,
        tiempo_estimado=te,
        activo=True,
    )
    db.session.add(p)
    db.session.flush()
    return p


def _get_source_processes_from_key(source_key):
    clave = ClaveProducto.query.filter_by(clave=source_key).first()
    if not clave:
        raise ValueError(f"No existe la clave origen: {source_key}")

    rows = ClaveProceso.query.filter_by(clave_id=clave.id).order_by(ClaveProceso.orden.asc()).all()
    if not rows:
        raise ValueError(f"La clave origen no tiene secuencia: {source_key}")

    out = []
    for r in rows:
        out.append(
            {
                "orden": r.orden,
                "centro_trabajo": r.centro_trabajo or (r.proceso.centro_trabajo if r.proceso else ""),
                "operacion": r.operacion or (r.proceso.operacion if r.proceso else ""),
                "t_e": r.t_e or (r.proceso.tiempo_estimado if r.proceso else ""),
                "t_tct": r.t_tct or "",
                "t_tco": r.t_tco or "",
                "t_to": r.t_to or "",
                "tiempo_estimado": r.tiempo_estimado or "",
                "notas": r.notas or "",
            }
        )
    return out


def _upsert_key(key_item):
    clave_txt = _norm(key_item.get("clave"))
    if not clave_txt:
        raise ValueError("Cada key requiere 'clave'")

    nombre = _norm(key_item.get("nombre"))
    notas = _norm(key_item.get("notas"))

    obj = ClaveProducto.query.filter_by(clave=clave_txt).first()
    if obj:
        obj.nombre = nombre or obj.nombre
        obj.notas = notas
        obj.activo = True
        return obj, False

    obj = ClaveProducto(
        clave=clave_txt,
        nombre=nombre or clave_txt,
        notas=notas,
        activo=True,
    )
    db.session.add(obj)
    db.session.flush()
    return obj, True


def _replace_sequence(clave_obj, process_list):
    ClaveProceso.query.filter_by(clave_id=clave_obj.id).delete()
    db.session.flush()

    for idx, proc in enumerate(process_list, start=1):
        pcat = _upsert_catalog_process(proc)
        orden = int(proc.get("orden") or idx)
        cp = ClaveProceso(
            clave_id=clave_obj.id,
            proceso_id=pcat.id,
            orden=orden,
            centro_trabajo=_norm(proc.get("centro_trabajo")) or pcat.centro_trabajo,
            operacion=_norm(proc.get("operacion")) or pcat.operacion,
            t_e=_norm(proc.get("t_e")) or pcat.tiempo_estimado,
            t_tct=_norm(proc.get("t_tct")),
            t_tco=_norm(proc.get("t_tco")),
            t_to=_norm(proc.get("t_to")),
            tiempo_estimado=_norm(proc.get("tiempo_estimado")),
            notas=_norm(proc.get("notas")),
        )
        db.session.add(cp)


def main():
    if len(sys.argv) < 2:
        print("Uso: python scripts/import_claves_batch.py <ruta_json>")
        return 1

    cfg_path = sys.argv[1]
    with open(cfg_path, "r", encoding="utf-8") as f:
        payload = json.load(f)

    groups = payload.get("groups") or []
    if not groups:
        print("No hay groups en el JSON")
        return 1

    created = 0
    updated = 0
    with app.app_context():
        for gidx, group in enumerate(groups, start=1):
            keys = group.get("keys") or []
            if not keys:
                raise ValueError(f"Group {gidx} sin keys")

            process_list = group.get("processes") or []
            copy_from = _norm(group.get("copy_processes_from_key"))
            if not process_list:
                if not copy_from:
                    raise ValueError(f"Group {gidx} requiere 'processes' o 'copy_processes_from_key'")
                process_list = _get_source_processes_from_key(copy_from)

            for key_item in keys:
                clave_obj, was_created = _upsert_key(key_item)
                _replace_sequence(clave_obj, process_list)
                if was_created:
                    created += 1
                else:
                    updated += 1

        db.session.commit()

    print(f"Importación completada {datetime.now().isoformat()}")
    print(f"Claves creadas: {created}")
    print(f"Claves actualizadas: {updated}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
