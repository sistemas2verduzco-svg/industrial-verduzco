# COMANDOS PARA RECONSTRUIR Y LEVANTAR DOCKER

# 1. Reconstruir imágenes (si hiciste cambios en el código o dependencias)
docker-compose build
# o (si usas la nueva sintaxis)
docker compose build

# 2. Levantar los servicios en segundo plano
docker-compose up -d
# o
docker compose up -d

# 3. Verificar que los contenedores estén corriendo
docker ps
git p
# COMANDOS PARA LOCALIZAR Y VERIFICAR LA BASE DE DATOS

# 1. Buscar archivos .db en todo el sistema (puede tardar)
find / -name "*.db" 2>/dev/null | grep -i industrial

# 2. Si usas Docker, ver contenedores y volúmenes
docker ps
docker volume ls

# 3. Buscar configuración de base de datos en el código fuente
grep -Ri "sqlite" .
grep -Ri "mysql" .
grep -Ri "postgres" .

# 4. Si encuentras el archivo .db (ejemplo: /ruta/a/tu.db), verifica integridad y haz respaldo:
sqlite3 /ruta/a/tu.db "PRAGMA integrity_check;"
cp /ruta/a/tu.db backup_antes_de_cambio.db

# 5. Si encuentras MySQL o PostgreSQL, usa los comandos de respaldo y chequeo según corresponda.

# 6. Para ver los datos de la tabla de usuarios (ejemplo SQLite):
sqlite3 /ruta/a/tu.db "SELECT * FROM user;"

# 7. Para ver las tablas existentes (ejemplo SQLite):
sqlite3 /ruta/a/tu.db ".tables"

# 8. Para ver los primeros 10 registros de cualquier tabla (ejemplo SQLite):
sqlite3 /ruta/a/tu.db "SELECT * FROM NOMBRE_TABLA LIMIT 10;"

# Cambia '/ruta/a/tu.db' y 'user' por los nombres reales si son diferentes.
