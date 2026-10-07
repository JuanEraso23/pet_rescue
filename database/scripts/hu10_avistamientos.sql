-- ============================================================
-- HU10 - Registrar avistamiento asociado a un reporte
-- Script incremental: agrega tabla avistamientos
-- ============================================================

CREATE TABLE IF NOT EXISTS avistamientos (
    id SERIAL PRIMARY KEY,

    reporte_id INTEGER NOT NULL
        REFERENCES reportes(id)
        ON DELETE CASCADE,

    descripcion VARCHAR(500) NOT NULL,

    ubicacion_aproximada VARCHAR(200) NOT NULL,

    fecha_avistamiento DATE NOT NULL,

    hora_avistamiento TIME NULL,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT avistamientos_descripcion_check
        CHECK (
            char_length(trim(descripcion)) >= 10
        ),

    CONSTRAINT avistamientos_ubicacion_check
        CHECK (
            char_length(trim(ubicacion_aproximada)) >= 3
        ),

    CONSTRAINT avistamientos_fecha_check
        CHECK (
            fecha_avistamiento <= CURRENT_DATE
        )
);

CREATE INDEX IF NOT EXISTS idx_avistamientos_reporte_id
ON avistamientos(reporte_id);

CREATE INDEX IF NOT EXISTS idx_avistamientos_fecha
ON avistamientos(fecha_avistamiento);