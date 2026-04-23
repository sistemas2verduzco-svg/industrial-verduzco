import { startTransition, useEffect, useState } from 'react';

function getApiBaseUrl() {
  const envBase = import.meta.env.VITE_API_BASE_URL;
  if (envBase) return envBase.replace(/\/$/, '');

  if (typeof window !== 'undefined') {
    const { origin, hostname } = window.location;
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'http://localhost:5001';
    }
    return origin;
  }

  return 'http://localhost:5001';
}

export function usePricing() {
  const [prices, setPrices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [meta, setMeta] = useState({ fetchedAt: '', source: '' });

  useEffect(() => {
    let active = true;

    async function loadPricing() {
      setLoading(true);
      setError('');

      try {
        const response = await fetch(`${getApiBaseUrl()}/api/precios`);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const payload = await response.json();
        if (!active) return;

        startTransition(() => {
          setPrices(Array.isArray(payload.materials) ? payload.materials : []);
          setMeta({
            fetchedAt: payload.fetchedAt || '',
            source: payload.source || '',
          });
        });
      } catch (fetchError) {
        if (!active) return;
        setError('No fue posible cargar los precios del cotizador.');
      } finally {
        if (active) setLoading(false);
      }
    }

    loadPricing();

    return () => {
      active = false;
    };
  }, []);

  return { prices, loading, error, meta };
}
