\# Casos de prueba de HU3



\## CP-HU3-01: Registrar características válidas



\- Condición previa: FastAPI y Flutter están ejecutándose.

\- Datos de entrada:

&#x20; - Nombre: Copito

&#x20; - Especie: Gato

&#x20; - Raza: Criollo

&#x20; - Color: Blanco

&#x20; - Tamaño: Pequeño

&#x20; - Edad aproximada: 2

&#x20; - Señas particulares: Mancha gris en la cola

\- Resultado esperado: Las características se almacenan y aparecen en el detalle del reporte.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 01.png



\## CP-HU3-02: Especie no seleccionada



\- Datos de entrada: Especie sin seleccionar.

\- Resultado esperado: El formulario muestra “Selecciona la especie”.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 02.png



\## CP-HU3-03: Color principal vacío



\- Datos de entrada: Color vacío.

\- Resultado esperado: El formulario indica que el color es obligatorio.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 03.png



\## CP-HU3-04: Tamaño no seleccionado



\- Datos de entrada: Tamaño sin seleccionar.

\- Resultado esperado: El formulario muestra “Selecciona el tamaño”.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 04.png



\## CP-HU3-05: Edad negativa



\- Datos de entrada: Edad aproximada igual a -1.

\- Resultado esperado: El formulario muestra “La edad no puede ser negativa”.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 05.png



\## CP-HU3-06: Campos opcionales vacíos



\- Datos de entrada:

&#x20; - Nombre vacío.

&#x20; - Raza vacía.

&#x20; - Edad vacía.

&#x20; - Señas particulares vacías.

\- Resultado esperado: El formulario permite continuar si los campos obligatorios están completos.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 06.png



\## CP-HU3-07: Persistencia de características



\- Acción: Consultar el reporte después de registrarlo.

\- Resultado esperado: Las características consultadas coinciden con las ingresadas.

\- Resultado obtenido:

\- Estado: Aprobado

\- Evidencia: docs/evidence/hu3/caso 07.png

