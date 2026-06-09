-- Relación claves + procesos (PostgreSQL)
-- Una fila por cada proceso de cada clave, ordenado por secuencia.

SELECT
    cp.clave,
    cp.nombre AS descripcion_clave,
    cp.notas AS notas_clave,
    cp.activo AS clave_activa,
    cpr.orden,
    pc.codigo AS proceso_codigo,
    pc.nombre AS proceso_nombre,
    pc.descripcion AS proceso_descripcion,
    COALESCE(NULLIF(TRIM(cpr.operacion), ''), pc.operacion) AS operacion,
    COALESCE(NULLIF(TRIM(cpr.centro_trabajo), ''), pc.centro_trabajo) AS centro_trabajo,
    cpr.t_e,
    cpr.t_tct,
    cpr.t_tco,
    cpr.t_to,
    cpr.notas AS notas_proceso
FROM claves_producto cp
LEFT JOIN clave_procesos cpr ON cpr.clave_id = cp.id
LEFT JOIN procesos_catalogo pc ON pc.id = cpr.proceso_id
ORDER BY cp.clave ASC, cpr.orden ASC, pc.nombre ASC;


-- Resumen: una fila por clave con todos los procesos en una columna
SELECT
    cp.clave,
    cp.nombre AS descripcion_clave,
    cp.notas AS notas_clave,
    cp.activo AS clave_activa,
    COUNT(cpr.id) AS total_procesos,
    STRING_AGG(
        cpr.orden::text || '. ' || pc.nombre,
        ' | ' ORDER BY cpr.orden, pc.nombre
    ) AS procesos_secuencia
FROM claves_producto cp
LEFT JOIN clave_procesos cpr ON cpr.clave_id = cp.id
LEFT JOIN procesos_catalogo pc ON pc.id = cpr.proceso_id
GROUP BY cp.id, cp.clave, cp.nombre, cp.notas, cp.activo
ORDER BY cp.clave ASC;
