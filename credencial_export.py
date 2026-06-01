"""
Exportación de credenciales técnicos a JPEG (300 DPI, CR80) vía Pillow.
Evita rasterizado del navegador (html2canvas) para logos y texto nítidos.
"""
from __future__ import annotations

import io
import math
import os
from datetime import datetime
from typing import List, Optional, Tuple

from PIL import Image, ImageDraw, ImageFilter, ImageFont

DPI = 300


def mm(value: float) -> int:
    return int(round(value / 25.4 * DPI))


def pt(value: float) -> int:
    return max(6, int(round(value / 72 * DPI)))


def _font_candidates() -> Tuple[List[str], List[str], List[str]]:
    win = os.environ.get('WINDIR', r'C:\Windows')
    regular = [
        os.path.join(win, 'Fonts', 'arial.ttf'),
        os.path.join(win, 'Fonts', 'Arial.ttf'),
        '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
        '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    ]
    bold = [
        os.path.join(win, 'Fonts', 'arialbd.ttf'),
        os.path.join(win, 'Fonts', 'Arialbd.ttf'),
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
        '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
    ]
    italic = [
        os.path.join(win, 'Fonts', 'ariali.ttf'),
        os.path.join(win, 'Fonts', 'Arial Italic.ttf'),
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf',
    ]
    return regular, bold, italic


def _load_font(size_px: int, bold: bool = False, italic: bool = False) -> ImageFont.FreeTypeFont:
    regular, bold_list, italic_list = _font_candidates()
    paths = italic_list if italic else (bold_list if bold else regular)
    for path in paths:
        if os.path.isfile(path):
            try:
                return ImageFont.truetype(path, size_px)
            except OSError:
                continue
    return ImageFont.load_default()


def _resolve_upload(url_path: Optional[str], base_dir: str) -> Optional[str]:
    if not url_path:
        return None
    clean = str(url_path).split('?')[0].strip()
    if clean.startswith('/uploads/'):
        rel = clean.lstrip('/').replace('/', os.sep)
        full = os.path.join(base_dir, rel)
        return full if os.path.isfile(full) else None
    if os.path.isfile(clean):
        return clean
    return None


def _open_image(path: Optional[str]) -> Optional[Image.Image]:
    if not path or not os.path.isfile(path):
        return None
    try:
        img = Image.open(path)
        return img.convert('RGBA')
    except OSError:
        return None


def _paste_cover(base: Image.Image, overlay: Image.Image, x: int, y: int, w: int, h: int) -> None:
    ow, oh = overlay.size
    scale = max(w / ow, h / oh)
    nw, nh = max(1, int(ow * scale)), max(1, int(oh * scale))
    resized = overlay.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - w) // 2
    top = (nh - h) // 2
    cropped = resized.crop((left, top, left + w, top + h))
    base.paste(cropped, (x, y), cropped if cropped.mode == 'RGBA' else None)


def _paste_contain(base: Image.Image, overlay: Image.Image, x: int, y: int, w: int, h: int) -> None:
    ow, oh = overlay.size
    scale = min(w / ow, h / oh)
    nw, nh = max(1, int(ow * scale)), max(1, int(oh * scale))
    resized = overlay.resize((nw, nh), Image.Resampling.LANCZOS)
    px = x + (w - nw) // 2
    py = y + (h - nh) // 2
    base.paste(resized, (px, py), resized if resized.mode == 'RGBA' else None)


def _logo_path(base_dir: str) -> str:
    return os.path.join(base_dir, 'static', 'img', 'logo_verduzco.png')


def _prepare_logo_for_white_card(logo: Image.Image) -> Image.Image:
    """Quita fondo negro del PNG y apoya el logo en blanco (como el círculo de la credencial)."""
    src = logo.convert('RGBA')
    w, h = src.size
    px = src.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 200 and r < 45 and g < 45 and b < 45:
                px[x, y] = (255, 255, 255, 0)
    out = Image.new('RGBA', (w, h), (255, 255, 255, 255))
    out.paste(src, (0, 0), src)
    return out


def _resize_sharp(logo: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Escala logo grande → tamaño final con supersampling para bordes nítidos."""
    ow, oh = logo.size
    tw, th = max(1, target_w), max(1, target_h)
    scale = min(tw / ow, th / oh)
    if scale <= 0:
        return logo
    ss = 2 if scale < 1.0 else 1
    mid_w = max(1, int(ow * scale * ss))
    mid_h = max(1, int(oh * scale * ss))
    work = logo.resize((mid_w, mid_h), Image.Resampling.LANCZOS)
    if ss > 1 or scale < 1.0:
        work = work.resize((tw, th), Image.Resampling.LANCZOS)
        work = work.filter(ImageFilter.UnsharpMask(radius=0.5, percent=115, threshold=1))
    return work


def _paste_logo_circle_front(
    base: Image.Image,
    logo: Image.Image,
    center_x: int,
    center_y: int,
    diameter_px: int,
) -> None:
    """
    Logo superior credencial seguridad (frente).
    Replica HTML: ~130% dentro del círculo + leve zoom.
    """
    fill_ratio = 1.38
    inner = max(1, int(diameter_px * fill_ratio))
    prepared = _prepare_logo_for_white_card(logo)
    ow, oh = prepared.size
    scale = min(inner / ow, inner / oh)
    tw = max(1, int(ow * scale))
    th = max(1, int(oh * scale))
    sharp = _resize_sharp(prepared, tw, th)
    px = center_x - sharp.size[0] // 2
    py = center_y - sharp.size[1] // 2
    base.paste(sharp, (px, py), sharp)


def _text_width(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> int:
    if hasattr(draw, 'textlength'):
        return int(draw.textlength(text, font=font))
    return int(draw.textsize(text, font=font)[0])


def _draw_text_center(
    draw: ImageDraw.ImageDraw,
    text: str,
    cx: int,
    y: int,
    size_pt: float,
    fill: str,
    bold: bool = False,
    italic: bool = False,
    max_width: Optional[int] = None,
) -> int:
    font = _load_font(pt(size_pt), bold=bold, italic=italic)
    label = text or ''
    if max_width and _text_width(draw, label, font) > max_width:
        while label and _text_width(draw, label + '…', font) > max_width:
            label = label[:-1]
        label = (label + '…') if label else '…'
    tw = _text_width(draw, label, font)
    draw.text((cx - tw // 2, y), label, fill=fill, font=font)
    bbox = draw.textbbox((cx - tw // 2, y), label, font=font)
    return bbox[3]


def _draw_text_left(
    draw: ImageDraw.ImageDraw,
    text: str,
    x: int,
    y: int,
    size_pt: float,
    fill: str,
    bold: bool = False,
    max_width: Optional[int] = None,
) -> int:
    font = _load_font(pt(size_pt), bold=bold)
    label = text or ''
    if max_width and _text_width(draw, label, font) > max_width:
        while label and _text_width(draw, label + '…', font) > max_width:
            label = label[:-1]
        label = (label + '…') if label else '…'
    draw.text((x, y), label, fill=fill, font=font)
    bbox = draw.textbbox((x, y), label, font=font)
    return bbox[3]


def _draw_hex_badge(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    cx, cy = x + w // 2, y + h // 2
    r_outer = min(w, h) * 0.48
    r_inner = r_outer * 0.88

    def hex_pts(radius: float) -> List[Tuple[float, float]]:
        pts = []
        for i in range(6):
            ang = math.radians(60 * i - 30)
            pts.append((cx + radius * math.cos(ang), cy + radius * math.sin(ang)))
        return pts

    draw.polygon(hex_pts(r_outer), fill='#0f2a54')
    draw.polygon(hex_pts(r_inner), fill='#f4bf21')
    arm = r_inner * 0.22
    for ang_deg in (0, 60, 120):
        ang = math.radians(ang_deg - 90)
        x1 = cx + arm * 0.35 * math.cos(ang)
        y1 = cy - r_inner * 0.35 + arm * 0.35 * math.sin(ang)
        x2 = cx - arm * 0.35 * math.cos(ang)
        y2 = cy - r_inner * 0.35 - arm * 0.35 * math.sin(ang)
        draw.line([(x1, y1), (x2, y2)], fill='#0f2a54', width=max(2, mm(0.35)))

    ty = cy - r_inner * 0.05
    _draw_text_center(draw, 'NUESTRA', cx, int(ty - pt(5)), 5.5, '#0f2a54', bold=True)
    _draw_text_center(draw, 'SEGURIDAD', cx, int(ty + pt(1.5)), 7, '#0f2a54', bold=True)
    _draw_text_center(draw, 'ES PRIMERO', cx, int(ty + pt(8)), 5, '#0f2a54', bold=True)


def _jpeg_bytes(img: Image.Image) -> bytes:
    buf = io.BytesIO()
    rgb = img.convert('RGB')
    rgb.save(buf, format='JPEG', quality=98, subsampling=0, optimize=False)
    return buf.getvalue()


def render_credencial_jpeg(
    tecnico,
    variant: str,
    lado: str,
    base_dir: str,
    *,
    firma_cri_path: Optional[str] = None,
    firma_supervision_path: Optional[str] = None,
    vigente: bool = True,
) -> bytes:
    lado = (lado or '').lower().strip()
    if lado not in ('frente', 'reverso'):
        raise ValueError('lado inválido')
    variant = (variant or '').lower().strip()
    if variant == 'seguridad':
        img = (
            _render_seguridad_frente(tecnico, base_dir)
            if lado == 'frente'
            else _render_seguridad_reverso(
                tecnico, base_dir, firma_cri_path, firma_supervision_path
            )
        )
    elif variant in ('corporativa', 'corp', 'verduzco'):
        img = (
            _render_corporativa_frente(tecnico, base_dir, vigente=vigente)
            if lado == 'frente'
            else _render_corporativa_reverso(tecnico, base_dir)
        )
    else:
        raise ValueError('variant inválido')
    return _jpeg_bytes(img)


def _render_seguridad_frente(tecnico, base_dir: str) -> Image.Image:
    w, h = mm(54), mm(85.6)
    img = Image.new('RGB', (w, h), '#ffffff')
    draw = ImageDraw.Draw(img)

    hole_w, hole_h = mm(9), mm(2)
    hx = (w - hole_w) // 2
    draw.rounded_rectangle(
        [hx, mm(2.5), hx + hole_w, mm(2.5) + hole_h],
        radius=mm(1),
        fill='#333333',
    )

    logo_d = mm(17.5)
    logo_x = (w - logo_d) // 2
    logo_y = mm(3.4)
    logo_cx = logo_x + logo_d // 2
    logo_cy = logo_y + logo_d // 2
    draw.ellipse([logo_x, logo_y, logo_x + logo_d, logo_y + logo_d], fill='#ffffff')
    logo = _open_image(_logo_path(base_dir))
    if logo:
        _paste_logo_circle_front(img, logo, logo_cx, logo_cy, logo_d)
    draw.ellipse(
        [logo_x, logo_y, logo_x + logo_d, logo_y + logo_d],
        outline='#777777',
        width=max(1, mm(0.35)),
    )

    y = logo_y + logo_d + mm(0.5)
    y = _draw_text_center(
        draw,
        'Eres el único responsable de tu vida',
        w // 2,
        y,
        4.7,
        '#cc0000',
        bold=True,
        italic=True,
        max_width=w - mm(6),
    )

    pw, ph = mm(18), mm(20.5)
    px = (w - pw) // 2
    py = y + mm(0.8)
    photo = _open_image(_resolve_upload(getattr(tecnico, 'foto', None), base_dir))
    if photo:
        _paste_cover(img, photo, px, py, pw, ph)
    else:
        draw.rectangle([px, py, px + pw, py + ph], fill='#e3f0ff')
    draw.rectangle(
        [px, py, px + pw, py + ph],
        outline='#1565c0',
        width=max(1, mm(0.35)),
    )

    y = py + ph + mm(0.6)
    nombre = getattr(tecnico, 'nombre', '') or ''
    y = _draw_text_center(draw, nombre, w // 2, y, 7.2, '#111111', bold=True, max_width=w - mm(6))

    puesto = (getattr(tecnico, 'puesto', None) or 'Técnico Industrial').upper()
    bar_h = mm(4.5)
    draw.rectangle([0, y, w, y + bar_h], fill='#9e9e9e')
    _draw_text_center(draw, puesto, w // 2, y + mm(0.35), 5.4, '#ffffff', bold=True, max_width=w - mm(4))
    y += bar_h + mm(0.5)

    blue_h = mm(7.2)
    bottom_y = h - blue_h
    section_h = bottom_y - y - mm(0.5)

    # Faltas
    lx = mm(3)
    ly = y + mm(0.5)
    _draw_text_left(draw, 'Faltas', lx, ly, 6.2, '#111111', bold=True)
    ly += mm(3.5)
    rows = [
        ('Rango 1', ['#4caf50', '#4caf50', '#4caf50']),
        ('Rango 2', ['#4caf50', '#fdd835']),
        ('Rango 3', ['#e53935']),
    ]
    sq = mm(2.7)
    for lbl, colors in rows:
        _draw_text_left(draw, lbl, lx, ly + mm(0.2), 4.5, '#333333')
        sx = lx + mm(10)
        for i, col in enumerate(colors):
            draw.rectangle([sx + i * (sq + mm(0.9)), ly, sx + i * (sq + mm(0.9)) + sq, ly + sq], fill=col)
        ly += mm(3.2)

    hex_w, hex_h = mm(17.8), mm(20.4)
    hx2 = w - mm(3) - hex_w
    hy2 = y + max(0, (section_h - hex_h) // 2)
    _draw_hex_badge(draw, hx2, hy2, hex_w, hex_h)

    empresa = (getattr(tecnico, 'empresa', None) or 'GRUPO INDUSTRIAL VERDUZCO').upper()
    draw.rectangle([0, bottom_y, w, h], fill='#1565c0')
    _draw_text_center(
        draw, empresa, w // 2, bottom_y + mm(1.2), 5.7, '#ffffff', bold=True, max_width=w - mm(4)
    )
    return img


def _render_seguridad_reverso(
    tecnico,
    base_dir: str,
    firma_cri_path: Optional[str],
    firma_supervision_path: Optional[str],
) -> Image.Image:
    w, h = mm(54), mm(85.6)
    img = Image.new('RGB', (w, h), '#ffffff')
    draw = ImageDraw.Draw(img)

    pad_x = mm(3.5)
    y = mm(4.5)

    qr_size = mm(15)
    qr = _open_image(_resolve_upload(getattr(tecnico, 'qr_imagen', None), base_dir))
    if qr:
        _paste_contain(img, qr, pad_x, y, qr_size, qr_size)
    else:
        draw.rectangle([pad_x, y, pad_x + qr_size, y + qr_size], fill='#eeeeee', outline='#cccccc')

    lx = w - pad_x - mm(22)
    _draw_text_center(draw, '✦', lx + mm(11), y, 8, '#113469')
    _draw_text_left(draw, 'Yo soy Líder', lx, y + mm(4), 7.4, '#113469')
    _draw_text_left(draw, 'de Seguridad', lx, y + mm(7.5), 7.4, '#113469')

    y += qr_size + mm(2)

    def field(label: str, value: str, na: bool = False) -> None:
        nonlocal y
        _draw_text_left(draw, label, pad_x, y, 3.7, '#555555', bold=True)
        val = value if value else '—'
        color = '#bbbbbb' if na or val == '—' else '#111111'
        _draw_text_left(draw, val, pad_x + mm(24), y, 4, color, max_width=w - pad_x * 2 - mm(24))
        y += mm(2.8)
        draw.line([pad_x, y, w - pad_x, y], fill='#e0e0e0', width=1)
        y += mm(0.4)

    field('NSS :', getattr(tecnico, 'nss', None) or '', not getattr(tecnico, 'nss', None))
    field('CURP :', getattr(tecnico, 'curp', None) or '', not getattr(tecnico, 'curp', None))
    field(
        'Tipo de Sangre :',
        getattr(tecnico, 'tipo_sangre', None) or '',
        not getattr(tecnico, 'tipo_sangre', None),
    )
    field('Alergias :', getattr(tecnico, 'alergias', None) or '', not getattr(tecnico, 'alergias', None))
    field(
        'Contacto Emergencia Laboral :',
        getattr(tecnico, 'contacto_emergencia', None) or '',
        not getattr(tecnico, 'contacto_emergencia', None),
    )
    field('Contacto Emergencia Personal :', '—', True)
    field('Nombre Proyecto :', getattr(tecnico, 'empresa', None) or '')
    field(
        'Antigüedad en la empresa :',
        getattr(tecnico, 'antiguedad', None) or '',
        not getattr(tecnico, 'antiguedad', None),
    )
    field(
        'Validación de experiencia :',
        getattr(tecnico, 'puesto', None) or '',
        not getattr(tecnico, 'puesto', None),
    )

    # Tabla especialidades
    y += mm(0.5)
    tbl_top = y
    tbl_h = mm(14)
    draw.rectangle([pad_x, tbl_top, w - pad_x, tbl_top + tbl_h], outline='#bbbbbb', width=1)
    instr = (
        'Coloca una X en el recuadro correspondiente para validar la obtención '
        'de la Capacitación y especialidad'
    )
    iy = tbl_top + mm(0.6)
    lines = []
    words = instr.split()
    line = []
    for word in words:
        line.append(word)
        test = ' '.join(line)
        if _text_width(draw, test, _load_font(pt(3.3))) > w - pad_x * 2 - mm(2):
            line.pop()
            if line:
                lines.append(' '.join(line))
            line = [word]
    if line:
        lines.append(' '.join(line))
    for ln in lines[:2]:
        _draw_text_left(draw, ln, pad_x + mm(0.8), iy, 3.3, '#555555', max_width=w - pad_x * 2)
        iy += mm(1.8)

    cols = [
        'Alturas',
        'Maniobras a baja',
        'Eléctricos',
        'Trabajos en caliente',
        'Espacio Confinados',
        'Excavaciones',
        'Maquinaria',
    ]
    flags = [
        bool(getattr(tecnico, 'esp_alturas', False)),
        bool(getattr(tecnico, 'esp_maniobras_baja', False)),
        bool(getattr(tecnico, 'esp_electricos', False)),
        bool(getattr(tecnico, 'esp_trabajos_caliente', False)),
        bool(getattr(tecnico, 'esp_espacios_confinados', False)),
        bool(getattr(tecnico, 'esp_excavaciones', False)),
        bool(getattr(tecnico, 'esp_maquinaria', False)),
    ]
    head_y = tbl_top + mm(5.5)
    col_w = (w - pad_x * 2) // 7
    for i, title in enumerate(cols):
        cx = pad_x + i * col_w
        draw.rectangle([cx, head_y, cx + col_w, head_y + mm(3.5)], fill='#1565c0')
        _draw_text_center(draw, title, cx + col_w // 2, head_y + mm(0.4), 2.8, '#ffffff', bold=True, max_width=col_w - 2)
    chk_y = head_y + mm(3.5)
    for i, on in enumerate(flags):
        cx = pad_x + i * col_w
        draw.rectangle([cx, chk_y, cx + col_w, tbl_top + tbl_h - mm(0.5)], outline='#b0bec5', fill='#ffffff')
        if on:
            _draw_text_center(draw, 'X', cx + col_w // 2, chk_y + mm(0.3), 7.2, '#0d47a1', bold=True)

    y = tbl_top + tbl_h + mm(1)
    draw.line([pad_x, y, w - pad_x, y], fill='#777777', width=max(1, mm(0.25)))
    y += mm(1)
    _draw_text_left(draw, 'Firma Compromiso del Trabajador', pad_x, y, 4, '#111111', bold=True)
    y += mm(1.8)
    _draw_text_left(
        draw,
        'Reconozco que conozco y me comprometo a cumplir con todas las medidas de seguridad',
        pad_x,
        y,
        3.6,
        '#555555',
        max_width=w - pad_x * 2,
    )
    y += mm(3.5)
    box_w = (w - pad_x * 2 - mm(2)) // 2
    box_h = mm(8)
    for idx, (label, fpath) in enumerate(
        (
            ('Firma de Validación de CRI', firma_cri_path),
            ('Firma de Validación Supervisión', firma_supervision_path),
        )
    ):
        bx = pad_x + idx * (box_w + mm(2))
        draw.line([bx, y + box_h - mm(1), bx + box_w, y + box_h - mm(1)], fill='#777777', width=max(1, mm(0.3)))
        sig = _open_image(fpath)
        if sig:
            _paste_contain(img, sig, bx, y, box_w, box_h - mm(2))
        else:
            _draw_text_center(draw, 'Sin firma', bx + box_w // 2, y + mm(2), 2.9, '#9e9e9e')
        _draw_text_center(draw, label, bx + box_w // 2, y + box_h + mm(0.3), 3.2, '#666666', max_width=box_w)

    return img


def _render_corporativa_frente(tecnico, base_dir: str, vigente: bool = True) -> Image.Image:
    w, h = mm(54), mm(85.6)
    img = Image.new('RGB', (w, h), '#ffffff')
    draw = ImageDraw.Draw(img)

    header_h = mm(32)
    draw.rectangle([0, 0, w, header_h], fill='#0f5f34')
    draw.ellipse([-mm(4), header_h - mm(8), w + mm(4), header_h + mm(6)], fill='#0f5f34')

    logo = _open_image(_logo_path(base_dir))
    if logo:
        prepared = _prepare_logo_for_white_card(logo)
        sharp = _resize_sharp(prepared, mm(18), mm(7))
        img.paste(sharp, (mm(3.5), mm(6)), sharp)

    _draw_text_right_block(
        draw, 'INDUSTRIAS\nVERDUZCO', w - mm(3.5), mm(6), 4.5, '#ffffff', bold=True
    )

    photo = _open_image(_resolve_upload(getattr(tecnico, 'foto', None), base_dir))
    pw, ph = mm(22), mm(26)
    px = (w - pw) // 2
    py = mm(17)
    if photo:
        _paste_cover(img, photo, px, py, pw, ph)
    else:
        draw.rounded_rectangle([px, py, px + pw, py + ph], radius=mm(2.5), fill='#e8f5e9')
    draw.rounded_rectangle(
        [px, py, px + pw, py + ph], radius=mm(2.5), outline='#ffffff', width=max(2, mm(1.1))
    )

    y = header_h + mm(10)
    nombre = getattr(tecnico, 'nombre', '') or ''
    y = _draw_text_center(draw, nombre, w // 2, y, 9, '#1a1a1a', bold=True, max_width=mm(46))
    puesto = (getattr(tecnico, 'puesto', None) or 'Técnico Industrial').upper()
    y = _draw_text_center(draw, puesto, w // 2, y + mm(0.8), 5.5, '#555555', max_width=mm(46))

    div_w = mm(30)
    draw.rectangle([(w - div_w) // 2, y + mm(2), (w + div_w) // 2, y + mm(2.45)], fill='#0f5f34')
    y += mm(5)

    rows = [
        ('ID No', str(getattr(tecnico, 'numero_empleado', '') or '')),
        ('Empresa', getattr(tecnico, 'empresa', '') or ''),
        (
            'Vigente',
            tecnico.fecha_expiracion.strftime('%d/%m/%Y')
            if getattr(tecnico, 'fecha_expiracion', None)
            else '—',
        ),
    ]
    gx = mm(8)
    for lbl, val in rows:
        _draw_text_left(draw, lbl, gx, y, 4, '#0f5f34', bold=True)
        _draw_text_left(draw, val, gx + mm(16), y, 5, '#222222', max_width=w - gx - mm(18))
        y += mm(3.2)

    badge = 'ACTIVO' if vigente else 'NO VIGENTE'
    badge_bg = '#d9f3df' if vigente else '#ffcdd2'
    badge_fg = '#0f5f34' if vigente else '#b71c1c'
    by = h - mm(6)
    draw.rounded_rectangle([mm(3.5), by, mm(22), by + mm(4)], radius=mm(2), fill=badge_bg)
    _draw_text_center(draw, badge, mm(12), by + mm(0.5), 4.5, badge_fg, bold=True)
    _draw_text_right(draw, 'controlcalidad360.site', w - mm(3.5), by + mm(1.2), 3.8, '#bbbbbb')
    draw.rectangle([0, h - mm(2), w, h], fill='#0f5f34')
    return img


def _draw_text_right(draw, text, x, y, size_pt, fill):
    font = _load_font(pt(size_pt))
    tw = _text_width(draw, text, font)
    draw.text((x - tw, y), text, fill=fill, font=font)


def _draw_text_right_block(draw, text, x, y, size_pt, fill, bold=False):
    font = _load_font(pt(size_pt), bold=bold)
    for i, line in enumerate(text.split('\n')):
        tw = _text_width(draw, line, font)
        draw.text((x - tw, y + i * pt(size_pt + 1)), line, fill=fill, font=font)


def _render_corporativa_reverso(tecnico, base_dir: str) -> Image.Image:
    w, h = mm(54), mm(85.6)
    img = Image.new('RGB', (w, h), '#ffffff')
    draw = ImageDraw.Draw(img)

    wave_h = mm(28)
    white_h = h - wave_h
    y = mm(7)
    nombre = getattr(tecnico, 'nombre', '') or ''
    y = _draw_text_center(draw, nombre, w // 2, y, 9, '#1a1a1a', bold=True, max_width=w - mm(8))
    div_w = mm(36)
    draw.rectangle([(w - div_w) // 2, y + mm(2), (w + div_w) // 2, y + mm(2.5)], fill='#0f5f34')

    rows = [
        ('NSS', getattr(tecnico, 'nss', None) or 'N/A'),
        ('CURP', getattr(tecnico, 'curp', None) or 'N/A'),
        ('Tipo de sangre', getattr(tecnico, 'tipo_sangre', None) or 'N/A'),
        ('Alergias', getattr(tecnico, 'alergias', None) or 'N/A'),
        ('Contacto emergencia', getattr(tecnico, 'contacto_emergencia', None) or 'N/A'),
        ('Antigüedad', getattr(tecnico, 'antiguedad', None) or 'N/A'),
        (
            'Expedición',
            tecnico.creado_en.strftime('%d/%m/%Y') if getattr(tecnico, 'creado_en', None) else '—',
        ),
        (
            'Vencimiento',
            tecnico.fecha_expiracion.strftime('%d/%m/%Y')
            if getattr(tecnico, 'fecha_expiracion', None)
            else '—',
        ),
    ]
    y += mm(5)
    pad = mm(4)
    for lbl, val in rows:
        _draw_text_left(draw, lbl.upper(), pad, y, 4, '#888888', bold=True)
        na = val in ('N/A', '—', '')
        _draw_text_right(draw, val, w - pad, y, 5.2, '#bbbbbb' if na else '#1a1a1a')
        y += mm(3.5)
        if y > white_h - mm(6):
            break

    draw.rectangle([0, white_h, w, h], fill='#0f5f34')
    draw.ellipse([-mm(4), white_h - mm(6), w + mm(4), white_h + mm(5)], fill='#0f5f34')

    qr = _open_image(_resolve_upload(getattr(tecnico, 'qr_imagen', None), base_dir))
    qy = white_h + mm(3.5)
    if qr:
        _paste_contain(img, qr, mm(4), qy, mm(17), mm(17))
    scan_x = mm(24)
    scan_y = qy + mm(2)
    _draw_text_left(draw, 'Escanea para', scan_x, scan_y, 4.8, '#ffffff')
    _draw_text_left(draw, 'verificar', scan_x, scan_y + pt(5), 4.8, '#ffffff', bold=True)
    logo = _open_image(_logo_path(base_dir))
    if logo:
        prepared = _prepare_logo_for_white_card(logo)
        sharp = _resize_sharp(prepared, mm(10), mm(5))
        img.paste(sharp, (w - mm(14), qy + mm(1)), sharp)
    return img
