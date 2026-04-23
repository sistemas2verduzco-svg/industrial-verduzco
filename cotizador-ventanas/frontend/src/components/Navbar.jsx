export function Navbar() {
  return (
    <header className="navbar-shell">
      <nav className="navbar container">
        <a href="#inicio" className="brand-mark">
          <span className="brand-kicker">ARQ</span>
          <span className="brand-name">Ventanas Studio</span>
        </a>

        <div className="nav-links">
          <a href="#inicio">Inicio</a>
          <a href="#productos">Productos</a>
          <a href="#galeria">Galeria</a>
          <a href="#cotizador">Cotizador</a>
          <a href="#contacto">Contacto</a>
        </div>

        <a href="#cotizador" className="btn btn-primary nav-cta">
          Cotizar ahora
        </a>
      </nav>
    </header>
  );
}
