import { useEffect, useState } from 'react';
import { Navbar } from './components/Navbar.jsx';
import { HeroSection } from './components/HeroSection.jsx';
import { ProductsSection } from './components/ProductsSection.jsx';
import { GallerySection } from './components/GallerySection.jsx';
import { QuoteSection } from './components/QuoteSection.jsx';
import { ContactSection } from './components/ContactSection.jsx';
import { usePricing } from './hooks/usePricing.js';
import {
  calculateQuote,
  getAvailableColors,
  getAvailableMaterials,
  getAvailableWindowTypes,
} from './utils/quote.js';

const products = [
  {
    icon: '01',
    title: 'Ventana corrediza',
    description: 'Ideal para vanos amplios y circulacion controlada en residencias, oficinas y frentes comerciales.',
    meta: 'Apertura horizontal / imagen limpia',
  },
  {
    icon: '02',
    title: 'Ventana fija',
    description: 'Solucion enfocada en entrada de luz, continuidad visual y fachadas minimalistas.',
    meta: 'Maxima transparencia / bajo mantenimiento',
  },
  {
    icon: '03',
    title: 'Ventana abatible',
    description: 'Pensada para ventilacion precisa y mayor control de operacion en espacios tecnicos o interiores.',
    meta: 'Ventilacion dirigida / detalle premium',
  },
];

const galleryItems = [
  {
    tag: 'Residencial premium',
    title: 'Grandes claros con marcos sobrios',
    description: 'Composiciones limpias para luz natural continua.',
    image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
  },
  {
    tag: 'Arquitectura comercial',
    title: 'Fachadas que comunican orden y precision',
    description: 'Acabados neutros y perfiles de presencia tecnica.',
    image: 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80',
  },
  {
    tag: 'Interiores ejecutivos',
    title: 'Integracion visual con materiales contemporaneos',
    description: 'Cristal, aluminio y proporciones balanceadas.',
    image: 'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?auto=format&fit=crop&w=1200&q=80',
  },
];

export default function App() {
  const { prices, loading, error, meta } = usePricing();
  const [form, setForm] = useState({
    width: 180,
    height: 140,
    windowType: '',
    material: '',
    color: '',
  });

  const materials = getAvailableMaterials(prices);
  const windowTypes = getAvailableWindowTypes(prices);
  const colors = getAvailableColors(prices, form.material, form.windowType);

  useEffect(() => {
    if (!prices.length) return;

    setForm((current) => ({
      ...current,
      material: current.material || materials[0] || '',
      windowType: current.windowType || windowTypes[0] || '',
    }));
  }, [prices.length, materials, windowTypes]);

  useEffect(() => {
    if (!colors.length) return;
    setForm((current) => {
      if (colors.includes(current.color)) return current;
      return { ...current, color: colors[0] };
    });
  }, [colors]);

  const quote = calculateQuote(form, prices);

  function handleChange(event) {
    const { name, value } = event.target;
    setForm((current) => ({
      ...current,
      [name]: value,
    }));
  }

  return (
    <div className="site-shell">
      <Navbar />
      <HeroSection />
      <ProductsSection products={products} />
      <GallerySection items={galleryItems} />
      <QuoteSection
        form={form}
        onChange={handleChange}
        materials={materials}
        windowTypes={windowTypes}
        colors={colors}
        quote={quote}
        loading={loading}
        error={error}
        meta={meta}
      />
      <ContactSection />

      <footer className="site-footer">
        <div className="container footer-inner">
          <div>
            <span className="eyebrow">VENTANAS STUDIO</span>
            <p>Frontend React, backend Node.js y despliegue independiente listo para subdominio.</p>
          </div>
          <a href="#inicio">Volver arriba</a>
        </div>
      </footer>
    </div>
  );
}
