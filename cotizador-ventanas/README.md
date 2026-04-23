# Cotizador de Ventanas

Proyecto web independiente para cotizacion publica de ventanas, separado del sistema MES actual. Incluye frontend React, backend Node.js con Express, visualizacion 3D con Three.js, integracion con Google Sheets y despliegue con Docker.

## Estructura

```text
cotizador-ventanas/
  backend/
    src/
      config/
      controllers/
      middleware/
      routes/
      services/
  frontend/
    src/
      components/
      hooks/
      utils/
  nginx/
  docker-compose.yml
  .env.example
```

## Caracteristicas

- Landing page publica y responsive.
- Secciones: inicio, productos, galeria, cotizador y contacto.
- Calculo en tiempo real desde datos consumidos del backend.
- Visor 3D interactivo de ventana usando Three.js y OrbitControls.
- Backend con arquitectura modular y cache en memoria de 5 minutos.
- Fuente de precios configurable desde Google Sheets publico.
- Contenedores independientes: `cotizador_front` y `cotizador_back`.
- Configuracion nginx lista para subdominio `cotizador.midominio.com`.

## Configuracion de Google Sheets

Publica una hoja como CSV y usa una URL de este estilo:

```text
https://docs.google.com/spreadsheets/d/e/TU_ID_PUBLICO/pub?gid=0&single=true&output=csv
```

Columnas recomendadas en la hoja:

```text
material,tipo_ventana,color,precio_base,precio_m2,recargo_color,moneda
```

Ejemplo:

```csv
material,tipo_ventana,color,precio_base,precio_m2,recargo_color,moneda
Aluminio,Corrediza,Natural,1500,2400,0,MXN
Aluminio,Corrediza,Negro,1500,2400,350,MXN
PVC,Fija,Blanco,1100,1800,0,MXN
PVC,Abatible,Gris,1400,2100,180,MXN
```

## Desarrollo local

### Backend

```bash
cd backend
npm install
npm run dev
```

Servidor disponible en `http://localhost:5001`.

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Sitio disponible en `http://localhost:3001`.

## Docker

1. Copia `.env.example` a `.env` dentro de `cotizador-ventanas`.
2. Ajusta `GOOGLE_SHEETS_CSV_URL` con tu hoja publica.
3. Levanta los contenedores:

```bash
docker compose up --build -d
```

Servicios:

- Frontend: `http://localhost:3001`
- Backend: `http://localhost:5001/api/precios`

## Nginx para subdominio

El archivo [nginx/cotizador.midominio.com.conf](nginx/cotizador.midominio.com.conf) enruta:

- `cotizador.midominio.com` hacia el frontend en puerto `3001`
- `/api` hacia el backend en puerto `5001`

## Notas de aislamiento

- El proyecto vive en una carpeta independiente.
- Usa puertos `3001` y `5001` para evitar conflicto con otros servicios.
- No modifica el `docker-compose.yml` ni el nginx del sistema principal.
- Puede desplegarse como stack separado o en otro servidor sin arrastrar dependencias del MES.
