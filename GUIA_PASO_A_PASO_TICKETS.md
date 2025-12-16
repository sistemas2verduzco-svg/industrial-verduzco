# 🎯 GUÍA PASO A PASO - SISTEMA DE TICKETS

## Índice
1. [Instalación y Configuración](#instalación)
2. [Registrar Ingenieros](#ingenieros)
3. [Configurar Email](#email)
4. [Usar el Sistema](#uso)
5. [Solución de Problemas](#problemas)

---

## 🔧 Instalación {#instalación}

### Paso 1: Instalar Dependencias

Abre PowerShell o Terminal en la carpeta del proyecto:

```powershell
pip install -r requirements.txt
```

**Debería instalar:**
- Flask
- Flask-SQLAlchemy
- psycopg2-binary
- openpyxl
- Y más...

✅ Espera a que termine sin errores.

---

### Paso 2: Verificar Base de Datos

Asegúrate de que tu `.env` tiene la conexión correcta a PostgreSQL:

```bash
# En tu .env
DATABASE_URL=postgresql://usuario:contraseña@localhost:5432/catalogo_db
```

✅ La BD debe estar corriendo.

---

## 👨‍💻 Registrar Ingenieros {#ingenieros}

### Paso 1: Ejecutar Script

En PowerShell, en la carpeta del proyecto:

```powershell
python registrar_ingenieros.py
```

**Debería mostrar:**
```
✓ Usuario ing_carlos creado
✓ Ingeniero ing_carlos registrado - Redes y Servidores
✓ Usuario ing_maria creado
✓ Ingeniero ing_maria registrado - Hardware y Impresoras
✓ Usuario ing_jorge creado
✓ Ingeniero ing_jorge registrado - Software y Bases de Datos

✅ Registro de ingenieros completado
```

✅ Los 3 ingenieros están listos para usar.

---

### Paso 2: Credenciales Iniciales

Guarda estas credenciales en un lugar seguro:

```
👤 Ingeniero 1
  Usuario: ing_carlos
  Contraseña: ing_carlos123
  Email: carlos@company.com
  Especialidad: Redes y Servidores

👤 Ingeniero 2
  Usuario: ing_maria
  Contraseña: ing_maria123
  Email: maria@company.com
  Especialidad: Hardware e Impresoras

👤 Ingeniero 3
  Usuario: ing_jorge
  Contraseña: ing_jorge123
  Email: jorge@company.com
  Especialidad: Software y Bases de Datos
```

---

## 📧 Configurar Email {#email}

### Paso 1: Abre tu `.env`

En la carpeta del proyecto, edita `.env` (si no existe, créalo).

### Paso 2: Si Usas Gmail

**Opción A: Crear Contraseña de Aplicación (Recomendado)**

1. Ve a: https://myaccount.google.com/apppasswords
2. Si pide 2FA, configúralo primero
3. Selecciona:
   - App: **Mail**
   - Dispositivo: **Windows Computer** (o tu dispositivo)
4. Google genera una contraseña de 16 caracteres
5. Copia y guarda esa contraseña

**Opción B: Usar Contraseña Normal**

Si prefieres, puedes usar tu contraseña de Gmail normal.

### Paso 3: Agregar a .env

```bash
# Configuración de Email
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=tu-email@gmail.com
SENDER_PASSWORD=contraseña-de-app-aqui
SMTP_USE_TLS=True
```

**Ejemplo real:**
```bash
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=catalogo@gmail.com
SENDER_PASSWORD=jklm nopq rstu vwxy
SMTP_USE_TLS=True
```

✅ Guarda el archivo.

### Paso 4: Otros Servidores SMTP

Si no usas Gmail:

**Outlook:**
```bash
SMTP_SERVER=smtp.office365.com
SMTP_PORT=587
SENDER_EMAIL=tu-email@outlook.com
SENDER_PASSWORD=tu-contraseña
SMTP_USE_TLS=True
```

**Yahoo:**
```bash
SMTP_SERVER=smtp.mail.yahoo.com
SMTP_PORT=587
SENDER_EMAIL=tu-email@yahoo.com
SENDER_PASSWORD=tu-contraseña
SMTP_USE_TLS=True
```

---

## 🚀 Usar el Sistema {#uso}

### Paso 1: Iniciar la Aplicación

```powershell
python app.py
```

Debería mostrar:
```
* Running on http://127.0.0.1:5000
```

✅ Abre esa URL en tu navegador.

---

### Paso 2: Como Usuario (Reportar Problema)

**1. Ve a:** `http://localhost:5000/tickets`

**2. Haz login con un usuario normal** (ejemplo: tu usuario de catálogo)

**3. Haz clic en "➕ Nuevo Ticket"**

**4. Completa el formulario:**
   - **Título:** "La impresora no imprime"
   - **Descripción:** "La impresora de la oficina no responde desde esta mañana"
   - **Categoría:** "Impresoras"
   - **Prioridad:** "Alta"

**5. Haz clic en "Crear Ticket"**

**6. ✅ Verás mensaje:** "Ticket creado exitosamente"

**7. 📧 Revisa tu email:** Deberías recibir confirmación

**8. 📧 Los ingenieros reciben notificación** (pero no será asignado hasta que admin lo asigne)

---

### Paso 3: Como Admin (Asignar Ticket)

**1. Ve a:** `http://localhost:5000/tickets/admin`

**2. Haz login como admin** (admin / admin123)

**3. Verás todos los tickets en una tabla**

**4. Busca el ticket que creaste**

**5. Haz clic en "Asignar"**

**6. Selecciona:** "ing_maria - Hardware e Impresoras"

**7. Haz clic en "Asignar"**

**8. ✅ Verás mensaje:** "Ingeniero asignado"

**9. 📧 Maria recibe email:** "Nuevo Ticket Asignado"

---

### Paso 4: Como Ingeniero (Resolver Ticket)

**1. Maria hace login** (`ing_maria` / `ing_maria123`)

**2. Va a:** `http://localhost:5000/tickets/ingeniero`

**3. Ve el dashboard con estadísticas:**
   - Total de tickets
   - Abiertos
   - En Progreso
   - En Espera
   - Cerrados

**4. Hace clic en "Cambiar Estado"**

**5. Selecciona:** "En Progreso"

**6. Haz clic en "Guardar"**

**7. ✅ El ticket cambió de estado**

**8. 📧 El usuario recibe email:** "Tu ticket cambió a EN PROGRESO"

**9. Maria va a la tab "Agregar Notas"**

**10. Escribe:** "Se verificó la conexión USB, se reinició. Impresora funcionando correctamente."

**11. Haz clic en "Guardar Notas"**

**12. Vuelve a cambiar estado a "Cerrado"**

**13. 📧 El usuario recibe:** "Tu ticket fue CERRADO"

---

### Paso 5: Como Usuario (Ver Resolución)

**1. Usuario hace login nuevamente**

**2. Va a:** `http://localhost:5000/tickets`

**3. Ve su ticket con estado "CERRADO" ✅**

**4. Haz clic en "Ver Detalles"**

**5. Lee las notas de Maria:**
   ```
   [16/12/2025 14:30 - ing_maria]: Se verificó la conexión USB, 
   se reinició. Impresora funcionando correctamente.
   ```

**6. Haz clic en "📥 Descargar Excel"**

**7. ✅ Descarga un archivo con todos sus tickets**

---

## 🔗 Rutas Principales

```
/tickets               → Panel de usuario (crear y ver tickets)
/tickets/ingeniero     → Panel de ingeniero (resolver tickets)
/tickets/admin         → Panel de admin (gestionar todo)
```

---

## 📊 Ejemplo Completo de Flujo

### Timeline de Emails

```
14:00 - Usuario Carlos crea ticket "Fax no funciona"
  ✉️ Email a Carlos: "Tu ticket fue recibido - TKT-1234567890"

14:05 - Admin ve ticket sin asignar
  → Asigna a Maria
  ✉️ Email a Maria: "Nuevo Ticket Asignado - TKT-1234567890"

14:15 - Maria ve su dashboard
  → Abre el ticket
  → Lee descripción: "Fax conectado a línea analógica pero no marca"
  → Cambia a "En Progreso"
  ✉️ Email a Carlos: "Tu ticket cambió a EN PROGRESO"

14:30 - Maria agrega nota
  "Revisé configuración de fax, número de entrada incorrecto"

14:45 - Maria resuelve
  → Cambia a "Cerrado"
  ✉️ Email a Carlos: "Tu ticket fue CERRADO ✅"

15:00 - Carlos verifica
  → Ve su ticket cerrado
  → Lee nota de Maria
  → Descarga Excel con historial
  ✅ Problema resuelto
```

---

## 🐛 Solución de Problemas {#problemas}

### Problema: Los emails no se envían

**Solución 1:** Verifica `.env`
```bash
# Abre .env y revisa que tenga:
SMTP_SERVER=smtp.gmail.com
SENDER_EMAIL=tu-email-valido@gmail.com
SENDER_PASSWORD=contraseña-correcta
```

**Solución 2:** Revisa credenciales de Gmail
- Si usas contraseña de app: ¿Está bien copiada?
- Si usas contraseña normal: ¿Es correcta?
- ¿Está habilitado "Acceso de aplicaciones menos seguras"?

**Solución 3:** Revisa logs
```bash
# Abre archivo: catalogo_app.log
# Busca mensajes de error con SMTP
```

---

### Problema: "No eres ingeniero"

**Solución:**
```bash
python registrar_ingenieros.py
```

Luego reinicia la app:
```bash
python app.py
```

---

### Problema: Tickets no aparecen

**Solución 1:** Actualiza la página
```
Presiona F5 en el navegador
```

**Solución 2:** Verifica BD
```bash
# Verifica que PostgreSQL esté corriendo
```

**Solución 3:** Revisa logs
```bash
# Abre catalogo_app.log y busca errores
```

---

### Problema: Error 500 al crear ticket

**Solución:**
1. Revisa `catalogo_app.log`
2. Verifica que todos los campos obligatorios estén completos
3. Reinicia la app:
```bash
python app.py
```

---

## ✅ Checklist Final

- [ ] Instalaste dependencias (`pip install -r requirements.txt`)
- [ ] Ejecutaste `python registrar_ingenieros.py`
- [ ] Configuraste email en `.env`
- [ ] Iniciaste app: `python app.py`
- [ ] Creaste un ticket desde `/tickets`
- [ ] Recibiste email de confirmación
- [ ] Asignaste desde `/tickets/admin`
- [ ] El ingeniero recibió email
- [ ] Cambiaste estado desde `/tickets/ingeniero`
- [ ] El usuario recibió email de cambio
- [ ] Descargaste en Excel

---

## 🎉 ¡Listo!

Tu sistema de tickets está 100% funcional.

**Si tienes problemas:**
1. Revisa `catalogo_app.log` para errores
2. Verifica `.env` con credenciales correctas
3. Reinicia la aplicación
4. Actualiza el navegador (F5)

**¡Cualquier cosa, avísame! 🚀**
