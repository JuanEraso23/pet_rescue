-- ============================================================
-- HU17 - Registrar placa o microchip de la mascota
-- ============================================================

ALTER TABLE mascotas
ADD COLUMN IF NOT EXISTS numero_placa VARCHAR(50);

ALTER TABLE mascotas
ADD COLUMN IF NOT EXISTS numero_microchip VARCHAR(100);

-- Un microchip identifica a una sola mascota. Los valores NULL
-- o vacios no participan en la restriccion de unicidad.
CREATE UNIQUE INDEX IF NOT EXISTS uq_mascotas_numero_microchip
ON mascotas (numero_microchip)
WHERE numero_microchip IS NOT NULL
  AND BTRIM(numero_microchip) <> '';
