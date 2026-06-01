/**
 * Descarga credenciales (frente/reverso) como JPG generado en servidor (Pillow, 300 DPI).
 */
(function (global) {
    function slugFilePart(s) {
        return String(s || 'tecnico').replace(/[^\w.-]+/g, '_').substring(0, 48);
    }

    function triggerBlobDownload(blob, filename) {
        var url = URL.createObjectURL(blob);
        var link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        link.remove();
        setTimeout(function () { URL.revokeObjectURL(url); }, 2000);
    }

    async function exportCredentialCards(options) {
        var exportBaseUrl = options.exportBaseUrl;
        if (!exportBaseUrl) {
            alert('No está configurada la exportación de credencial.');
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
                var side = sides[i];
                var fname = options.prefix + '_' + idPart + '_' + side + '.jpg';
                var res = await fetch(exportBaseUrl + '/' + side + '.jpg', {
                    credentials: 'same-origin',
                });
                if (!res.ok) {
                    throw new Error('HTTP ' + res.status);
                }
                var blob = await res.blob();
                triggerBlobDownload(blob, fname);
                if (i < cards.length - 1 && i < sides.length - 1) {
                    await new Promise(function (r) { setTimeout(r, 500); });
                }
            }
        } catch (err) {
            console.error(err);
            alert('Error al generar JPG en el servidor. Intenta de nuevo o usa Imprimir.');
        } finally {
            if (btn) {
                btn.disabled = false;
                btn.textContent = prevText;
            }
        }
    }

    global.exportCredentialCards = exportCredentialCards;
})(window);
