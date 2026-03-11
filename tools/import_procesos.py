import argparse
import os
import sys
from typing import Optional
import re

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
    # Soportar nulos de pandas (NaN/NaT) sin romper la importacion
    try:
        if pd.isna(val):
            return None
    except Exception:
        pass

    text = str(val).strip()
    if not text or text.lower() in ('nan', 'nat', 'none', '-'):
        return None
    try:
        td = pd.to_timedelta(text)
    except Exception:
        return None
    try:
        if pd.isna(td):
            return None
    except Exception:
        pass

    total_seconds = int(td.total_seconds())
    h, r = divmod(total_seconds, 3600)
    m, s = divmod(r, 60)
    return f"{h:02d}:{m:02d}:{s:02d}"


def parse_excel_blocks(path: str, sheet: Optional[str]) -> pd.DataFrame:
    """Parse el Excel con formato de bloques repetidos por clave."""
    import re
    
    ext = os.path.splitext(path)[1].lower()
    if ext in (".xlsx", ".xls"):
        sheet_name = sheet if sheet else 0
        try:
            df_raw = pd.read_excel(path, sheet_name=sheet_name, header=None)
        except ValueError as e:
            if sheet and "Worksheet named" in str(e):
                print(f"⚠ Hoja '{sheet}' no encontrada; usando la primera hoja del archivo.")
                df_raw = pd.read_excel(path, sheet_name=0, header=None)
            else:
                raise
    else:
        df_raw = pd.read_csv(path, header=None)
    
    records = []
    current_clave = None
    current_nombre = None
    current_block_id = {}  # Contador de bloques por clave
    orden = 0
    
    # Patrón para detectar claves válidas: letras seguidas de números (AS01, BY01/BY02, etc.)
    clave_pattern = re.compile(r'^[A-Z]{1,4}\d{1,3}(/[A-Z]{1,4}\d{1,3})?$', re.IGNORECASE)
    
    for idx, row in df_raw.iterrows():
        # Columna B (índice 1) tiene claves como AS01, AS02, etc.
        col_b = str(row.iloc[1] if len(row) > 1 else "").strip()
        
        # Detectar fila de clave (debe coincidir con el patrón AS01, BY01, etc.)
        if col_b and clave_pattern.match(col_b):
            # Es una clave nueva (o repetida)
            current_clave = col_b.upper()
            # Incrementar el ID de bloque para esta clave
            current_block_id[current_clave] = current_block_id.get(current_clave, -1) + 1
            # El nombre está en columnas posteriores (C, D, E, F aprox.)
            # Intentar primero columna C (índice 2), si no hay datos seguir con D, E, F, etc.
            nombre_parts = []
            for i in range(2, 12):  # Columnas C hasta L (índices 2-11)
                if i < len(row) and pd.notna(row.iloc[i]):
                    val = str(row.iloc[i]).strip()
                    # Descartar valores que sean códigos, encabezados comunes, o unnamed
                    if val and val.upper() != current_clave and not val.startswith("Unnamed") and val.upper() not in ["PROC.", "C.T.", "OPERACIÓN", "T/E", "T/CT", "T/O", "T/TCT", "KG.BRUTO", "$ -"]:
                        nombre_parts.append(val)
            current_nombre = " ".join(nombre_parts).strip() if nombre_parts else None
            orden = 0
            print(f"Detectada clave: {current_clave} - {current_nombre}")
            continue
        
        # Detectar fila de encabezados (tiene "PROC." en columna A o "C.T." en columna B)
        col_a = str(row.iloc[0] if len(row) > 0 else "").strip()
        if col_a == "PROC." or col_b == "C.T.":
            continue
        
        # Detectar fila de datos (tiene 1°, 2°, 3°, 4°, 5° en columna A)
        if current_clave and col_a and (col_a.endswith("°") or (col_a.isdigit() and int(col_a) < 100)):
            orden += 1
            ct = str(row.iloc[1] if len(row) > 1 else "").strip()  # C.T.
            operacion = str(row.iloc[2] if len(row) > 2 else "").strip()  # OPERACIÓN
            te = str(row.iloc[3] if len(row) > 3 else "").strip()  # T/E
            
            if ct and operacion and ct != "C.T.":
                records.append({
                    'clave': current_clave,
                    'nombre_clave': current_nombre,
                    'block_id': current_block_id.get(current_clave, 0),  # Identificador de bloque
                    'orden': orden,
                    'centro_trabajo': ct,
                    'operacion': operacion,
                    'tiempo_estimado': te if te and te != 'nan' else None,
                })
    
    df = pd.DataFrame(records)
    print(f"\nRegistros parseados: {len(df)}")
    print(f"Claves únicas: {df['clave'].nunique() if len(df) > 0 else 0}")
    if len(df) > 0:
        print(f"Claves encontradas: {sorted(df['clave'].unique())}")
        print(f"\nPrimeros 10 registros:")
        print(df.head(10))
    return df


def _split_clave_code(raw_clave: str) -> list[str]:
    """Expande claves compuestas (ej. SF10/SF11 -> [SF10, SF11])."""
    text = str(raw_clave or '').strip().upper()
    if not text:
        return []

    if '/' not in text:
        return [text]

    parts = [p.strip().upper() for p in text.split('/') if p and p.strip()]
    if not parts:
        return []

    # Si alguna parte viene solo numérica, tomar prefijo alfabético de la primera parte.
    m = re.match(r'^([A-Z]+)', parts[0])
    base_prefix = m.group(1) if m else ''

    expanded = []
    for part in parts:
        if re.match(r'^[A-Z]+\d+[A-Z0-9-]*$', part):
            expanded.append(part)
            continue
        if re.match(r'^\d+[A-Z0-9-]*$', part) and base_prefix:
            expanded.append(base_prefix + part)
            continue
        expanded.append(part)

    # Evitar repetidos conservando orden
    seen = set()
    unique_expanded = []
    for item in expanded:
        if item not in seen:
            seen.add(item)
            unique_expanded.append(item)
    return unique_expanded


def expand_composite_claves(df: pd.DataFrame) -> pd.DataFrame:
    """Duplica filas de procesos para cada clave cuando la clave viene compuesta con '/' ."""
    rows = []
    expanded_count = 0
    for _, row in df.iterrows():
        claves = _split_clave_code(row.get('clave'))
        if not claves:
            continue
        if len(claves) > 1:
            expanded_count += 1

        for c in claves:
            new_row = row.copy()
            new_row['clave'] = c
            rows.append(new_row)

    out = pd.DataFrame(rows)
    if expanded_count > 0:
        print(f"\nℹ Claves compuestas expandidas: {expanded_count} filas origen")
        print(f"   Total filas despues de expansion: {len(out)}")
    return out


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Mapea nombres de columnas flexibles a nombres estándar."""
    mapping = {
        'clave': ['clave', 'CLAVE', 'Clave', 'PROC.', 'proc'],
        'nombre_clave': ['nombre_clave', 'nombre clave', 'NOMBRE', 'nombre', 'Nombre'],
        'orden': ['orden', 'ORDEN', 'Orden', 'Nº', 'nº', 'no', 'NO'],
        'centro_trabajo': ['centro_trabajo', 'centro trabajo', 'CT', 'c.t.', 'C.T.', 'CENTRO_TRABAJO', 'h. ruta', 'h.ruta', 'hoja ruta', 'ruta'],
        'operacion': ['operacion', 'OPERACIÓN', 'operación', 'OPERACION', 'operación', 'Operación', 'concepto'],
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
    df.columns = [str(c).strip().lower() for c in df.columns]
    
    print(f"Columnas mapeadas a: {list(df.columns)}")
    return df


def parse_excel_tabular(path: str, sheet: Optional[str], header_row: int = 0) -> pd.DataFrame:
    """Parse alternativo para archivos en formato tabular con encabezados."""
    ext = os.path.splitext(path)[1].lower()
    if ext in (".xlsx", ".xls"):
        sheet_name = sheet if sheet else 0
        try:
            df = pd.read_excel(path, sheet_name=sheet_name, header=header_row)
        except ValueError as e:
            if sheet and "Worksheet named" in str(e):
                print(f"⚠ Hoja '{sheet}' no encontrada; usando la primera hoja del archivo.")
                df = pd.read_excel(path, sheet_name=0, header=header_row)
            else:
                raise
    else:
        df = pd.read_csv(path, header=header_row)

    # Limpiar filas/columnas totalmente vacías
    df = df.dropna(axis=0, how='all').dropna(axis=1, how='all')
    if len(df) == 0:
        return df

    df = normalize_columns(df)

    # Fallbacks para formatos operativos (ej: OT_JOSE_ACTUALIZACION2.xlsx)
    if 'operacion' not in df.columns and 'concepto' in df.columns:
        df['operacion'] = df['concepto']
    if 'centro_trabajo' not in df.columns and 'h. ruta' in df.columns:
        df['centro_trabajo'] = df['h. ruta']
    if 'centro_trabajo' not in df.columns and 'h.ruta' in df.columns:
        df['centro_trabajo'] = df['h.ruta']

    # Si aún falta centro de trabajo, usar valor por defecto para no bloquear importación
    if 'centro_trabajo' not in df.columns:
        df['centro_trabajo'] = 'GENERAL'

    # Normalizar valores mínimos
    for col in ('clave', 'centro_trabajo', 'operacion'):
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip()

    # Filtrar filas sin datos básicos
    required_base = {'clave', 'centro_trabajo', 'operacion'}
    if required_base.issubset(set(df.columns)):
        df = df[(df['clave'] != '') & (df['centro_trabajo'] != '') & (df['operacion'] != '')].copy()

    # Si no existe orden, generarlo por clave
    if 'orden' not in df.columns and 'clave' in df.columns:
        df['orden'] = df.groupby('clave', sort=False).cumcount() + 1

    print(f"\nRegistros parseados (tabular): {len(df)}")
    if 'clave' in df.columns and len(df) > 0:
        print(f"Claves únicas (tabular): {df['clave'].nunique()}")
    return df


# --- Import logic ---------------------------------------------------------

def import_file(path: str, sheet: Optional[str], overwrite: bool, header_row: int = 0) -> None:
    # Parsear el Excel con formato de bloques; si no detecta filas, intentar formato tabular.
    df = parse_excel_blocks(path, sheet)
    source_mode = 'blocks'
    if len(df) == 0:
        print("\n⚠ No se detectó formato por bloques; intentando parse tabular...")
        df = parse_excel_tabular(path, sheet, header_row=header_row)
        source_mode = 'tabular'

    if len(df) == 0:
        raise ValueError("No se encontraron datos válidos en el archivo")

    required = {"clave", "orden", "centro_trabajo", "operacion"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Faltan columnas requeridas: {missing}\nColumnas disponibles: {list(df.columns)}")

    # Detectar claves duplicadas (múltiples bloques)
    if source_mode == 'blocks' and 'block_id' in df.columns:
        max_block_per_clave = df.groupby('clave')['block_id'].max()
        claves_duplicadas = max_block_per_clave[max_block_per_clave > 0]
        if len(claves_duplicadas) > 0:
            print(f"\n⚠ Claves duplicadas detectadas (se usará última aparición):")
            for clave, max_block in claves_duplicadas.items():
                count = df[df['clave'] == clave].groupby('block_id').size()
                print(f"   {clave}: {max_block+1} apariciones - filas por bloque: {list(count)}")
            
            # Filtrar: mantener solo el último bloque de cada clave
            df['_max_block'] = df.groupby('clave')['block_id'].transform('max')
            df = df[df['block_id'] == df['_max_block']].copy()
            df = df.drop(columns=['block_id', '_max_block'])
            print(f"   Mantenidos {len(df)} registros de últimas apariciones")
        else:
            df = df.drop(columns=['block_id'])
    
    # Expandir claves compuestas (ej. SF10/SF11) para importar por separado.
    df = expand_composite_claves(df)

    df = df.sort_values(["clave", "orden"])  # asegura orden correcto
    
    # Deduplicar procesos repetidos dentro de cada clave:
    # Mantener solo la PRIMERA ocurrencia de cada combinación única (centro_trabajo, operacion)
    df['_dedup_key'] = df['centro_trabajo'] + '|' + df['operacion']
    df['_grupo_clave'] = df.groupby('clave', sort=False)['_dedup_key'].rank(method='first')
    # Marcar como duplicado si la primera ocurrencia de esta (ct, op) en la clave no es esta fila
    df['_es_duplicado'] = df.groupby(['clave', '_dedup_key']).cumcount() > 0
    duplicados_eliminados = df['_es_duplicado'].sum()
    if duplicados_eliminados > 0:
        print(f"\n⚠ Eliminados {duplicados_eliminados} procesos duplicados dentro de claves")
        df = df[~df['_es_duplicado']].copy()
    df = df.drop(columns=['_dedup_key', '_grupo_clave', '_es_duplicado'])
    
    # Reordenar orden después de deduplicar
    df['orden'] = df.groupby('clave', sort=False).cumcount() + 1

    # Agrupamos por clave para poder limpiar secuencia por clave si overwrite=True
    grouped = df.groupby("clave", sort=False)
    claves_detectadas = [str(k).strip() for k in grouped.groups.keys() if str(k).strip()]
    imported_keys = []
    total_pasos_importados = 0

    with app.app_context():
        if overwrite:
            # Evitar ambigüedad en producción: eliminar claves compuestas (ej. SF10/SF11)
            # porque ahora se importan separadas como SF10 y SF11.
            compuestas = ClaveProducto.query.filter(ClaveProducto.clave.contains('/')).all()
            if compuestas:
                comp_ids = [c.id for c in compuestas]
                comp_codes = [c.clave for c in compuestas]
                deleted_steps = ClaveProceso.query.filter(ClaveProceso.clave_id.in_(comp_ids)).delete(synchronize_session=False)
                deleted_keys = ClaveProducto.query.filter(ClaveProducto.id.in_(comp_ids)).delete(synchronize_session=False)
                db.session.commit()
                print(f"\n⚠ Limpieza previa overwrite: eliminadas {deleted_keys} claves compuestas y {deleted_steps} pasos")
                print(f"   Claves removidas (muestra): {comp_codes[:15]}{' ...' if len(comp_codes) > 15 else ''}")

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
                deleted_count = ClaveProceso.query.filter_by(clave_id=clave_obj.id).delete()
                # COMMIT inmediato para asegurar que DELETE se ejecuta antes de INSERT
                db.session.commit()
                # Limpiar sesión para evitar que SQLAlchemy reinserte objetos viejos
                db.session.expire_all()
                if deleted_count > 0:
                    print(f"  Limpiadas {deleted_count} filas previas de {clave_code}")

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
                    # Deshabilitar autoflush para evitar conflictos con ClaveProceso pendientes
                    with db.session.no_autoflush:
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

            # Commit por clave para evitar transacción gigante
            db.session.commit()
            imported_keys.append(clave_code)
            total_pasos_importados += len(gdf)
            print(f"✓ Importada clave {clave_code} con {len(gdf)} pasos")

        # Validación estricta: toda clave detectada por el parser debe quedar importada.
        set_detectadas = set(claves_detectadas)
        set_importadas = set(imported_keys)
        faltantes = sorted(set_detectadas - set_importadas)

        print("\n=== RESUMEN IMPORTACION PROCESOS/CLAVES ===")
        print(f"Claves detectadas en archivo: {len(set_detectadas)}")
        print(f"Claves importadas: {len(set_importadas)}")
        print(f"Total de pasos importados: {total_pasos_importados}")

        if faltantes:
            print("\nERROR: Faltaron claves por importar:")
            for c in faltantes:
                print(f"  - {c}")
            raise RuntimeError("Importacion incompleta: hay claves detectadas que no se importaron")

        print("Importacion OK: todas las claves detectadas quedaron importadas.")


# --- CLI ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Importa claves y procesos desde CSV/Excel")
    parser.add_argument("--file", required=True, help="Ruta al CSV o Excel")
    parser.add_argument("--sheet", default=None, help="Nombre de hoja (solo Excel)")
    parser.add_argument("--header", type=int, default=0, help="Fila del encabezado (0=primera fila, 1=segunda, etc.)")
    parser.add_argument("--overwrite", action="store_true", help="Sobrescribe la secuencia existente de cada clave")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"No se encuentra el archivo: {args.file}", file=sys.stderr)
        sys.exit(1)

    import_file(args.file, args.sheet, args.overwrite, args.header)
    print("Importación completada.")


if __name__ == "__main__":
    main()
