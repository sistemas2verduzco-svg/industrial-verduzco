# Actualización Módulo de Hojas de Ruta

**Fecha:** 15 de enero de 2026  
**Estado:** Implementado, pendiente de pruebas

## Cambios Implementados

### 1. Nuevo Endpoint API
**Ruta:** `GET /api/claves_procesos`  
**Descripción:** Devuelve todas las claves activas con sus procesos ordenados y el tiempo total T/O de cada clave.  
**Respuesta:**
```json
[
  {
    "id": 1,
    "clave": "AS01",
    "nombre": "Producto ejemplo",
    "tiempo_to": "01:30:00",
    "procesos": [...]
  }
]
```

### 2. Formulario Actualizado (`hojas_ruta_form.html`)

#### Campos Modificados:
- **Clave:** Ahora es un combo que carga desde `/api/claves_procesos`
- **Calidad:** Combo con supervisores (Rodrigo Gomez, Jose Nemesio, Otro...)
- **Almacén:** Combo con 3 opciones fijas (AlmacenPT, AlmacenMP, Maquinaria)
- **Orden de trabajo:** Campo unificado manual (antes era orden_trabajo_hr)
- **Total tiempo:** Calculado automáticamente (readonly)
- **Días a laborar:** Calculado automáticamente (readonly)
- **Fecha de término:** Calculada automáticamente (readonly)

#### Campos Eliminados:
- Producto (ahora se toma del nombre de la clave)
- Revisión
- Checkboxes: aprobada, rechazada

#### Campos Ajustados:
- **Scrap:** Ahora es texto opcional (antes checkbox)
- **Retrabajo:** Ahora es texto opcional (antes checkbox)

### 3. Cálculos Automáticos (JavaScript)

#### Al seleccionar clave + cantidad de piezas:
1. **Total tiempo:** `T/O de la clave × cantidad de piezas`
2. **Días a laborar:** `Total tiempo en segundos / (9 horas × 3600)`
   - Jornada: 6:30-12:00 (5.5h) + 12:30-16:00 (3.5h) = 9 horas/día
3. **Fecha de término:** `Fecha actual + días laborales calculados`

### 4. Backend Actualizado (`app.py`)

#### Endpoint `POST /api/hojas_ruta`:
- Ahora requiere `clave_id` obligatorio
- Valida que la clave exista
- Crea automáticamente las **estaciones de trabajo** desde los procesos de la clave
- Cada estación incluye:
  - Nombre: operación del proceso
  - Pro_c: número secuencial
  - Centro de trabajo
  - Tiempos (T/E, T/CT, T/CO, T/O)
  - Total piezas

### 5. Modelo Actualizado (`models.py`)

**Tabla:** `hojas_ruta`
- `scrap`: Cambiado de `Boolean` a `String(255)` nullable
- `retrabajo`: Cambiado de `Boolean` a `String(255)` nullable

### 6. Migración de Base de Datos

**Archivo:** `migrations/update_scrap_retrabajo.sql`

```sql
ALTER TABLE hojas_ruta ALTER COLUMN scrap TYPE VARCHAR(255);
ALTER TABLE hojas_ruta ALTER COLUMN retrabajo TYPE VARCHAR(255);
```

**Ejecutar en el servidor:**
```bash
docker compose exec db psql -U postgres -d catalogo_db -f /path/to/migration.sql
```

## Flujo de Uso

1. Usuario accede a `/hojas_ruta_form`
2. Formulario carga claves desde `/api/claves_procesos`
3. Usuario selecciona:
   - Nombre de hoja
   - Clave (combo)
   - Cantidad de piezas
4. Sistema calcula automáticamente:
   - Total tiempo
   - Días a laborar
   - Fecha de término
5. Usuario completa campos opcionales:
   - Calidad (supervisor)
   - Fecha salida
   - Orden de trabajo
   - Almacén
   - Scrap, Retrabajo
6. Al enviar, el backend:
   - Crea la hoja de ruta
   - Genera estaciones desde procesos de la clave
   - Guarda todos los datos calculados

## Pendientes

### Por definir:
- [ ] Tabla de **materia prima** (id, clave, nombre) - por ahora placeholder
- [ ] **Consecutivo automático** para orden de trabajo
- [ ] Lista definitiva de **supervisores de calidad** (actualmente fija)

### Próximos pasos:
1. Ejecutar migración SQL en servidor
2. Probar creación de hoja con clave real
3. Verificar que estaciones se crean correctamente
4. Validar cálculos de tiempo y fechas
5. Crear tabla de materias primas cuando se tenga el catálogo

## Archivos Modificados

- `app.py`: Nuevo endpoint `/api/claves_procesos`, actualización de `POST /api/hojas_ruta`
- `models.py`: Cambio de tipo en `scrap` y `retrabajo`
- `templates/hojas_ruta_form.html`: Completo rediseño del formulario
- `migrations/update_scrap_retrabajo.sql`: Nueva migración

## Notas Técnicas

- Jornada laboral: 9 horas/día (6:30-12:00 + 12:30-16:00)
- Tiempo base: Se usa el campo `t_to` del último proceso de la secuencia
- Fecha término: Se calcula desde la fecha actual (no desde fecha_salida)
- Estaciones: Se crean automáticamente al crear la hoja, no son editables en la creación
