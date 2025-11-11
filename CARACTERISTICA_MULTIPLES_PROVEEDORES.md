# ✅ Característica: Asignar Múltiples Proveedores a un Producto

## 📋 Estado: IMPLEMENTADA Y FUNCIONANDO

Esta característica permite asignar **uno o más proveedores** a cada producto, con precios y fechas específicas para cada proveedor.

---

## 🎯 Cómo Funciona

### **Paso 1: Acceder al Panel Admin**
1. Abre `http://localhost/admin`
2. Haz login con: `admin / admin123`
3. En la pestaña **"📦 Productos"**, busca el producto que deseas editar

### **Paso 2: Abrir la Modal de Edición**
1. Haz clic en el botón **"Editar"** (✏️) del producto
2. Se abrirá una modal con toda la información del producto

### **Paso 3: Asignar Proveedores (NUEVA SECCIÓN)**
En la modal encontrarás una sección llamada **"🏢 Asignar Proveedores"** con:

```
┌─────────────────────────────────────┐
│ 🏢 Asignar Proveedores              │
├─────────────────────────────────────┤
│ Seleccionar Proveedor:              │
│ [Dropdown con todos los proveedores]│
│                                     │
│ Precio del Proveedor:  [_____]      │
│ Fecha del Precio:      [_____]      │
│                                     │
│ [➕ Asignar Proveedor]              │
│                                     │
│ Proveedores Asignados:              │
│ ┌────────────────────────────────┐  │
│ │ Proveedor 1                    │  │
│ │ Precio: $100.00 | Fecha: ...   │ ✕│
│ ├────────────────────────────────┤  │
│ │ Proveedor 2                    │  │
│ │ Precio: $95.00 | Fecha: ...    │ ✕│
│ └────────────────────────────────┘  │
└─────────────────────────────────────┘
```

### **Paso 4: Agregar Proveedores**
1. Selecciona un proveedor del dropdown
2. Ingresa el **precio que ese proveedor ofrece**
3. Selecciona la **fecha del precio** (permite actualizar precios históricos)
4. Haz clic en **"➕ Asignar Proveedor"**

### **Paso 5: Ver Proveedores Asignados**
- Los proveedores aparecen en una lista debajo
- Muestra: nombre, precio y fecha
- Cada proveedor tiene un botón **✕** para desasignarlo

### **Paso 6: Guardar Cambios**
- Haz clic en **"Guardar Cambios"** al final del formulario
- Los cambios se guardan en la base de datos

---

## 💾 Datos Almacenados

Cuando asignas un proveedor a un producto, se guarda:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `producto_id` | INTEGER | ID del producto |
| `proveedor_id` | INTEGER | ID del proveedor |
| `precio_proveedor` | FLOAT | Precio que ofrece ese proveedor |
| `fecha_precio` | DATE | Fecha en que es válido ese precio |
| `cantidad_minima` | INTEGER | Cantidad mínima para ese proveedor |

---

## 🔄 Flujo de Datos

```
Frontend (admin.html)
       ↓
JavaScript (proveedores-admin.js)
       ↓
API Endpoint: POST /api/productos/{id}/proveedores
       ↓
Backend (app.py)
       ↓
Database (ProductoProveedor table)
       ↓
Mostrar lista actualizada
```

---

## 📱 Endpoints API Utilizados

### **Obtener Proveedores de un Producto**
```bash
GET /api/productos/{producto_id}/proveedores
```
**Respuesta:**
```json
[
  {
    "id": 1,
    "producto_id": 5,
    "proveedor_id": 2,
    "precio_proveedor": 100.50,
    "fecha_precio": "2025-11-10",
    "cantidad_minima": 10,
    "proveedor": {
      "id": 2,
      "nombre": "Proveedor XYZ",
      "telefono": "555-1234",
      ...
    }
  },
  {
    "id": 2,
    "producto_id": 5,
    "proveedor_id": 3,
    "precio_proveedor": 95.00,
    "fecha_precio": "2025-11-10",
    ...
  }
]
```

### **Asignar Proveedor a Producto**
```bash
POST /api/productos/{producto_id}/proveedores
Content-Type: application/json

{
  "proveedor_id": 2,
  "precio_proveedor": 100.50,
  "fecha_precio": "2025-11-10",
  "cantidad_minima": 10
}
```

### **Desasignar Proveedor**
```bash
DELETE /api/productos/{producto_id}/proveedores/{proveedor_id}
```

---

## ✨ Características Incluidas

✅ **Múltiples Proveedores por Producto**
- Un producto puede tener 1, 2, 3 o más proveedores

✅ **Precios Diferentes por Proveedor**
- Cada proveedor puede tener su propio precio

✅ **Control de Fechas**
- Puedes registrar cambios de precio históricos

✅ **Interfaz Intuitiva**
- Visual clara en el panel admin
- Botones para agregar/eliminar con confirmación

✅ **Validación**
- No permite asignar el mismo proveedor dos veces
- Valida que los campos requeridos estén completos

✅ **Base de Datos Relacional**
- Tabla `ProductoProveedor` (junction table)
- Relaciones One-to-Many correctamente configuradas

---

## 🐛 Cómo Verificar que Funciona

### **1. Abre el inspector de navegador (F12)**
1. Ve a la pestaña **Network**
2. Edita un producto
3. Asigna un proveedor
4. Verifica que se envíe un POST a `/api/productos/{id}/proveedores`
5. Verifica que la respuesta sea 201 (Created)

### **2. Consulta la Base de Datos**
```sql
SELECT * FROM producto_proveedor;
```
Deberías ver los registros de asignaciones

### **3. Prueba con Múltiples Proveedores**
1. Crea 2 proveedores
2. Asigna ambos al mismo producto
3. Verifica que ambos aparezcan en la lista

---

## 📚 Archivos Involucrados

| Archivo | Rol |
|---------|-----|
| `app.py` | Endpoints API para asignar/desasignar proveedores |
| `models.py` | Tabla `ProductoProveedor` (junction table) |
| `templates/admin.html` | Modal de edición con sección de proveedores |
| `static/proveedores-admin.js` | Lógica JavaScript para gestión |
| `static/admin.js` | Integración con el modal |

---

## 🎓 Ejemplo Completo

### **Escenario:**
Tienes un producto "Motor 2000W" y quieres asignarle dos proveedores con diferentes precios.

### **Pasos:**
1. Accede a `/admin` y edita el producto "Motor 2000W"
2. En "Asignar Proveedores":
   - Selecciona "Proveedor A"
   - Precio: 500.00
   - Fecha: 2025-11-10
   - Clic en "➕ Asignar Proveedor"
   
3. Luego:
   - Selecciona "Proveedor B"
   - Precio: 480.00
   - Fecha: 2025-11-10
   - Clic en "➕ Asignar Proveedor"

4. Verás la lista con ambos proveedores

5. Clic en "Guardar Cambios"

### **Resultado en BD:**
```sql
SELECT * FROM producto_proveedor 
WHERE producto_id = (SELECT id FROM producto WHERE nombre = 'Motor 2000W');

-- Resultado:
-- id | producto_id | proveedor_id | precio_proveedor | fecha_precio
-- 1  |     5       |      2       |     500.00       | 2025-11-10
-- 2  |     5       |      3       |     480.00       | 2025-11-10
```

---

## 🚀 Estado Actual

✅ **IMPLEMENTADA COMPLETAMENTE**
- Backend: 3 endpoints funcionales
- Frontend: Interfaz completa
- Base de datos: Schema creada
- Docker: Todos los servicios running

---

## 📞 Soporte

Si tienes problemas:
1. Verifica que el servidor Flask esté corriendo: `docker-compose ps`
2. Consulta los logs: `docker-compose logs app`
3. Comprueba que hayas creado al menos un proveedor en `/proveedores`
4. Abre DevTools (F12) para ver errores en consola

