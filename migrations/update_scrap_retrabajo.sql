-- Migración: Cambiar scrap y retrabajo de Boolean a String en hojas_ruta
-- Fecha: 2026-01-15

BEGIN;

-- Cambiar tipo de columna scrap de boolean a varchar
ALTER TABLE hojas_ruta ALTER COLUMN scrap TYPE VARCHAR(255) USING 
  CASE 
    WHEN scrap = TRUE THEN 'Sí' 
    WHEN scrap = FALSE THEN NULL 
    ELSE NULL 
  END;

-- Cambiar tipo de columna retrabajo de boolean a varchar
ALTER TABLE hojas_ruta ALTER COLUMN retrabajo TYPE VARCHAR(255) USING 
  CASE 
    WHEN retrabajo = TRUE THEN 'Sí' 
    WHEN retrabajo = FALSE THEN NULL 
    ELSE NULL 
  END;

COMMIT;
