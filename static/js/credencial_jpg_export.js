/**
 * Exporta tarjetas de credencial (frente/reverso) a JPG ~300 DPI (CR80 54×85.6 mm).
 * Requiere html2canvas en la página.
 */
(function (global) {
    const CARD_W_MM = 54;
    const CARD_H_MM = 85.6;
    const EXPORT_DPI = 300;
    const MM_PER_IN = 25.4;
    const SCREEN_DPI = 96;

    function mmToPx(mm, dpi) {
        return Math.round((mm / MM_PER_IN) * dpi);
    }

    function slugFilePart(s) {
        return String(s || 'tecnico').replace(/[^\w.-]+/g, '_').substring(0, 48);
    }

    function prepareImagesForCapture(root) {
        root.querySelectorAll('img').forEach(function (img) {
            if (!img.getAttribute('crossorigin')) {
                img.setAttribute('crossorigin', 'anonymous');
            }
        });
    }

    function waitImages(root) {
        return Promise.all(
            Array.from(root.querySelectorAll('img')).map(function (img) {
                if (img.complete && img.naturalWidth) return Promise.resolve();
                return new Promise(function (resolve) {
                    img.addEventListener('load', resolve, { once: true });
                    img.addEventListener('error', resolve, { once: true });
                });
            })
        );
    }

  /** Escala el clon al tamaño de impresión (~300 DPI) y quita transforms que pixelan el logo. */
    function prepareExportClone(doc, node) {
        const exportScale = EXPORT_DPI / SCREEN_DPI;
        const pxPerMm = EXPORT_DPI / MM_PER_IN;

        doc.documentElement.style.setProperty('--card-scale', String(exportScale));
        node.style.transform = 'scale(' + exportScale + ')';
        node.style.transformOrigin = 'top left';
        node.style.boxShadow = 'none';

        node.querySelectorAll('img').forEach(function (img) {
            img.style.transform = 'none';
            img.style.imageRendering = 'auto';

            var circle = img.closest('.wm-logo-circle');
            if (circle) {
                var logoPx = Math.round(17.5 * pxPerMm);
                img.style.width = logoPx + 'px';
                img.style.height = logoPx + 'px';
                img.style.maxWidth = 'none';
                img.style.objectFit = 'contain';
                return;
            }

            var topbar = img.closest('.corp-topbar');
            if (topbar) {
                var logoBarPx = Math.round(14 * pxPerMm);
                img.style.width = logoBarPx + 'px';
                img.style.height = 'auto';
                img.style.maxHeight = Math.round(10 * pxPerMm) + 'px';
                img.style.objectFit = 'contain';
                return;
            }

            var backLogo = img.closest('.back-logo');
            if (backLogo) {
                var backPx = Math.round(12 * pxPerMm);
                img.style.width = backPx + 'px';
                img.style.height = backPx + 'px';
                img.style.objectFit = 'contain';
                return;
            }

            if (img.classList.contains('wm-photo') || img.classList.contains('corp-photo')) {
                return;
            }

            if (img.classList.contains('wm-firma-img')) {
                return;
            }
        });
    }

    function resizeCanvasToTarget(src, targetW, targetH) {
        if (src.width === targetW && src.height === targetH) {
            return src;
        }
        var out = document.createElement('canvas');
        out.width = targetW;
        out.height = targetH;
        var ctx = out.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, targetW, targetH);
        var fit = Math.min(targetW / src.width, targetH / src.height);
        var dw = Math.round(src.width * fit);
        var dh = Math.round(src.height * fit);
        var dx = Math.round((targetW - dw) / 2);
        var dy = Math.round((targetH - dh) / 2);
        var downscale = fit < 1;
        ctx.imageSmoothingEnabled = downscale;
        if (downscale && ctx.imageSmoothingQuality) {
            ctx.imageSmoothingQuality = 'high';
        }
        ctx.drawImage(src, dx, dy, dw, dh);
        return out;
    }

    async function captureCardToJpeg(cardEl, filename) {
        prepareImagesForCapture(cardEl);
        await waitImages(cardEl);

        var targetW = mmToPx(CARD_W_MM, EXPORT_DPI);
        var targetH = mmToPx(CARD_H_MM, EXPORT_DPI);
        var rect = cardEl.getBoundingClientRect();
        var screenScale = getCardScaleOnScreen();
        var exportScale = EXPORT_DPI / SCREEN_DPI;
        var expectedW = rect.width * (exportScale / screenScale);
        var canvasScale = Math.max(2.5, targetW / Math.max(expectedW, 1));

        var canvas = await html2canvas(cardEl, {
            scale: canvasScale,
            useCORS: true,
            allowTaint: false,
            backgroundColor: '#ffffff',
            logging: false,
            onclone: function (doc, node) {
                prepareExportClone(doc, node);
            },
        });

        var out = resizeCanvasToTarget(canvas, targetW, targetH);
        var link = document.createElement('a');
        link.download = filename;
        link.href = out.toDataURL('image/jpeg', 0.98);
        link.click();
    }

    function getCardScaleOnScreen() {
        var root = getComputedStyle(document.documentElement);
        return parseFloat(root.getPropertyValue('--card-scale')) || 1.4;
    }

    async function exportCredentialCards(options) {
        if (typeof html2canvas !== 'function') {
            alert('No se pudo cargar html2canvas. Revisa tu conexion e intenta de nuevo.');
            return;
        }

        var cards = document.querySelectorAll(options.cardSelector);
        if (!cards.length) {
            alert('No se encontraron tarjetas para exportar.');
            return;
        }

        var sides = options.sides || ['frente', 'reverso'];
        var idPart = slugFilePart(options.empleadoId);
        var btn = options.buttonEl;
        var prevText = '';
        if (btn) {
            prevText = btn.textContent;
            btn.disabled = true;
            btn.textContent = 'Generando JPG…';
        }

        try {
            for (var i = 0; i < cards.length && i < sides.length; i++) {
                var fname = options.prefix + '_' + idPart + '_' + sides[i] + '.jpg';
                await captureCardToJpeg(cards[i], fname);
                if (i < cards.length - 1 && i < sides.length - 1) {
                    await new Promise(function (r) { setTimeout(r, 450); });
                }
            }
        } catch (err) {
            console.error(err);
            alert('Error al generar JPG. Intenta de nuevo o usa Imprimir.');
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.textContent = prevText;
            }
        }
    }

    global.exportCredentialCards = exportCredentialCards;
})(window);
