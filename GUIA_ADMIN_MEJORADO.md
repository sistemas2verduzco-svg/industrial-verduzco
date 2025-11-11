# 📊 Guía del Panel Administrador Mejorado

## ¿QUÉ SE AGREGÓ?

Tu panel administrador ahora tiene **3 secciones principales** con muchas más funcionalidades:

---

## 🎯 SECCIÓN 1: PRODUCTOS

**Aquí es donde agregas y editas tus productos**

### Características:

1. **Formulario de Agregar Producto** (Arriba)
   - Nombre del producto *
   - Descripción (puede ser más largo)
   - Precio (ejemplo: 12000.00)
   - Cantidad/Stock
   - Categoría (ejemplo: MOTOR, ELECTRÓNICA, etc.)
   - URL de Imagen

2. **Búsqueda y Filtros Avanzados** 
   - **🔍 Buscar por nombre**: Escribe el nombre del producto
   - **🏷️ Filtrar por categoría**: Escribe la categoría exacta
   - **Precio mínimo**: Define el precio mínimo de búsqueda
   - **Precio máximo**: Define el precio máximo de búsqueda
   - **Botón Buscar**: Aplica todos los filtros juntos

3. **Botones de Utilidad**
   - **📥 Exportar CSV**: Descarga todos los productos en formato CSV (Excel)
   - **Editar**: Abre modal para modificar el producto
   - **Eliminar**: Borra el producto (con confirmación)

### Ejemplo de Uso:
- Quieres buscar productos MOTOR con precio entre $10,000 y $15,000:
  1. Deja en blanco "Buscar por nombre" 
  2. Escribe "MOTOR" en categoría
  3. Escribe "10000" en precio mínimo
  4. Escribe "15000" en precio máximo
  5. Haz clic en "Buscar"

---

## 📊 SECCIÓN 2: ESTADÍSTICAS

**Aquí ves métricas importantes de tu catálogo**

### 4 Tarjetas Principales (arriba):

1. **📦 Total de Productos**: Cuántos productos tienes en total
2. **💰 Valor Total Inventario**: El valor en dinero de todo tu inventario
3. **📊 Stock Total**: La suma de todas las cantidades
4. **⚠️ Bajo Stock**: Cuántos productos tienen menos de 5 unidades

### Información Avanzada:

- **💎 Producto Más Caro**: Cuál es tu producto con mayor precio
- **🤑 Producto Más Barato**: Cuál es tu producto con menor precio

### Productos por Categoría:

Una lista que muestra:
- Nombre de cada categoría
- Cuántos productos hay en esa categoría
- Se actualiza automáticamente según lo que agregues

### ¿Cuándo Mirar Aquí?
- Cada mañana para revisar el estado del inventario
- Cuando necesites reportes rápidos
- Para identificar qué categorías tienen más productos
- Para detectar productos con bajo stock

---

## ⚙️ SECCIÓN 3: HERRAMIENTAS AVANZADAS

**4 Funciones útiles para administrar todo mejor**

### 1. 📥 Exportar Catálogo
- **Función**: Descarga TODOS los productos en formato CSV
- **Uso**: Para respaldar datos, compartir con otros, importar a Excel/Google Sheets
- **Botón**: "Exportar CSV"
- **Resultado**: Se descarga un archivo llamado `catalogo_[fecha].csv`

### 2. ⚠️ Productos con Bajo Stock
- **Función**: Muestra solo productos con menos de 5 unidades
- **Uso**: Para saber rápidamente qué necesitas reabastecer
- **Botón**: "Ver Bajo Stock"
- **Resultado**: Abre una ventana con la lista de productos criticos

### 3. 🔄 Sincronizar BD (Base de Datos)
- **Función**: Recarga todos los datos desde la base de datos
- **Uso**: Si algo se ve raro o desactualizado
- **Botón**: "Sincronizar"
- **Resultado**: Actualiza todos los datos y confirmación de éxito

### 4. 🗑️ Vaciar Búsqueda
- **Función**: Limpia todos los filtros aplicados
- **Uso**: Cuando terminas de buscar y quieres ver todo de nuevo
- **Botón**: "Limpiar"
- **Resultado**: Vuelve a mostrar todos los productos sin filtros

### Información del Sistema
Una tabla que muestra:
- **Versión**: 1.0.0
- **Base de Datos**: PostgreSQL 15
- **Servidor**: Gunicorn + Nginx
- **Última actualización**: Hora exacta de la última sincronización

---

## 🚀 PASOS PARA ACCEDER

### Desde tu PC (localhost):
1. Abre navegador
2. Ve a: **http://localhost/admin**
3. Usuario: `admin`
4. Contraseña: `admin123`
5. ¡Listo! Estás en el panel

### Desde otra PC en la red:
1. Abre navegador
2. Ve a: **http://192.168.0.94/admin** (o tu IP)
3. Usuario: `admin`
4. Contraseña: `admin123`
5. ¡Listo! Estás en el panel

---

## 💡 TIPS ÚTILES

### Para Búsquedas Rápidas:
- **Buscar + Enter**: Puedes presionar Enter después de escribir en "Buscar por nombre" para hacer la búsqueda
- **Filtros Combinados**: Puedes combinar varios filtros (nombre + categoría + precio) para búsquedas muy específicas

### Para Mantener Orden:
- Usa categorías consistentes (ejemplo: siempre "MOTOR" no "motor" o "Motor")
- Agrega precios con 2 decimales (ejemplo: 12000.00 no 12000)
- Mantén URLs de imágenes válidas (http o https)

### Para Respaldar Datos:
- **Todas las semanas**: Haz un "Exportar CSV" como respaldo
- **Antes de cambios grandes**: Sincroniza la BD para asegurar datos frescos

### Para Monitorear:
- **Revisa Bajo Stock regularmente**: Para no quedarte sin productos populares
- **Compara Valores**: La pestaña de Estadísticas te muestra tendencias

---

## 📝 EJEMPLO COMPLETO DE FLUJO

### Escenario: Es lunes por la mañana

1. **Ingresa al Panel**
   - Abre navegador → http://localhost/admin

2. **Revisa Estadísticas** (Haz clic en 📊 Estadísticas)
   - Ves que tienes 5 productos, valor total $60,000
   - Ves que hay 2 productos con bajo stock
   - Identificas que MOTOR es tu categoría con más productos (3)

3. **Chequea Bajo Stock** (En Herramientas → Bajo Stock)
   - Ves qué productos necesitan reabastecimiento
   - Haces nota mental de comprar más

4. **Busca Productos Específicos** (Vuelve a Productos)
   - Filtras por categoría "MOTOR" y precio entre $10,000 y $15,000
   - Encuentras 2 productos que cumplen criterios
   - Actualizas las cantidades si es necesario

5. **Exporta Respaldo** (Va a Herramientas → Exportar CSV)
   - Descarga el catálogo completo
   - Lo guarda en tu PC como respaldo

6. **Cierra Sesión**
   - Haz clic en "Cerrar Sesión" en la esquina superior derecha

---

## ❓ PREGUNTAS FRECUENTES

**P: ¿Qué pasa si hago clic en "Sincronizar"?**
R: Recarga los datos desde la BD. No borra nada, solo refresca lo que ves en pantalla.

**P: ¿Puedo descargar el CSV desde otro navegador?**
R: Sí, si estás conectado y autenticado, puedes descargar el CSV desde cualquier navegador.

**P: ¿Qué significa "Stock Total"?**
R: Es la suma de todas las cantidades de todos los productos. Si tienes 3 MOTOR con 1 cada uno = 3 stock total.

**P: ¿Dónde están mis productos eliminados?**
R: Se eliminan permanentemente de la BD. Es por eso que es importante hacer backups con "Exportar CSV".

**P: ¿Puedo cambiar la contraseña?**
R: Actualmente no desde el panel. Necesitas cambiar la variable `ADMIN_PASSWORD` en el archivo `.env` y reiniciar Docker.

---

## 🎨 DISEÑO Y COLORES

- **Azul/Morado**: Colores principales (profesionales)
- **Verde**: Botones de éxito (Sincronizar, Exportar CSV)
- **Amarillo**: Alertas (Bajo Stock)
- **Rojo**: Botones de eliminar

---

## 📞 SOPORTE

Si algo no funciona:
1. Recarga la página (F5)
2. Intenta hacer "Sincronizar"
3. Si persiste, reinicia Docker: 
   ```
   docker-compose down
   docker-compose up -d
   ```

¡Disfruta tu nuevo panel administrador profesional! 🚀
