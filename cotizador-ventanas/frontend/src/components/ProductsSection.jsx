export function ProductsSection({ products }) {
  return (
    <section id="productos" className="section-block">
      <div className="container">
        <div className="section-heading">
          <span className="eyebrow">PORTAFOLIO</span>
          <h2>Tipos de ventanas para diferentes estrategias de iluminacion y ventilacion.</h2>
          <p>
            La pagina fue planteada para una presentacion comercial seria: informacion clara,
            enfoque visual y estructura reutilizable para crecer en catalogo y reglas de negocio.
          </p>
        </div>

        <div className="products-grid">
          {products.map((product) => (
            <article key={product.title} className="product-card">
              <div className="product-icon">{product.icon}</div>
              <h3>{product.title}</h3>
              <p>{product.description}</p>
              <span className="product-meta">{product.meta}</span>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
