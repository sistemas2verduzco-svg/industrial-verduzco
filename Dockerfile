FROM python:3.11-slim

WORKDIR /app

# Instalar herramientas necesarias (pg_dump para backups)
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar aplicación
COPY . .

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Crear directorio para backups
RUN mkdir -p /app/backups

# Exponer puerto interno
EXPOSE 5000

# Usar Gunicorn (servidor de producción) con 4 workers por defecto
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
