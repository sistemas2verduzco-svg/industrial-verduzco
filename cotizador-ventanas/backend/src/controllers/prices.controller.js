import { getSheetPrices } from '../services/sheets.service.js';

export async function getPrices(req, res, next) {
  try {
    const payload = await getSheetPrices();
    res.json(payload);
  } catch (error) {
    next(error);
  }
}
