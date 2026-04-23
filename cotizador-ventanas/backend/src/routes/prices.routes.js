import { Router } from 'express';
import { getPrices } from '../controllers/prices.controller.js';

const router = Router();

router.get('/precios', getPrices);

export default router;
