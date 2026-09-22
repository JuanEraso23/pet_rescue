\# HU4: Registrar información del extravío



\## Descripción



Como propietario de una mascota, quiero indicar el lugar, la fecha y la hora aproximada del extravío para delimitar la zona y el periodo de búsqueda.



\## Prioridad



Alta.



\## Sprint



Sprint 01.



\## Estado



Done.



\## Criterios de aceptación



1\. El usuario debe registrar una ubicación aproximada.

2\. El usuario debe seleccionar la fecha del extravío.

3\. La fecha del extravío no puede ser posterior a la fecha actual.

4\. El usuario puede registrar una hora aproximada.

5\. La hora aproximada puede omitirse.

6\. El sistema rechaza el formulario si falta la ubicación.

7\. El sistema rechaza el formulario si falta la fecha.

8\. La información del extravío queda almacenada en PostgreSQL.

9\. La ubicación, fecha y hora aparecen en el detalle del reporte.



\## Campos obligatorios



\- Ubicación aproximada.

\- Fecha del extravío.



\## Campos opcionales



\- Hora aproximada.



\## Reglas



\- No se debe solicitar una dirección residencial exacta.

\- La ubicación publicada debe ser aproximada.

\- La fecha no puede ser futura.

