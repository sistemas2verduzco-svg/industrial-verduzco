export function ContactSection() {
  return (
    <section id="contacto" className="section-block contact-section">
      <div className="container contact-grid">
        <div className="section-heading">
          <span className="eyebrow">CONTACTO</span>
          <h2>Conecta el cotizador con tu equipo comercial.</h2>
          <p>
            Esta seccion queda preparada para capturar prospectos y conectar con procesos de seguimiento,
            sin mezclar responsabilidades con otros sistemas internos.
          </p>

          <div className="contact-cards">
            <div className="contact-card">
              <strong>Telefono</strong>
              <span>+52 800 000 0000</span>
            </div>
            <div className="contact-card">
              <strong>Correo</strong>
              <span>ventas@midominio.com</span>
            </div>
            <div className="contact-card">
              <strong>Ubicacion</strong>
              <span>Zona industrial / Atencion nacional</span>
            </div>
          </div>
        </div>

        <form className="contact-form">
          <label>
            Nombre
            <input type="text" placeholder="Tu nombre" />
          </label>
          <label>
            Correo
            <input type="email" placeholder="nombre@correo.com" />
          </label>
          <label>
            Telefono
            <input type="tel" placeholder="555 000 0000" />
          </label>
          <label>
            Proyecto
            <textarea rows="5" placeholder="Describe medidas, ubicacion y requerimientos."></textarea>
          </label>
          <button type="submit" className="btn btn-primary">Enviar consulta</button>
        </form>
      </div>
    </section>
  );
}
