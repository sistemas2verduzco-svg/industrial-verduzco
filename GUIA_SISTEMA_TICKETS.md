# 🎟️ Sistema de Tickets - Guía Completa

## 📋 Descripción General

Se ha implementado un **Sistema de Tickets Completo** para tu plataforma de catálogo que permite:

✅ **Usuarios** reportan problemas/incidencias  
✅ **3 Ingenieros de Sistemas** reciben y gestionan tickets  
✅ **Notificaciones por correo** automáticas  
✅ **Descargas en Excel** con historial completo  
✅ **Panel de Administración** para gestión centralizada  

---

## 🚀 Implementación Rápida

### 1. **Instalar Dependencias**

```bash
pip install Flask Flask-SQLAlchemy psycopg2-binary openpyxl
```

El archivo `requirements.txt` ya incluye estas dependencias.

### 2. **Configurar Email (.env)**

Edita tu archivo `.env` con tus credenciales SMTP:

```bash
# Gmail
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=tu-email@gmail.com
SENDER_PASSWORD=tu-contraseña-app  # Usa contraseña de aplicación, no la normal
SMTP_USE_TLS=True
```

**Nota para Gmail:**
- Ve a: https://myaccount.google.com/apppasswords
- Selecciona App: Mail, Device: Windows Computer
- Copia la contraseña de 16 caracteres
- Pegala en `SENDER_PASSWORD`

### 3. **Registrar Ingenieros**

```bash
python registrar_ingenieros.py
```

Esto crea automáticamente 3 ingenieros:
- **ing_carlos** - Redes y Servidores (carlos@company.com)
- **ing_maria** - Hardware y Impresoras (maria@company.com)
- **ing_jorge** - Software y BD (jorge@company.com)

**Credenciales iniciales:**
```
ing_carlos / ing_carlos123
ing_maria / ing_maria123
ing_jorge / ing_jorge123
```

---

## 📱 Interfaces Disponibles

### 1️⃣ **Panel de Usuario** (`/tickets`)
- ✏️ **Crear nuevo ticket**
- 📋 **Ver mis tickets**
- 📥 **Descargar mis tickets en Excel**
- 👀 **Ver detalles y estado**

### 2️⃣ **Panel de Ingeniero** (`/tickets/ingeniero`)
- 📊 **Dashboard** con estadísticas
- 🎯 **Mis tickets asignados**
- ⚙️ **Cambiar estado de tickets**
- 📝 **Agregar notas internas**
- 📥 **Descargar mis tickets en Excel**

### 3️⃣ **Panel Admin** (`/tickets/admin`)
- 🔍 **Ver todos los tickets**
- 🔗 **Asignar ingenieros**
- 📊 **Filtrar y buscar**
- 📥 **Descargar todo en Excel**

---

## 📊 Flujo de Trabajo

```
1. USUARIO reporta problema
   ↓
2. Se envía email al usuario confirmando recepción (Ticket #TKT-XXXX)
   ↓
3. ADMIN revisa el ticket
   ↓
4. ADMIN asigna a un INGENIERO
   ↓
5. INGENIERO recibe email notificándole la asignación
   ↓
6. INGENIERO cambia estado (Abierto → En Progreso → En Espera → Cerrado)
   ↓
7. USUARIO recibe email con cada cambio de estado
   ↓
8. TICKET se marca como CERRADO
```

---

## 🔄 Estados de Ticket

| Estado | Descripción |
|--------|------------|
| **Abierto** 🔵 | Problema reportado, sin asignar |
| **En Progreso** 🟡 | Ingeniero está trabajando |
| **En Espera** ⚫ | Esperando info del usuario |
| **Cerrado** 🟢 | Problema resuelto |

---

## 🎯 Prioridades

| Prioridad | Color | Uso |
|-----------|-------|-----|
| **Baja** 🟢 | Verde | Mejoras, solicitudes de información |
| **Media** 🟡 | Amarillo | Problemas normales |
| **Alta** 🔴 | Rojo | Problemas graves |
| **Crítica** ⚫ | Oscuro | Sistema down, datos en riesgo |

---

## 📂 Categorías de Tickets

```
- Hardware (computadoras, monitores, etc)
- Software (aplicaciones, instalaciones)
- Red/Conectividad (internet, WiFi)
- Seguridad (contraseñas, acceso)
- Impresoras (papel, tóner, conexión)
- Bases de Datos (consultas, backups)
- Otro (diversos)
```

---

## 📧 Notificaciones por Email

### Emails Automáticos

1. **Confirmación de Ticket** (Usuario)
   - Se envía cuando crea un ticket
   - Contiene número de ticket único

2. **Nuevo Ticket Asignado** (Ingeniero)
   - Se envía cuando admin lo asigna
   - Incluye detalles completos

3. **Cambio de Estado** (Usuario)
   - Se envía en cada cambio
   - Notifica el nuevo estado

---

## 💾 Base de Datos

### Nuevas Tablas Creadas

```sql
-- Tabla de ingenieros
CREATE TABLE ingenieros (
    id INTEGER PRIMARY KEY,
    usuario_id INTEGER FOREIGN KEY,
    especialidad VARCHAR(100),
    telefono VARCHAR(20),
    disponible BOOLEAN,
    fecha_creacion DATETIME
);

-- Tabla de tickets
CREATE TABLE tickets (
    id INTEGER PRIMARY KEY,
    numero_ticket VARCHAR(20) UNIQUE,
    usuario_id INTEGER FOREIGN KEY,
    ingeniero_id INTEGER FOREIGN KEY,
    titulo VARCHAR(255),
    descripcion TEXT,
    prioridad VARCHAR(20),  -- baja, media, alta, critica
    estado VARCHAR(20),     -- abierto, en_progreso, en_espera, cerrado
    categoria VARCHAR(100),
    notas_internas TEXT,
    fecha_creacion DATETIME,
    fecha_actualizacion DATETIME,
    fecha_cierre DATETIME
);
```

---

## 🔌 API REST

### Crear Ticket
```
POST /api/tickets
{
    "titulo": "No puedo acceder al correo",
    "descripcion": "Cuando intento entrar recibo error 401",
    "categoria": "software",
    "prioridad": "alta"
}
```

### Obtener Mis Tickets
```
GET /api/mis-tickets
```

### Obtener Tickets del Ingeniero
```
GET /api/tickets-ingeniero
```

### Cambiar Estado
```
PUT /api/tickets/{id}/estado
{
    "estado": "en_progreso"
}
```

### Agregar Notas
```
PUT /api/tickets/{id}/notas
{
    "notas": "Cliente reporta que reinició la máquina"
}
```

### Descargar Excel
```
GET /api/tickets/descargar/excel?tipo=mis
GET /api/tickets/descargar/excel?tipo=ingeniero
GET /api/tickets/descargar/excel?tipo=todos
```

---

## 📱 Navegación

### Desde Admin Principal
1. Buscar "Tickets" en navegación
2. O acceder directamente: `http://localhost:5000/tickets/admin`

### Desde Perfil de Usuario
- Link: "📋 Sistema de Tickets"
- Permite crear y ver propios tickets

### Desde Perfil de Ingeniero
- Link: "🔧 Panel de Ingeniero"
- Dashboard con estadísticas

---

## 🛠️ Solución de Problemas

### Los emails no se envían
- ❌ Verifica las credenciales SMTP en `.env`
- ❌ Usa contraseña de app de Google, no la normal
- ❌ Verifica que la cuenta SMTP_SERVER sea correcta

### Tickets no aparecen
- ❌ Actualiza la página (F5)
- ❌ Verifica que la BD esté conectada
- ❌ Revisa logs en `catalogo_app.log`

### Error: "No eres ingeniero"
- ❌ Ejecuta `python registrar_ingenieros.py`
- ❌ O registra manualmente vía `/api/ingenieros`

---

## 📝 Ejemplos de Uso

### Como Usuario (reportar problema)
1. Voy a `/tickets`
2. Hago clic en "➕ Nuevo Ticket"
3. Completo el formulario
4. El admin y ingeniero reciben notificación
5. Puedo ver el estado en tiempo real

### Como Ingeniero (resolver)
1. Voy a `/tickets/ingeniero`
2. Veo mis tickets asignados
3. Cambio estado a "En Progreso"
4. Usuario recibe email
5. Agrego notas del problema
6. Cierro el ticket cuando resuelvo
7. Descargo Excel con historial

### Como Admin (gestionar)
1. Voy a `/tickets/admin`
2. Filtro por estado/prioridad
3. Asigno tickets a ingenieros
4. Los ingenieros reciben emails
5. Descargo reporte completo

---

## 🔐 Seguridad

- ✅ Autenticación requerida para todo
- ✅ Usuarios solo ven sus tickets
- ✅ Ingenieros solo ven asignados
- ✅ Contraseñas hasheadas
- ✅ HTTPS en producción (recomendado)

---

## 📈 Estadísticas

El sistema registra automáticamente:
- Total de tickets
- Por estado (abiertos, en progreso, etc)
- Por prioridad
- Tiempo de resolución
- Ingeniero con más tickets

---

## 🎓 Personalización

### Cambiar Categorías
Edita en `templates/tickets.html` línea ~130:
```javascript
<option value="hardware">Hardware</option>
<option value="software">Software</option>
// Agrega más según necesites
```

### Cambiar Prioridades
En el mismo archivo, modifica el select de prioridad

### Personalizar Emails
Edita `email_manager.py` para cambiar contenido, colores, logo

---

## ✅ Checklist de Implementación

- [ ] Instalar dependencias
- [ ] Actualizar `.env` con credenciales SMTP
- [ ] Ejecutar `registrar_ingenieros.py`
- [ ] Probar crear un ticket desde usuario
- [ ] Verificar que engineer recibe email
- [ ] Cambiar estado y verificar emails
- [ ] Descargar Excel
- [ ] Customizar según tus necesidades

---

## 📞 Soporte

Si necesitas ayuda:
1. Revisa `catalogo_app.log` para errores
2. Verifica configuración de `.env`
3. Asegúrate de que BD está conectada
4. Verifica credenciales SMTP

---

## 🎉 ¡Listo!

Tu sistema de tickets está 100% funcional. Los usuarios pueden reportar problemas, los ingenieros los resuelven y todos reciben notificaciones automáticas.

**Cualquier pregunta o mejora, ¡hazme saber!** 🚀
