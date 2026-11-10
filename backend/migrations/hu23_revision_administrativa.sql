ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS estado_revision VARCHAR(20);

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS fecha_revision TIMESTAMP WITHOUT TIME ZONE;

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS observacion_revision TEXT;

UPDATE reportes
SET estado_revision = 'Pendiente'
WHERE estado_revision IS NULL;

ALTER TABLE reportes
ALTER COLUMN estado_revision SET DEFAULT 'Pendiente';

ALTER TABLE reportes
ALTER COLUMN estado_revision SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'reportes_estado_revision_check'
    ) THEN
        ALTER TABLE reportes
        ADD CONSTRAINT reportes_estado_revision_check
        CHECK (
            estado_revision IN (
                'Pendiente',
                'Aprobado',
                'Rechazado'
            )
        );
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_reportes_estado_revision
ON reportes (estado_revision);