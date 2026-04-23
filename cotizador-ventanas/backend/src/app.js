import cors from 'cors';
import express from 'express';
import pricesRoutes from './routes/prices.routes.js';
import { env } from './config/env.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';

export const app = express();

app.use(express.json());
app.use(
  cors({
    origin(origin, callback) {
      if (!origin) {
        callback(null, true);
        return;
      }

      if (env.frontendOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error('Origen no autorizado por CORS'));
    },
  })
);

app.get('/health', (req, res) => {
  res.json({
    ok: true,
    service: 'cotizador-ventanas-backend',
    time: new Date().toISOString(),
  });
});

app.use('/api', pricesRoutes);
app.use(notFoundHandler);
app.use(errorHandler);
