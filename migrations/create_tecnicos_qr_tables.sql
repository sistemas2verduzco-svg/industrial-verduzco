CREATE TABLE IF NOT EXISTS tecnicos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    empresa VARCHAR(255) NOT NULL,
    numero_empleado VARCHAR(120) NOT NULL UNIQUE,
    foto VARCHAR(500) NULL,
    qr_imagen VARCHAR(500) NULL,
    token_qr VARCHAR(36) NOT NULL UNIQUE,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    fecha_expiracion TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    creado_en TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_tecnicos_nombre ON tecnicos (nombre);
CREATE INDEX IF NOT EXISTS ix_tecnicos_empresa ON tecnicos (empresa);
CREATE INDEX IF NOT EXISTS ix_tecnicos_estado ON tecnicos (estado);
CREATE INDEX IF NOT EXISTS ix_tecnicos_fecha_expiracion ON tecnicos (fecha_expiracion);
CREATE INDEX IF NOT EXISTS ix_tecnicos_token_qr ON tecnicos (token_qr);

CREATE TABLE IF NOT EXISTS logs_verificacion (
    id SERIAL PRIMARY KEY,
    tecnico_id INTEGER NULL REFERENCES tecnicos(id) ON DELETE SET NULL,
    fecha_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    ip_cliente VARCHAR(64) NULL,
    user_agent TEXT NULL,
    token_consultado VARCHAR(80) NULL,
    resultado VARCHAR(40) NOT NULL DEFAULT 'invalido'
);

CREATE INDEX IF NOT EXISTS ix_logs_verificacion_tecnico_id ON logs_verificacion (tecnico_id);
CREATE INDEX IF NOT EXISTS ix_logs_verificacion_fecha_hora ON logs_verificacion (fecha_hora);
CREATE INDEX IF NOT EXISTS ix_logs_verificacion_ip_cliente ON logs_verificacion (ip_cliente);
CREATE INDEX IF NOT EXISTS ix_logs_verificacion_token_consultado ON logs_verificacion (token_consultado);
CREATE INDEX IF NOT EXISTS ix_logs_verificacion_resultado ON logs_verificacion (resultado);
