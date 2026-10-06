-- HU9: actualizar los estados permitidos de un reporte.

ALTER TABLE reportes
DROP CONSTRAINT IF EXISTS reportes_estado_check;

ALTER TABLE reportes
ADD CONSTRAINT reportes_estado_check
CHECK (
    estado IN (
        'Activo',
        'Encontrado',
        'Cerrado'
    )
);