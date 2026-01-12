import argparse
import os
import sys
from typing import Optional

# Obtener la ruta del directorio raíz (padre de tools/)
script_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.dirname(script_dir)
sys.path.insert(0, root_dir)

# Debug: mostrar rutas
print(f"Script dir: {script_dir}")
print(f"Root dir: {root_dir}")
print(f"Archivos en root: {os.listdir(root_dir)[:5]}")

import pandas as pd

from app import app, db
from models import ProcesoCatalogo, ClaveProducto, ClaveProceso


# --- Helpers --------------------------------------------------------------

def hhmmss(val: Optional[str]) -> Optional[str]:
    """Normalize a time-like value to HH:MM:SS; return None if empty/invalid."""
    if val is None:
        return None
    text = str(val).strip()
    if not text:
        return None
    try:
        td = pd.to_timedelta(text)
    except Exception:
        return None
    total_seconds = int(td.total_seconds())
    h, r = divmod(total_seconds, 3600)
    m, s = divmod(r, 60)
    return f"{h:02d}:{m:02d}:{s:02d}"


def load_dataframe(path: str, sheet: Optional[str]) -> pd.DataFrame:
    ext = os.path.splitext(path)[1].lower()
    if ext in (".xlsx", ".xls"):
        # Si no especifica hoja, usa la primera (0)
        sheet_name = sheet if sheet else 0
        df = pd.read_excel(path, sheet_name=sheet_name)
    else:
        df = pd.read_csv(path)
    
    # Mostrar columnas detectadas para debug
    print(f"Columnas detectadas: {list(df.columns)}")
    return df


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Mapea nombres de columnas flexibles a nombres estándar."""
    mapping = {
        'clave': ['clave', 'CLAVE', 'Clave', 'PROC.', 'proc'],
        'nombre_clave': ['nombre_clave', 'nombre clave', 'NOMBRE', 'nombre', 'Nombre'],
        'orden': ['orden', 'ORDEN', 'Orden', 'Nº', 'nº', 'no', 'NO'],
        'centro_trabajo': ['centro_trabajo', 'centro trabajo', 'CT', 'c.t.', 'C.T.', 'CENTRO_TRABAJO'],
        'operacion': ['operacion', 'OPERACIÓN', 'operación', 'OPERACION', 'operación', 'Operación'],
        'tiempo_estimado': ['tiempo_estimado', 'tiempo estimado', 't/e', 'T/E', 'T/E (HH:MM:SS)', 'TIEMPO_ESTIMADO'],
        'notas_paso': ['notas_paso', 'notas paso', 'notas', 'NOTAS', 'Notas', 'observaciones'],
        'notas_clave': ['notas_clave', 'notas clave', 'notas'],
    }
    
    # Crear mapeo inverso (columna actual -> columna estándar)
    col_map = {}
    for std_col, variants in mapping.items():
        for var in variants:
            if var in df.columns:
                col_map[var] = std_col
                break
    
    # Renombrar columnas
    df = df.rename(columns=col_map)
    df.columns = [c.strip().lower() for c in df.columns]
    
    print(f"Columnas mapeadas a: {list(df.columns)}")
    return df


# --- Import logic ---------------------------------------------------------

def import_file(path: str, sheet: Optional[str], overwrite: bool) -> None:
    df = load_dataframe(path, sheet)
    df = normalize_columns(df)

    required = {"clave", "orden", "centro_trabajo", "operacion", "tiempo_estimado"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Faltan columnas requeridas: {missing}\nColumnas disponibles: {list(df.columns)}")

    df = df.sort_values(["clave", "orden"])  # asegura orden correcto

    # Agrupamos por clave para poder limpiar secuencia por clave si overwrite=True
    grouped = df.groupby("clave", sort=False)

    with app.app_context():
        for clave_code, gdf in grouped:
            clave_code = str(clave_code).strip()
            if not clave_code:
                continue

            # Upsert de clave
            clave_obj = ClaveProducto.query.filter_by(clave=clave_code).first()
            if not clave_obj:
                clave_obj = ClaveProducto(clave=clave_code, activo=True)
                db.session.add(clave_obj)
                db.session.flush()

            # Actualizar nombre/notas si vienen
            nombre_clave = str(gdf.get("nombre_clave", pd.Series([None])).iloc[0] or "").strip()
            notas_clave = str(gdf.get("notas_clave", pd.Series([None])).iloc[0] or "").strip()
            if nombre_clave:
                clave_obj.nombre = nombre_clave
            if notas_clave:
                clave_obj.notas = notas_clave

            # Si overwrite, limpiar secuencia previa de esta clave
            if overwrite:
                ClaveProceso.query.filter_by(clave_id=clave_obj.id).delete()
                db.session.flush()

            # Cache local de procesos para esta corrida
            proc_cache = {}

            for _, row in gdf.iterrows():
                ct = str(row["centro_trabajo"]).strip()
                oper = str(row["operacion"]).strip()
                orden = int(row["orden"])
                t_e = hhmmss(row.get("tiempo_estimado"))
                notas_paso = str(row.get("notas_paso") or "").strip() or None

                if not ct or not oper:
                    continue

                key_proc = (ct.lower(), oper.lower())
                proc_obj = proc_cache.get(key_proc)
                if not proc_obj:
                    proc_obj = ProcesoCatalogo.query.filter_by(centro_trabajo=ct, operacion=oper).first()
                if not proc_obj:
                    proc_obj = ProcesoCatalogo(
                        centro_trabajo=ct,
                        operacion=oper,
                        nombre=oper,
                        activo=True,
                        tiempo_estimado=t_e,
                    )
                    db.session.add(proc_obj)
                    db.session.flush()
                proc_cache[key_proc] = proc_obj

                cp = ClaveProceso(
                    clave=clave_obj,
                    proceso=proc_obj,
                    orden=orden,
                    centro_trabajo=ct,
                    operacion=oper,
                    t_e=t_e,
                    notas=notas_paso,
                )
                db.session.add(cp)

        db.session.commit()


# --- CLI ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Importa claves y procesos desde CSV/Excel")
    parser.add_argument("--file", required=True, help="Ruta al CSV o Excel")
    parser.add_argument("--sheet", default=None, help="Nombre de hoja (solo Excel)")
    parser.add_argument("--overwrite", action="store_true", help="Sobrescribe la secuencia existente de cada clave")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"No se encuentra el archivo: {args.file}", file=sys.stderr)
        sys.exit(1)

    import_file(args.file, args.sheet, args.overwrite)
    print("Importación completada.")


if __name__ == "__main__":
    main()
