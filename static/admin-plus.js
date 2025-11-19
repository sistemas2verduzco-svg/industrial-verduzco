/* ========================================
   ADMIN PLUS - EXTENDED ADMIN PANEL SCRIPTS
   ======================================== */

// Helper: parse JSON safely checking content-type
async function parseJsonSafe(response) {
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
        const text = await response.text();
        throw new Error('Respuesta no JSON: ' + text);
    }
    return response.json();
}

// TAB SWITCHING FUNCTION
function cambiarTab(tabName) {
    // Hide all tab contents
    const tabContents = document.querySelectorAll('.tab-content');
    tabContents.forEach(tab => {
        tab.classList.remove('active');
    });

    // Remove active class from all buttons
    const tabButtons = document.querySelectorAll('.tab-btn');
    tabButtons.forEach(btn => {
        btn.classList.remove('active');
    });

    // Show selected tab
    const selectedTab = document.getElementById(`tab-${tabName}`);
    if (selectedTab) {
        selectedTab.classList.add('active');
    }

    // Add active class to clicked button
    const activeButton = document.querySelector(`button[onclick="cambiarTab('${tabName}')"]`);
    if (activeButton) {
        activeButton.classList.add('active');
    }

    // Load data for Estadísticas tab
    if (tabName === 'estadisticas') {
        cargarEstadisticas();
    }
}

// LOAD STATISTICS
function cargarEstadisticas() {
    fetch('/api/estadisticas')
        .then(response => parseJsonSafe(response))
        .then(data => {
            // Update main stats
            document.getElementById('stat-total').textContent = data.total_productos || 0;
            document.getElementById('stat-valor').textContent = '$' + (data.valor_total_inventario || 0).toFixed(2);
            document.getElementById('stat-stock').textContent = data.stock_total || 0;
            document.getElementById('stat-bajo').textContent = data.productos_bajo_stock || 0;

            // Update advanced stats
            if (data.producto_mas_caro) {
                document.getElementById('stats-mas-caro').textContent = 
                    `${data.producto_mas_caro.nombre} - $${data.producto_mas_caro.precio.toFixed(2)}`;
            }

            if (data.producto_mas_barato) {
                document.getElementById('stats-mas-barato').textContent = 
                    `${data.producto_mas_barato.nombre} - $${data.producto_mas_barato.precio.toFixed(2)}`;
            }

            // Update categorías
            if (data.productos_por_categoria) {
                const categoriasHtml = Object.entries(data.productos_por_categoria)
                    .map(([categoria, count]) => `
                        <div class="categoria-item">
                            <span class="categoria-nombre">${categoria || 'Sin categoría'}</span>
                            <span class="categoria-count">${count}</span>
                        </div>
                    `)
                    .join('');
                document.getElementById('stats-categorias').innerHTML = categoriasHtml;
            }

            // Update last sync time
            document.getElementById('ultima-sync').textContent = new Date().toLocaleString('es-ES');
        })
        .catch(error => {
            console.error('Error cargando estadísticas:', error);
            alert('Error al cargar las estadísticas');
        });
}

// APPLY FILTERS
function aplicarFiltros() {
    const buscar = document.getElementById('buscar-producto').value.trim();
    const categoria = document.getElementById('filtro-categoria').value;
    const precioMin = document.getElementById('filtro-precio-min').value;
    const precioMax = document.getElementById('filtro-precio-max').value;

    // Build query params
    const params = new URLSearchParams();
    if (buscar) params.append('q', buscar);
    if (categoria) params.append('categoria', categoria);
    if (precioMin) params.append('precio_min', precioMin);
    if (precioMax) params.append('precio_max', precioMax);

    // Fetch filtered products
    fetch(`/api/productos/buscar?${params.toString()}`)
        .then(response => parseJsonSafe(response))
        .then(data => {
            // Update table with results
            const tbody = document.querySelector('table tbody');
            tbody.innerHTML = '';

            if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:2rem;">No se encontraron productos</td></tr>';
                return;
            }

            data.forEach(producto => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${producto.id}</td>
                    <td>${producto.nombre}</td>
                    <td>${producto.categoria || 'Sin categoría'}</td>
                    <td>$${producto.precio.toFixed(2)}</td>
                    <td>${producto.cantidad}</td>
                    <td>
                        <button class="btn-small btn-edit" onclick="abrirEdicion(${producto.id})">Editar</button>
                        <button class="btn-small btn-delete" onclick="eliminarProducto(${producto.id})">Eliminar</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        })
        .catch(error => {
            console.error('Error buscando productos:', error);
            alert('Error al buscar productos');
        });
}

// EXPORT TO CSV
function exportarCSV() {
    fetch('/api/productos/exportar')
        .then(response => {
            if (!response.ok) throw new Error('Error en la descarga');
            return response.blob();
        })
        .then(blob => {
            // Create download link
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `catalogo_${new Date().getTime()}.csv`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            alert('Catálogo exportado exitosamente');
        })
        .catch(error => {
            console.error('Error exportando CSV:', error);
            alert('Error al exportar el catálogo');
        });
}

// VIEW LOW STOCK PRODUCTS
function verBajoStock() {
    fetch('/api/productos/bajo-stock')
        .then(response => parseJsonSafe(response))
        .then(data => {
            if (data.length === 0) {
                alert('No hay productos con bajo stock');
                return;
            }

            // Build modal content
            let content = '<h3 style="margin-top:0;">Productos con Bajo Stock</h3>';
            content += '<table style="width:100%;border-collapse:collapse;">';
            content += '<tr style="background:#f0f0f0;"><th style="padding:0.5rem;text-align:left;">Producto</th><th style="padding:0.5rem;text-align:right;">Stock</th></tr>';

            data.forEach(p => {
                const isVeryLow = p.cantidad < 3 ? 'style="background:#ffe0e0;"' : '';
                content += `<tr ${isVeryLow}><td style="padding:0.5rem;">${p.nombre}</td><td style="padding:0.5rem;text-align:right;color:#d32f2f;font-weight:bold;">${p.cantidad}</td></tr>`;
            });

            content += '</table>';

            // Show in modal
            const modal = document.getElementById('productModal');
            const modalContent = modal.querySelector('.modal-content');
            modalContent.innerHTML = content;
            modal.style.display = 'block';
        })
        .catch(error => {
            console.error('Error obteniendo bajo stock:', error);
            alert('Error al obtener productos con bajo stock');
        });
}

// SYNC DATABASE
function sincronizarBD() {
    const confirmar = confirm('¿Deseas sincronizar la base de datos? Esto recargará todos los datos.');
    if (!confirmar) return;

    // Reload products and statistics
    Promise.all([
        cargarProductos(),
        cargarEstadisticas()
    ])
    .then(() => {
        alert('Base de datos sincronizada exitosamente');
        document.getElementById('ultima-sync').textContent = new Date().toLocaleString('es-ES');
    })
    .catch(error => {
        console.error('Error sincronizando:', error);
        alert('Error al sincronizar la base de datos');
    });
}

// CLEAR FILTERS
function limpiarFiltros() {
    // Clear all input fields
    document.getElementById('buscar-producto').value = '';
    document.getElementById('filtro-categoria').value = '';
    document.getElementById('filtro-precio-min').value = '';
    document.getElementById('filtro-precio-max').value = '';

    // Reload all products
    cargarProductos();
}

// INITIALIZE ON PAGE LOAD
document.addEventListener('DOMContentLoaded', function() {
    // Set first tab as active
    const firstTab = document.querySelector('.tab-btn');
    if (firstTab) {
        firstTab.classList.add('active');
        document.getElementById('tab-productos').classList.add('active');
    }

    // Add event listeners to filter inputs for real-time search
    const searchInput = document.getElementById('buscar-producto');
    if (searchInput) {
        searchInput.addEventListener('keyup', function(e) {
            if (e.key === 'Enter') {
                aplicarFiltros();
            }
        });
    }

    // Load initial products
    cargarProductos();
});

// Helper function - Load products (already exists in admin.js but ensuring it's available)
function cargarProductos() {
    fetch('/api/productos')
        .then(response => parseJsonSafe(response))
        .then(data => {
            const tbody = document.querySelector('table tbody');
            if (!tbody) return;

            tbody.innerHTML = '';

            if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:2rem;">No hay productos</td></tr>';
                return;
            }

            data.forEach(producto => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${producto.id}</td>
                    <td>${producto.nombre}</td>
                    <td>${producto.categoria || 'Sin categoría'}</td>
                    <td>$${producto.precio.toFixed(2)}</td>
                    <td>${producto.cantidad}</td>
                    <td>
                        <button class="btn-small btn-edit" onclick="abrirEdicion(${producto.id})">Editar</button>
                        <button class="btn-small btn-delete" onclick="eliminarProducto(${producto.id})">Eliminar</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        })
        .catch(error => console.error('Error cargando productos:', error));
}
