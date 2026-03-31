#!/usr/bin/env python
"""
Importa BOMs de maquinaria desde un archivo Excel multi-hoja.

Uso:
  python scripts/import_maquinaria_boms_excel.py --excel-path "BOOMS ACTUALIZADOS (RB) _ 28012026.xlsx" --dry-run
  python scripts/import_maquinaria_boms_excel.py --excel-path "BOOMS ACTUALIZADOS (RB) _ 28012026.xlsx"
"""

import argparse
import math
import re
import sys
from pathlib import Path

import pandas as pd


def clean_text(value):
    if value is None:
        return ""
    text = str(value).strip()
    if not text or text.lower() in {"nan", "none"}:
        return ""
    return " ".join(text.split())


def parse_number(value, default=1.0):
    if value is None:
        return default
    if isinstance(value, (int, float)):
        if isinstance(value, float) and (math.isnan(value) or not math.isfinite(value)):
            return default
        return float(value)

    text = clean_text(value).replace(",", "")
    if not text:
        return default
    try:
        return float(text)
    except Exception:
        return default


def normalize_machine_key(sheet_name):
    key = re.sub(r"^\s*BOM\s+", "", sheet_name, flags=re.IGNORECASE)
    key = re.sub(r"^\s*BOOM\s+", "", key, flags=re.IGNORECASE)
    key = clean_text(key)
    if not key:
        key = f"BOM_{sheet_name}"
    key = re.sub(r"\s+", "_", key.upper())
    return key[:120]


def find_header_row(df):
    scan_limit = min(len(df.index), 25)
    for idx in range(scan_limit):
        row = [clean_text(v).upper() for v in df.iloc[idx].tolist()]
        has_item = any("ITEM" in cell or "\u00cdTEM" in cell or "\u00ccTEM" in cell for cell in row)
        has_clave = any("CLAVE" in cell for cell in row)
        if has_item and has_clave:
            return idx
    return None


def first_non_empty_text(df, max_rows=6):
    for idx in range(min(len(df.index), max_rows)):
        for value in df.iloc[idx].tolist():
            text = clean_text(value)
            if text:
                return text
    return ""


def is_item_value(value):
    text = clean_text(value)
    if not text:
        return False
    if re.fullmatch(r"\d+", text):
        return True
    try:
        num = float(text)
        return num.is_integer()
    except Exception:
        return False


def parse_sheet(sheet_name, df):
    header_row = find_header_row(df)
    if header_row is None:
        return None

    machine_name = first_non_empty_text(df, max_rows=4) or sheet_name
    machine_key = normalize_machine_key(sheet_name)

    components = []
    current_group = ""

    for idx in range(header_row + 1, len(df.index)):
        row = df.iloc[idx].tolist()
        c0 = clean_text(row[0] if len(row) > 0 else "")
        c1 = clean_text(row[1] if len(row) > 1 else "")
        c2 = row[2] if len(row) > 2 else None
        c3 = clean_text(row[3] if len(row) > 3 else "")
        c4 = clean_text(row[4] if len(row) > 4 else "")
        c7 = clean_text(row[7] if len(row) > 7 else "")

        # Filas de seccion: REFACCIONES, CHASIS, CABEZA, etc.
        if c0 and not is_item_value(c0) and not c1 and not c4:
            current_group = c0
            continue

        if not is_item_value(c0):
            continue

        if not c1 and not c4:
            continue

        cantidad = max(0.01, parse_number(c2, default=1.0))
        codigo = c1 if c1 else f"SINCLAVE_{machine_key}_{c0}"
        nombre = c4 if c4 else f"COMPONENTE {c0}"

        components.append(
            {
                "codigo_componente": codigo[:120],
                "nombre_componente": nombre[:255],
                "cantidad": cantidad,
                "unidad": c3[:30] if c3 else None,
                "proceso_base": current_group[:120] if current_group else None,
                "notas": c7 if c7 else None,
            }
        )

    if not components:
        return None

    return {
        "clave_maquina": machine_key,
        "nombre_maquina": machine_name[:255],
        "version": None,
        "estado": "activo",
        "notas": f"Importado desde Excel hoja: {sheet_name}",
        "componentes": components,
        "sheet_name": sheet_name,
    }


def parse_workbook(excel_path):
    workbook = pd.ExcelFile(excel_path)
    parsed = []
    skipped = []

    for sheet_name in workbook.sheet_names:
        try:
            # Reusar el objeto ExcelFile evita recargar estilos/metadata en cada iteracion.
            df = workbook.parse(sheet_name=sheet_name, header=None, dtype=object)
            bom = parse_sheet(sheet_name, df)
            if bom:
                parsed.append(bom)
            else:
                skipped.append(sheet_name)
        except Exception:
            skipped.append(sheet_name)

    return parsed, skipped


def upsert_boms(parsed_boms, replace_existing=True):
    sys.path.insert(0, ".")
    from app import app
    from models import MaquinariaBOM, MaquinariaBOMComponente, db

    created_boms = 0
    updated_boms = 0
    created_components = 0

    with app.app_context():
        for payload in parsed_boms:
            bom = MaquinariaBOM.query.filter_by(clave_maquina=payload["clave_maquina"]).first()
            if not bom:
                bom = MaquinariaBOM(
                    clave_maquina=payload["clave_maquina"],
                    nombre_maquina=payload["nombre_maquina"],
                    version=payload["version"],
                    estado=payload["estado"],
                    notas=payload["notas"],
                )
                db.session.add(bom)
                db.session.flush()
                created_boms += 1
            else:
                bom.nombre_maquina = payload["nombre_maquina"]
                bom.version = payload["version"]
                bom.estado = payload["estado"]
                bom.notas = payload["notas"]
                updated_boms += 1

                if replace_existing:
                    MaquinariaBOMComponente.query.filter_by(bom_id=bom.id).delete(synchronize_session=False)

            for comp in payload["componentes"]:
                row = MaquinariaBOMComponente(
                    bom_id=bom.id,
                    codigo_componente=comp["codigo_componente"],
                    nombre_componente=comp["nombre_componente"],
                    cantidad=comp["cantidad"],
                    unidad=comp["unidad"],
                    proceso_base=comp["proceso_base"],
                    notas=comp["notas"],
                )
                db.session.add(row)
                created_components += 1

        db.session.commit()

    return {
        "created_boms": created_boms,
        "updated_boms": updated_boms,
        "created_components": created_components,
    }


def main():
    parser = argparse.ArgumentParser(description="Importador de BOMs Maquinaria desde Excel")
    parser.add_argument("--excel-path", required=True, help="Ruta al archivo .xlsx")
    parser.add_argument("--dry-run", action="store_true", help="Solo analiza y muestra resumen, sin guardar")
    parser.add_argument(
        "--no-replace-existing",
        action="store_true",
        help="No borra componentes existentes al actualizar una BOM",
    )
    args = parser.parse_args()

    excel_path = Path(args.excel_path)
    if not excel_path.exists():
        raise RuntimeError(f"No existe el archivo: {excel_path}")

    parsed_boms, skipped = parse_workbook(excel_path)
    total_components = sum(len(b["componentes"]) for b in parsed_boms)

    print(f"Archivo: {excel_path}")
    print(f"Hojas BOM detectadas: {len(parsed_boms)}")
    print(f"Hojas omitidas: {len(skipped)}")
    print(f"Componentes detectados: {total_components}")

    if parsed_boms:
        sample = parsed_boms[0]
        print(f"Ejemplo BOM: {sample['clave_maquina']} ({sample['sheet_name']}) -> {len(sample['componentes'])} componentes")

    if args.dry_run:
        print("Dry-run completado. No se guardaron cambios.")
        return 0

    stats = upsert_boms(parsed_boms, replace_existing=not args.no_replace_existing)
    print("Importacion completada:", stats)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print("ERROR importando BOMs:", str(exc))
        sys.exit(1)
