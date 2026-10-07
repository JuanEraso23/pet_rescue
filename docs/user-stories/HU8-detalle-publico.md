# HU8: Consultar el detalle público de un reporte

## Descripción

Como usuario, quiero consultar el detalle público de un reporte para revisar la fotografía, las características de la mascota, la información del extravío y el medio de contacto autorizado.

## Sprint

Sprint 2.

## Prioridad

90.

## Complejidad

Baja.

## Responsable principal

Juan Manuel Eraso Grijalba.

## Product Owner

Diego Escobar Enríquez.

## Estado

En desarrollo.

## Objetivo

Consolidar en una sola pantalla toda la información pública asociada con un reporte de mascota extraviada, protegiendo los datos privados y controlando correctamente la ausencia de información opcional.

## Alcance

HU8 incluye:

- Consultar un reporte mediante su identificador.
- Mostrar el código del reporte.
- Mostrar el tipo y estado del reporte.
- Mostrar la fecha de publicación.
- Mostrar la fotografía reciente.
- Mostrar la descripción del reporte.
- Mostrar las características físicas de la mascota.
- Mostrar la ubicación, fecha y hora aproximada del extravío.
- Mostrar el medio de contacto autorizado.
- Proteger el contacto cuando se encuentre marcado como privado.
- Mostrar mensajes controlados cuando no exista fotografía o contacto.
- Controlar los campos opcionales ausentes.
- Diferenciar entre detalle público y modo de gestión.
- Mostrar un error controlado cuando el reporte no exista.

## Fuera de alcance

HU8 no incluye:

- Autenticación de usuarios.
- Autorización real del propietario.
- Perfiles de usuario.
- Edición de la información del reporte.
- Eliminación de reportes.
- Geolocalización mediante mapas.
- Chat interno.
- Notificaciones.
- Compartir el reporte en redes sociales.

## Información mostrada

### Información general

- Código del reporte.
- Tipo del reporte.
- Estado.
- Fecha de publicación.
- Título.
- Descripción.

### Fotografía

- Fotografía reciente asociada con el reporte.
- Mensaje de fotografía pendiente cuando no exista una imagen.

### Características de la mascota

- Nombre.
- Especie.
- Raza.
- Color.
- Tamaño.
- Edad aproximada.
- Señas particulares.

### Información del extravío

- Ubicación aproximada.
- Fecha del extravío.
- Hora aproximada, si fue registrada.

### Medio de contacto

- Tipo de contacto.
- Valor autorizado.
- Visibilidad del contacto.

## Modos de visualización

### Detalle público

El detalle público permite consultar la información del reporte sin mostrar acciones para modificar su estado.

Se abre mediante:

```dart
DetalleReporteScreen(
  reporteId: reporteId,
)
```

El valor predeterminado de `permitirGestion` es `false`.

### Modo de gestión

El modo de gestión se utiliza después de publicar un reporte y permite consultar la información y cambiar su estado.

Se abre mediante:

```dart
DetalleReporteScreen(
  reporteId: reporte.id,
  permitirGestion: true,
)
```

Esta separación es únicamente visual. La autorización real del propietario requiere autenticación y queda fuera del alcance de HU8.

## Criterios de aceptación

1. El sistema permite consultar un reporte existente mediante su identificador.
2. El detalle muestra el código, tipo, estado, título y fecha de publicación.
3. El detalle muestra la fotografía asociada con el reporte.
4. Si el reporte no tiene fotografía, se muestra el mensaje `Fotografía pendiente`.
5. El detalle muestra las características físicas de la mascota.
6. Los campos opcionales ausentes se reemplazan por mensajes como `No registrado` o `No registrada`.
7. El detalle muestra la ubicación y la fecha del extravío.
8. La hora se muestra cuando fue registrada.
9. Si no existe una hora, se muestra `No registrada`.
10. El detalle muestra el tipo de contacto.
11. Si el contacto es público, se muestra su valor.
12. Si el contacto es privado, se muestra `Contacto privado`.
13. El valor real de un contacto privado no se muestra en la consulta pública.
14. Si no existe contacto, se muestra `Medio de contacto no registrado`.
15. Los reportes con estado `Activo`, `Encontrado` o `Cerrado` se representan correctamente.
16. Un reporte en estado final muestra una indicación visual.
17. El modo público no muestra acciones para actualizar el estado.
18. El modo de gestión permite mostrar las acciones correspondientes.
19. Si el reporte no existe, el sistema muestra un mensaje de error controlado.
20. La pantalla permite reintentar la consulta cuando ocurre un error.
21. La pantalla se adapta a distintos tamaños de ventana.
22. La actualización mediante deslizamiento recarga el reporte, la fotografía y el contacto.

## Reglas de negocio

- Los contactos privados no deben revelar su valor.
- El detalle público tiene una finalidad únicamente informativa.
- La fotografía es opcional.
- El nombre, raza, edad aproximada, señas particulares y hora del extravío pueden ser opcionales.
- Un reporte inexistente debe producir un error `404`.
- Los estados permitidos son:
  - `Activo`
  - `Encontrado`
  - `Cerrado`
- Los reportes en estado `Encontrado` o `Cerrado` se consideran finales.
- La ausencia de información opcional no debe provocar errores en Flutter.
- No deben utilizarse datos personales reales durante las pruebas.

## Dependencias

HU8 depende de:

- HU1: registro del reporte.
- HU2: fotografía reciente.
- HU3: características físicas.
- HU4: información del extravío.
- HU5: medio de contacto seguro.
- HU9: estado actualizado del reporte.
- FastAPI.
- PostgreSQL.
- Flutter Web.

## Endpoints utilizados

### Consultar el reporte

```text
GET /reportes/{reporte_id}
```

### Consultar fotografías

```text
GET /reportes/{reporte_id}/fotografias
```

### Consultar el contacto

```text
GET /reportes/{reporte_id}/contacto
```

## Flujo funcional

```text
Usuario selecciona un reporte
        ↓
Flutter recibe el identificador
        ↓
Consulta el reporte
        ↓
Consulta las fotografías
        ↓
Consulta el medio de contacto
        ↓
Construye el detalle público
        ↓
Protege el contacto privado
        ↓
Muestra mensajes para datos ausentes
```

## Archivos principales

```text
frontend/lib/models/reporte.dart
frontend/lib/screens/detalle_reporte_screen.dart
frontend/lib/screens/confirmacion_reporte_screen.dart
frontend/lib/services/reporte_service.dart
```

## Definition of Done

HU8 se considera terminada cuando:

- [ ] El detalle muestra la información general del reporte.
- [ ] La fecha de publicación se visualiza.
- [ ] La fotografía se muestra correctamente.
- [ ] La ausencia de fotografía se controla.
- [ ] Las características físicas se muestran.
- [ ] Los campos opcionales ausentes se controlan.
- [ ] La información del extravío se muestra.
- [ ] El contacto público se muestra.
- [ ] El contacto privado se protege.
- [ ] La ausencia de contacto se controla.
- [ ] Los estados se representan correctamente.
- [ ] El modo público no muestra acciones de gestión.
- [ ] El modo de gestión conserva las acciones de estado.
- [ ] El reporte inexistente se controla.
- [ ] La recarga actualiza toda la información.
- [ ] Los casos de prueba están diligenciados.
- [ ] Las evidencias están almacenadas.
- [ ] `flutter analyze` termina sin errores.
- [ ] `flutter test` termina correctamente.
- [ ] La revisión técnica fue completada.
- [ ] El Product Owner confirmó los criterios funcionales.
- [ ] El Pull Request fue fusionado hacia `develop`.

## Evidencias

Las capturas se almacenan en:

```text
docs/evidence/hu8/
```