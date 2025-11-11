# Catálogo Web - Plataforma de Productos con Docker

Esta es una plataforma web completa para gestionar un catálogo de productos, construida con **Flask**, **PostgreSQL** y **Docker**.

## 📋 Características

✅ **Catálogo de productos** - Vista pública de todos los productos
✅ **Panel de administración** - CRUD completo (Crear, Leer, Actualizar, Eliminar)
✅ **API REST** - Endpoints para integración con otros sistemas
✅ **Base de datos PostgreSQL** - Almacenamiento robusto multi-usuario
✅ **Multi-usuario** - Acceso desde múltiples usuarios en tu red
✅ **Responsive** - Funciona en computadora, tablet y móvil
✅ **Docker Compose** - Deployment profesional y fácil

## 🚀 Requisitos

- **Docker** instalado ([Descargar aquí](https://www.docker.com/products/docker-desktop))
- **Docker Compose** (incluido en Docker Desktop)
- Puerto **5000** disponible (aplicativo)
- Puerto **5432** disponible (base de datos)

## 📁 Estructura del Proyecto

```
CATALOGO WEB/
├── app.py                  # Aplicativo principal Flask
├── models.py              # Modelos de base de datos
├── requirements.txt       # Dependencias Python
├── Dockerfile             # Configuración del contenedor
├── docker-compose.yml     # Orquestación de contenedores
├── .env                   # Variables de entorno
├── templates/
│   ├── index.html        # Página del catálogo público
│   └── admin.html        # Panel de administración
└── static/
    ├── styles.css        # Estilos CSS
    ├── admin.js          # JavaScript del admin
    └── app.js            # JavaScript del catálogo
```

## 🐳 Cómo Ejecutar con Docker

### 1. Abre PowerShell y ve a la carpeta del proyecto

```powershell
cd "c:\Users\PRIDE BACK TO SCHOOL\Documents\CATALOGO WEB"
```

### 2. Levanta los contenedores

```powershell
docker-compose up
```

**Espera hasta ver en la consola:**
```
 * Running on http://0.0.0.0:5000
```

### 3. Accede a la aplicación

**En tu PC:**
- 🏠 Catálogo: http://localhost:5000
- 🔧 Admin: http://localhost:5000/admin

**Desde otra PC en tu red:**
- Averigua tu IP: En PowerShell: `ipconfig` (busca "IPv4 Address")
- 🏠 Catálogo: http://TU_IP:5000
- 🔧 Admin: http://TU_IP:5000/admin

### 4. Detener la aplicación

En la misma consola donde corre: `Ctrl + C`

## 📊 Estructura de Base de Datos

### Tabla: Productos

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID único |
| `nombre` | String | Nombre del producto |
| `descripcion` | Text | Descripción |
| `precio` | Float | Precio |
| `cantidad` | Integer | Stock disponible |
| `imagen_url` | String | URL de la imagen |
| `categoria` | String | Categoría |
| `fecha_creacion` | DateTime | Cuándo se creó |
| `fecha_actualizacion` | DateTime | Última actualización |

## 🔌 API Endpoints

### Productos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/productos` | Obtener todos los productos |
| GET | `/api/productos/<id>` | Obtener producto por ID |
| POST | `/api/productos` | Crear nuevo producto |
| PUT | `/api/productos/<id>` | Actualizar producto |
| DELETE | `/api/productos/<id>` | Eliminar producto |
| GET | `/api/estadisticas` | Estadísticas del catálogo |

### Ejemplo: Crear Producto con cURL

```powershell
$headers = @{"Content-Type"="application/json"}
$body = @{
    nombre="Mi Producto"
    descripcion="Descripción"
    precio=99.99
    cantidad=10
    categoria="Categoría"
    imagen_url="https://ejemplo.com/imagen.jpg"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5000/api/productos" `
    -Method POST `
    -Headers $headers `
    -Body $body
```

## 🔐 Credenciales Base de Datos

Las credenciales están en `docker-compose.yml`:
- **Usuario**: catalogo_user
- **Contraseña**: catalogo_pass
- **Base de datos**: catalogo_db

⚠️ **IMPORTANTE**: Para producción, cambia las credenciales en `docker-compose.yml` antes de publicar

## 🐛 Solución de Problemas

### Error: Puerto 5000 en uso

```powershell
# Encuentra qué usa el puerto
netstat -ano | findstr :5000

# Mata el proceso (reemplaza PID)
taskkill /PID <PID> /F
```

### Reiniciar contenedores

```powershell
docker-compose down
docker-compose up
```

### Ver logs

```powershell
docker-compose logs -f
```

### Limpiar todo

```powershell
docker-compose down -v
```

## 📝 Agregar Datos de Prueba

1. Ve a **Admin**: http://localhost:5000/admin
2. Llena el formulario
3. Haz clic en "Agregar Producto"

O desde PowerShell (ejemplo):

```powershell
$headers = @{"Content-Type"="application/json"}

$productos = @(
    @{nombre="Laptop"; precio=999.99; cantidad=5; categoria="Electrónica"},
    @{nombre="Mouse"; precio=25.00; cantidad=50; categoria="Accesorios"},
    @{nombre="Teclado"; precio=75.00; cantidad=30; categoria="Accesorios"}
)

foreach($p in $productos) {
    Invoke-WebRequest -Uri "http://localhost:5000/api/productos" `
        -Method POST `
        -Headers $headers `
        -Body ($p | ConvertTo-Json)
    
    Write-Host "Producto $($p.nombre) agregado"
}
```

## 🌐 Acceso desde la Red Local

Si tienes varias PCs en la misma red:

1. **En tu servidor (donde corre Docker):**
   ```powershell
   ipconfig
   ```
   Busca "IPv4 Address" (ej: 192.168.1.100)

2. **En otras PCs:**
   - Abre el navegador
   - Ve a: `http://192.168.1.100:5000`

## 🚢 Deployment a Producción

Para desplegar en un servidor real:

1. Sube los archivos a tu servidor
2. Asegúrate de tener Docker instalado
3. Cambia credenciales en `docker-compose.yml`
4. Ejecuta: `docker-compose up -d`
5. Usa Nginx/Let's Encrypt para SSL

## 📞 Soporte

¿Algo no funciona? Verifica:
- ✅ Docker está corriendo
- ✅ Puertos 5000 y 5432 están libres
- ✅ Revisa los logs: `docker-compose logs`
- ✅ Reinicia todo: `docker-compose down && docker-compose up`

---

**¡Lista tu plataforma de catálogo!** 🎉
