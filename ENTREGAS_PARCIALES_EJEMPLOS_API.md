# 🧪 ENTREGAS PARCIALES - EJEMPLOS DE PRUEBA

## 📝 EJEMPLOS: Cómo probar los endpoints

Usa estos comandos `curl` para probar la API de entregas parciales.

---

## 1️⃣ REGISTRAR UNA ENTREGA PARCIAL

```bash
curl -X POST http://localhost:5000/api/entregas/parcial \
  -H "Content-Type: application/json" \
  -b "session=tu_cookie_session" \
  -d '{
    "flujo_id": 123,
    "cantidad_entregada": 50,
    "notas": "Entrega en almacén PT"
  }'
```

**Respuesta exitosa (201):**
```json
{
  "ok": true,
  "entrega": {
    "id": 456,
    "flujo_id": 123,
    "hoja_ruta_id": 789,
    "cantidad_entregada": 50,
    "usuario_entrega": "juan_entregas",
    "notas": "Entrega en almacén PT",
    "fecha_entrega": "2026-03-17T14:30:00",
    "fecha_creacion": "2026-03-17T14:30:00"
  },
  "flujo": {
    "id": 123,
    "hoja_ruta_id": 789,
    "estado": "entregas",
    "cantidad_total_piezas": 100,
    "cantidad_entregada": 50,
    "cantidad_pendiente": 50,
    "porcentaje_entregado": 50.0,
    "estado_parciales": "pendientes"
  }
}
```

**Errores posibles:**

```bash
# Error: cantidad > pendiente
{
  "error": "No puedes entregar 150 piezas. Pendiente: 50",
  "cantidad_pendiente": 50
}
# Status: 400

# Error: flujo no en estado "entregas"
{
  "error": "La hoja debe estar en estado 'entregas' para registrar entrega parcial"
}
# Status: 409

# Error: datos inválidos
{
  "error": "Datos inválidos: flujo_id y cantidad_entregada deben ser números"
}
# Status: 400
```

---

## 2️⃣ OBTENER TODAS LAS ENTREGAS DE UNA HOJA

```bash
curl http://localhost:5000/api/entregas/123/parciales \
  -b "session=tu_cookie_session"
```

**Respuesta (200):**
```json
{
  "ok": true,
  "hoja_id": 123,
  "entregas": [
    {
      "id": 456,
      "flujo_id": 100,
      "hoja_ruta_id": 123,
      "cantidad_entregada": 50,
      "usuario_entrega": "juan",
      "notas": "Lote 1",
      "fecha_entrega": "2026-03-17T14:00:00",
      "fecha_creacion": "2026-03-17T14:00:00"
    },
    {
      "id": 457,
      "flujo_id": 100,
      "hoja_ruta_id": 123,
      "cantidad_entregada": 30,
      "usuario_entrega": "carlos",
      "notas": "Lote 2",
      "fecha_entrega": "2026-03-17T15:00:00",
      "fecha_creacion": "2026-03-17T15:00:00"
    }
  ],
  "total_registros": 2
}
```

---

## 3️⃣ DESHACER UNA ENTREGA PARCIAL

```bash
curl -X DELETE http://localhost:5000/api/entregas/parcial/456 \
  -H "Content-Type: application/json" \
  -b "session=tu_cookie_session"
```

**Respuesta (200):**
```json
{
  "ok": true,
  "message": "Entrega parcial eliminada",
  "flujo": {
    "id": 100,
    "hoja_ruta_id": 123,
    "estado": "entregas",
    "cantidad_total_piezas": 100,
    "cantidad_entregada": 30,
    "cantidad_pendiente": 70,
    "porcentaje_entregado": 30.0,
    "estado_parciales": "pendientes"
  }
}
```

---

## 4️⃣ MARCAR TODAS LAS ENTREGAS COMO COMPLETADAS

```bash
curl -X POST http://localhost:5000/api/entregas/completar-all/100 \
  -H "Content-Type: application/json" \
  -b "session=tu_cookie_session"
```

**Respuesta (200) - Si está 100%:**
```json
{
  "ok": true,
  "message": "Entregas completadas",
  "flujo": {
    "id": 100,
    "estado": "entregas",
    "estado_parciales": "todas",
    "cantidad_entregada": 100,
    "cantidad_total_piezas": 100,
    "porcentaje_entregado": 100.0
  }
}
```

**Error (409) - Si no está 100%:**
```json
{
  "error": "No todas las piezas han sido entregadas. Entregado: 80/100",
  "cantidad_entregada": 80,
  "cantidad_total": 100
}
```

---

## 🔄 FLUJO COMPLETO (Paso a paso)

### Escenario: Entregar 100 piezas en 3 movimientos

**Estado inicial:**
```
Flujo ID: 100
Cantidad total: 100
Entregada: 0
Pendiente: 100
```

**Movimiento 1: Entregar 30 piezas**
```bash
curl -X POST http://localhost:5000/api/entregas/parcial \
  -H "Content-Type: application/json" \
  -b "session=cookie" \
  -d '{"flujo_id": 100, "cantidad_entregada": 30, "notas": "Lote 1"}'
```

**Verificar estado:**
```bash
curl http://localhost:5000/api/entregas/123/parciales -b "session=cookie"
```

**Resultado:**
```json
{
  "entregas": [
    {"id": 1, "cantidad_entregada": 30, "usuario_entrega": "juan"}
  ],
  "total_registros": 1
}
```

**Estado después:**
- Entregada: 30/100 (30%)

---

**Movimiento 2: Entregar 50 piezas más**
```bash
curl -X POST http://localhost:5000/api/entregas/parcial \
  -H "Content-Type: application/json" \
  -b "session=cookie" \
  -d '{"flujo_id": 100, "cantidad_entregada": 50, "notas": "Lote 2"}'
```

**Estado después:**
- Entregada: 80/100 (80%)

---

**Movimiento 3: Entregar las últimas 20 piezas**
```bash
curl -X POST http://localhost:5000/api/entregas/parcial \
  -H "Content-Type: application/json" \
  -b "session=cookie" \
  -d '{"flujo_id": 100, "cantidad_entregada": 20, "notas": "Últimas piezas"}'
```

**Estado después:**
- Entregada: 100/100 (100%) ✅

---

**Verificar historial completo:**
```bash
curl http://localhost:5000/api/entregas/123/parciales -b "session=cookie"
```

**Resultado:**
```json
{
  "entregas": [
    {
      "id": 1,
      "cantidad_entregada": 30,
      "usuario_entrega": "juan",
      "fecha_entrega": "2026-03-17T10:00:00",
      "notas": "Lote 1"
    },
    {
      "id": 2,
      "cantidad_entregada": 50,
      "usuario_entrega": "juan",
      "fecha_entrega": "2026-03-17T11:00:00",
      "notas": "Lote 2"
    },
    {
      "id": 3,
      "cantidad_entregada": 20,
      "usuario_entrega": "carlos",
      "fecha_entrega": "2026-03-17T12:00:00",
      "notas": "Últimas piezas"
    }
  ],
  "total_registros": 3
}
```

---

**Deshacer la entrega #2 (por error):**
```bash
curl -X DELETE http://localhost:5000/api/entregas/parcial/2 \
  -b "session=cookie"
```

**Resultado:**
```json
{
  "ok": true,
  "message": "Entrega parcial eliminada",
  "flujo": {
    "cantidad_entregada": 50,
    "cantidad_pendiente": 50,
    "porcentaje_entregado": 50.0
  }
}
```

**Rehistorial:**
```
Entregada: 50/100 (50%)
Entregas: 2 (la #2 fue removida)
```

---

**Registrar de nuevo con cantidad correcta:**
```bash
curl -X POST http://localhost:5000/api/entregas/parcial \
  -H "Content-Type: application/json" \
  -b "session=cookie" \
  -d '{"flujo_id": 100, "cantidad_entregada": 50, "notas": "Lote 2 CORREGIDO"}'
```

**Estado final:**
- Entregada: 100/100 (100%) ✅

---

## 🔑 VALORES CLAVE PARA REEMPLAZAR

En los ejemplos anteriores, reemplaza:

| Placeholder | Descripción | Ejemplo |
|------------|-------------|---------|
| `http://localhost:5000` | URL de tu app | `http://tu-dominio.com` |
| `tu_cookie_session` | Cookie de sesión | Ver instrucciones abajo |
| `123` (flujo_id) | ID del flujo logístico | Ver DB `hojas_ruta_flujo_logistica.id` |
| `789` (hoja_id) | ID de la hoja de ruta | Ver DB `hojas_ruta.id` |
| `50` (cantidad) | Piezas a entregar | Tu número |

---

## 🔐 OBTENER COOKIE DE SESIÓN

**Opción 1: Desde navegador**
1. Ve a `http://localhost:5000/entregas`
2. Abre DevTools (F12)
3. Pestaña "Application" → Cookies
4. Busca `session`
5. Copia el valor completo

**Opción 2: Login con curl (modo avanzado)**
```bash
curl -c cookies.txt -d "username=tu_usuario&password=tu_pass" \
  http://localhost:5000/login
  
# Luego usa:
-b cookies.txt
```

---

## 🧪 PROBAR EN POSTMAN

### Crear nueva request:

**POST /api/entregas/parcial**

Headers:
```
Content-Type: application/json
Cookie: session=ABC123...DEF
```

Body (json):
```json
{
  "flujo_id": 100,
  "cantidad_entregada": 50,
  "notas": "Mi entrega de prueba"
}
```

Click "Send" → Verás respuesta

---

## ❌ ERRORES COMUNES

### Error: "Unauthorized"
**Causa:** No incluiste cookie de sesión
**Fix:** Agrega `-b "session=tu_cookie"` al curl

### Error: "400 - Datos inválidos"
**Causa:** Los números no son enteros
**Fix:** Asegúrate que flujo_id y cantidad_entregada sean números:
```json
{
  "flujo_id": 100,        ← número
  "cantidad_entregada": 50 ← número
}
```

### Error: "409 - No puedes entregar X piezas"
**Causa:** Intentas entregar más que el pendiente
**Fix:** Reduce la cantidad o verifica `cantidad_pendiente` en respuesta

### Error: "404 - Flujo no encontrado"
**Causa:** El flujo_id no existe en la BD
**Fix:** Verifica que el ID sea correcto. Query:
```sql
SELECT id, hoja_ruta_id, estado FROM hojas_ruta_flujo_logistica WHERE id = 100;
```

---

## 🧮 CÁLCULOS ÚTILES

```python
# Pendiente = Total - Entregada
pendiente = cantidad_total_piezas - cantidad_entregada

# Porcentaje
porcentaje = (cantidad_entregada / cantidad_total_piezas) * 100

# ¿Está completo?
es_100_porciento = (cantidad_entregada == cantidad_total_piezas)
```

---

## 📊 CONSULTAS SQL ÚTILES

**Ver todas las entregas:**
```sql
SELECT * FROM entregas_parciales ORDER BY fecha_entrega DESC;
```

**Ver entregas por hoja:**
```sql
SELECT * FROM entregas_parciales 
WHERE hoja_ruta_id = 123 
ORDER BY fecha_entrega DESC;
```

**Ver total entregado por usuario:**
```sql
SELECT usuario_entrega, COUNT(*) as entregas, SUM(cantidad_entregada) as total
FROM entregas_parciales
GROUP BY usuario_entrega
ORDER BY total DESC;
```

**Ver progreso de hojas:**
```sql
SELECT 
  f.hoja_ruta_id,
  f.cantidad_total_piezas,
  f.cantidad_entregada,
  f.cantidad_pendiente,
  f.porcentaje_entregado,
  COUNT(ep.id) as num_movimientos
FROM hojas_ruta_flujo_logistica f
LEFT JOIN entregas_parciales ep ON f.id = ep.flujo_id
GROUP BY f.id
ORDER BY f.fecha_actualizacion DESC;
```

---

## 🎯 CASOS DE USO

### Caso 1: Múltiples entregas de un día

```bash
# Mañana
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 25, "notas": "Turno mañana"}'

# Tarde  
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 25, "notas": "Turno tarde"}'

# Noche
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 50, "notas": "Turno noche"}'

# Resultado: 100/100 (100%) en un día
```

### Caso 2: Entregas en días diferentes

```bash
# Lunes
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 50, "notas": "Lunes - Lote 1"}'

# Miércoles
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 50, "notas": "Miércoles - Lote 2"}'

# Resultado: 100/100 (100%), pero en 2 días
```

### Caso 3: Corrección de error

```bash
# Registras 50, pero eran 40
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 50}'
  
# Verás: 50/100 (50%)

# Deshacer
curl -X DELETE http://localhost:5000/api/entregas/parcial/456

# Registrar cantidad correcta
curl -X POST http://localhost:5000/api/entregas/parcial \
  -d '{"flujo_id": 100, "cantidad_entregada": 40}'

# Resultado: 40/100 (40%)
```

---

¡Listo! Ahora tienes todo para probar y usar los endpoints. 🚀
