#!/bin/bash

# SCRIPT DE VERIFICACIÓN: ENTREGAS PARCIALES
# Este script verifica que todo está instalado y funcionando

echo "🔍 VERIFICANDO... Entregas Parciales"
echo "======================================"
echo ""

# 1. Verificar modelo
echo "1. Verificando modelos Python..."
if grep -q "class EntregaParcial" /workspaces/industrial-verduzco/models.py; then
    echo "   ✅ Modelo EntregaParcial exists"
else
    echo "   ❌ Modelo EntregaParcial NOT found"
fi

if grep -q "cantidad_entregada = db.Column" /workspaces/industrial-verduzco/models.py; then
    echo "   ✅ Campos en HojaRutaFlujoLogistica added"
else
    echo "   ❌ Campos NOT found"
fi

echo ""

# 2. Verificar endpoints
echo "2. Verificando endpoints API..."
if grep -q "def api_registrar_entrega_parcial" /workspaces/industrial-verduzco/app.py; then
    echo "   ✅ POST /api/entregas/parcial implemented"
else
    echo "   ❌ POST endpoint NOT found"
fi

if grep -q "def api_obtener_entregas_parciales" /workspaces/industrial-verduzco/app.py; then
    echo "   ✅ GET /api/entregas/.../parciales implemented"
else
    echo "   ❌ GET endpoint NOT found"
fi

if grep -q "def api_eliminar_entrega_parcial" /workspaces/industrial-verduzco/app.py; then
    echo "   ✅ DELETE /api/entregas/parcial/.../implemented"
else
    echo "   ❌ DELETE endpoint NOT found"
fi

echo ""

# 3. Verificar template
echo "3. Verificando frontend..."
if grep -q "abrirModalEntregaParcial" /workspaces/industrial-verduzco/templates/entregas_module.html; then
    echo "   ✅ Modal para entregas parciales added"
else
    echo "   ❌ Modal NOT found"
fi

if grep -q "modalEntregaParcial" /workspaces/industrial-verduzco/templates/entregas_module.html; then
    echo "   ✅ JavaScript functions presente"
else
    echo "   ❌ JavaScript NOT found"
fi

echo ""

# 4. Verificar migraciones
echo "4. Verificando migraciones SQL..."
if [ -f /workspaces/industrial-verduzco/migrations/add_entregas_parciales.sql ]; then
    echo "   ✅ SQL migration file exists"
    echo "   📝 Recuerda ejecutar: psql -f migrations/add_entregas_parciales.sql"
else
    echo "   ❌ SQL migration file NOT found"
fi

echo ""

# 5. Verificar documentación
echo "5. Verificando documentación..."
if [ -f /workspaces/industrial-verduzco/GUIA_ENTREGAS_PARCIALES.md ]; then
    echo "   ✅ GUIA_ENTREGAS_PARCIALES.md created"
else
    echo "   ❌ GUIA NOT found"
fi

if [ -f /workspaces/industrial-verduzco/ENTREGAS_PARCIALES_RESUMEN.md ]; then
    echo "   ✅ ENTREGAS_PARCIALES_RESUMEN.md created"
else
    echo "   ❌ RESUMEN NOT found"
fi

if [ -f /workspaces/industrial-verduzco/ENTREGAS_PARCIALES_EJEMPLOS_API.md ]; then
    echo "   ✅ ENTREGAS_PARCIALES_EJEMPLOS_API.md created"
else
    echo "   ❌ EJEMPLOS NOT found"
fi

echo ""
echo "======================================"
echo "✨ VERIFICACIÓN COMPLETADA"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "   1. Ejecuta migración SQL:"
echo "      psql -U usuario -d basedatos -f migrations/add_entregas_parciales.sql"
echo ""
echo "   2. Reinicia la app (si está corriendo)"
echo ""
echo "   3. Ve a /entregas y verifica que funcione"
echo ""
echo "   4. Lee la documentación:"
echo "      - ENTREGAS_PARCIALES_RESUMEN.md (rápido)"
echo "      - GUIA_ENTREGAS_PARCIALES.md (completo)"
echo "      - ENTREGAS_PARCIALES_EJEMPLOS_API.md (técnico)"
echo ""
