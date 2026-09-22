\# Casos de prueba de HU5



\## Información general



\- Historia: HU5, proporcionar un medio de contacto seguro.

\- Sprint: Sprint 01.

\- Responsable de ejecución: Juan Manuel Eraso Grijalba.

\- Product Owner: Diego Escobar Enríquez.

\- Base de datos: PostgreSQL.

\- Backend: FastAPI.

\- Frontend: Flutter Web.

\- Estado general: En ejecución.



\---



\## CP-HU5-01: Registrar un teléfono público válido



\### Condiciones previas



\- FastAPI está ejecutándose.

\- PostgreSQL está disponible.

\- Existe un reporte sin contacto.

\- La tabla `contacto\_reporte` existe.



\### Datos de entrada



```json

{

&#x20; "tipo\_contacto": "Telefono",

&#x20; "valor\_contacto": "300 123-4567",

&#x20; "mostrar\_publicamente": true

}

``

