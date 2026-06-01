/**
 * Exporta tarjetas de credencial (frente/reverso) a JPG ~300 DPI (CR80 54×85.6 mm).
 * Requiere html2canvas en la página.
 */
(function (global) {
    const CARD_W_MM = 54;
    const CARD_H_MM = 85.6;
    const EXPORT_DPI = 300;
    const MM_PER_IN = 25.4;

    function mmToPx(mm, dpi) {
        return Math.round((mm / MM_PER_IN) * dpi);
    }

    function slugFilePart(s) {
        return String(s || 'tecnico').replace(/[^\w.-]+/g, '_').substring(0, 48);
    }

    function waitImages(root) {
        const imgs = root.querySelectorAll('img');
        return Promise.all(
            Array.from(imgs).map(function (img) {
                if (img.complete && img.naturalWidth) return Promise.resolve();
                return new Promise(function (resolve) {
                    img.addEventListener('load', resolve, { once: true });
                    img.addEventListener('error', resolve, { once: true });
                });
            })
        );
    }

    async function captureCardToJpeg(cardEl, filename, renderScale) {
        await waitImages(cardEl);
        const canvas = await html2canvas(cardEl, {
            scale: renderScale,
            useCORS: true,
            allowTaint: false,
            backgroundColor: '#ffffff',
            logging: false,
            onclone: function (_doc, node) {
                node.style.transform = 'none';
                node.style.transformOrigin = 'top left';
                node.style.boxShadow = 'none';
            },
        });

        const targetW = mmToPx(CARD_W_MM, EXPORT_DPI);
        const targetH = mmToPx(CARD_H_MM, EXPORT_DPI);
        const out = document.createElement('canvas');
        out.width = targetW;
        out.height = targetH;
        const ctx = out.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, targetW, targetH);

        const fit = Math.min(targetW / canvas.width, targetH / canvas.height);
        const dw = canvas.width * fit;
        const dh = canvas.height * fit;
        const dx = (targetW - dw) / 2;
        const dy = (targetH - dh) / 2;
        ctx.drawImage(canvas, dx, dy, dw, dh);

        const link = document.createElement('a');
        link.download = filename;
        link.href = out.toDataURL('image/jpeg', 0.92);
        link.click();
    }

    async function exportCredentialCards(options) {
        if (typeof html2canvas !== 'function') {
            alert('No se pudo cargar html2canvas. Revisa tu conexion e intenta de nuevo.');
            return;
        }

        const cards = document.querySelectorAll(options.cardSelector);
        if (!cards.length) {
            alert('No se encontraron tarjetas para exportar.');
            return;
        }

        const sides = options.sides || ['frente', 'reverso'];
        const idPart = slugFilePart(options.empleadoId);
        const btn = options.buttonEl;
        let prevText = '';
        if (btn) {
            prevText = btn.textContent;
            btn.disabled = true;
            btn.textContent = 'Generando JPG…';
        }

        try {
            for (let i = 0; i < cards.length && i < sides.length; i++) {
                const fname = options.prefix + '_' + idPart + '_' + sides[i] + '.jpg';
                await captureCardToJpeg(cards[i], fname, options.renderScale || 4);
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
