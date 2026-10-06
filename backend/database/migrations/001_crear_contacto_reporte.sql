-- HU5: crear la tabla para el medio de contacto seguro.

CREATE TABLE IF NOT EXISTS contacto_reporte (
    id SERIAL PRIMARY KEY,

    reporte_id INTEGER NOT NULL UNIQUE,

    tipo_contacto VARCHAR(20) NOT NULL,

    valor_contacto VARCHAR(150) NOT NULL,

    mostrar_publicamente BOOLEAN NOT NULL DEFAULT TRUE,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_contacto_reporte_reporte
        FOREIGN KEY (reporte_id)
        REFERENCES reportes(id)
        ON DELETE CASCADE,

    CONSTRAINT contacto_reporte_tipo_check
        CHECK (
            tipo_contacto IN (
                'Telefono',
                'Correo'
            )
        )
);