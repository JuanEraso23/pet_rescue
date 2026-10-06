-- ============================================================
-- Pet Rescue - Esquema inicial de base de datos
-- ============================================================

DROP TABLE IF EXISTS reportes CASCADE;
DROP TABLE IF EXISTS mascotas CASCADE;

-- ------------------------------------------------------------
-- Tabla: mascotas
-- ------------------------------------------------------------
CREATE TABLE mascotas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    especie VARCHAR(50) NOT NULL CHECK (especie IN ('Perro', 'Gato', 'Ave', 'Roedor', 'Otro')),
    raza VARCHAR(100),
    color VARCHAR(50) NOT NULL,
    tamano VARCHAR(20) NOT NULL CHECK (tamano IN (U&'Peque\00F1o', 'Mediano', 'Grande')),
    edad_aproximada INTEGER CHECK (edad_aproximada >= 0),
    senas_particulares TEXT
);

-- ------------------------------------------------------------
-- Tabla: reportes
-- ------------------------------------------------------------
CREATE TABLE reportes (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    mascota_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT NOT NULL,
    tipo VARCHAR(20) NOT NULL DEFAULT 'Perdida' CHECK (tipo IN ('Perdida', 'Encontrada')),
    estado VARCHAR(20) NOT NULL DEFAULT 'Activo' CHECK (estado IN ('Activo', 'Cerrado', 'Resuelto')),
    ubicacion_extravio VARCHAR(200) NOT NULL,
    fecha_extravio DATE NOT NULL CHECK (fecha_extravio <= CURRENT_DATE),
    hora_extravio TIME,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- Índices
-- ------------------------------------------------------------
CREATE INDEX idx_reportes_mascota_id ON reportes(mascota_id);
CREATE INDEX idx_reportes_codigo ON reportes(codigo);
CREATE INDEX idx_reportes_estado ON reportes(estado);
