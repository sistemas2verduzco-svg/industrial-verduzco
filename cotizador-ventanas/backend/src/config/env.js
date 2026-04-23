import dotenv from 'dotenv';

dotenv.config();

const parseList = (value, fallback = []) => {
  if (!value) return fallback;
  return value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
};

export const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 5001),
  frontendOrigins: parseList(process.env.FRONTEND_ORIGINS, ['http://localhost:3001', 'http://127.0.0.1:3001']),
  sheetsCsvUrl:
    process.env.GOOGLE_SHEETS_CSV_URL ||
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vQ-demo/pub?gid=0&single=true&output=csv',
  cacheTtlMs: Number(process.env.CACHE_TTL_MS || 300000),
};
