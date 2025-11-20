// Variables globales
let productoEnEdicion = null;
// Proveedores añadidos en el formulario de creación (temporales hasta que se cree el producto)
let proveedoresEnCreacion = [];
// Cache local de proveedores (id -> objeto) para mostrar nombres sin hacer llamadas extra
let proveedoresCache = [];

// Elementos del DOM
const formulario = document.getElementById('formulario-producto');
const formularioEditar = document.getElementById('formulario-editar');
const tablaBody = document.getElementById('tabla-body');
const modal = document.getElementById('modal-editar');
const closeBtn = document.querySelector('.close');
const mensajeForm = document.getElementById('mensaje-form');
const inputImagenFile = document.getElementById('imagen_file');
const previewDiv = document.getElementById('preview-imagen');
const previewImg = document.getElementById('preview-img');
// Para edición
const editarInputImagenFile = document.getElementById('editar-imagen_file');
const editarPreviewDiv = document.getElementById('editar-preview-imagen');
const editarPreviewImg = document.getElementById('editar-preview-img');
let imagenSubidaUrl = null;

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
    cargarProductos();
    formulario.addEventListener('submit', agregarProducto);
    formularioEditar.addEventListener('submit', guardarEdicion);
    closeBtn.addEventListener('click', cerrarModal);
    window.addEventListener('click', function(event) {
        if (event.target === modal) {
            cerrarModal();
        }
    });
    
    // Event listener para vista previa de imagen (alta)
    if (inputImagenFile) {
        inputImagenFile.addEventListener('change', mostrarPreviewImagen);
    }
    // Event listener para vista previa de imagen (edición)
    if (editarInputImagenFile) {
        editarInputImagenFile.addEventListener('change', function(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    editarPreviewImg.src = e.target.result;
                    editarPreviewDiv.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        });
    }
    // Cargar proveedores para el formulario de creación (si existe el select)
    cargarProveedoresParaCrear();
    // Si el usuario enfoca o hace click en el select, recargar proveedores (útil si agregó uno en otra pestaña)
    const selectNuevo = document.getElementById('select-proveedor-nuevo');
    if (selectNuevo) {
        // Solo recargar si todavía no hay opciones (evita que al hacer click se reemplacen opciones y no se pueda seleccionar)
        selectNuevo.addEventListener('focus', function() { if (selectNuevo.options.length <= 1) cargarProveedoresParaCrear(); });
        selectNuevo.addEventListener('click', function() { if (selectNuevo.options.length <= 1) cargarProveedoresParaCrear(); });
    }

    // Si la pestaña recupera visibilidad (volviste desde /proveedores en otra pestaña), recargar proveedores
    document.addEventListener('visibilitychange', function() {
        if (!document.hidden) {
            const selectNuevo = document.getElementById('select-proveedor-nuevo');
            if (selectNuevo && selectNuevo.options.length <= 1) {
                cargarProveedoresParaCrear();
            }
        }
    });
});

// Helper: parse JSON safely checking content-type
async function parseJsonSafe(response) {
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
        const text = await response.text();
        throw new Error('Respuesta no JSON: ' + text);
    }
    return response.json();
}

// Cargar lista de proveedores en el select del formulario de creación
function cargarProveedoresParaCrear() {
    const selectNuevo = document.getElementById('select-proveedor-nuevo');
    if (!selectNuevo) return;
    // Mejor manejo de errores: comprobar status y tipo de contenido
    fetch('/api/proveedores')
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }
            const contentType = response.headers.get('content-type') || '';
            if (!contentType.includes('application/json')) {
                // Probablemente redirigido al login (HTML)
                throw new Error('No autenticado o respuesta inesperada (no JSON)');
            }
            return parseJsonSafe(response);
        })
        .then(proveedores => {
            // Guardar en cache para mostrar nombre en la lista local
            proveedoresCache = proveedores || [];

            // limpiar opciones previas (excepto la primera)
            while (selectNuevo.options.length > 1) {
                selectNuevo.remove(1);
            }

            proveedores.forEach(prov => {
                const option = document.createElement('option');
                option.value = prov.id;
                option.textContent = prov.nombre;
                selectNuevo.appendChild(option);
            });
            // si ya hay proveedores en la lista local, re-renderizar para mostrar nombres
            renderListaProveedoresNuevos();
        })
        .catch(error => {
            console.error('Error cargando proveedores:', error);
            // Mostrar mensaje amigable en el select contenedor
            const cont = document.getElementById('lista-proveedores-nuevo');
            if (cont) {
                cont.innerHTML = '<p style="color:#b71c1c;">No se pudieron cargar los proveedores. Asegúrate de haber iniciado sesión. <a href="/login">Iniciar sesión</a> o ve a <a href="/proveedores">Proveedores</a>.</p>';
            }
        });
}

// Agregar proveedor a la lista local antes de crear el producto
function agregarProveedorNuevo() {
    const proveedorId = document.getElementById('select-proveedor-nuevo').value;
    const precio = document.getElementById('precio-proveedor-nuevo').value;
    const fecha = document.getElementById('fecha-precio-nuevo').value;

    if (!proveedorId) { alert('❌ Selecciona un proveedor'); return; }
    if (!precio) { alert('❌ Ingresa un precio'); return; }
    if (!fecha) { alert('❌ Selecciona una fecha'); return; }

    const prov = {
        id: parseInt(proveedorId),
        precio: parseFloat(precio),
        fecha: fecha
    };

    // evitar duplicados: si ya existe el proveedor en la lista, preguntar y reemplazar
    const idx = proveedoresEnCreacion.findIndex(p => p.id === prov.id);
    if (idx !== -1) {
        if (!confirm('Este proveedor ya está en la lista. ¿Deseas reemplazar el precio/fecha?')) return;
        proveedoresEnCreacion[idx] = prov;
    } else {
        proveedoresEnCreacion.push(prov);
    }

    // limpiar inputs
    document.getElementById('select-proveedor-nuevo').value = '';
    document.getElementById('precio-proveedor-nuevo').value = '';
    document.getElementById('fecha-precio-nuevo').value = '';

    renderListaProveedoresNuevos();
}

function renderListaProveedoresNuevos() {
    const cont = document.getElementById('lista-proveedores-nuevo');
    if (!cont) return;

    if (proveedoresEnCreacion.length === 0) {
        cont.innerHTML = '<p style="color: #999; font-size: 0.9rem; margin: 0;">Aquí aparecerán los proveedores que vas agregando antes de crear el producto.</p>';
        return;
    }

    cont.innerHTML = '<h5 style="margin: 0 0 0.5rem 0; color: var(--color-primary);">Proveedores a asignar:</h5>';
    cont.innerHTML += proveedoresEnCreacion.map(p => {
        const provObj = proveedoresCache.find(x => x.id === p.id);
        const nombre = provObj ? provObj.nombre : `ID:${p.id}`;
        return `
        <div style="background: #f0f0f0; padding: 0.6rem; border-radius: 6px; margin-bottom: 0.5rem; display:flex; justify-content:space-between; align-items:center;">
            <div>
                <strong>${nombre}</strong><br>
                <small style="color:#666;">Precio: $${p.precio.toFixed(2)} | Fecha: ${p.fecha}</small>
            </div>
            <div style="display:flex; gap:6px;">
                <button type="button" class="btn btn-small" onclick="eliminarProveedorNuevo(${p.id})">✕</button>
            </div>
        </div>
    `}).join('');
}

function eliminarProveedorNuevo(id) {
    proveedoresEnCreacion = proveedoresEnCreacion.filter(p => p.id !== id);
    renderListaProveedoresNuevos();
}

// ==================== VISTA PREVIA DE IMAGEN ====================
function mostrarPreviewImagen(event) {
    const file = event.target.files[0];
    
    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            previewDiv.style.display = 'block';
        };
        reader.readAsDataURL(file);
    }
}

// ==================== SUBIR IMAGEN ====================
function subirImagen(file) {
    return new Promise((resolve, reject) => {
        const formData = new FormData();
        formData.append('imagen', file);
        
        fetch('/api/productos/upload-imagen', {
            method: 'POST',
            body: formData
        })
        .then(response => parseJsonSafe(response))
        .then(data => {
            if (data.error) {
                reject(data.error);
            } else {
                resolve(data.url);
            }
        })
        .catch(error => reject(error));
    });
}

// ==================== CARGAR PRODUCTOS ====================
function cargarProductos() {
    fetch('/api/productos')
        .then(response => parseJsonSafe(response))
        .then(productos => {
            tablaBody.innerHTML = '';
            
            if (productos.length === 0) {
                tablaBody.innerHTML = '<tr><td colspan="6" class="text-center">No hay productos</td></tr>';
                return;
            }
            
            productos.forEach(producto => {
                const fila = document.createElement('tr');
                fila.innerHTML = `
                    <td>${producto.id}</td>
                    <td>${producto.nombre}</td>
                    <td>${producto.categoria || '-'}</td>
                    <td>$${producto.precio.toFixed(2)}</td>
                    <td>${producto.cantidad}</td>
                    <td class="acciones">
                        <button class="btn btn-warning" onclick="abrirEdicion(${producto.id})" title="Editar producto y asignar proveedores">✏️ Editar</button>
                        <button class="btn btn-danger" onclick="eliminarProducto(${producto.id})">🗑️ Eliminar</button>
                    </td>
                `;
                tablaBody.appendChild(fila);
            });
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarMensaje('Error al cargar productos', 'error');
        });
}

// ==================== AGREGAR PRODUCTO ====================
async function agregarProducto(event) {
    event.preventDefault();
    
    try {
        // Verificar si hay imagen para subir
        let urlImagen = document.getElementById('imagen_url').value;
        
        if (inputImagenFile && inputImagenFile.files.length > 0) {
            mostrarMensaje('📤 Subiendo imagen...', 'info');
            urlImagen = await subirImagen(inputImagenFile.files[0]);
        }
        
        const producto = {
            nombre: document.getElementById('nombre').value,
            descripcion: document.getElementById('descripcion').value,
            precio: parseFloat(document.getElementById('precio').value),
            cantidad: parseInt(document.getElementById('cantidad').value) || 0,
            categoria: document.getElementById('categoria').value,
            imagen_url: urlImagen
        };
        
        const response = await fetch('/api/productos', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(producto)
        });

        const result = await parseJsonSafe(response);

        if (response.ok) {
            // Si el usuario añadió proveedores en el formulario de creación, asignarlos ahora
            if (proveedoresEnCreacion.length > 0) {
                for (const p of proveedoresEnCreacion) {
                    try {
                        await fetch(`/api/productos/${result.id}/proveedores`, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ proveedor_id: p.id, precio_proveedor: p.precio, fecha_precio: p.fecha })
                        });
                    } catch (err) {
                        console.error('Error asignando proveedor tras creación:', err);
                    }
                }
            }

            mostrarMensaje('✓ Producto agregado correctamente', 'success');
            setTimeout(() => {
                // Si ya se asignaron proveedores, mostrar mensaje directo
                if (proveedoresEnCreacion.length > 0) {
                    alert('✅ Producto creado y proveedores asignados correctamente.\n\nPuedes editar para ver o ajustar el historial de precios.');
                } else {
                    alert('✅ Producto creado exitosamente!\n\n📌 PRÓXIMO PASO:\nHaz clic en ✏️ EDITAR en la tabla para:\n  • Asignar proveedores\n  • Configurar precios por proveedor\n  • Establecer historial de precios');
                }
            }, 500);

            // limpiar lista local de proveedores añadidos
            proveedoresEnCreacion = [];
            renderListaProveedoresNuevos();

            formulario.reset();
            previewDiv.style.display = 'none';
            imagenSubidaUrl = null;
            cargarProductos();
        } else {
            const msg = result && result.error ? result.error : 'Error al agregar producto';
            mostrarMensaje(`✗ ${msg}`, 'error');
        }
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje(`✗ Error: ${error}`, 'error');
    }
}

// ==================== EDITAR PRODUCTO ====================
function abrirEdicion(id) {
    fetch(`/api/productos/${id}`)
        .then(response => parseJsonSafe(response))
        .then(producto => {
            productoEnEdicion = producto.id;
            document.getElementById('editar-id').value = producto.id;
            document.getElementById('editar-nombre').value = producto.nombre;
            document.getElementById('editar-descripcion').value = producto.descripcion || '';
            document.getElementById('editar-precio').value = producto.precio;
            document.getElementById('editar-cantidad').value = producto.cantidad;
            document.getElementById('editar-categoria').value = producto.categoria || '';
            document.getElementById('editar-imagen_url').value = producto.imagen_url || '';
            // Limpiar input de archivo y preview
            if (editarInputImagenFile) editarInputImagenFile.value = '';
            if (editarPreviewDiv) editarPreviewDiv.style.display = 'none';
            if (editarPreviewImg) editarPreviewImg.src = '';
            modal.classList.add('show');
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error al cargar producto');
        });
}

function guardarEdicion(event) {
    event.preventDefault();
    
    const id = document.getElementById('editar-id').value;
    const producto = {
        nombre: document.getElementById('editar-nombre').value,
        descripcion: document.getElementById('editar-descripcion').value,
        precio: parseFloat(document.getElementById('editar-precio').value),
        cantidad: parseInt(document.getElementById('editar-cantidad').value) || 0,
        categoria: document.getElementById('editar-categoria').value,
        imagen_url: document.getElementById('editar-imagen_url').value
    };
    
    fetch(`/api/productos/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(producto)
    })
    .then(response => {
        if (response.ok) {
            mostrarMensaje('✓ Producto actualizado correctamente', 'success');
            cerrarModal();
            // Si hay archivo de imagen, subir primero
            const file = editarInputImagenFile && editarInputImagenFile.files[0];
            if (file) {
                subirImagen(file).then(url => {
                    enviarEdicionProducto(id, url);
                }).catch(err => {
                    mostrarMensaje('✗ Error al subir imagen', 'error');
                });
            } else {
                const url = document.getElementById('editar-imagen_url').value;
                enviarEdicionProducto(id, url);
            }
        }

        function enviarEdicionProducto(id, imagenUrl) {
            const producto = {
                nombre: document.getElementById('editar-nombre').value,
                descripcion: document.getElementById('editar-descripcion').value,
                precio: parseFloat(document.getElementById('editar-precio').value),
                cantidad: parseInt(document.getElementById('editar-cantidad').value) || 0,
                categoria: document.getElementById('editar-categoria').value,
                imagen_url: imagenUrl
            };
            fetch(`/api/productos/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(producto)
            })
            .then(response => parseJsonSafe(response))
            .then(result => {
                if (result && !result.error) {
                    mostrarMensaje('✓ Producto actualizado', 'success');
                    modal.classList.remove('show');
                    cargarProductos();
                } else {
                    const msg = result && result.error ? result.error : 'Error al actualizar producto';
                    mostrarMensaje(`✗ ${msg}`, 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                mostrarMensaje('✗ Error al actualizar producto', 'error');
            });
        }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        mostrarMensaje('✗ Error en la solicitud', 'error');
    });
}

// ==================== UTILIDADES ====================
function mostrarMensaje(texto, tipo) {
    mensajeForm.textContent = texto;
    mensajeForm.className = `mensaje ${tipo}`;
    
    setTimeout(() => {
        mensajeForm.className = 'mensaje';
    }, 3000);
}

// ==================== EXPORTAR E IMPORTAR ====================
function exportarExcel() {
    fetch('/api/productos/exportar-excel')
        .then(response => {
            if (!response.ok) throw new Error('Error en la descarga');
            return response.blob();
        })
        .then(blob => {
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'catalogo_productos.xlsx';
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            mostrarMensaje('✓ Catálogo exportado correctamente', 'success');
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarMensaje('✗ Error al exportar catálogo', 'error');
        });
}

function exportarCSV() {
    fetch('/api/productos/exportar')
        .then(response => {
            if (!response.ok) throw new Error('Error en la descarga');
            return response.text();
        })
        .then(csv => {
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'productos.csv';
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            mostrarMensaje('✓ Catálogo exportado como CSV', 'success');
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarMensaje('✗ Error al exportar CSV', 'error');
        });
}

// Manejador para importar Excel
document.addEventListener('DOMContentLoaded', function() {
    const inputArchivo = document.getElementById('archivo-importar');
    if (inputArchivo) {
        inputArchivo.addEventListener('change', function(e) {
            const archivo = e.target.files[0];
            if (archivo) {
                document.getElementById('archivo-nombre').textContent = `Cargando: ${archivo.name}...`;
                importarExcel(archivo);
            }
        });
    }
});

function importarExcel(archivo) {
    const formData = new FormData();
    formData.append('file', archivo);
    
    fetch('/api/productos/importar-excel', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.error) {
            mostrarMensaje(`✗ Error: ${data.error}`, 'error');
        } else {
            const resumen = `Importación completada:\n✓ ${data.creados} creados\n✓ ${data.actualizados} actualizados\n✗ ${data.errores} errores`;
            mostrarMensaje(resumen, 'success');
            console.log('Detalles:', data.detalles);
            cargarProductos(); // Recargar tabla
            document.getElementById('archivo-nombre').textContent = '';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        mostrarMensaje('✗ Error al importar Excel', 'error');
        document.getElementById('archivo-nombre').textContent = '';
    });
}

function verBajoStock() {
    fetch('/api/productos/bajo-stock')
        .then(response => response.json())
        .then(productos => {
            if (productos.length === 0) {
                mostrarMensaje('✓ No hay productos con bajo stock', 'success');
                return;
            }
            alert(`Productos con bajo stock (< 5 unidades):\n\n${productos.map(p => `${p.nombre}: ${p.cantidad} uds`).join('\n')}`);
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarMensaje('✗ Error al obtener bajo stock', 'error');
        });
}

function sincronizarBD() {
    mostrarMensaje('⟳ Sincronizando base de datos...', 'info');
    cargarProductos();
    setTimeout(() => {
        mostrarMensaje('✓ Base de datos sincronizada', 'success');
    }, 500);
}

function limpiarFiltros() {
    document.getElementById('filtro-nombre').value = '';
    document.getElementById('filtro-categoria').value = '';
    cargarProductos();
    mostrarMensaje('✓ Filtros limpiados', 'success');
}

