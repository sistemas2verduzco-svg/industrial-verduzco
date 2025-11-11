# 🏢 GUÍA COMPLETA - SISTEMA DE PROVEEDORES

**Fecha:** 10 de Noviembre de 2025  
**Versión:** 2.1 - Sistema de Proveedores Integrado

---

## 📋 ¿QUÉ ES EL NUEVO SISTEMA DE PROVEEDORES?

Un sistema completo para gestionar tus proveedores, asignar múltiples proveedores a cada producto, registrar sus precios, y cargar imágenes localmente en tu servidor.

---

## 🎯 NUEVAS CARACTERÍSTICAS

### 1. 📋 Gestión de Proveedores (Nueva Página)
**URL:** `http://localhost/proveedores`

Aquí puedes:
- ✅ Registrar nuevos proveedores
- ✅ Ver lista de todos los proveedores
- ✅ Editar datos de proveedores
- ✅ Eliminar proveedores
- ✅ Almacenar información completa:
  - Nombre del proveedor
  - Teléfono de contacto
  - RFC
  - Domicilio completo
  - Correo electrónico
  - Persona de contacto
  - Notas adicionales

### 2. 🔗 Asignar Múltiples Proveedores por Producto
**Ubicación:** Panel Admin → Editar Producto

Desde aquí puedes:
- ✅ Asignar 1 o más proveedores a cada producto
- ✅ Registrar el precio que cada proveedor cobra
- ✅ Establecer la fecha del precio
- ✅ Ver todos los proveedores asignados
- ✅ Desasignar proveedores si es necesario

### 3. 📤 Carga de Imágenes Locales
**Ubicación:** Panel Admin → Agregar Producto

Ahora puedes:
- ✅ Seleccionar una imagen desde tu computadora
- ✅ Ver vista previa antes de guardar
- ✅ Formatos soportados: PNG, JPG, JPEG, GIF, WEBP
- ✅ Máximo 5MB por imagen
- ✅ Las imágenes se almacenan en tu servidor (resguardo local)

---

## 🚀 CÓMO USAR

### PASO 1: Agregar Proveedores

1. Abre: `http://localhost/proveedores`
2. Completa el formulario:
   ```
   Nombre: Proveedor XYZ
   Teléfono: +52 123 456 7890
   RFC: ABC123XYZ456
   Domicilio: Calle Principal 123, Piso 2
   Correo: contacto@proveedor.com
   Persona de Contacto: Juan Pérez
   Notas: Entrega en 3-5 días hábiles
   ```
3. Haz clic en "Guardar Proveedor"
4. El proveedor aparecerá en la lista

### PASO 2: Editar/Actualizar Proveedores

1. En la lista de proveedores, haz clic en **Editar**
2. Modifica los datos que necesites
3. Haz clic en **Guardar Cambios**

### PASO 3: Agregar Producto con Imagen Local

1. Ve a: `http://localhost/admin` (Tab PRODUCTOS)
2. Completa el formulario:
   ```
   Nombre: Mi Producto
   Descripción: Una descripción
   Precio: 1500.00
   Cantidad: 10
   Categoría: MOTOR
   ```
3. **Opción A: Cargar imagen**
   - Haz clic en "Seleccionar imagen"
   - Elige una imagen de tu PC
   - Verás una vista previa
   - La imagen se sube automáticamente

4. **Opción B: Usar URL**
   - Si prefieres una URL externa, pégala en "O URL de Imagen"

5. Haz clic en "Agregar Producto"

### PASO 4: Asignar Proveedores a un Producto

1. En Panel Admin, haz clic en **Editar** del producto
2. Se abre el modal con los datos del producto
3. Desplázate hacia abajo hasta "🏢 Asignar Proveedores"
4. En el select, elige un proveedor
5. Ingresa el precio que ese proveedor cobra
6. Selecciona la fecha del precio
7. Haz clic en "➕ Asignar Proveedor"
8. El proveedor aparecerá en la lista de asignados
9. Puedes asignar múltiples proveedores al mismo producto

### PASO 5: Ver Proveedores Asignados

En el modal de edición del producto, verás una sección "Proveedores Asignados" que muestra:
- Nombre del proveedor
- Precio que cobra
- Fecha del precio
- Botón para desasignar si es necesario

---

## 📊 ESTRUCTURA DE DATOS

### Tabla: Proveedores
```sql
id              - ID único
nombre          - Nombre del proveedor (único)
telefono        - Número de teléfono
rfc             - RFC del proveedor (13 caracteres)
domicilio       - Dirección completa
correo          - Email para contacto
contacto        - Persona de contacto
notas           - Notas adicionales
fecha_creacion  - Cuándo se registró
fecha_actualiza - Última actualización
```

### Tabla: ProductoProveedor (Relación)
```sql
id              - ID único
producto_id     - ID del producto (FK)
proveedor_id    - ID del proveedor (FK)
precio_prov     - Precio que cobra el proveedor
fecha_precio    - Fecha del precio
cant_minima     - Cantidad mínima de compra
fecha_creac     - Cuándo se asignó
```

### Almacenamiento de Imágenes
```
/uploads/productos/
├── 20251110_164200_imagen1.jpg
├── 20251110_164215_imagen2.png
└── 20251110_164230_imagen3.webp
```

---

## 🔄 CASOS DE USO

### CASO 1: Comparar Precios de Proveedores

**Escenario:** Quieres saber cuál proveedor ofrece mejor precio

1. Ve a Panel Admin
2. Edita un producto
3. Scrollea a "🏢 Asignar Proveedores"
4. Verás una tabla como:
   ```
   Proveedor A: $120 (25-10-2025)
   Proveedor B: $115 (26-10-2025)
   Proveedor C: $125 (25-10-2025)
   ```
5. Identifica el más económico

### CASO 2: Actualizar Precio de Proveedor

**Escenario:** El proveedor cambió su precio

1. Desasigna el proveedor anterior (botón ✕)
2. Vuelve a asignarlo con el nuevo precio
3. Actualiza la fecha
4. Guarda cambios

### CASO 3: Múltiples Proveedores para Mismo Producto

**Escenario:** Tienes 3 proveedores para "MOTOR"

1. En producto MOTOR, asigna:
   - Proveedor A: $100
   - Proveedor B: $95
   - Proveedor C: $110
2. Ahora tienes registro de todos
3. Puedes elegir el más barato o cambiar según disponibilidad

### CASO 4: Resguardo de Imágenes Locales

**Escenario:** Quieres que las imágenes estén en tu servidor

1. Al agregar producto:
   - Selecciona "Cargar Imagen"
   - Elige archivo de tu PC
   - Automáticamente se sube a `/uploads/productos/`
2. Las imágenes se guardan con:
   - Timestamp para evitar duplicados
   - Nombre original del archivo
   - Acceso vía `/uploads/productos/NOMBRE.ext`

---

## 📱 ACCESO A LOS NUEVOS ENDPOINTS

### API Endpoints - Proveedores

```
GET    /api/proveedores                    - Listar todos
POST   /api/proveedores                    - Crear
GET    /api/proveedores/<id>               - Obtener uno
PUT    /api/proveedores/<id>               - Actualizar
DELETE /api/proveedores/<id>               - Eliminar
```

### API Endpoints - ProductoProveedor

```
GET    /api/productos/<id>/proveedores              - Listar asignados
POST   /api/productos/<id>/proveedores              - Asignar
DELETE /api/productos/<id>/proveedores/<prov_id>   - Desasignar
```

### API Endpoint - Cargar Imágenes

```
POST   /api/productos/upload-imagen        - Subir imagen
GET    /uploads/productos/<filename>       - Descargar/ver
```

---

## ⚙️ VALIDACIONES

### Al Crear Proveedor:
- ✅ Nombre es obligatorio
- ✅ No se pueden crear proveedores con mismo nombre
- ✅ RFC debe ser válido (13 caracteres)
- ✅ Correo debe tener formato válido

### Al Asignar Proveedor:
- ✅ Proveedor debe estar registrado
- ✅ Producto debe existir
- ✅ Precio es obligatorio
- ✅ Fecha es obligatoria
- ✅ No se pueden asignar duplicados (se actualizan)

### Al Cargar Imagen:
- ✅ Máximo 5MB
- ✅ Formatos: PNG, JPG, JPEG, GIF, WEBP
- ✅ Se genera timestamp para evitar sobrescrituras
- ✅ Ruta accesible vía `/uploads/productos/`

---

## 📊 EJEMPLOS DE JSON API

### Crear Proveedor

**Request:**
```json
POST /api/proveedores
{
  "nombre": "Suministros Industriales SA",
  "telefono": "+52 1234567890",
  "rfc": "SI1234567890",
  "correo": "ventas@suministros.mx",
  "domicilio": "Av. Industrial 500, Monterrey NL",
  "contacto": "Carlos López",
  "notas": "Entrega en 24-48 horas"
}
```

**Response:**
```json
{
  "id": 1,
  "nombre": "Suministros Industriales SA",
  "telefono": "+52 1234567890",
  "rfc": "SI1234567890",
  "correo": "ventas@suministros.mx",
  "domicilio": "Av. Industrial 500, Monterrey NL",
  "contacto": "Carlos López",
  "notas": "Entrega en 24-48 horas",
  "fecha_creacion": "2025-11-10T16:30:00",
  "fecha_actualizacion": "2025-11-10T16:30:00"
}
```

### Asignar Proveedor a Producto

**Request:**
```json
POST /api/productos/123/proveedores
{
  "proveedor_id": 1,
  "precio_proveedor": 1500.00,
  "fecha_precio": "2025-11-10",
  "cantidad_minima": 5
}
```

**Response:**
```json
{
  "id": 1,
  "producto_id": 123,
  "proveedor_id": 1,
  "proveedor": { /* datos del proveedor */ },
  "precio_proveedor": 1500.00,
  "fecha_precio": "2025-11-10",
  "cantidad_minima": 5,
  "fecha_creacion": "2025-11-10T16:35:00"
}
```

### Subir Imagen

**Request:**
```
POST /api/productos/upload-imagen
Content-Type: multipart/form-data
imagen: [archivo.jpg]
```

**Response:**
```json
{
  "mensaje": "Imagen subida exitosamente",
  "url": "/uploads/productos/20251110_164200_imagen.jpg",
  "filename": "20251110_164200_imagen.jpg"
}
```

---

## 🔐 SEGURIDAD

✅ Todos los endpoints requieren autenticación (@login_required)  
✅ Imágenes se validan por tipo y tamaño  
✅ Nombres de archivo se sanitizan  
✅ Las imágenes se almacenan en servidor (resguardo seguro)  
✅ Relaciones de base de datos protegidas

---

## 📁 CARPETAS Y ARCHIVOS NUEVOS

```
/uploads/
  └── /productos/
      ├── 20251110_164200_imagen.jpg
      ├── 20251110_164215_motor.png
      └── 20251110_164230_pieza.webp

/templates/
  └── proveedores.html (Nueva página)

/static/
  └── proveedores-admin.js (Nueva lógica)

/models.py (Actualizado con 2 nuevas tablas)
/app.py (Actualizado con 11 nuevos endpoints)
```

---

## 🔧 TROUBLESHOOTING

**P: No se sube la imagen**
R: Verifica que sea menor a 5MB y formato válido (PNG, JPG, GIF, WEBP)

**P: La imagen no se ve**
R: Asegúrate de que la ruta es `/uploads/productos/NOMBRE.ext` (con el timestamp)

**P: No puedo asignar proveedor**
R: Primero crea el proveedor en http://localhost/proveedores

**P: Se eliminó un proveedor, ¿pierdo los datos de asignaciones?**
R: Las asignaciones se eliminan automáticamente (foreign key con cascade)

**P: ¿Dónde se guardan las imágenes?**
R: En `/uploads/productos/` dentro del servidor (resguardo local)

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- ✅ Tabla de Proveedores creada
- ✅ Tabla de ProductoProveedor creada
- ✅ Página /proveedores implementada
- ✅ CRUD de proveedores en API
- ✅ Asignación de proveedores a productos
- ✅ Carga de imágenes locales
- ✅ Validaciones completas
- ✅ Carpeta /uploads creada
- ✅ Todos los endpoints funcionando
- ✅ Documentación completada

---

## 📞 SOPORTE RÁPIDO

```
Acceso:
  - Proveedores:    http://localhost/proveedores
  - Admin Panel:    http://localhost/admin
  - Catálogo:       http://localhost/

Usuario: admin
Clave:   admin123

Desde otra PC: http://192.168.0.94/proveedores (o /admin)
```

---

*Sistema de Proveedores integrado y funcionando correctamente.*  
*¡Listo para usar!* 🚀
