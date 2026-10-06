# Diccionario de Datos — Pet Rescue

## Tabla: mascotas

| Campo | Tipo | Longitud | Nulo | Valor por defecto | Restricción | Descripción |
|---|---|---|---|---|---|---|
| id | SERIAL | — | No | Auto | PK | Identificador único de la mascota |
| nombre | VARCHAR | 100 | Sí | — | — | Nombre de la mascota |
| especie | VARCHAR | 50 | No | — | Valor controlado | Especie (Perro, Gato, Ave, Roedor, Otro) |
| raza | VARCHAR | 100 | Sí | — | — | Raza de la mascota |
| color | VARCHAR | 50 | No | — | — | Color predominante |
| tamano | VARCHAR | 20 | No | — | Valor controlado | Tamaño (Pequeño, Mediano, Grande) |
| edad_aproximada | INTEGER | — | Sí | — | CHECK >= 0 | Edad en años |
| senas_particulares | TEXT | — | Sí | — | — | Señas particulares visibles |

## Tabla: reportes

| Campo | Tipo | Longitud | Nulo | Valor por defecto | Restricción | Descripción |
|---|---|---|---|---|---|---|
| id | SERIAL | — | No | Auto | PK | Identificador único del reporte |
| codigo | VARCHAR | 20 | No | — | UNIQUE | Código público del reporte (ej: PR-0001) |
| mascota_id | INTEGER | — | No | — | FK → mascotas.id | Mascota asociada al reporte |
| titulo | VARCHAR | 200 | No | — | — | Título del reporte |
| descripcion | TEXT | — | No | — | — | Descripción detallada |
| tipo | VARCHAR | 20 | No | Perdida | Valor controlado | Tipo (Perdida, Encontrada) |
| estado | VARCHAR | 20 | No | Activo | Valor controlado | Estado (Activo, Cerrado, Resuelto) |
| ubicacion_extravio | VARCHAR | 200 | No | — | — | Lugar donde se extravió |
| fecha_extravio | DATE | — | No | — | CHECK <= CURRENT_DATE | Fecha del extravío |
| hora_extravio | TIME | — | Sí | — | — | Hora del extravío |
| fecha_creacion | TIMESTAMP | — | No | NOW() | — | Fecha de creación del registro |

## Reglas de negocio

- El `codigo` del reporte debe ser único.
- `fecha_extravio` no puede ser una fecha futura.
- `estado` inicia en `Activo` por defecto.
- `tipo` inicia en `Perdida` por defecto.
- `edad_aproximada` no puede ser negativa.
- `hora_extravio` es opcional.
