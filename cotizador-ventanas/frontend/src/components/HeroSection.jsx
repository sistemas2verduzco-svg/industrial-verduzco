export function HeroSection() {
  return (
    <section id="inicio" className="hero-section">
      <div className="container hero-grid">
        <div className="hero-copy">
          <span className="eyebrow">SISTEMA DE COTIZACION PARA VENTANAS</span>
          <h1>Precision arquitectonica para proyectos residenciales y comerciales.</h1>
          <p>
            Cotiza ventanas corredizas, fijas y abatibles con una experiencia visual moderna,
            parametros tecnicos en tiempo real y un visor 3D pensado para presentar propuestas con claridad.
          </p>

          <div className="hero-actions">
            <a href="#cotizador" className="btn btn-primary">Cotizar ahora</a>
            <a href="#productos" className="btn btn-secondary">Ver soluciones</a>
          </div>

          <div className="hero-metrics">
            <div>
              <strong>+120</strong>
              <span>Configuraciones cotizables</span>
            </div>
            <div>
              <strong>3D</strong>
              <span>Vista en tiempo real</span>
            </div>
            <div>
              <strong>Sheets</strong>
              <span>Precios actualizados</span>
            </div>
          </div>
        </div>

        <div className="hero-panel">
          <div className="hero-panel-card glass-card">
            <span className="panel-tag">Proyecto destacado</span>
            <h3>Fachadas ligeras y perfiles de alto desempeño</h3>
            <p>
              Una interfaz publica pensada para convertir interes en propuestas concretas,
              sin depender del sistema MES ni interferir con otros servicios productivos.
            </p>
            <ul className="feature-list">
              <li>Precios desde Google Sheets</li>
              <li>Calculo instantaneo por medidas</li>
              <li>Preparado para subdominio independiente</li>
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
