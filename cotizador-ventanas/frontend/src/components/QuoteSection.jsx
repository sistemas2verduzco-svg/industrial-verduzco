import { Suspense, lazy, useState } from 'react';

const WindowViewer3D = lazy(() => import('./WindowViewer3D.jsx').then((module) => ({ default: module.WindowViewer3D })));

function formatMoney(value, currency) {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: currency || 'MXN',
    maximumFractionDigits: 2,
  }).format(value || 0);
}

export function QuoteSection({
  form,
  onChange,
  materials,
  windowTypes,
  colors,
  quote,
  loading,
  error,
  meta,
}) {
  const [viewerMode, setViewerMode] = useState('photo');
  const [cameraPreset, setCameraPreset] = useState('facade');

  return (
    <section id="cotizador" className="section-block quote-section">
      <div className="container">
        <div className="section-heading split-heading">
          <div>
            <span className="eyebrow">COTIZADOR</span>
            <h2>Configura medidas, acabados y tipologia con calculo en tiempo real.</h2>
          </div>
          <p>
            El precio se calcula en cliente usando datos servidos por el backend. El modulo es escalable y permite
            sustituir reglas o integrar mas variables sin rehacer la interfaz base.
          </p>
        </div>

        <div className="quote-layout">
          <article className="quote-panel form-panel">
            <div className="status-strip">
              <span className={loading ? 'status-dot active' : 'status-dot'}></span>
              <span>{loading ? 'Cargando precios...' : 'Precios listos para cotizar'}</span>
            </div>

            {error ? <div className="alert-box">{error}</div> : null}

            <div className="form-grid">
              <label>
                Ancho (cm)
                <input name="width" type="number" min="30" step="1" value={form.width} onChange={onChange} />
              </label>
              <label>
                Alto (cm)
                <input name="height" type="number" min="30" step="1" value={form.height} onChange={onChange} />
              </label>
              <label>
                Tipo de ventana
                <select name="windowType" value={form.windowType} onChange={onChange}>
                  {windowTypes.map((item) => (
                    <option key={item} value={item}>{item}</option>
                  ))}
                </select>
              </label>
              <label>
                Tipo de material
                <select name="material" value={form.material} onChange={onChange}>
                  {materials.map((item) => (
                    <option key={item} value={item}>{item}</option>
                  ))}
                </select>
              </label>
              <label>
                Color
                <select name="color" value={form.color} onChange={onChange}>
                  {colors.map((item) => (
                    <option key={item} value={item}>{item}</option>
                  ))}
                </select>
              </label>
            </div>

            <div className="pricing-box">
              <div>
                <span className="mini-label">Area estimada</span>
                <strong>{quote.area ? `${quote.area.toFixed(2)} m²` : '0.00 m²'}</strong>
              </div>
              <div>
                <span className="mini-label">Subtotal</span>
                <strong>{formatMoney(quote.subtotal, quote.currency)}</strong>
              </div>
              <div>
                <span className="mini-label">Instalacion estimada</span>
                <strong>{formatMoney(quote.installationEstimate, quote.currency)}</strong>
              </div>
            </div>

            <div className="quote-total-card">
              <span>Total estimado</span>
              <strong>{formatMoney(quote.total, quote.currency)}</strong>
              <p>
                {quote.ready
                  ? `Configuracion base: ${quote.record.material} / ${quote.record.windowType} / ${quote.record.color}`
                  : 'Selecciona dimensiones y combinaciones disponibles para generar la cotizacion.'}
              </p>
            </div>

            <div className="quote-meta">
              <span>Fuente de datos: Google Sheets</span>
              <span>Actualizado: {meta.fetchedAt ? new Date(meta.fetchedAt).toLocaleString('es-MX') : 'Pendiente'}</span>
            </div>
          </article>

          <article className="quote-panel viewer-panel">
            <div className="viewer-head">
              <div>
                <span className="eyebrow">VISTA 3D</span>
                <h3>Representacion interactiva de la ventana</h3>
              </div>
              <div className="viewer-controls">
                <p className="viewer-help">Orbita la camara y ajusta dimensiones o color desde el formulario.</p>
                <label className="viewer-control">
                  Ambiente visual
                  <select
                    value={viewerMode}
                    onChange={(event) => setViewerMode(event.target.value)}
                  >
                    <option value="photo">Showroom foto</option>
                    <option value="day">Dia natural</option>
                    <option value="sunset">Atardecer</option>
                    <option value="night">Noche elegante</option>
                  </select>
                </label>
                <label className="viewer-control">
                  Angulo de camara
                  <select
                    value={cameraPreset}
                    onChange={(event) => setCameraPreset(event.target.value)}
                  >
                    <option value="facade">Fachada comercial</option>
                    <option value="interior">Interior acogedor</option>
                    <option value="detail">Detalle de herraje</option>
                  </select>
                </label>
                <p className="viewer-touch-hint">Tip movil: arrastra con un dedo para orbitar y pellizca para acercar.</p>
              </div>
            </div>
            <Suspense fallback={<div className="viewer-canvas viewer-loading">Cargando visor 3D...</div>}>
              <WindowViewer3D
                width={form.width}
                height={form.height}
                color={form.color}
                environment={viewerMode}
                cameraPreset={cameraPreset}
              />
            </Suspense>
          </article>
        </div>
      </div>
    </section>
  );
}
