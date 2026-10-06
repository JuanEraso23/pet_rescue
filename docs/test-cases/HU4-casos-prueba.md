\# Casos de prueba de HU4



\## CP-HU4-01: Información válida del extravío



\- Resultado esperado: La ubicación, fecha y hora se almacenan y muestran correctamente.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 01.png



\## CP-HU4-02: Ubicación vacía



\- Resultado esperado: El formulario indica que la ubicación es obligatoria.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 02.png



\## CP-HU4-03: Fecha no seleccionada



\- Resultado esperado: El formulario solicita seleccionar la fecha.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 03.png



\## CP-HU4-04: Fecha futura



\- Resultado esperado: El formulario no permite seleccionar una fecha futura y la API rechaza una fecha futura enviada manualmente.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 04.png



\## CP-HU4-05: Hora aproximada registrada



\- Resultado esperado: La hora queda almacenada y aparece en el detalle.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 05.png



\## CP-HU4-06: Hora aproximada omitida



\- Resultado esperado: El reporte puede registrarse sin hora y el detalle indica que no fue registrada.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 06.png



\## CP-HU4-07: Persistencia en PostgreSQL



\- Resultado esperado: La ubicación, fecha y hora consultadas coinciden con la información registrada.

\- Resultado obtenido:

\- Estado: Aprobado.

\- Evidencia: docs/evidence/hu4/caso 07.png

