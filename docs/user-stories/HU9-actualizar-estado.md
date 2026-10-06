# HU9 - Actualizar el estado de un reporte

## Historia de usuario

Como propietario de una mascota, quiero actualizar el estado de mi reporte para indicar si la mascota continúa extraviada, fue encontrada o si el reporte debe cerrarse.

## Objetivo

Permitir que un reporte activo cambie a un estado final y que la actualización se conserve en PostgreSQL y se refleje inmediatamente en Flutter Web.

## Estados definidos

- Activo.
- Encontrado.
- Cerrado.

## Reglas de negocio

1. Los reportes nuevos se crean en estado `Activo`.
2. Un reporte `Activo` puede pasar a `Encontrado`.
3. Un reporte `Activo` puede pasar a `Cerrado`.
4. Los estados `Encontrado` y `Cerrado` son finales.
5. Un reporte en estado final no puede regresar a `Activo` ni cambiar a otro estado final.
6. Repetir el mismo estado se considera una operación válida sin cambios.
7. Cualquier estado diferente de `Activo`, `Encontrado` o `Cerrado` debe rechazarse.
8. Un identificador inexistente debe producir una respuesta controlada.
9. La autorización real del propietario queda fuera del alcance del Sprint 2 y deberá implementarse en una historia futura.

## Criterios de aceptación

- El backend expone `PATCH /reportes/{reporte_id}/estado`.
- La solicitud recibe el nuevo estado en formato JSON.
- La actualización válida responde con código 200.
- Los estados inválidos responden con código 422.
- Los reportes inexistentes responden con código 404.
- Las transiciones desde estados finales responden con código 409.
- PostgreSQL conserva el nuevo estado.
- El detalle del reporte devuelve el estado actualizado.
- Flutter muestra el estado actual.
- Flutter solicita confirmación antes de cambiar el estado.
- Flutter bloquea los controles durante la operación.
- Flutter actualiza la pantalla después de una respuesta exitosa.
- Las acciones desaparecen cuando el reporte queda en un estado final.
- Los errores se muestran sin cerrar la aplicación.

## Implementación realizada

### Backend

- Se creó el esquema `EstadoReporteUpdate`.
- Se creó el esquema de salida `EstadoReporteOut`.
- Se implementó el endpoint `PATCH /reportes/{reporte_id}/estado`.
- Se controlaron los códigos 200, 404, 409 y 422.
- Se agregó `rollback` ante errores inesperados.
- Se documentó la restricción de estados en PostgreSQL.
- Se agregó la migración faltante de `contacto_reporte`, detectada durante las pruebas de regresión.

### Flutter Web

- Se agregó el método `actualizarEstado` en `ReporteService`.
- Se agregó la sección para actualizar el estado.
- Se implementaron las acciones `Marcar como encontrada` y `Cerrar reporte`.
- Se agregó confirmación antes de enviar la solicitud.
- Se bloquearon los controles durante la actualización.
- Se volvió a consultar el detalle después del cambio.
- Se ocultaron las acciones en estados finales.
- Se conservaron la fotografía y los datos del reporte.

## Resultado

La HU9 fue implementada y validada desde Swagger, Flutter Web y PostgreSQL. Los estados válidos quedaron persistidos y las transiciones inválidas fueron rechazadas correctamente.

## Estado de la historia

Implementada y validada, pendiente de revisión técnica e integración a `develop`.