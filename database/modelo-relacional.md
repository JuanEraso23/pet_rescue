# Modelo Relacional — Pet Rescue

## MASCOTA

| Atributo | Tipo | Restricción |
|---|---|---|
| id | SERIAL | PK |
| nombre | VARCHAR(100) | — |
| especie | VARCHAR(50) | NOT NULL |
| raza | VARCHAR(100) | — |
| color | VARCHAR(50) | NOT NULL |
| tamano | VARCHAR(20) | NOT NULL |
| edad_aproximada | INTEGER | CHECK >= 0 |
| senas_particulares | TEXT | — |

## REPORTE

| Atributo | Tipo | Restricción |
|---|---|---|
| id | SERIAL | PK |
| codigo | VARCHAR(20) | UNIQUE, NOT NULL |
| mascota_id | INTEGER | FK → MASCOTA.id, NOT NULL |
| titulo | VARCHAR(200) | NOT NULL |
| descripcion | TEXT | NOT NULL |
| tipo | VARCHAR(20) | NOT NULL, DEFAULT 'Perdida' |
| estado | VARCHAR(20) | NOT NULL, DEFAULT 'Activo' |
| ubicacion_extravio | VARCHAR(200) | NOT NULL |
| fecha_extravio | DATE | NOT NULL, CHECK <= CURRENT_DATE |
| hora_extravio | TIME | — |
| fecha_creacion | TIMESTAMP | NOT NULL, DEFAULT NOW() |

## Relación

MASCOTA (1) ──────── (N) REPORTE

Una mascota puede tener varios reportes a lo largo del tiempo.
Cada reporte pertenece a una sola mascota.
