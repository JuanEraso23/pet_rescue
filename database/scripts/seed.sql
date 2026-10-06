-- ============================================================
-- Pet Rescue - Datos de prueba (SEED)
-- ============================================================
-- ADVERTENCIA: Este archivo contiene datos de PRUEBA.
-- NO ejecutar en producción.
-- ============================================================

-- Mascota de prueba: Max
INSERT INTO mascotas (nombre, especie, raza, color, tamano, edad_aproximada, senas_particulares)
VALUES ('Max', 'Perro', 'Mestizo', 'Café', 'Mediano', 4, 'Mancha blanca en el pecho');

-- Reporte de prueba: extravío de Max
INSERT INTO reportes (codigo, mascota_id, titulo, descripcion, tipo, estado, ubicacion_extravio, fecha_extravio, hora_extravio)
VALUES ('PR-0001', 1, 'Max se perdió', 'Mascota extraviada durante un paseo', 'Perdida', 'Activo', 'Sector centro', '2026-09-14', '18:30');
