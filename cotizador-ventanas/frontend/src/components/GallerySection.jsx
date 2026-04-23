export function GallerySection({ items }) {
  return (
    <section id="galeria" className="section-block gallery-section">
      <div className="container">
        <div className="section-heading split-heading">
          <div>
            <span className="eyebrow">GALERIA</span>
            <h2>Referencias visuales para un lenguaje contemporaneo.</h2>
          </div>
          <p>
            Las tarjetas pueden sustituirse despues por fotografias propias del negocio,
            pero ya queda una base publica lista para mostrar contexto arquitectonico y acabados.
          </p>
        </div>

        <div className="gallery-grid">
          {items.map((item) => (
            <article key={item.title} className="gallery-card" style={{ backgroundImage: `linear-gradient(180deg, rgba(15, 23, 42, 0.12), rgba(15, 23, 42, 0.74)), url(${item.image})` }}>
              <div>
                <span>{item.tag}</span>
                <h3>{item.title}</h3>
                <p>{item.description}</p>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
