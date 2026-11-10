-- ============================================================
-- HU19 - Notificaciones de coincidencias
-- ============================================================
CREATE TABLE IF NOT EXISTS notificaciones_coincidencia (
    id SERIAL PRIMARY KEY,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    reporte_coincidente_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    mensaje VARCHAR(300) NOT NULL,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT ux_notificacion_pareja UNIQUE (reporte_id, reporte_coincidente_id),
    CONSTRAINT ck_notificacion_reportes_distintos CHECK (reporte_id <> reporte_coincidente_id)
);

CREATE INDEX IF NOT EXISTS ix_notificaciones_reporte_id ON notificaciones_coincidencia(reporte_id);