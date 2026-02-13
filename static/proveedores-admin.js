// Script para gestión de proveedores en el panel admin

// Helper: parse JSON safely checking content-type
async function parseJsonSafe(response) {
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
        const text = await response.text();
        throw new Error('Respuesta no JSON: ' + text);
    }
    return response.json();
}

let productoActualConProveedores = null;

// Cargar proveedores en el select cuando se abre el modal
function cargarProveedoresEnSelect() {
    fetch('/api/proveedores')
        .then(response => parseJsonSafe(response))
        .then(proveedores => {
            const select = document.getElementById('select-proveedor');
            // Limpiar opciones previas (excepto la primera)
            while (select.options.length > 1) {
                select.remove(1);
            }
            
            proveedores.forEach(prov => {
                const option = document.createElement('option');
                option.value = prov.id;
                option.textContent = prov.nombre;
                select.appendChild(option);
            });
        })
        .catch(error => console.error('Error:', error));
}

// Cargar proveedores asignados al producto
function cargarProveedoresProducto(productoId) {
    productoActualConProveedores = productoId;
    
    fetch(`/api/productos/${productoId}/proveedores`)
        .then(response => parseJsonSafe(response))
        .then(proveedores => {
            const lista = document.getElementById('lista-proveedores-producto');
            
            if (proveedores.length === 0) {
                lista.innerHTML = '<p style="color: #999; font-size: 0.9rem;">No hay proveedores asignados</p>';
                return;
            }
            
            lista.innerHTML = '<h5 style="margin: 0 0 0.5rem 0; color: var(--color-primary);">Proveedores Asignados:</h5>';
            lista.innerHTML += proveedores.map(pp => `
                <div style="background: #f0f0f0; padding: 0.75rem; border-radius: 6px; margin-bottom: 0.5rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div style="flex: 1;">
                            <strong>${pp.proveedor.nombre}</strong><br>
                            <small style="color: #666;">Precio Actual: $${pp.precio_proveedor.toFixed(2)} ${pp.divisa || ''} | Fecha: ${pp.fecha_precio}</small>
                        </div>
                        <div style="display: flex; gap: 0.3rem;">
                            <button type="button" class="btn btn-info" onclick="mostrarModalHistorialPrecios(${productoId}, ${pp.proveedor_id}, '${pp.proveedor.nombre}')" style="padding: 0.3rem 0.6rem; font-size: 0.8rem; background: #2196F3; color: white;">
                                📊
                            </button>
                            <button type="button" class="btn btn-small btn-delete" onclick="desasignarProveedor(${productoId}, ${pp.proveedor_id})" style="padding: 0.3rem 0.6rem; font-size: 0.8rem;">
                                ✕
                            </button>
                        </div>
                    </div>
                </div>
            `).join('');
        })
        .catch(error => console.error('Error:', error));
}

// Asignar proveedor al producto
function asignarProveedorModal() {
    const proveedorId = document.getElementById('select-proveedor').value;
    const precioProveedor = document.getElementById('precio-proveedor').value;
    const fechaPrecio = document.getElementById('fecha-precio').value;
    
    if (!proveedorId) {
        alert('❌ Debes seleccionar un proveedor');
        return;
    }
    
    if (!precioProveedor) {
        alert('❌ Debes ingresar un precio');
        return;
    }
    
    if (!fechaPrecio) {
        alert('❌ Debes seleccionar una fecha');
        return;
    }
    
    const data = {
        proveedor_id: parseInt(proveedorId),
        precio_proveedor: parseFloat(precioProveedor),
        fecha_precio: fechaPrecio
    };
    
    fetch(`/api/productos/${productoActualConProveedores}/proveedores`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => parseJsonSafe(response))
    .then(data => {
        if (data.error) {
            alert('❌ Error: ' + data.error);
        } else {
            alert('✅ Proveedor asignado exitosamente');
            document.getElementById('select-proveedor').value = '';
            document.getElementById('precio-proveedor').value = '';
            document.getElementById('fecha-precio').value = '';
            cargarProveedoresProducto(productoActualConProveedores);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('❌ Error al asignar proveedor');
    });
}

// Desasignar proveedor
function desasignarProveedor(productoId, proveedorId) {
    if (confirm('¿Estás seguro de que deseas desasignar este proveedor?')) {
        fetch(`/api/productos/${productoId}/proveedores/${proveedorId}`, {
            method: 'DELETE'
        })
        .then(response => parseJsonSafe(response))
        .then(data => {
            alert('✅ Proveedor desasignado');
            cargarProveedoresProducto(productoId);
        })
        .catch(error => {
            console.error('Error:', error);
            alert('❌ Error al desasignar proveedor');
        });
    }
}

// Hook para cargar proveedores cuando se abre el modal de edición
// Se ejecuta después de abrirEdicion() en admin.js
const originalAbrirEdicion = window.abrirEdicion;
window.abrirEdicion = function(id) {
    originalAbrirEdicion(id);
    
    // Esperar un poco para que se cargue el modal
    setTimeout(() => {
        cargarProveedoresEnSelect();
        cargarProveedoresProducto(id);
    }, 100);
};

// Cargar proveedores en select al abrir la página
document.addEventListener('DOMContentLoaded', function() {
    cargarProveedoresEnSelect();
});
