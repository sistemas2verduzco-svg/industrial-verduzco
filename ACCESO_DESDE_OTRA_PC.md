# 🌐 ACCESO DESDE OTRA COMPUTADORA EN TU RED

## 🔄 TRASPASO RÁPIDO DE ESTA SESIÓN (CHAT + CÓDIGO)

Usa esta sección cuando cambies de máquina y quieras continuar exactamente donde nos quedamos.

### 1) Estado de git ya sincronizado

- Rama actual: `contpaq-mi4-integration`
- Último commit: `d0cb246`
- Remoto: `origin/contpaq-mi4-integration`

Comandos en la otra máquina:

```powershell
git clone https://github.com/sistemas2verduzco-svg/industrial-verduzco.git
cd industrial-verduzco
git checkout contpaq-mi4-integration
git pull origin contpaq-mi4-integration
```

### 2) Contexto funcional implementado (resumen)

- Mapa de máquinas:
	- Card compacto de `Tiempo semanal general` en el bloque de eficiencia.
	- En cada tarjeta de máquina ya se muestra `Trabajado semana`.
- API de mapa:
	- Por máquina: productivo/disponible/eficiencia para hora, día y semana.
	- General planta: eficiencia hora/día/semana con productivo y disponible.
- Reportes de producción (`/produccion/reportes`):
	- Panel extra abajo: `Panel de Tiempos por Máquina`.
	- Filtros: periodo, máquina, estado, módulo, solo activas.
	- Tabla por máquina con: productivo periodo, disponible periodo, eficiencia periodo, día y semana.
	- Bloque general de planta (hora/día/semana) y export CSV con parámetros de tiempo.

### 3) Commits clave de esta parte

- `d0cb246` feat: tiempos por maquina y parametros generales en reportes
- `4244d5e` feat: tiempos semanales compactos en mapa y panel de reportes
- `bf57927` feat: agregar estado de revision para devoluciones en entregas

### 4) Archivo suelto no comprometido (sin impacto en este flujo)

- `migrations/add_maquinaria_ot_snapshot_tables.sql`

### 5) Prompt de reanudación (copiar y pegar en el nuevo chat)

```text
Continua desde el estado actual de la rama contpaq-mi4-integration (commit d0cb246).
Ya existe:
1) card compacto de tiempo semanal general en /mapa_maquinas,
2) tiempo semanal por maquina visible en cada card,
3) panel extra de tiempos en /produccion/reportes con parametros por maquina y generales (prod/disp/eficiencia).

Primero valida visualmente y por API (/api/mapa_maquinas) que los campos de tiempo estén llegando y mostrándose.
Si algo no aparece, corrige frontend/backend y haz commit + push.
```

### 6) Nota sobre historial de chat

El historial del chat puede o no aparecer en otra máquina según sesión/cuenta. Este bloque de traspaso evita depender del historial del chat.

## 📍 Tu IP de Servidor

**IP de tu computadora servidor:** `192.168.0.94`

---

## 🚀 PASO 1: Verifica que Docker está corriendo

En tu computadora servidor (la que corre Docker), abre PowerShell y ejecuta:

```powershell
docker-compose ps
```

Deberías ver algo como:
```
NAME             IMAGE                 COMMAND                  SERVICE   STATUS
catalogo_app     catalogoweb-app       "gunicorn -w 4 -b 0.…"   app       Up
catalogo_db      postgres:15           "docker-entrypoint.s…"   db        Up
catalogo_nginx   nginx:stable-alpine   "/docker-entrypoint.…"   nginx     Up
```

✅ Si ves esto, todo está listo.

---

## 🖥️ PASO 2: En la OTRA computadora

En otra PC conectada a la **misma red**, abre un navegador (Chrome, Edge, Firefox, etc.) y accede a:

### 🌐 **Catálogo Público:**
```
http://192.168.0.94
```

### 🔐 **Panel Admin:**
```
http://192.168.0.94/admin
```

### 🔌 **API (para programadores):**
```
http://192.168.0.94/api/productos
```

---

## 📱 EJEMPLOS VISUALES

### Opción A: Catálogo Público
1. Abre navegador en otra PC
2. En la barra de direcciones, escribe: **http://192.168.0.94**
3. Presiona Enter
4. Verás la lista de productos

### Opción B: Panel Admin
1. Abre navegador en otra PC
2. En la barra de direcciones, escribe: **http://192.168.0.94/admin**
3. Presiona Enter
4. Login: `admin` / `admin123`
5. Ahora puedes agregar, editar, eliminar productos

---

## ⚠️ SI NO FUNCIONA - Solución de Problemas

### ❌ "No puedo acceder"

**Razón 1: Firewall de Windows bloquea el puerto 80**

Abre PowerShell como Administrador y ejecuta:

```powershell
# Ver si algo usa el puerto 80
netstat -ano | findstr ":80"

# Si ves algo, apunta el PID y ejecuta (reemplaza PID):
taskkill /PID <PID> /F

# Después reinicia Docker
docker-compose restart nginx
```

**Razón 2: Firewall de Windows blocking port 80**

```powershell
# Permitir puerto 80 en firewall
New-NetFirewallRule -DisplayName "Allow HTTP 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow

# Después reinicia Docker
docker-compose restart nginx
```

**Razón 3: Las computadoras no están en la misma red**

Verifica:
- Ambas PCs conectadas al mismo WiFi O mismo cable Ethernet
- Misma red (ej: ambas en 192.168.0.x)

**Razón 4: Docker no está corriendo**

```powershell
# En tu servidor, verifica Docker Desktop
docker ps

# Si no ves nada, abre Docker Desktop desde el Inicio de Windows
# Espera 30-60 segundos a que inicie
```

---

## 🔍 VERIFICAR CONECTIVIDAD

### Desde la otra PC (IMPORTANTE):

Abre PowerShell en la otra computadora y ejecuta:

```powershell
# Verificar ping (comprobar que hay conexión)
ping 192.168.0.94

# Si ves "Reply from...", hay conexión ✅
# Si ves "Request timed out", no hay conexión ❌
```

Si el ping funciona pero el navegador no carga:
```powershell
# Probar conexión al puerto 80
Test-NetConnection -ComputerName 192.168.0.94 -Port 80

# Si ves "TcpTestSucceeded : True", el puerto 80 está abierto ✅
```

---

## 🎯 ACCESO DESDE DIFERENTES LUGARES

### Opción 1: Misma Red WiFi (Recomendado)
```
Tu Servidor:  192.168.0.94 (conectado a WiFi)
Otra PC:      192.168.0.X  (conectada a MISMO WiFi)
Acceso:       http://192.168.0.94  ✅ FUNCIONA
```

### Opción 2: Misma Red Ethernet (Cable)
```
Tu Servidor:  192.168.0.94 (cable Ethernet)
Otra PC:      192.168.0.X  (cable Ethernet)
Acceso:       http://192.168.0.94  ✅ FUNCIONA
```

### Opción 3: Red Mixta (WiFi + Ethernet)
```
Tu Servidor:  192.168.0.94 (cable Ethernet)
Otra PC:      192.168.0.X  (WiFi)
Acceso:       http://192.168.0.94  ✅ FUNCIONA (si mismo router)
```

### ❌ Opción 4: Redes Diferentes
```
Tu Servidor:  192.168.0.94     (Red A)
Otra PC:      192.168.1.X      (Red B diferente)
Acceso:       NO FUNCIONA ❌
```

---

## 🔐 SEGURIDAD - Cambiar credenciales

Si accederán OTROS usuarios, deberías cambiar la contraseña:

### En tu servidor:

1. Abre el archivo `.env`:
```
c:\Users\PRIDE BACK TO SCHOOL\Documents\CATALOGO WEB\.env
```

2. Edita estas líneas:
```ini
ADMIN_USER=admin             # Cambiar nombre de usuario
ADMIN_PASSWORD=nuevapass123  # Cambiar contraseña
```

3. Reconstruye Docker:
```powershell
docker-compose down
docker-compose up -d --build
```

4. Los nuevos usuarios usarán: `usuario_nuevo / nuevapass123`

---

## 📡 DESDE INTERNET (Fuera de tu Red)

Si quieres acceder desde FUERA de tu red (Internet), necesitas:

1. **Puerto forwarding** en tu router
2. **Dominio** (ej: ejemplo.com)
3. **SSL/HTTPS** (certificado Let's Encrypt)
4. **IP pública estática** (opcional pero recomendado)

Esto es más complejo. ¿Necesitas ayuda con esto? Dime y lo configuramos.

---

## 🎊 RESUMEN RÁPIDO

| Ubicación | URL | Requisito |
|-----------|-----|-----------|
| Tu PC | http://localhost | - |
| Otra PC en RED | http://192.168.0.94 | Misma WiFi/Red |
| Desde Internet | https://ejemplo.com | Dominio + SSL |

---

## ✅ CHECKLIST DE VERIFICACIÓN

Antes de intentar acceder desde otra PC:

- [ ] Docker Desktop está corriendo (ícono en bandeja)
- [ ] `docker-compose ps` muestra 3 servicios (app, db, nginx)
- [ ] Tu IP es 192.168.0.94 (verifica con `ipconfig`)
- [ ] La otra PC está conectada a la misma RED
- [ ] Firewall de Windows permite puerto 80 (o agrega regla)
- [ ] Prueba ping desde la otra PC: `ping 192.168.0.94`

---

## 📞 CUALQUIER DUDA

Ejecuta este comando en tu servidor para diagnosticar:

```powershell
Write-Output @"
=== DIAGNÓSTICO ===
Docker Status:
"@; docker ps; Write-Output "`n=== PUERTOS ===" ; netstat -ano | findstr ":80"; Write-Output "`n=== IP ===" ; ipconfig | findstr "IPv4"
```

Copia la salida y dime qué ves. 👍

---

**¡Ahora sí! A acceder desde otra computadora 🚀**
