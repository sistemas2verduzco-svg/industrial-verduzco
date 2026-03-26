# 📦 GUÍA: ENTREGAS PARCIALES - SISTEMA DE FLUJO LOGÍSTICO

## ¿QUÉ SON LAS ENTREGAS PARCIALES?

Las entregas parciales permiten que el personal de entregas **registre entregas incrementales** de una hoja de ruta sin necesidad de entregar todas las piezas de una sola vez. Cada entrega se registra con cantidad, usuario, fecha y notas.

---

## 🎯 FLUJO COMPLETO DE ENTREGAS PARCIALES

```
1. CREAR HOJA DE RUTA
   └─ Ej: 100 piezas totales

2. AGREGAR A ENTREGAS (Bandeja temporal)
   └─ Estado: "entregas"
   └─ Se inicializa: cantidad_total = 100, entregada = 0, pendiente = 100

3. REGISTRAR ENTREGAS PARCIALES (INCREMENTALES)
   ├─ Día 1: Entregar 30 piezas
   │  └─ Entregada: 30/100 (30%)
   ├─ Día 2: Entregar 50 piezas
   │  └─ Entregada: 80/100 (80%)
   └─ Día 3: Entregar 20 piezas
      └─ Entregada: 100/100 (100%) ✅ LISTO

4. COMPLETADAS TODAS LAS ENTREGAS
   └─ Botón "Enviar a Almacén" se activa
   └─ Se transfiere con estado "almacen"

5. ALMACÉN RECEPCIONA
   └─ Valida CONTPAQ + captura
   └─ Libera → "entregas_lista_facturación"

6. SE ENVÍA A FACTURACIÓN
   └─ Facturación aprueba
   └─ Finalizada
```

---

## 💻 INTERFACES Y ACCIONES

### 📍 MÓDULO ENTREGAS (`/entregas`)

#### Bandeja temporal (Por cada hoja):

| Campo | Descripción |
|-------|-------------|
| **Nombre de hoja** | Identificador único |
| **📊 Entregas parciales** (grande azul) | Muestra `X de Y` piezas entregadas |
| **Porcentaje** | Progreso visual (ej: 75%) |
| **📋 Ver entregas registradas** | Tabla expandible con histórico |

#### Acciones disponibles:

1. **➕ Entregar parcial** (botón verde)
   - Abre modal para ingresar cantidad
   - Valida no entregar más que pendiente
   - Agrega notas opcionales
   - Se registra automáticamente

2. **→ Enviar a Almacén** (botón naranja)
   - **Se activa solo cuando 100% de piezas está entregadas**
   - Si no está 100%: botón deshabilitado (gris)
   - Transfiere hoja a almacén

3. **Quitar** (botón rojo)
   - Elimina hoja de bandeja
   - Se puede re-agregar después

#### Tabla de entregas (expandible):

```
Fecha      | Cantidad | Usuario    | Notas                  | Acción
-----------|----------|------------|------------------------|--------
2026-03-17 | 30       | juan_entr  | Entrega almacén PT    | [X]
2026-03-18 | 50       | juan_entr  | Lote completo         | [X]
2026-03-19 | 20       | carlos_a   | Últimas piezas        | [X]
```

- El botón X permite **deshacer una entrega parcial**
- Se revierte cantidad y estado automáticamente

---

## 🔄 CAMPOS RASTREADOS POR EL SISTEMA

### En `HojaRutaFlujoLogistica`:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `cantidad_total_piezas` | Integer | Copia de la cantidad original (se guarda al inicio) |
| `cantidad_entregada` | Integer | Acumulado de todas las entregas parciales |
| `cantidad_pendiente` | Integer | Derivado: total - entregada |
| `porcentaje_entregado` | Float | % completado (0-100) |
| `estado_parciales` | String | 'pendientes' o 'todas' |

### En `EntregaParcial` (Nueva tabla):

```
id | flujo_id | hoja_ruta_id | cantidad_entregada | usuario_entrega | notas | fecha_entrega | fecha_creacion
```

---

## 🚀 ENDPOINTS API

### 1. Registrar entregas parcial

```
POST /api/entregas/parcial
Content-Type: application/json

{
  "flujo_id": 123,
  "cantidad_entregada": 50,
  "notas": "Entrega en almacén PT"
}

Response (201):
{
  "ok": true,
  "entrega": { id, flujo_id, cantidad_entregada, usuario_entrega, ... },
  "flujo": { ... estado actualizado ... }
}

Validaciones:
- cantidad_entregada > 0
- cantidad_entregada <= pendiente
- estado flujo = "entregas"
```

### 2. Obtener entregas de una hoja

```
GET /api/entregas/<hoja_id>/parciales

Response (200):
{
  "ok": true,
  "hoja_id": 123,
  "entregas": [ { ... }, { ... } ],
  "total_registros": 3
}
```

### 3. Deshacer entrega parcial

```
DELETE /api/entregas/parcial/<parcial_id>

Response (200):
{
  "ok": true,
  "message": "Entrega parcial eliminada",
  "flujo": { ... estado revertido ... }
}

Efecto:
- Resta cantidad_entregada del total
- Recalcula porcentaje
- Registra en auditoría
```

### 4. Marcar todas completadas (interno)

```
POST /api/entregas/completar-all/<flujo_id>

Validación:
- cantidad_entregada == cantidad_total_piezas
- Si no: retorna error 409
```

---

## 📋 FLUJO DE PERMISOS

| Rol | Vista | Acción |
|-----|------|--------|
| `entregas_view` | Ver bandeja, ver entregas | NO |
| `entregas_edit` | Ver bandeja, ver entregas | **SÍ - Crear/eliminar entregas parciales** |
| `almacen_view` | NO | NO |
| `almacen_edit` | NO | NO |
| `admin` | TODO | TODO |

---

## 🔔 AUDITORÍA Y BITÁCORA

Cada acción se registra en **`entregas_registros`**:

```
accion                           | usuario  | notas
---------------------------------|----------|-----------------------------------
entrega_parcial_registrada       | juan_e   | Entregadas 50 piezas. Pendiente: 50 (50%)
entrega_parcial_eliminada        | juan_e   | Se eliminó entrega de 50 piezas...
entregas_parciales_completadas   | juan_e   | Todas las entregas parciales completadas
enviada_a_almacen                | juan_e   | Entregas parciales completadas: 100/100
```

---

## ⚠️ VALIDACIONES Y RESTRICCIONES

1. **No se puede entregar más que lo pendiente**
   - Pendiente 50 piezas → Máximo entregar 50
   - Intento de entregar 60 → Error 400

2. **No se puede enviar a Almacén con entregas pendientes**
   - Entregada 80/100 → Botón deshabilitado
   - Necesita 100% completado

3. **Se necesita eliminar sin dejar huella**
   - Botón X en cada entrega permite deshacer
   - Se revierte el contador e historial

4. **Una hoja no puede regresar a "entregas" si tiene parciales**
   - Si Almacén rechaza → se mantienen los parciales registrados
   - Si Facturación rechaza → igual, se conserva historial

---

## 🎮 EJEMPLO DE USO REAL

### Escenario: Entregas de muelles

**Hoja de Ruta:**
- Clave: MUEL-001
- Cantidad: 100 piezas
- Destino: Almacén PT

**Día 1 (Lunes):**
1. Juan (Entregas) agrega hoja a bandeja
2. Registra entrega parcial: **30 piezas** (Nota: "Lote 1 recibido en PT")
3. Estado: 30/100 (30%)

**Día 2 (Martes):**
1. Mismo Juan registra: **40 piezas** (Nota: "Lote 2 completo")
2. Estado: 70/100 (70%)

**Día 3 (Miércoles):**
1. Carlos (otro personal) registra: **30 piezas** (Nota: "Últimas piezas verificadas")
2. Estado: 100/100 (100%) ✅
3. Botón "Enviar a Almacén" ahora está **habilitado**

**Día 3 (Miércoles, tarde):**
1. Juan hace clic en "Enviar a Almacén"
2. Sistema valida: 100/100 ✅
3. Hoja se transfiere a Almacén
4. Se registra en auditoría

**Día 4 (Jueves, Almacén):**
1. María (Almacén) recepciona
2. Valida CONTPAQ y captura
3. Libera a Facturación

**Día 4 (Jueves, Facturación):**
1. Pedro (Facturación) aprueba
2. Status: Finalizada ✅

---

## 🔧 CONFIGURACIÓN Y DEPLOYMENT

### Migración SQL necesaria:

```bash
psql -U usuario -d basedatos -f migrations/add_entregas_parciales.sql
```

### Nuevas tablas:

- ✅ `entregas_parciales` - Registros de entregas
- ✅ Columnas agregadas en `hojas_ruta_flujo_logistica`

### Modelos actualizados:

- ✅ `EntregaParcial` (nuevo)
- ✅ `HojaRutaFlujoLogistica` (campos adicionales)

---

## 📞 SOPORTE Y TROUBLESHOOTING

### "No puedo entregar más piezas"
- **Causa:** Ya se entregó el 100%
- **Solución:** Verificar entregas registradas o deshacer alguna

### "El botón 'Enviar a Almacén' está gris"
- **Causa:** Aún hay piezas pendientes
- **Solución:** Registrar entregas parciales hasta completar 100%

### "Se entregó mal, quiero deshacer"
- **Solución:** Hacer clic en el botón **X** en la tabla de entregas
- El sistema revierte cantidad automáticamente

### "¿Se pierden los datos si elimino una entrega?"
- **No:** Se conserva en auditoría (entregas_registros)
- Se marca como "entrega_parcial_eliminada"

---

## 📊 REPORTES Y ANÁLISIS

Se pueden generar reportes con:

```sql
-- Entregas por usuario
SELECT usuario_entrega, COUNT(*) as entregas, SUM(cantidad_entregada) as total
FROM entregas_parciales
GROUP BY usuario_entrega;

-- Entregas por hoja
SELECT hoja_ruta_id, COUNT(*) as movimientos, SUM(cantidad_entregada) as total
FROM entregas_parciales
GROUP BY hoja_ruta_id;

-- Tiempo promedio por entrega
SELECT AVG(EXTRACT(EPOCH FROM (fecha_entrega - lag(fecha_entrega) OVER (PARTITION BY hoja_ruta_id ORDER BY fecha_entrega))))::interval as promedio
FROM entregas_parciales;
```

---

## ✅ CHECKLIST: LO QUE FUNCIONA

- [x] Registrar entregas parciales incrementales
- [x] Validar no entregar más que pendiente
- [x] Mostrar progreso % en bandeja
- [x] Tabla de entregas expandible/colapsable
- [x] Deshacer entregas (botón X)
- [x] Auditoría completa
- [x] Bloqueo de envío a Almacén si no está 100%
- [x] Inicialización automática de campos
- [x] Permisos granulares
- [x] API RESTful completa
- [x] Responsive en mobile
