"""
Generador de iconos PNG a partir de los SVG placeholders en static/icons/

Requisitos (instalar localmente):
  pip install cairosvg pillow

Uso:
  python tools/generate_icons.py

Esto generará en `static/icons/` los archivos:
  - apple-touch-icon-180.png
  - icon-192.png
  - icon-512.png

Si ya tienes iconos de marca, reemplázalos después.
"""
from pathlib import Path
import sys

try:
    import cairosvg
except Exception as e:
    print("Error: cairosvg no está instalado. Instala con: pip install cairosvg")
    sys.exit(1)

BASE = Path(__file__).resolve().parents[1]
ICONS_DIR = BASE / 'static' / 'icons'
ICONS_DIR.mkdir(parents=True, exist_ok=True)

SVG_192 = ICONS_DIR / 'icon-192.svg'
SVG_512 = ICONS_DIR / 'icon-512.svg'

OUT_180 = ICONS_DIR / 'apple-touch-icon-180.png'
OUT_192 = ICONS_DIR / 'icon-192.png'
OUT_512 = ICONS_DIR / 'icon-512.png'

if not SVG_192.exists() and not SVG_512.exists():
    print('No se encontraron SVG placeholders (icon-192.svg o icon-512.svg). Coloca los SVG en static/icons/ e intenta de nuevo.')
    sys.exit(1)

# Prefer SVG_512 if exists for scaling down
src_svg = SVG_512 if SVG_512.exists() else SVG_192

print(f'Generando PNGs desde: {src_svg}')

# icon-512
cairosvg.svg2png(url=str(src_svg), write_to=str(OUT_512), output_width=512, output_height=512)
print(f'Creado: {OUT_512}')

# icon-192
cairosvg.svg2png(url=str(src_svg), write_to=str(OUT_192), output_width=192, output_height=192)
print(f'Creado: {OUT_192}')

# apple-touch-icon-180
cairosvg.svg2png(url=str(src_svg), write_to=str(OUT_180), output_width=180, output_height=180)
print(f'Creado: {OUT_180}')

print('Iconos generados correctamente. Reemplaza con tus iconos de marca si lo deseas.')
