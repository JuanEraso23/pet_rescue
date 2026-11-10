ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS estado_gestion VARCHAR(20);

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS reporte_principal_id INTEGER;

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS motivo_gestion TEXT;

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS fecha_gestion TIMESTAMP WITHOUT TIME ZONE;

UPDATE reportes
SET estado_gestion = 'Vigente'
WHERE estado_gestion IS NULL;

ALTER TABLE reportes
ALTER COLUMN estado_gestion SET DEFAULT 'Vigente';

ALTER TABLE reportes
ALTER COLUMN estado_gestion SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'reportes_estado_gestion_check'
    ) THEN
        ALTER TABLE reportes
        ADD CONSTRAINT reportes_estado_gestion_check
        CHECK (
            estado_gestion IN (
                'Vigente',
                'Duplicado',
                'Desactualizado'
            )
        );
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'reportes_principal_fkey'
    ) THEN
        ALTER TABLE reportes
        ADD CONSTRAINT reportes_principal_fkey
        FOREIGN KEY (reporte_principal_id)
        REFERENCES reportes(id)
        ON DELETE RESTRICT;
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'reportes_gestion_coherente_check'
    ) THEN
        ALTER TABLE reportes
        ADD CONSTRAINT reportes_gestion_coherente_check
        CHECK (
            (
                estado_gestion = 'Vigente'
                AND reporte_principal_id IS NULL
            )
            OR
            (
                estado_gestion = 'Duplicado'
                AND reporte_principal_id IS NOT NULL
                AND reporte_principal_id <> id
                AND motivo_gestion IS NOT NULL
                AND LENGTH(TRIM(motivo_gestion)) > 0
            )
            OR
            (
                estado_gestion = 'Desactualizado'
                AND reporte_principal_id IS NULL
                AND motivo_gestion IS NOT NULL
                AND LENGTH(TRIM(motivo_gestion)) > 0
            )
        );
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_reportes_estado_gestion
ON reportes (estado_gestion);

CREATE INDEX IF NOT EXISTS idx_reportes_principal_id
ON reportes (reporte_principal_id);