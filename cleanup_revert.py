#!/usr/bin/env python3
import os

files_to_remove = [
    '/workspaces/industrial-verduzco/ENTREGAS_PARCIALES_EJEMPLOS_API.md',
    '/workspaces/industrial-verduzco/ENTREGAS_PARCIALES_MANIFEST_CAMBIOS.md',
    '/workspaces/industrial-verduzco/ENTREGAS_PARCIALES_RESUMEN.md',
    '/workspaces/industrial-verduzco/GUIA_ENTREGAS_PARCIALES.md',
    '/workspaces/industrial-verduzco/verify_entregas_parciales.sh',
    '/workspaces/industrial-verduzco/migrations/add_entregas_parciales.sql',
]

print("🗑️ Removiendo archivos de entregas parciales...")
for filepath in files_to_remove:
    try:
        if os.path.exists(filepath):
            os.remove(filepath)
            print(f"✅ Removido: {filepath}")
        else:
            print(f"⏭️ No existe: {filepath}")
    except Exception as e:
        print(f"❌ Error removiendo {filepath}: {e}")

print("\n✅ Limpieza completada!")
