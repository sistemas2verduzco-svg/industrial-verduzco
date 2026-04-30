-- Fix: columna materia_prima en hojas_ruta_nueva era VARCHAR(255).
-- El sistema guarda el bloque de estado de procesos ([MP_PROCESS_STATE_START]...)
-- en este campo y supera 255 caracteres, causando el error
-- "No se pudo actualizar el proceso MP" al marcar/avanzar un proceso.

ALTER TABLE hojas_ruta_nueva ALTER COLUMN materia_prima TYPE TEXT;
