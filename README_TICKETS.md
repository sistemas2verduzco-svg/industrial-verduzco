# 🎟️ SISTEMA DE TICKETS - INICIO RÁPIDO

## ¿Qué es?
Un sistema completo de tickets donde:
- **Usuarios** reportan problemas
- **3 Ingenieros** los resuelven  
- **Todos** reciben notificaciones por email automáticas

---

## ⚡ Inicio en 5 minutos

### 1️⃣ Instalar
```bash
pip install -r requirements.txt
```

### 2️⃣ Configurar Email (.env)

Edita tu `.env` y agrega:
```
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=tu-email@gmail.com
SENDER_PASSWORD=contraseña-app-google
SMTP_USE_TLS=True
```

**Para Gmail:** 
- Ve a https://myaccount.google.com/apppasswords
- Copia contraseña de 16 caracteres
- Pega en `SENDER_PASSWORD`

### 3️⃣ Registrar Ingenieros
```bash
python registrar_ingenieros.py
```

Esto crea 3 usuarios:
- `ing_carlos` / `ing_carlos123`
- `ing_maria` / `ing_maria123`
- `ing_jorge` / `ing_jorge123`

### 4️⃣ ¡Listo!

Accede a:
- **Usuario:** http://localhost:5000/tickets
- **Ingeniero:** http://localhost:5000/tickets/ingeniero
- **Admin:** http://localhost:5000/tickets/admin

---

## 📋 Funcionalidades

### ✅ Usuarios
- ✏️ Crear tickets
- 👀 Ver estado en tiempo real
- 📥 Descargar en Excel
- 📧 Recibir emails de cambios

### ✅ Ingenieros
- 📊 Dashboard con estadísticas
- 🎯 Ver tickets asignados
- ⚙️ Cambiar estado
- 📝 Agregar notas
- 📥 Descargar en Excel

### ✅ Admin
- 🔍 Ver todos los tickets
- 🔗 Asignar a ingenieros
- 📊 Filtrar y buscar
- 📥 Descargar reporte completo

---

## 📧 Emails Automáticos

1. **Usuario crea ticket** → Usuario recibe confirmación
2. **Admin asigna a ingeniero** → Ingeniero recibe notificación
3. **Ingeniero cambia estado** → Usuario recibe actualización
4. **Ingeniero cierra ticket** → Usuario recibe confirmación

---

## 🎯 Ejemplo de Uso

### Como Usuario
```
1. Voy a /tickets
2. Hago clic en "Nuevo Ticket"
3. Completo: Título, Descripción, Categoría, Prioridad
4. ¡Listo! Recibo email y veo mi ticket
```

### Como Ingeniero
```
1. Voy a /tickets/ingeniero
2. Veo mis tickets asignados
3. Cambio estado a "En Progreso"
4. Agrego notas del problema
5. Lo cierro cuando resuelvo
6. Usuario recibe emails en cada paso
```

### Como Admin
```
1. Voy a /tickets/admin
2. Veo todos los tickets
3. Asigno a un ingeniero
4. El ingeniero recibe email automáticamente
5. Puedo descargar todo en Excel
```

---

## 🔧 Archivos Nuevos

- `email_manager.py` - Sistema de notificaciones
- `registrar_ingenieros.py` - Script para crear ingenieros
- `templates/tickets.html` - Panel usuario
- `templates/tickets_ingeniero.html` - Panel ingeniero
- `templates/tickets_admin.html` - Panel admin
- `GUIA_SISTEMA_TICKETS.md` - Guía completa
- `README_TICKETS.md` - Este archivo

---

## 🐛 Solución de Problemas

### Emails no se envían
- Verifica credenciales SMTP en `.env`
- Usa contraseña de app de Google
- Revisa `catalogo_app.log`

### Tickets no aparecen
- Actualiza la página (F5)
- Verifica conexión a BD
- Revisa logs

### Error "No eres ingeniero"
- Ejecuta `python registrar_ingenieros.py`
- Reinicia la aplicación

---

## 📚 Documentación Completa

Para más detalles, ver: **GUIA_SISTEMA_TICKETS.md**

---

## ✅ Checklist

- [ ] Instalar dependencias
- [ ] Configurar email en `.env`
- [ ] Ejecutar `registrar_ingenieros.py`
- [ ] Probar desde `/tickets`
- [ ] Probar desde `/tickets/ingeniero`
- [ ] Verificar emails
- [ ] Descargar Excel

---

## 🎉 ¡Todo Listo!

Tu sistema de tickets está 100% operacional.

**Soporta:**
- ✅ Creación de tickets por usuarios
- ✅ Asignación a 3 ingenieros
- ✅ Notificaciones automáticas por email
- ✅ Descarga en Excel
- ✅ Gestión de estados
- ✅ Notas internas

¡Úsalo y personaliza según necesites! 🚀
