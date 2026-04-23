function normalizeToken(value) {
  return String(value || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function toNumber(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
}

function uniqueValues(items, pick) {
  return [...new Set(items.map(pick).filter(Boolean))];
}

export function getAvailableMaterials(prices) {
  return uniqueValues(prices, (item) => item.material);
}

export function getAvailableWindowTypes(prices) {
  return uniqueValues(prices, (item) => item.windowType);
}

export function getAvailableColors(prices, material, windowType) {
  const materialKey = normalizeToken(material);
  const windowTypeKey = normalizeToken(windowType);

  const subset = prices.filter((item) => {
    const materialMatches = materialKey ? normalizeToken(item.material) === materialKey : true;
    const windowMatches = windowTypeKey ? normalizeToken(item.windowType) === windowTypeKey : true;
    return materialMatches && windowMatches;
  });

  return uniqueValues(subset, (item) => item.color);
}

function findPriceRecord(prices, form) {
  const materialKey = normalizeToken(form.material);
  const windowKey = normalizeToken(form.windowType);
  const colorKey = normalizeToken(form.color);

  const exact = prices.find(
    (item) =>
      normalizeToken(item.material) === materialKey &&
      normalizeToken(item.windowType) === windowKey &&
      normalizeToken(item.color) === colorKey
  );
  if (exact) return exact;

  const sameMaterialWindow = prices.find(
    (item) =>
      normalizeToken(item.material) === materialKey && normalizeToken(item.windowType) === windowKey
  );
  if (sameMaterialWindow) return sameMaterialWindow;

  return null;
}

export function calculateQuote(form, prices) {
  const widthCm = toNumber(form.width);
  const heightCm = toNumber(form.height);
  const widthM = widthCm / 100;
  const heightM = heightCm / 100;
  const area = widthM * heightM;
  const record = findPriceRecord(prices, form);

  if (!record || widthCm <= 0 || heightCm <= 0) {
    return {
      ready: false,
      subtotal: 0,
      total: 0,
      area: 0,
      currency: 'MXN',
      record: null,
    };
  }

  const openingMultiplier = {
    corrediza: 1,
    fija: 0.85,
    abatible: 1.15,
  }[normalizeToken(form.windowType)] || 1;

  const subtotal = (record.basePrice + area * record.pricePerSquareMeter + record.colorSurcharge) * openingMultiplier;
  const installationEstimate = subtotal * 0.12;
  const total = subtotal + installationEstimate;

  return {
    ready: true,
    area,
    subtotal,
    installationEstimate,
    total,
    currency: record.currency || 'MXN',
    record,
  };
}
