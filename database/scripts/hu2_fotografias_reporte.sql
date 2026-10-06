CREATE TABLE IF NOT EXISTS fotografias_reporte (
    id SERIAL PRIMARY KEY,
    reporte_id INTEGER NOT NULL
        REFERENCES reportes(id) ON DELETE CASCADE,
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_archivo VARCHAR(500) NOT NULL,
    tipo_mime VARCHAR(100) NOT NULL
        CHECK (
            tipo_mime IN (
                'image/jpeg',
                'image/png',
                'image/webp'
            )
        ),
    tamano_bytes INTEGER NOT NULL
        CHECK (
            tamano_bytes > 0
            AND tamano_bytes <= 5242880
        ),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fotografias_reporte_id
ON fotografias_reporte(reporte_id);