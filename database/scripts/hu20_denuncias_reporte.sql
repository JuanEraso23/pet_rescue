-- ============================================================
-- HU20 - Denunciar publicaciones
-- ============================================================
CREATE TABLE IF NOT EXISTS denuncias_reporte (
    id SERIAL PRIMARY KEY,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    motivo VARCHAR(30) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_revision TIMESTAMP,
    observacion_admin TEXT
);

CREATE INDEX IF NOT EXISTS ix_denuncias_reporte_reporte_id ON denuncias_reporte(reporte_id);
CREATE INDEX IF NOT EXISTS ix_denuncias_reporte_estado ON denuncias_reporte(estado);