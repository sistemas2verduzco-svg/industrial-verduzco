# 🎉 CATÁLOGO WEB - Guía Visual y Rápida

## ✨ Lo que hemos construido

Tu plataforma de catálogo web está **completamente operativa en producción** con Docker, Nginx, PostgreSQL y autenticación segura.

---

## 🌐 **Acceso a la Aplicación**

### Desde tu computadora:
- **Catálogo público**: http://localhost
- **Panel admin**: http://localhost/admin

### Desde otra PC en tu red:
1. En tu servidor, abre PowerShell y ejecuta:
   ```powershell
   ipconfig
   ```
   Busca "IPv4 Address" (ej: 192.168.1.100)

2. En otra PC, abre navegador:
   - **Catálogo**: http://192.168.1.100
   - **Admin**: http://192.168.1.100/admin

---

## 🔐 **Credenciales de Login**

| Campo | Valor |
|-------|-------|
| **Usuario** | `admin` |
| **Contraseña** | `admin123` |

⚠️ **Cambiar en producción**: Edita `.env` y `docker-compose.yml` antes de desplegar en internet.

---

## 📊 **Estructura de la App**

```
CATALOGO WEB/
├── 📝 Página Pública (/)
│   └── Vista de todos los productos en catálogo
│   └── Mostrar nombre, precio, stock, imagen
│
├── 🔐 Panel Admin (/admin)
│   ├── Login requerido (usuario/contraseña)
│   ├── Agregar productos (formulario)
│   ├── Ver lista de productos
│   ├── Editar productos
│   └── Eliminar productos
│
└── 🔌 API REST (/api/productos)
    ├── GET    → Obtener todos los productos
    ├── POST   → Crear producto (requiere login)
    ├── PUT    → Actualizar producto (requiere login)
    └── DELETE → Eliminar producto (requiere login)
```

---

## 🚀 **Comandos Útiles**

### Levantar la app
```powershell
cd "c:\Users\PRIDE BACK TO SCHOOL\Documents\CATALOGO WEB"
docker-compose up -d --build
```

### Ver el estado
```powershell
docker-compose ps
```

### Ver logs en tiempo real
```powershell
docker-compose logs -f           # Todos los servicios
docker-compose logs -f app       # Solo aplicación
docker-compose logs -f db        # Solo base de datos
docker-compose logs -f nginx     # Solo servidor web
```

### Detener la app
```powershell
docker-compose down              # Mantiene la BD y volúmenes
docker-compose down -v           # Elimina TODO (datos incluidos)
```

### Hacer backup manual de la BD
```powershell
docker-compose exec db pg_dump -U catalogo_user catalogo_db > backup_manual.sql
```

### Restaurar backup
```powershell
docker-compose exec -T db psql -U catalogo_user catalogo_db < backup_manual.sql
```

---

## 🎯 **Acciones Comunes**

### Agregar un producto desde el catálogo
1. Abre http://localhost/admin
2. Inicia sesión (admin / admin123)
3. Llena el formulario:
   - Nombre *
   - Descripción
   - Precio * (ej: 99.99)
   - Cantidad (ej: 10)
   - Categoría (ej: Electrónica)
   - URL de imagen (ej: https://example.com/image.jpg)
4. Haz clic en "Agregar Producto"
5. Verás el producto en el catálogo público

### Editar un producto
1. Ve a http://localhost/admin
2. En la tabla de "Productos Existentes", haz clic en "✏️ Editar"
3. Modifica los datos y haz clic en "Guardar Cambios"

### Eliminar un producto
1. Ve a http://localhost/admin
2. En la tabla, haz clic en "🗑️ Eliminar"
3. Confirma la eliminación

### Cerrar sesión
1. En /admin, haz clic en "Cerrar Sesión"
2. Serás redirigido a la página pública

---

## 📦 **Servicios Docker**

| Servicio | Puerto | Función |
|----------|--------|---------|
| **nginx** | 80 | Servidor web, proxy reverso |
| **app** | 5000 | Flask con Gunicorn (interno) |
| **db** | 5432 | PostgreSQL (interno) |

---

## 💾 **Base de Datos**

### Estructura de la tabla `productos`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID único (auto-incremental) |
| `nombre` | String | Nombre del producto |
| `descripcion` | Text | Descripción |
| `precio` | Float | Precio unitario |
| `cantidad` | Integer | Stock disponible |
| `imagen_url` | String | URL de la imagen |
| `categoria` | String | Categoría del producto |
| `fecha_creacion` | DateTime | Fecha de creación |
| `fecha_actualizacion` | DateTime | Última actualización |

### Credenciales de la BD
- **Usuario**: catalogo_user
- **Contraseña**: catalogo_pass
- **Base de datos**: catalogo_db
- **Host**: db (interno en Docker)
- **Puerto**: 5432

---

## 🔌 **API REST - Ejemplos con curl**

### Obtener todos los productos
```bash
curl http://localhost/api/productos
```

### Obtener producto por ID
```bash
curl http://localhost/api/productos/1
```

### Crear producto (requiere login, usa POST multipart o JSON)
```bash
curl -X POST http://localhost/api/productos \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Laptop",
    "descripcion": "Laptop Gaming",
    "precio": 999.99,
    "cantidad": 5,
    "categoria": "Electrónica",
    "imagen_url": "https://example.com/laptop.jpg"
  }'
```

### Estadísticas
```bash
curl http://localhost/api/estadisticas
```

---

## 🐛 **Solucionar Problemas**

### Error: "Puerto 80 en uso"
```powershell
netstat -ano | findstr :80
taskkill /PID <PID> /F
docker-compose up -d
```

### Error: "No puedo conectar desde otra PC"
- Verifica que el firewall no bloquea el puerto 80
- Asegúrate de que Docker Desktop está corriendo
- Comprueba la IP correcta con `ipconfig`

### Error: "Login no funciona"
- Verifica credenciales en `.env`
- Reconstruye con `docker-compose up -d --build`

### Ver la IP de tu servidor
```powershell
ipconfig | findstr "IPv4"
```

---

## 📝 **Archivo de Configuración (.env)**

```ini
FLASK_APP=app.py
FLASK_ENV=production
DATABASE_URL=postgresql://catalogo_user:catalogo_pass@db:5432/catalogo_db
SECRET_KEY=tu-clave-secreta-cambiar-en-produccion
ADMIN_USER=admin
ADMIN_PASSWORD=admin123
```

**IMPORTANTE**: Cambiar `SECRET_KEY` y `ADMIN_PASSWORD` antes de producción.

---

## 🔒 **Seguridad**

✅ Autenticación de sesión para /admin
✅ Hashing seguro de contraseñas
✅ CSRF protection en formularios
✅ Validación de entrada en API
✅ Variables de entorno para credenciales
✅ Nginx como proxy reverso

---

## 📈 **Próximas Mejoras (Opcionales)**

- [ ] HTTPS con Let's Encrypt (SSL)
- [ ] Backup automático programado (cron)
- [ ] Panel de estadísticas avanzadas
- [ ] Búsqueda y filtrado de productos
- [ ] Carrito de compras
- [ ] Sistema de órdenes
- [ ] Integración de pagos (Stripe, PayPal)
- [ ] Notificaciones por email
- [ ] Autenticación con roles (admin, vendedor, cliente)

---

## 📞 **Resumen Rápido**

Tu aplicación está en:
- 🌐 **http://localhost** (catálogo público)
- 🔐 **http://localhost/admin** (panel admin)
- 🔑 Credenciales: admin / admin123
- 💾 BD automática en PostgreSQL
- 🚀 Servidor de producción con Gunicorn + Nginx
- 🐳 Todo encapsulado en Docker

**¡Listo para usar, escalar y desplegar!** 🎉
