#!/usr/bin/env bash
# Carga datos de demostracion para presentacion:
# - Importa procesos/claves desde Excel
# - Crea usuarios demo
# - Crea maquinas demo
# - Crea hojas de ruta demo (asignadas y pendientes)
#
# Uso:
#   ./scripts/setup_demo_presentacion.sh
#   ./scripts/setup_demo_presentacion.sh --reset

set -euo pipefail

DO_RESET=0
if [[ "${1:-}" == "--reset" ]]; then
  DO_RESET=1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker no esta en PATH"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose no disponible"
  exit 1
fi

echo "[DEMO] Levantando servicios base..."
docker compose up -d app db nginx

if [[ "$DO_RESET" -eq 1 ]]; then
  echo "[DEMO] Reset de hojas/estaciones/QC..."
  ./scripts/reset_hojas_ruta.sh --yes
fi

echo "[DEMO] Importando claves/procesos desde /app/data/procesos.xlsx (hoja TIEMPOS)..."
./scripts/import_procesos_excel_docker.sh /app/data/procesos.xlsx TIEMPOS || {
  echo "[DEMO] Advertencia: fallo import en TIEMPOS, intentando hoja por defecto..."
  ./scripts/import_procesos_excel_docker.sh /app/data/procesos.xlsx
}

echo "[DEMO] Creando dataset de presentacion..."
docker compose exec -T app python - <<'PY'
from datetime import datetime

from app import app, db
import models

Usuario = models.Usuario
Maquina = getattr(models, 'Máquina')
HojaRuta = models.HojaRuta
EstacionTrabajo = models.EstacionTrabajo
ClaveProducto = models.ClaveProducto
ClaveProceso = models.ClaveProceso


def ensure_user(username, password, correo=None, is_admin=False):
    u = Usuario.query.filter_by(username=username).first()
    if u:
        return u
    u = Usuario(username=username, correo=correo, es_admin=is_admin, activo=True)
    u.set_password(password)
    db.session.add(u)
    db.session.flush()
    return u


def ensure_machine(nombre, tipo, descripcion):
    m = Maquina.query.filter_by(nombre=nombre).first()
    if m:
        return m
    m = Maquina(nombre=nombre, tipo=tipo, descripcion=descripcion, activo=True)
    db.session.add(m)
    db.session.flush()
    return m


def build_estaciones(hoja_id, clave_id):
    cps = ClaveProceso.query.filter_by(clave_id=clave_id).order_by(ClaveProceso.orden.asc()).all()
    estaciones = []
    for idx, cp in enumerate(cps, start=1):
        est = EstacionTrabajo(
            hoja_ruta_id=hoja_id,
            nombre=(cp.operacion or cp.proceso.operacion or cp.proceso.nombre or f"Proceso {idx}"),
            pro_c=str(idx),
            centro_trabajo=(cp.centro_trabajo or cp.proceso.centro_trabajo or ''),
            operacion=(cp.operacion or cp.proceso.operacion or cp.proceso.nombre or ''),
            orden=cp.orden or idx,
            t_e=cp.t_e or cp.proceso.tiempo_estimado or '',
            t_tct=cp.t_tct or '',
            t_tco=cp.t_tco or '',
            t_to=cp.t_to or '',
            estado='pendiente',
        )
        db.session.add(est)
        estaciones.append(est)
    return estaciones


with app.app_context():
    # Usuarios de presentacion
    ensure_user('admin', 'admin123', 'admin@example.com', True)
    ensure_user('jefe_demo', 'demo123', 'jefe_demo@controlcalidad360.site', False)

    # Maquinas de presentacion
    m1 = ensure_machine('CNC-01 DEMO', 'CNC', 'Centro maquinado demo')
    m2 = ensure_machine('TORNO-01 DEMO', 'TORNO', 'Torno demo')
    m3 = ensure_machine('FRESA-01 DEMO', 'FRESADORA', 'Fresadora demo')

    # Tomar claves con procesos
    claves = (
        db.session.query(ClaveProducto)
        .join(ClaveProceso, ClaveProceso.clave_id == ClaveProducto.id)
        .distinct()
        .order_by(ClaveProducto.id.asc())
        .limit(3)
        .all()
    )

    if not claves:
        raise RuntimeError('No hay claves con procesos. Revisa importacion de /app/data/procesos.xlsx')

    now = datetime.utcnow()

    # Limpiar hojas demo previas para evitar duplicados visuales
    hojas_previas = HojaRuta.query.filter(HojaRuta.nombre.like('DEMO-HR-%')).all()
    for h in hojas_previas:
        db.session.delete(h)
    db.session.flush()

    def make_hoja(idx, clave, maquina=None, piezas=25):
        hoja = HojaRuta(
            maquina_id=maquina.id if maquina else None,
            nombre=f"DEMO-HR-{now.strftime('%Y%m%d')}-{idx:03d}",
            descripcion='Hoja de presentacion para demo ejecutiva',
            estado='activa',
            producto=clave.nombre or clave.clave,
            calidad='Evelyn',
            pn=clave.clave,
            revision='A',
            fecha_salida=now,
            cantidad_piezas=piezas,
            orden_trabajo_hr=f"OT-DEMO-{idx:03d}",
            almacen='Maquinaria',
            supervisor='AUTORIZADO',
            operador='AUTORIZADO',
            aprobada=False,
            rechazada=False,
        )
        db.session.add(hoja)
        db.session.flush()
        estaciones = build_estaciones(hoja.id, clave.id)
        return hoja, estaciones

    # Hoja 1: asignada a CNC, en proceso
    hoja1, est1 = make_hoja(1, claves[0], maquina=m1, piezas=30)
    for e in est1[:2]:
        e.estado = 'completada'
        e.fecha_finalizacion = now
    if len(est1) > 2:
        est1[2].estado = 'en_proceso'

    # Hoja 2: pendiente de asignar, con procesos completados para que salga en Control Calidad
    hoja2, est2 = make_hoja(2, claves[1 if len(claves) > 1 else 0], maquina=None, piezas=20)
    for e in est2[:2]:
        e.estado = 'completada'
        e.fecha_finalizacion = now

    # Hoja 3: pendiente sin completar
    hoja3, est3 = make_hoja(3, claves[2 if len(claves) > 2 else 0], maquina=None, piezas=15)
    if est3:
        est3[0].estado = 'pendiente'

    db.session.commit()

    print('\n[DEMO] Datos cargados correctamente')
    print('Usuarios: admin/admin123, jefe_demo/demo123')
    print(f'Maquinas demo: {m1.nombre}, {m2.nombre}, {m3.nombre}')
    print(f'Hojas demo: {hoja1.nombre}, {hoja2.nombre}, {hoja3.nombre}')
PY

echo "[DEMO] Listo. Para presentar:"
echo "  1) /hojas_ruta       (Estaciones T)"
echo "  2) /control_calidad  (revisar DEMO-HR)"
echo "  3) /mapa_maquinas    (estado visual)"
echo "  4) /hojas_ruta_form  (ver/editar hojas demo)"
