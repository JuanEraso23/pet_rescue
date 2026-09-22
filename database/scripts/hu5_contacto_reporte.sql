-- ============================================================
-- HU5 - Medio de contacto seguro
-- Script incremental: agrega tabla contacto_reporte
-- ============================================================

CREATE TABLE contacto_reporte (
    id SERIAL PRIMARY KEY,
    reporte_id INTEGER NOT NULL UNIQUE REFERENCES reportes(id) ON DELETE CASCADE,
    tipo_contacto VARCHAR(20) NOT NULL CHECK (tipo_contacto IN ('Telefono', 'Correo')),
    valor_contacto VARCHAR(150) NOT NULL,
    mostrar_publicamente BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_contacto_reporte_reporte_id ON contacto_reporte(reporte_id);
