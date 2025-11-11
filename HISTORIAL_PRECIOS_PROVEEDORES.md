# 📊 Historial de Precios por Proveedor

## ✅ NUEVA CARACTERÍSTICA IMPLEMENTADA

Se ha implementado un sistema completo para **agregar y gestionar múltiples precios históricos** para cada proveedor en cada producto. Esto permite rastrear cambios de precio en el tiempo.

---

## 🎯 ¿Qué Permite Esta Característica?

✅ **Agregar múltiples precios** para el mismo proveedor
✅ **Especificar fecha manualmente** para cada precio
✅ **Rastrear historial completo** de precios a lo largo del tiempo
✅ **Modificar precios** sin perder el historial
✅ **Ver tendencias** de cambio de precios por proveedor
✅ **Agregar notas** explicativas para cada cambio

---

## 📋 Cómo Funciona

### **Paso 1: Editar un Producto**
1. Accede a `http://localhost/admin`
2. Ve a la pestaña "📦 Productos"
3. Haz clic en "✏️ Editar" de un producto

### **Paso 2: Ver Proveedores Asignados**
En la sección "🏢 Asignar Proveedores", verás los proveedores asignados con un **nuevo botón 📊**:

```
Proveedores Asignados:
┌────────────────────────────────────────────────┐
│ Proveedor A                          [📊] [✕]  │
│ Precio Actual: $500.00 | Fecha: 2025-11-10    │
├────────────────────────────────────────────────┤
│ Proveedor B                          [📊] [✕]  │
│ Precio Actual: $480.00 | Fecha: 2025-11-10    │
└────────────────────────────────────────────────┘
```

### **Paso 3: Hacer Clic en el Botón 📊**
Al hacer clic en el botón **📊**, se abre una modal con:
- Formulario para agregar nuevo precio
- Historial completo de todos los precios anteriores

### **Paso 4: Agregar Nuevo Precio**

```
┌─────────────────────────────────────────────────┐
│ 📊 Historial de Precios: Proveedor A            │
├─────────────────────────────────────────────────┤
│                                                 │
│ Agregar Nuevo Precio:                           │
│ ─────────────────────────────────────────────   │
│ Precio:    [500.00____________]                │
│ Fecha:     [2025-11-10________]                │
│ Notas:     [_________________]                 │
│                                                 │
│ [➕ AGREGAR PRECIO]                             │
│                                                 │
│ Historial de Precios:                           │
│ ─────────────────────────────────────────────   │
│ ┌─────────────────────────────────────────────┐│
│ │ $500.00                              [🗑️]   ││
│ │ 📅 2025-11-10                               ││
│ │ Precio actual más reciente                  ││
│ │                                              ││
│ │ $480.00                              [🗑️]   ││
│ │ 📅 2025-11-08                               ││
│ │ "Precio de descuento por cantidad"          ││
│ │                                              ││
│ │ $490.00                              [🗑️]   ││
│ │ 📅 2025-11-01                               ││
│ │ "Precio inicial"                            ││
│ └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

### **Paso 5: Campos a Completar**

| Campo | Descripción | Requerido |
|-------|-------------|-----------|
| **Precio** | El nuevo precio del proveedor | ✅ Sí |
| **Fecha** | La fecha en que es válido este precio | ✅ Sí |
| **Notas** | Motivo del cambio o información adicional | ❌ No |

### **Paso 6: Ejemplos de Uso**

**Ejemplo 1: Historial de Cambios**
```
Proveedor: Industrias XYZ
Producto: Motor 2000W

- $550.00 (2025-11-10) → Precio actual
- $500.00 (2025-11-01) → Precio inicial
- $480.00 (2025-10-15) → Promoción especial
- $495.00 (2025-10-01) → Regreso a precio normal
```

**Ejemplo 2: Con Notas**
```
- $450.00 (2025-11-10) → "Compra en volumen (mín 100 unidades)"
- $480.00 (2025-11-05) → "Compra normal (mín 10 unidades)"
- $550.00 (2025-10-20) → "Precio pequeño volumen"
```

---

## 💾 Base de Datos

### **Tabla: historial_precios_proveedor**

```sql
CREATE TABLE historial_precios_proveedor (
    id INTEGER PRIMARY KEY,
    producto_proveedor_id INTEGER NOT NULL (FK),
    precio FLOAT NOT NULL,
    fecha_precio DATE NOT NULL,
    notas TEXT,
    fecha_creacion DATETIME DEFAULT NOW()
);
```

### **Estructura de Datos**

```
Producto: Motor 2000W (ID: 5)
└─ Proveedor: Industrias XYZ (ID: 2)
   └─ ProductoProveedor (ID: 1) ← Precio actual: $500.00
      └─ HistorialPreciosProveedor (registros):
         ├─ ID: 1, Precio: $550.00, Fecha: 2025-11-10
         ├─ ID: 2, Precio: $500.00, Fecha: 2025-11-01
         └─ ID: 3, Precio: $480.00, Fecha: 2025-10-15
```

---

## 🔌 API Endpoints

### **1. Obtener Historial de Precios**
```bash
GET /api/productos/{producto_id}/proveedores/{proveedor_id}/historial
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "producto_proveedor_id": 1,
    "precio": 550.00,
    "fecha_precio": "2025-11-10",
    "notas": "",
    "fecha_creacion": "2025-11-10T10:30:00"
  },
  {
    "id": 2,
    "producto_proveedor_id": 1,
    "precio": 500.00,
    "fecha_precio": "2025-11-01",
    "notas": "Precio inicial",
    "fecha_creacion": "2025-11-01T14:00:00"
  }
]
```

### **2. Agregar Precio Histórico**
```bash
POST /api/productos/{producto_id}/proveedores/{proveedor_id}/historial

Content-Type: application/json

{
  "precio": 450.00,
  "fecha_precio": "2025-11-10",
  "notas": "Descuento por volumen"
}
```

**Respuesta:**
```json
{
  "mensaje": "Precio agregado al historial",
  "precio_historico": {
    "id": 3,
    "producto_proveedor_id": 1,
    "precio": 450.00,
    "fecha_precio": "2025-11-10",
    "notas": "Descuento por volumen",
    "fecha_creacion": "2025-11-10T15:45:00"
  }
}
```

### **3. Eliminar Precio Histórico**
```bash
DELETE /api/historial-precios/{precio_id}
```

**Respuesta:**
```json
{
  "mensaje": "Precio histórico eliminado correctamente"
}
```

---

## 📁 Archivos Modificados/Creados

### **Modificados:**
1. **models.py**
   - Agregada nueva tabla: `HistorialPreciosProveedor`
   - Relación con `ProductoProveedor`

2. **app.py**
   - Agregado import: `HistorialPreciosProveedor`
   - 3 nuevos endpoints API
   - Documentación de rutas

3. **static/proveedores-admin.js**
   - Botón 📊 en lista de proveedores
   - Llamada a `mostrarModalHistorialPrecios()`

4. **templates/admin.html**
   - Incluido script: `historial-precios.js`

### **Creados:**
1. **static/historial-precios.js** (150+ líneas)
   - Gestión de modal de historial
   - CRUD de precios históricos
   - Carga y visualización de datos

---

## ✨ Características Técnicas

✅ **Relación One-to-Many**
- Cada ProductoProveedor puede tener múltiples precios históricos

✅ **Cascade Delete**
- Al eliminar un ProductoProveedor, se eliminan sus precios históricos

✅ **Timestamps Automáticos**
- Cada precio registra cuándo fue agregado

✅ **Validación de Datos**
- Valida precio y fecha requeridos
- Formatos correctos de fecha

✅ **Ordenamiento**
- Los precios se muestran ordenados por fecha (más recientes primero)

✅ **Indicador Visual**
- Borde izquierdo verde para precio más reciente
- Borde izquierdo azul para precios antiguos

---

## 🎓 Casos de Uso

### **Caso 1: Rastrear Cambios de Precio**
Un proveedor baja el precio cada mes. Con esta característica, puedes ver:
- Cuándo bajó el precio
- Cuánto bajó en cada ocasión
- Historial completo de negociaciones

### **Caso 2: Precios Condicionados**
Un proveedor ofrece:
- $550 para 1-9 unidades
- $500 para 10-49 unidades
- $480 para 50+ unidades

Puedes registrar todos estos precios con sus condiciones en las notas.

### **Caso 3: Auditoría de Costos**
Necesitas reportar a gerencia:
- Cuáles fueron los costos en cierta fecha
- Si los precios han subido o bajado
- Tendencias de largo plazo

### **Caso 4: Comparación de Proveedores**
Comparar el historial de precios de múltiples proveedores:
- Cuál ha ofrecido mejor precio históricamente
- Quién es más estable en precios
- Quién ha aumentado más en cierto período

---

## 🧪 Cómo Probar

### **Prueba 1: Agregar Precio Histórico**
1. Edita un producto con un proveedor asignado
2. Haz clic en el botón 📊
3. Ingresa un precio antiguo (ej: $400.00)
4. Ingresa una fecha antigua (ej: 2025-09-01)
5. Agregá una nota (ej: "Precio antiguo")
6. Haz clic en "➕ Agregar Precio"
7. Verifica que aparezca en el historial

### **Prueba 2: Ver Historial Completo**
1. Abre varios proveedores (botón 📊)
2. Verifica que cada uno muestra su propio historial
3. Los precios deben estar ordenados por fecha (más recientes primero)

### **Prueba 3: Eliminar Precio**
1. En la modal de historial, haz clic en 🗑️ de un precio
2. Confirma la eliminación
3. Verifica que desaparece del historial

### **Prueba 4: Actualizar Precio Actual**
1. Agrega un nuevo precio con fecha de hoy
2. El precio en la lista de proveedores se actualiza automáticamente
3. El nuevo precio aparece primero en el historial

---

## 📊 Visualización del Precio Actual

Cuando agregas un nuevo precio histórico, automáticamente:

1. Se guarda en la tabla `historial_precios_proveedor`
2. Se actualiza `ProductoProveedor.precio_proveedor` con el nuevo valor
3. Se actualiza `ProductoProveedor.fecha_precio` con la nueva fecha
4. La interfaz muestra el precio actualizado inmediatamente

---

## 🚀 Próximas Mejoras Opcionales

- 📈 Gráfico de tendencia de precios
- 📊 Comparativa entre proveedores
- 📉 Alertas de cambios de precio
- 💾 Exportar historial a CSV
- 🔔 Notificaciones de bajadas de precio

---

## 🐛 Troubleshooting

**P: No aparece el botón 📊**
R: Asegúrate de que:
   1. Recargaste la página (Ctrl+F5)
   2. Los contenedores Docker están corriendo
   3. No hay errores en consola (F12)

**P: Error "Asignación no encontrada"**
R: El proveedor no está asignado al producto. Primero debes asignar el proveedor.

**P: ¿Se pierde el historial si elimino un proveedor?**
R: Sí, al desasignar un proveedor (botón ✕), se elimina todo su historial de precios.

---

## ✅ Estado Actual

| Aspecto | Estado |
|---|---|
| Base de Datos | ✅ Tabla creada |
| Backend | ✅ 3 endpoints implementados |
| Frontend | ✅ Modal y botones funcionales |
| Validación | ✅ Campos requeridos |
| Docker | ✅ Todos servicios corriendo |
| Testing | ✅ Testeado y funcional |

---

## 📞 Resumen

**Solicitaste:** Agregar uno o más precios con fechas distintas para un proveedor

**Implementamos:**
✅ Nueva tabla `historial_precios_proveedor`
✅ 3 endpoints API (GET, POST, DELETE)
✅ Modal de historial con formulario
✅ Lista de precios ordenada por fecha
✅ Botón 📊 para acceso rápido
✅ Notas opcionales para contexto
✅ Eliminación de precios individuales

**Resultado:** Sistema completo de historial de precios con múltiples registros por proveedor y control manual de fechas.

