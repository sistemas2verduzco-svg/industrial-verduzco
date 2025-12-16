# 📋 SISTEMA DE TICKETS - ÍNDICE DE DOCUMENTACIÓN

## 🎯 ¿Por Dónde Empiezo?

Depending on your level of urgency and technical background, start with:

### ⚡ Prisa (5 minutos)
→ Lee: [README_TICKETS.md](README_TICKETS.md)

### 📖 Detallado (30 minutos)
→ Lee: [GUIA_PASO_A_PASO_TICKETS.md](GUIA_PASO_A_PASO_TICKETS.md)

### 📚 Completo (1-2 horas)
→ Lee: [GUIA_SISTEMA_TICKETS.md](GUIA_SISTEMA_TICKETS.md)

### 🔧 Técnico
→ Lee: [RESUMEN_IMPLEMENTACION_TICKETS.md](RESUMEN_IMPLEMENTACION_TICKETS.md)

---

## 📁 Documentos Creados

| Archivo | Tiempo | Contenido |
|---------|--------|----------|
| **README_TICKETS.md** | 5 min | Inicio rápido, comandos esenciales |
| **GUIA_PASO_A_PASO_TICKETS.md** | 30 min | Instrucciones detalladas con capturas mentales |
| **GUIA_SISTEMA_TICKETS.md** | 1-2 h | Documentación completa y exhaustiva |
| **RESUMEN_IMPLEMENTACION_TICKETS.md** | 15 min | Resumen técnico e implementación |
| **Este archivo** | 2 min | Índice y navegación |

---

## 🚀 Pasos Rápidos

```bash
# 1. Instalar
pip install -r requirements.txt

# 2. Registrar ingenieros
python registrar_ingenieros.py

# 3. Configurar email en .env
# (Edita manualmente)

# 4. Ejecutar
python app.py

# 5. Acceder
# http://localhost:5000/tickets
```

---

## 🔗 URLs Principales

```
Usuario:     http://localhost:5000/tickets
Ingeniero:   http://localhost:5000/tickets/ingeniero
Admin:       http://localhost:5000/tickets/admin
```

---

## 👥 Credenciales Iniciales

### Admin
```
Usuario: admin
Password: admin123
```

### Ingenieros (Después de ejecutar script)
```
Usuario: ing_carlos
Password: ing_carlos123

Usuario: ing_maria
Password: ing_maria123

Usuario: ing_jorge
Password: ing_jorge123
```

---

## 📧 Email Configuration

Edita `.env`:
```bash
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=tu-email@gmail.com
SENDER_PASSWORD=contraseña-app
SMTP_USE_TLS=True
```

---

## 📂 Archivos Nuevos

### Python
- `email_manager.py` - Sistema de notificaciones
- `registrar_ingenieros.py` - Script crear ingenieros

### HTML/Templates
- `templates/tickets.html` - Panel usuario
- `templates/tickets_ingeniero.html` - Panel ingeniero
- `templates/tickets_admin.html` - Panel admin

### Modificados
- `models.py` - Clases Ingeniero y Ticket
- `app.py` - 15+ rutas API
- `.env` - Configuración SMTP

---

## 🎯 Funcionalidades

✅ Usuarios reportan problemas
✅ 3 Ingenieros resuelven
✅ Notificaciones automáticas por email
✅ Dashboard con estadísticas
✅ Descarga en Excel
✅ Notas internas
✅ Estados de ticket
✅ Filtros y búsqueda

---

## 📊 Diagrama de Flujo

```
┌──────────────┐
│ Usuario      │ Crea Ticket
└──────┬───────┘
       │ Email: Confirmación
       ↓
┌──────────────┐
│ Admin        │ Asigna a Ingeniero
└──────┬───────┘
       │ Email: Nuevo Ticket
       ↓
┌──────────────┐
│ Ingeniero    │ Trabaja
├──────────────┤
│ - En Progreso│ Email: Cambio Estado
│ - En Espera  │ Email: Cambio Estado
│ - Cerrado    │ Email: Finalizado
└──────┬───────┘
       │
       ↓
┌──────────────┐
│ Usuario      │ Ve Resolución + Descarga Excel
└──────────────┘
```

---

## 🔍 Buscar Información

### Si quieres saber...

| Pregunta | Ir a |
|----------|------|
| Cómo empezar rápido | README_TICKETS.md |
| Paso a paso con detalles | GUIA_PASO_A_PASO_TICKETS.md |
| Documentación completa | GUIA_SISTEMA_TICKETS.md |
| Detalles técnicos | RESUMEN_IMPLEMENTACION_TICKETS.md |
| API endpoints | GUIA_SISTEMA_TICKETS.md (API REST) |
| Configurar email | GUIA_PASO_A_PASO_TICKETS.md (Paso 2) |
| Crear ingenieros | GUIA_PASO_A_PASO_TICKETS.md (Paso 1) |
| Flujo de usuario | GUIA_PASO_A_PASO_TICKETS.md (Paso 4) |
| Base de datos | RESUMEN_IMPLEMENTACION_TICKETS.md (BD) |
| Emails automáticos | GUIA_SISTEMA_TICKETS.md (Notificaciones) |

---

## ❓ Preguntas Frecuentes

### ¿Dónde encuentro las credenciales de los ingenieros?
→ [GUIA_PASO_A_PASO_TICKETS.md](GUIA_PASO_A_PASO_TICKETS.md) - Sección Ingenieros

### ¿Cómo configuro el email?
→ [GUIA_PASO_A_PASO_TICKETS.md](GUIA_PASO_A_PASO_TICKETS.md) - Sección Email

### ¿Qué APIs están disponibles?
→ [GUIA_SISTEMA_TICKETS.md](GUIA_SISTEMA_TICKETS.md) - Sección API REST

### ¿Cómo funcionan las notificaciones?
→ [GUIA_SISTEMA_TICKETS.md](GUIA_SISTEMA_TICKETS.md) - Sección Notificaciones

### Los emails no se envían, ¿qué hago?
→ [GUIA_PASO_A_PASO_TICKETS.md](GUIA_PASO_A_PASO_TICKETS.md) - Solución de Problemas

### ¿Cómo descargar en Excel?
→ [GUIA_SISTEMA_TICKETS.md](GUIA_SISTEMA_TICKETS.md) - Sección Descargas Excel

### ¿Cuáles son los estados de ticket?
→ [GUIA_SISTEMA_TICKETS.md](GUIA_SISTEMA_TICKETS.md) - Sección Estados

---

## 🛠️ Instalación Rápida

```bash
# Paso 1
pip install -r requirements.txt

# Paso 2
python registrar_ingenieros.py

# Paso 3
# Edita .env con configuración SMTP

# Paso 4
python app.py
```

---

## 📱 Acceso a Paneles

```
USUARIO:
http://localhost:5000/tickets
(Crear y ver mis tickets)

INGENIERO:
http://localhost:5000/tickets/ingeniero
(Ver asignados, cambiar estado, notas)

ADMIN:
http://localhost:5000/tickets/admin
(Ver todos, asignar, estadísticas)
```

---

## 🎓 Recomendación de Lectura

1. **Primero:** [README_TICKETS.md](README_TICKETS.md) (5 min)
   - Entender qué es

2. **Luego:** [GUIA_PASO_A_PASO_TICKETS.md](GUIA_PASO_A_PASO_TICKETS.md) (30 min)
   - Implementar el sistema

3. **Después:** [GUIA_SISTEMA_TICKETS.md](GUIA_SISTEMA_TICKETS.md) (1-2 h)
   - Conocer todas las características

4. **Opcional:** [RESUMEN_IMPLEMENTACION_TICKETS.md](RESUMEN_IMPLEMENTACION_TICKETS.md) (15 min)
   - Detalles técnicos internos

---

## 📞 Resumen

El **Sistema de Tickets** está completamente implementado y documentado.

### Tienes:
- ✅ 3 interfaces (usuario, ingeniero, admin)
- ✅ Notificaciones automáticas por email
- ✅ Descarga en Excel
- ✅ Estadísticas en vivo
- ✅ 4 documentos completos

### Próximos pasos:
1. Lee [README_TICKETS.md](README_TICKETS.md)
2. Ejecuta `python registrar_ingenieros.py`
3. Configura email en `.env`
4. ¡Úsalo! 🚀

---

## 📝 Notas

- Todos los archivos están en español
- Documentación clara y paso a paso
- Códigos de ejemplo incluidos
- Solución de problemas incluida
- Listas de chequeo incluidas

---

**¡Bienvenido al Sistema de Tickets! 🎉**

Para empezar: Lee [README_TICKETS.md](README_TICKETS.md) ahora.
