import axios from 'axios';
import { parse } from 'csv-parse/sync';
import { env } from '../config/env.js';
import { memoryCache } from './cache.service.js';

const CACHE_KEY = 'google-sheet-prices';

const HEADER_ALIASES = {
  material: ['material', 'material_type', 'tipo_material'],
  windowType: ['window_type', 'tipo_ventana', 'ventana', 'producto'],
  color: ['color', 'acabado'],
  basePrice: ['base_price', 'precio_base', 'base'],
  pricePerSquareMeter: ['price_per_square_meter', 'precio_m2', 'precio_por_m2', 'precio_metro2'],
  colorSurcharge: ['color_surcharge', 'recargo_color', 'plus_color'],
  currency: ['currency', 'moneda'],
};

function normalizeHeader(header) {
  return String(header || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function getValue(row, aliases) {
  for (const alias of aliases) {
    const key = normalizeHeader(alias);
    if (Object.prototype.hasOwnProperty.call(row, key) && String(row[key] || '').trim() !== '') {
      return row[key];
    }
  }
  return '';
}

function parseMoney(value) {
  if (value === null || value === undefined || value === '') return 0;
  const normalized = String(value)
    .replace(/\$/g, '')
    .replace(/,/g, '')
    .replace(/\s+/g, '')
    .trim();
  const amount = Number(normalized);
  return Number.isFinite(amount) ? amount : 0;
}

function normalizeRecord(row) {
  const material = String(getValue(row, HEADER_ALIASES.material)).trim();
  const windowType = String(getValue(row, HEADER_ALIASES.windowType)).trim();
  const color = String(getValue(row, HEADER_ALIASES.color)).trim() || 'Natural';

  if (!material || !windowType) return null;

  return {
    material,
    windowType,
    color,
    basePrice: parseMoney(getValue(row, HEADER_ALIASES.basePrice)),
    pricePerSquareMeter: parseMoney(getValue(row, HEADER_ALIASES.pricePerSquareMeter)),
    colorSurcharge: parseMoney(getValue(row, HEADER_ALIASES.colorSurcharge)),
    currency: String(getValue(row, HEADER_ALIASES.currency)).trim() || 'MXN',
  };
}

async function fetchSheetCsv() {
  const response = await axios.get(env.sheetsCsvUrl, {
    responseType: 'text',
    timeout: 10000,
  });

  return response.data;
}

function parseSheetCsv(csvText) {
  const rows = parse(csvText, {
    columns: (headers) => headers.map(normalizeHeader),
    skip_empty_lines: true,
    trim: true,
  });

  return rows
    .map(normalizeRecord)
    .filter(Boolean);
}

export async function getSheetPrices() {
  const cached = memoryCache.get(CACHE_KEY);
  if (cached) {
    return {
      ...cached,
      cache: 'hit',
    };
  }

  try {
    const csvText = await fetchSheetCsv();
    const materials = parseSheetCsv(csvText);

    const payload = {
      materials,
      source: env.sheetsCsvUrl,
      fetchedAt: new Date().toISOString(),
      cacheTtlMs: env.cacheTtlMs,
    };

    memoryCache.set(CACHE_KEY, payload, env.cacheTtlMs);

    return {
      ...payload,
      cache: 'miss',
    };
  } catch (error) {
    const wrappedError = new Error('No fue posible obtener precios desde Google Sheets');
    wrappedError.status = 502;
    wrappedError.details = error.message;
    throw wrappedError;
  }
}
