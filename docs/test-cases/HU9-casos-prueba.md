# Casos de prueba HU9

## Información general

- Proyecto: Pet Rescue
- Sprint: Sprint 2
- Historia de usuario: HU9 - Actualizar el estado de un reporte
- Responsable: Diego Escobar Enríquez
- Rama: `feature/hu9-actualizar-estado`
- Fecha de ejecución: 06/10/2026
- Documento de evidencias: `docs/evidence/hu9/`

## Objetivo

Comprobar que el sistema permita actualizar el estado de un reporte desde `Activo` hacia `Encontrado` o `Cerrado`, persista el cambio y rechace valores o transiciones no permitidas.

## Condiciones generales

- FastAPI disponible en `http://127.0.0.1:8000`.
- Flutter Web disponible en `http://127.0.0.1:8080`.
- PostgreSQL en funcionamiento.
- Reportes de prueba disponibles.
- Estados permitidos: `Activo`, `Encontrado` y `Cerrado`.

---

## CP-HU9-01 - Actualizar de Activo a Encontrado

**Resultado esperado:** El backend responde con código 200, guarda `Encontrado` y el detalle refleja el nuevo estado.

**Resultado obtenido:** El reporte fue actualizado correctamente a `Encontrado`, el detalle devolvió el nuevo valor y PostgreSQL conservó el cambio.

**Estado:** APROBADO

**Evidencia:** `01-encontrado-swagger.png`, `02-detalle-encontrado.png` y `13-encontrado-postgresql.png`.

**Observaciones:** No aplica.

---

## CP-HU9-02 - Actualizar de Activo a Cerrado

**Resultado esperado:** El backend responde con código 200 y guarda `Cerrado`.

**Resultado obtenido:** El reporte fue actualizado correctamente a `Cerrado` y el valor quedó persistido.

**Estado:** APROBADO

**Evidencia:** `03-cerrado-swagger.png`, `15-cerrado-flutter.png` y `16-estados-finales-postgresql.png`.

**Observaciones:** No aplica.

---

## CP-HU9-03 - Repetir el mismo estado

**Resultado esperado:** La operación responde con código 200 sin modificar nuevamente el reporte.

**Resultado obtenido:** El backend mantuvo `Cerrado` y mostró que el reporte ya se encontraba en el estado solicitado.

**Estado:** APROBADO

**Evidencia:** `04-estado-repetido.png`.

**Observaciones:** La operación se comportó de forma idempotente.

---

## CP-HU9-04 - Rechazar un estado inválido

**Resultado esperado:** Un estado diferente de los permitidos genera código 422.

**Resultado obtenido:** El valor `Perdido` fue rechazado con código 422 y se mostraron los estados permitidos.

**Estado:** APROBADO

**Evidencia:** `06-estado-invalido.png`.

**Observaciones:** La validación ocurrió antes de ejecutar la lógica del endpoint.

---

## CP-HU9-05 - Consultar un reporte inexistente

**Resultado esperado:** El identificador `99999` genera código 404.

**Resultado obtenido:** El backend respondió con código 404 y el mensaje `Reporte no encontrado.`

**Estado:** APROBADO

**Evidencia:** `07-reporte-inexistente.png`.

**Observaciones:** No se creó ni modificó ningún registro.

---

## CP-HU9-06 - Rechazar transición desde un estado final

**Resultado esperado:** Un reporte en `Encontrado` o `Cerrado` no puede regresar a `Activo`.

**Resultado obtenido:** El intento de cambiar `Encontrado` a `Activo` fue rechazado con código 409.

**Estado:** APROBADO

**Evidencia:** `05-transicion-no-permitida.png`.

**Observaciones:** Los estados finales quedaron protegidos.

---

## CP-HU9-07 - Persistencia en PostgreSQL

**Resultado esperado:** Los cambios realizados desde Swagger y Flutter permanecen almacenados.

**Resultado obtenido:** PostgreSQL mostró los reportes correspondientes en `Encontrado` y `Cerrado`.

**Estado:** APROBADO

**Evidencia:** `08-estado-postgresql.png`, `13-encontrado-postgresql.png` y `16-estados-finales-postgresql.png`.

**Observaciones:** Los intentos rechazados no alteraron los registros.

---

## CP-HU9-08 - Actualizar desde Flutter Web

**Resultado esperado:** Flutter solicita confirmación, envía el cambio, actualiza el chip y elimina las acciones cuando el estado es final.

**Resultado obtenido:** Flutter presentó la confirmación, actualizó el estado, volvió a consultar el reporte, conservó la fotografía y ocultó las acciones.

**Estado:** APROBADO

**Evidencia:** `09-reporte-activo-flutter.png`, `10-confirmacion-encontrado.png`, `11-encontrado-flutter.png`, `12-flujo-fastapi-flutter.png`, `14-confirmacion-cerrado.png` y `15-cerrado-flutter.png`.

**Observaciones:** Se probaron los dos estados finales.

---

## CP-HU9-09 - Conservar funcionalidades anteriores

**Resultado esperado:** Las funcionalidades de fotografía y contacto continúan disponibles después de integrar HU9.

**Resultado obtenido:** La fotografía siguió visible, la consulta sin contacto respondió de forma controlada y se comprobó la creación y consulta de un contacto.

**Estado:** APROBADO

**Evidencia:** Capturas del detalle y pruebas de regresión ejecutadas en Swagger.

**Observaciones:** Se agregó la migración faltante de `contacto_reporte`.

---

## CP-HU9-10 - Comprobaciones técnicas

**Resultado esperado:** La aplicación debe compilar y superar el análisis y las pruebas automatizadas.

**Resultado obtenido:** Los archivos Python compilaron, `flutter analyze` terminó sin problemas y `flutter test` informó que todas las pruebas fueron superadas.

**Estado:** APROBADO

**Evidencia:** `17-flutter-analyze-test.png`.

**Observaciones:** Los avisos de versiones disponibles no representan errores.

---

# Resumen de ejecución

| Caso | Estado |
|---|---|
| CP-HU9-01 | APROBADO |
| CP-HU9-02 | APROBADO |
| CP-HU9-03 | APROBADO |
| CP-HU9-04 | APROBADO |
| CP-HU9-05 | APROBADO |
| CP-HU9-06 | APROBADO |
| CP-HU9-07 | APROBADO |
| CP-HU9-08 | APROBADO |
| CP-HU9-09 | APROBADO |
| CP-HU9-10 | APROBADO |

## Resultado general

- Casos aprobados: 10
- Casos no aprobados: 0
- Casos bloqueados: 0
- Casos pendientes: 0
- Total ejecutado: 10

## Conclusión

La HU9 cumple con los criterios funcionales definidos para el Sprint 2. El estado puede actualizarse desde Flutter Web, se conserva en PostgreSQL y las transiciones inválidas se controlan correctamente. La historia queda pendiente únicamente de revisión técnica y merge hacia `develop`.