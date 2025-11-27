PLACEHOLDER - icons for the PWA and Apple touch icon

Please add the following image files to this folder (recommended formats: PNG):

- apple-touch-icon-180.png    (180x180)  - used by iOS for "Add to Home Screen"
- icon-192.png                (192x192)  - used in manifest for many browsers
- icon-512.png                (512x512)  - used in manifest for high resolution

If you don't have production icons yet, you can create simple PNGs using any image editor or online generator (canva, favicon-generator, realfavicongenerator.net).

Quick local generator (recommended):
- We include `tools/generate_icons.py`, a small script that converts the SVG placeholders to PNGs (requires `cairosvg`).
- To use it:
	1. Install requirements: `pip install cairosvg pillow`
	2. Run: `python tools/generate_icons.py`
	3. The script will produce:
		 - `apple-touch-icon-180.png`
		 - `icon-192.png`
		 - `icon-512.png`

Notes:
- For best results use transparent background or a background matching your brand color.
- Replace these placeholders with properly exported PNG files before publishing.
