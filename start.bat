# Script para iniciar fácilmente en Windows

@echo off
echo ========================================
echo  CATALOGO WEB - Docker Compose
echo ========================================
echo.

if "%1"=="up" (
    echo [*] Levantando contenedores...
    docker-compose up
) else if "%1"=="down" (
    echo [*] Deteniendo contenedores...
    docker-compose down
) else if "%1"=="restart" (
    echo [*] Reiniciando contenedores...
    docker-compose down
    docker-compose up
) else if "%1"=="logs" (
    echo [*] Mostrando logs...
    docker-compose logs -f
) else if "%1"=="clean" (
    echo [*] Limpiando todo...
    docker-compose down -v
) else (
    echo Uso:
    echo   start.bat up       - Levantar contenedores
    echo   start.bat down     - Detener contenedores
    echo   start.bat restart  - Reiniciar contenedores
    echo   start.bat logs     - Ver logs en tiempo real
    echo   start.bat clean    - Eliminar todo (datos incluidos)
    echo.
    echo Ejemplo:
    echo   start.bat up
)
