-- ============================================================
-- HU18 - Ubicacion aproximada de reportes
-- Coordenadas opcionales; los reportes antiguos quedan en NULL.
-- ============================================================

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS latitud NUMERIC(9,6);

ALTER TABLE reportes
ADD COLUMN IF NOT EXISTS longitud NUMERIC(9,6);
