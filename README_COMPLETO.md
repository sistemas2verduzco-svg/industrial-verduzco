# CATÁLOGO WEB - Plataforma Profesional de Gestión de Productos

## 📋 Descripción General

**CATÁLOGO WEB** es una plataforma web completa, segura y lista para producción para gestionar un catálogo de productos. Construida con tecnologías modernas y mejores prácticas de desarrollo.

### Características Principales

✅ **Interfaz Web Responsiva** - Funciona en PC, tablet y móvil
✅ **Panel Administrativo Seguro** - Autenticación de sesión con contraseña hasheada
✅ **API REST Completa** - Endpoints CRUD para integración con otros sistemas
✅ **Base de Datos PostgreSQL** - Robusta, multi-usuario, escalable
✅ **Servidor de Producción** - Gunicorn + Nginx (reverse proxy)
✅ **Docker Containerizado** - Deploy y escalado sin fricciones
✅ **Multi-Red** - Acceso desde múltiples PCs en tu red
✅ **Seguridad** - Hash de contraseñas, CSRF protection, variables de entorno

---

## 🚀 **Inicio Rápido**

### Requisitos
- Docker Desktop instalado
- Puerto 80 disponible
- Windows PowerShell

### Pasos

1. **Navega a la carpeta del proyecto**
   ```powershell
   cd "c:\Users\PRIDE BACK TO SCHOOL\Documents\CATALOGO WEB"
   ```

2. **Levanta los servicios**
   ```powershell
   docker-compose up -d --build
   ```

3. **Accede a la app**
   - 🌐 Catálogo público: http://localhost
   - 🔐 Panel admin: http://localhost/admin
   - 👤 Usuario: `admin` | Contraseña: `admin123`

4. **Detener la app** (cuando termines)
   ```powershell
   docker-compose down
   ```

---

## 📁 **Estructura del Proyecto**

```
CATALOGO WEB/
│
├── 📄 Archivos Python
│   ├── app.py              ← Aplicativo principal Flask + rutas
│   ├── models.py           ← Modelos de BD (Producto)
│   ├── auth.py             ← Módulo de autenticación
│   └── requirements.txt    ← Dependencias Python
│
├── 🐳 Docker
│   ├── Dockerfile          ← Imagen de la app (Python 3.11 + Gunicorn)
│   ├── docker-compose.yml  ← Orquestación (app + db + nginx)
│   └── nginx/
│       └── default.conf    ← Configuración de Nginx
│
├── 🎨 Frontend
│   ├── templates/
│   │   ├── index.html      ← Catálogo público
│   │   ├── admin.html      ← Panel de administración
│   │   └── login.html      ← Página de login
│   └── static/
│       ├── styles.css      ← Estilos (diseño responsive)
│       ├── admin.js        ← JavaScript del admin
│       └── app.js          ← JavaScript público
│
├── ⚙️ Configuración
│   ├── .env                ← Variables de entorno (no commitear)
│   ├── .env.example        ← Plantilla de variables (para el repo)
│   └── .gitignore          ← Archivos ignorados en Git
│
├── 📜 Documentación
│   ├── README.md           ← Guía técnica completa
│   ├── GUIA_VISUAL.md      ← Guía visual y rápida
│   ├── backup.sh           ← Script de backup automático
│   └── start.bat           ← Script de inicio (Windows)
│
├── 📦 Volúmenes Docker
│   └── backups/            ← Copias de seguridad de la BD

```

---

## 🎯 **Casos de Uso**

### Caso 1: Ver el Catálogo
```
1. Abre http://localhost
2. Visualiza todos los productos
3. Ve nombre, precio, stock, imagen y categoría
```

### Caso 2: Agregar un Producto
```
1. Abre http://localhost/admin
2. Login: admin / admin123
3. Llena el formulario
4. Haz clic en "Agregar Producto"
5. Aparecerá en el catálogo público automáticamente
```

### Caso 3: Editar Producto
```
1. En /admin, tabla de productos
2. Haz clic en "Editar"
3. Modifica datos
4. Haz clic en "Guardar Cambios"
```

### Caso 4: Acceder desde otra PC
```
1. En tu servidor: ipconfig → Busca IPv4
2. En otra PC: http://192.168.1.100 (reemplaza con tu IP)
```

---

## 🔌 **API REST Endpoints**

| Método | Endpoint | Autenticación | Descripción |
|--------|----------|---------------|-------------|
| GET | `/api/productos` | No | Obtener todos los productos |
| GET | `/api/productos/<id>` | No | Obtener producto por ID |
| POST | `/api/productos` | **Sí** | Crear nuevo producto |
| PUT | `/api/productos/<id>` | **Sí** | Actualizar producto |
| DELETE | `/api/productos/<id>` | **Sí** | Eliminar producto |
| GET | `/api/estadisticas` | No | Obtener estadísticas |

### Ejemplo: Crear Producto con API

```bash
curl -X POST http://localhost/api/productos \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Mi Producto",
    "descripcion": "Descripción",
    "precio": 99.99,
    "cantidad": 10,
    "categoria": "Categoría",
    "imagen_url": "https://example.com/imagen.jpg"
  }'
```

---

## 🐳 **Servicios Docker**

### 1. **app** (Aplicación Flask)
- **Imagen**: Python 3.11 slim + Gunicorn
- **Puerto interno**: 5000
- **Workers**: 4 (configurable)
- **Rol**: Servidor de aplicación

### 2. **db** (Base de Datos)
- **Imagen**: PostgreSQL 15
- **Puerto**: 5432 (expuesto localmente)
- **Base de datos**: catalogo_db
- **Usuario**: catalogo_user

### 3. **nginx** (Servidor Web)
- **Imagen**: nginx:stable-alpine
- **Puerto**: 80 (acceso público)
- **Función**: Reverse proxy, servir estáticos
- **Beneficios**: Mejor rendimiento, SSL ready

---

## 📊 **Base de Datos**

### Tabla: `productos`

```sql
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio FLOAT NOT NULL,
    cantidad INTEGER DEFAULT 0,
    imagen_url VARCHAR(500),
    categoria VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);
```

### Conectarse a la BD

```bash
# Acceso directo
psql -h localhost -U catalogo_user -d catalogo_db

# Desde Docker
docker-compose exec db psql -U catalogo_user catalogo_db
```

---

## 🔐 **Seguridad**

### Autenticación
- Contraseñas hasheadas con Werkzeug
- Sesiones seguras con Flask
- CSRF protection en formularios

### Credenciales
- **Usuario admin**: `admin` (cambiar en `.env`)
- **Contraseña admin**: `admin123` (cambiar en `.env`)
- **Secret key**: Generada aleatoriamente (cambiar en producción)

### Variables de Entorno
Usar `.env` para credenciales sensibles:
```ini
ADMIN_USER=admin
ADMIN_PASSWORD=cambiar-en-produccion
SECRET_KEY=clave-aleatoria-larga
DATABASE_URL=postgresql://...
```

---

## 💾 **Backup y Restauración**

### Backup Manual
```powershell
docker-compose exec db pg_dump -U catalogo_user catalogo_db > backup.sql
```

### Restaurar Backup
```powershell
docker-compose exec -T db psql -U catalogo_user catalogo_db < backup.sql
```

### Backup Automático
El script `backup.sh` se puede ejecutar con cron (Linux) o Scheduled Tasks (Windows):
```bash
# Ejecutar manual
docker-compose exec app bash /app/backup.sh
```

---

## 🛠️ **Comandos Útiles**

```powershell
# Ver estado
docker-compose ps

# Ver logs (tiempo real)
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f app
docker-compose logs -f db
docker-compose logs -f nginx

# Reconstruir imágenes
docker-compose up -d --build

# Detener (mantiene datos)
docker-compose down

# Detener y eliminar datos
docker-compose down -v

# Reiniciar un servicio
docker-compose restart app

# Ver puertos
netstat -ano | findstr ":80"
```

---

## 🚀 **Desplegar en Producción**

### Cambios necesarios:

1. **Credenciales** (`.env`)
   ```ini
   ADMIN_USER=admin-produccion
   ADMIN_PASSWORD=contraseña-fuerte-cambiar
   SECRET_KEY=generar-con-secrets.token_hex(32)
   ```

2. **Nginx** (SSL con Let's Encrypt)
   ```nginx
   # Agregar certificados SSL
   ssl_certificate /etc/letsencrypt/live/ejemplo.com/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/ejemplo.com/privkey.pem;
   ```

3. **Docker Compose** (producción)
   ```yaml
   # Cambiar a WSL2 si es necesario
   # Usar secrets para credenciales
   ```

4. **Base de datos** (backup diario)
   ```bash
   # Agregar cron job
   0 2 * * * docker-compose exec db pg_dump -U catalogo_user catalogo_db > /backups/backup_$(date +\%Y\%m\%d).sql
   ```

---

## 📈 **Escalado Futuro**

- ✅ Agregar más servidores de aplicación (load balancing con Nginx)
- ✅ Cache con Redis
- ✅ CDN para imágenes
- ✅ ElasticSearch para búsqueda
- ✅ Microservicios
- ✅ Kubernetes para orquestación

---

## 📞 **Soporte Rápido**

### "No funciona la app"
```powershell
docker-compose logs | Select-String "error"
docker-compose down -v
docker-compose up -d --build
```

### "Puerto 80 en uso"
```powershell
netstat -ano | findstr ":80"
taskkill /PID <PID> /F
```

### "No puedo acceder desde otra PC"
```powershell
ipconfig                          # Ver tu IP
# En otra PC: http://TU_IP
```

### "Perdí los datos"
```powershell
# Restaurar desde backup
docker-compose exec -T db psql -U catalogo_user catalogo_db < backup.sql
```

---

## 📝 **Historial de Cambios**

| Fecha | Cambio |
|-------|--------|
| 10/11/2025 | ✅ Creación inicial: Flask + PostgreSQL + Docker |
| 10/11/2025 | ✅ Gunicorn + Nginx (producción) |
| 10/11/2025 | ✅ Autenticación segura para admin |
| 10/11/2025 | ✅ Script de backup automático |
| 10/11/2025 | ✅ Documentación completa |

---

## 🎉 **¡Listo!**

Tu plataforma de catálogo está **100% operativa**, segura y lista para escalar.

**URLs principales:**
- 🌐 Catálogo: http://localhost
- 🔐 Admin: http://localhost/admin
- 🔌 API: http://localhost/api/productos

**Disfruta!** 🚀
