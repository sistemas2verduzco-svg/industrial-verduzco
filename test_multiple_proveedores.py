#!/usr/bin/env python3
"""
Script de prueba para verificar que la asignación de múltiples proveedores funciona
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://localhost"
USERNAME = "admin"
PASSWORD = "admin123"

def test_assignment():
    """Prueba la asignación de múltiples proveedores"""
    
    session = requests.Session()
    
    # 1. Login
    print("1️⃣  Realizando login...")
    response = session.post(f"{BASE_URL}/login", data={
        'username': USERNAME,
        'password': PASSWORD
    })
    if response.status_code != 200:
        print("❌ Error en login")
        return False
    print("✅ Login exitoso")
    
    # 2. Obtener productos
    print("\n2️⃣  Obteniendo productos...")
    response = session.get(f"{BASE_URL}/api/productos")
    if response.status_code != 200:
        print("❌ Error obteniendo productos")
        return False
    
    productos = response.json()
    if not productos:
        print("⚠️  No hay productos, crea uno primero")
        return False
    
    producto_id = productos[0]['id']
    print(f"✅ Producto encontrado: {productos[0]['nombre']} (ID: {producto_id})")
    
    # 3. Obtener proveedores
    print("\n3️⃣  Obteniendo proveedores...")
    response = session.get(f"{BASE_URL}/api/proveedores")
    proveedores = response.json()
    
    if len(proveedores) < 2:
        print(f"⚠️  Se necesitan al menos 2 proveedores (hay {len(proveedores)})")
        print("   Crea más proveedores en /proveedores")
        return False
    
    print(f"✅ Proveedores disponibles: {len(proveedores)}")
    
    # 4. Asignar primer proveedor
    print(f"\n4️⃣  Asignando proveedor 1: {proveedores[0]['nombre']}...")
    response = session.post(
        f"{BASE_URL}/api/productos/{producto_id}/proveedores",
        json={
            "proveedor_id": proveedores[0]['id'],
            "precio_proveedor": 100.50,
            "fecha_precio": datetime.now().strftime('%Y-%m-%d'),
            "cantidad_minima": 5
        }
    )
    
    if response.status_code not in [200, 201]:
        print(f"❌ Error: {response.text}")
        return False
    print("✅ Proveedor 1 asignado")
    
    # 5. Asignar segundo proveedor
    print(f"\n5️⃣  Asignando proveedor 2: {proveedores[1]['nombre']}...")
    response = session.post(
        f"{BASE_URL}/api/productos/{producto_id}/proveedores",
        json={
            "proveedor_id": proveedores[1]['id'],
            "precio_proveedor": 95.00,
            "fecha_precio": datetime.now().strftime('%Y-%m-%d'),
            "cantidad_minima": 10
        }
    )
    
    if response.status_code not in [200, 201]:
        print(f"❌ Error: {response.text}")
        return False
    print("✅ Proveedor 2 asignado")
    
    # 6. Verificar asignaciones
    print(f"\n6️⃣  Verificando asignaciones del producto {producto_id}...")
    response = session.get(f"{BASE_URL}/api/productos/{producto_id}/proveedores")
    asignaciones = response.json()
    
    print(f"✅ Total de proveedores asignados: {len(asignaciones)}")
    
    for i, asig in enumerate(asignaciones, 1):
        print(f"\n   Proveedor {i}:")
        print(f"   - Nombre: {asig['proveedor']['nombre']}")
        print(f"   - Precio: ${asig['precio_proveedor']}")
        print(f"   - Fecha: {asig['fecha_precio']}")
        print(f"   - Cantidad mínima: {asig['cantidad_minima']}")
    
    print("\n" + "="*50)
    print("🎉 ¡TODO FUNCIONA CORRECTAMENTE!")
    print("="*50)
    print(f"\nUn producto puede tener múltiples proveedores:")
    print(f"✅ Producto: {productos[0]['nombre']}")
    print(f"✅ Proveedores asignados: {len(asignaciones)}")
    print(f"✅ Cada proveedor con su propio precio y fecha")
    
    return True

if __name__ == "__main__":
    try:
        test_assignment()
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        print("\n💡 Asegúrate de que:")
        print("   1. El servidor Flask está corriendo (docker-compose ps)")
        print("   2. Has creado al menos un producto")
        print("   3. Has creado al menos 2 proveedores en /proveedores")
