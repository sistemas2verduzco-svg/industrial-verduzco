// Script para gestión de historial de precios de proveedores

let productoActualHistorial = null;
let proveedorActualHistorial = null;

// Mostrar modal para agregar precio histórico
function mostrarModalHistorialPrecios(productoId, proveedorId, nombreProveedor) {
    productoActualHistorial = productoId;
    proveedorActualHistorial = proveedorId;
    
    // Crear/mostrar modal
    let modal = document.getElementById('modal-historial-precios');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'modal-historial-precios';
        modal.className = 'modal';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 600px;">
                <span class="close" onclick="cerrarModalHistorial()">&times;</span>
                <h2>📊 Historial de Precios: ${nombreProveedor}</h2>
                
                <div style="margin: 1.5rem 0;">
                    <h4 style="color: var(--color-primary); margin-bottom: 1rem;">Agregar Nuevo Precio</h4>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="hist-precio-input">Precio *</label>
                            <input type="number" id="hist-precio-input" step="0.01" placeholder="Ej: 500.00" style="width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 6px;">
                        </div>
                        
                        <div class="form-group">
                            <label for="hist-fecha-input">Fecha *</label>
                            <input type="date" id="hist-fecha-input" style="width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 6px;">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="hist-notas-input">Notas (Opcional)</label>
                        <textarea id="hist-notas-input" rows="2" placeholder="Ej: Precio especial, cantidad mínima 50 unidades" style="width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 6px;"></textarea>
                    </div>
                    
                    <button type="button" class="btn btn-primary" onclick="agregarPrecioHistorico()" style="width: 100%; margin-top: 1rem;">
                        ➕ Agregar Precio
                    </button>
                </div>
                
                <hr style="margin: 1.5rem 0; border: none; border-top: 1px solid #e0e0e0;">
                
                <h4 style="color: var(--color-primary); margin-bottom: 1rem;">Historial de Precios</h4>
                <div id="lista-historial-precios" style="max-height: 300px; overflow-y: auto;">
                    <p style="color: #999; font-size: 0.9rem;">Cargando...</p>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }
    
    // Mostrar modal
    modal.style.display = 'block';
    
    // Establecer fecha de hoy por defecto
    document.getElementById('hist-fecha-input').valueAsDate = new Date();
    
    // Cargar historial
    cargarHistorialPrecios(productoId, proveedorId);
}

// Cerrar modal de historial
function cerrarModalHistorial() {
    const modal = document.getElementById('modal-historial-precios');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Cargar historial de precios
function cargarHistorialPrecios(productoId, proveedorId) {
    fetch(`/api/productos/${productoId}/proveedores/${proveedorId}/historial`)
        .then(response => response.json())
        .then(historial => {
            const lista = document.getElementById('lista-historial-precios');
            
            if (historial.length === 0) {
                lista.innerHTML = '<p style="color: #999; font-size: 0.9rem;">Sin registros de precios anteriores</p>';
                return;
            }
            
            lista.innerHTML = historial.map((h, index) => `
                <div style="background: #f9f9f9; padding: 0.75rem; border-radius: 6px; margin-bottom: 0.5rem; border-left: 4px solid ${index === 0 ? '#4CAF50' : '#2196F3'};">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div>
                            <strong style="font-size: 1.1rem; color: var(--color-primary);">$${h.precio.toFixed(2)}</strong>
                            <small style="color: #666; display: block; margin-top: 0.3rem;">📅 ${h.fecha_precio}</small>
                            ${h.notas ? `<small style="color: #888; display: block; margin-top: 0.3rem; font-style: italic;">"${h.notas}"</small>` : ''}
                            <small style="color: #999; display: block; margin-top: 0.3rem;">Agregado: ${new Date(h.fecha_creacion).toLocaleDateString()}</small>
                        </div>
                        <button type="button" class="btn btn-delete" onclick="eliminarPrecioHistorico(${h.id}, ${productoId}, ${proveedorId})" style="padding: 0.3rem 0.6rem; font-size: 0.8rem;">
                            🗑️
                        </button>
                    </div>
                </div>
            `).join('');
        })
        .catch(error => {
            console.error('Error:', error);
            document.getElementById('lista-historial-precios').innerHTML = '<p style="color: red;">Error al cargar historial</p>';
        });
}

// Agregar precio histórico
function agregarPrecioHistorico() {
    const precio = document.getElementById('hist-precio-input').value;
    const fecha = document.getElementById('hist-fecha-input').value;
    const notas = document.getElementById('hist-notas-input').value;
    
    if (!precio) {
        alert('❌ Debes ingresar un precio');
        return;
    }
    
    if (!fecha) {
        alert('❌ Debes seleccionar una fecha');
        return;
    }
    
    const data = {
        precio: parseFloat(precio),
        fecha_precio: fecha,
        notas: notas
    };
    
    fetch(`/api/productos/${productoActualHistorial}/proveedores/${proveedorActualHistorial}/historial`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.error) {
            alert('❌ Error: ' + result.error);
        } else {
            alert('✅ Precio agregado al historial');
            
            // Limpiar inputs
            document.getElementById('hist-precio-input').value = '';
            document.getElementById('hist-notas-input').value = '';
            
            // Recargar historial
            cargarHistorialPrecios(productoActualHistorial, proveedorActualHistorial);
            
            // Recargar proveedores en la lista principal
            if (window.cargarProveedoresProducto) {
                cargarProveedoresProducto(productoActualHistorial);
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('❌ Error al agregar precio');
    });
}

// Eliminar precio histórico
function eliminarPrecioHistorico(precioId, productoId, proveedorId) {
    if (confirm('¿Está seguro de eliminar este registro de precio?')) {
        fetch(`/api/historial-precios/${precioId}`, {
            method: 'DELETE'
        })
        .then(response => response.json())
        .then(data => {
            alert('✅ Precio eliminado');
            
            // Recargar historial
            cargarHistorialPrecios(productoId, proveedorId);
            
            // Recargar proveedores en la lista principal
            if (window.cargarProveedoresProducto) {
                cargarProveedoresProducto(productoId);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('❌ Error al eliminar precio');
        });
    }
}

// Cerrar modal al hacer clic fuera
window.addEventListener('click', function(event) {
    const modal = document.getElementById('modal-historial-precios');
    if (modal && event.target === modal) {
        modal.style.display = 'none';
    }
});

// Permitir agregar precio con Enter
document.addEventListener('DOMContentLoaded', function() {
    const observer = new MutationObserver(function() {
        const fechaInput = document.getElementById('hist-fecha-input');
        if (fechaInput && !fechaInput.hasListener) {
            fechaInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    agregarPrecioHistorico();
                }
            });
            fechaInput.hasListener = true;
        }
    });
    
    observer.observe(document.body, { childList: true, subtree: true });
});
