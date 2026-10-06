# Casos de prueba HU2

## Información general

- Proyecto: Pet Rescue
- Sprint: Sprint 01
- Historia de usuario: HU2 - Agregar fotografías recientes
- Responsable: Diego Escobar Enríquez
- Rama: feature/hu2-fotografias
- Fecha de ejecución: 22/09/2026
- Documento de evidencias: `docs/evidence/hu2/Evidencias.docx`

## Objetivo

Comprobar que el sistema permita seleccionar, previsualizar, retirar, cargar, almacenar y consultar una fotografía asociada a un reporte de mascota extraviada.

## Condiciones generales

- El backend de FastAPI debe estar disponible en `http://127.0.0.1:8000`.
- Flutter Web debe estar disponible en `http://127.0.0.1:8080`.
- PostgreSQL debe estar en funcionamiento.
- Debe existir al menos un reporte registrado.
- Los formatos permitidos son JPG, JPEG, PNG y WebP.
- El tamaño máximo permitido es de 5 MB.
- Las imágenes utilizadas deben ser archivos de prueba sin información personal.

---

## CP-HU2-01 - Cargar una imagen JPG válida

**Objetivo:** Verificar que el sistema permita seleccionar y cargar una imagen JPG válida.

**Precondiciones:**

- El backend y Flutter Web se encuentran en ejecución.
- El usuario tiene acceso al formulario de registro.

**Datos de prueba:**

- Imagen JPG menor de 5 MB.

**Pasos:**

1. Ingresar al formulario para registrar una mascota perdida.
2. Presionar el botón "Seleccionar fotografía".
3. Seleccionar una imagen JPG menor de 5 MB.
4. Comprobar que aparezca la vista previa.
5. Completar los campos obligatorios.
6. Presionar "Publicar reporte".
7. Abrir el detalle del reporte.

**Resultado esperado:**

El sistema crea el reporte, carga la fotografía JPG y la muestra correctamente en el detalle.

**Resultado obtenido:**

La imagen JPG fue seleccionada y previsualizada correctamente. Después de publicar el reporte, la fotografía fue enviada al backend, almacenada y mostrada en el detalle.

**Estado:** APROBADO

**Evidencia:** Prueba de carga de imagen JPG incluida en `Evidencias.docx`.

**Observaciones:** La fotografía quedó asociada al reporte correspondiente y se almacenó con un nombre único.

---

## CP-HU2-02 - Cargar una imagen PNG válida

**Objetivo:** Verificar que el sistema permita cargar una imagen PNG válida.

**Precondiciones:**

- El sistema se encuentra disponible.
- El usuario tiene acceso al formulario.

**Datos de prueba:**

- Imagen PNG menor de 5 MB.

**Pasos:**

1. Abrir el formulario de registro.
2. Seleccionar una imagen PNG menor de 5 MB.
3. Comprobar la vista previa.
4. Completar los campos obligatorios.
5. Publicar el reporte.
6. Abrir el detalle.

**Resultado esperado:**

El reporte se crea correctamente y la imagen PNG aparece en el detalle.

**Resultado obtenido:**

La imagen PNG fue seleccionada, previsualizada, enviada y mostrada correctamente en el detalle del reporte.

**Estado:** APROBADO

**Evidencia:** Selección, vista previa, publicación y detalle incluidos en `Evidencias.docx`.

**Observaciones:** La fotografía quedó asociada correctamente al reporte y sus metadatos se almacenaron en PostgreSQL.

---

## CP-HU2-03 - Rechazar un archivo que no sea imagen

**Objetivo:** Comprobar que el sistema rechace formatos no permitidos.

**Precondiciones:**

- El formulario de registro se encuentra disponible.

**Datos de prueba:**

- Archivo PDF, TXT u otro formato diferente de JPG, JPEG, PNG o WebP.

**Pasos:**

1. Presionar el botón "Seleccionar fotografía".
2. Intentar seleccionar un archivo no permitido.
3. Observar la respuesta del selector o del sistema.
4. Comprobar que el archivo no quede seleccionado.
5. Verificar que no aparezca una vista previa.

**Resultado esperado:**

El selector no permite seleccionar el archivo o el sistema muestra un mensaje indicando que únicamente se permiten imágenes JPG, PNG o WebP.

**Resultado obtenido:**

El selector limitó los archivos disponibles a los formatos permitidos y no permitió seleccionar el archivo con formato inválido. El archivo no quedó cargado y no apareció ninguna vista previa.

**Estado:** APROBADO

**Evidencia:** Validación de formato incluida en `Evidencias.docx`.

**Observaciones:** El filtro de extensiones funcionó correctamente y evitó el envío de archivos no permitidos.

---

## CP-HU2-04 - Rechazar una imagen mayor de 5 MB

**Objetivo:** Verificar que el sistema rechace fotografías que superen el tamaño máximo permitido.

**Precondiciones:**

- El formulario de registro se encuentra disponible.

**Datos de prueba:**

- Imagen JPG, PNG o WebP mayor de 5 MB.

**Pasos:**

1. Presionar el botón "Seleccionar fotografía".
2. Seleccionar una imagen que supere los 5 MB.
3. Observar el mensaje presentado.
4. Comprobar que no aparezca la vista previa.
5. Verificar que la imagen no sea enviada al backend.

**Resultado esperado:**

El sistema muestra que la fotografía no puede superar los 5 MB y no conserva la selección.

**Resultado obtenido:**

El sistema detectó que la fotografía superaba los 5 MB, mostró el mensaje de validación y no conservó el archivo seleccionado.

**Estado:** APROBADO

**Evidencia:** Validación de tamaño incluida en `Evidencias.docx`.

**Observaciones:** La imagen no fue previsualizada, enviada ni registrada en PostgreSQL.

---

## CP-HU2-05 - Consultar las fotografías de un reporte

**Objetivo:** Comprobar que el endpoint GET devuelva la fotografía asociada a un reporte.

**Precondiciones:**

- Existe un reporte con una fotografía registrada.
- FastAPI se encuentra en ejecución.

**Datos de prueba:**

- Identificador de un reporte con fotografía asociada.

**Pasos:**

1. Abrir Swagger en `http://127.0.0.1:8000/docs`.
2. Ejecutar `GET /reportes/{reporte_id}/fotografias`.
3. Ingresar el identificador del reporte.
4. Revisar el código y el cuerpo de la respuesta.

**Resultado esperado:**

El endpoint responde con código 200 y devuelve la información de la fotografía, incluyendo la URL, el tipo MIME, el tamaño y la fecha de creación.

**Resultado obtenido:**

El endpoint respondió con código 200 y devolvió correctamente la fotografía asociada al reporte, junto con sus metadatos y la URL de acceso.

**Estado:** APROBADO

**Evidencia:** Respuesta del endpoint GET incluida en `Evidencias.docx`.

**Observaciones:** La URL devuelta permitió consultar el archivo guardado desde el navegador.

---

## CP-HU2-06 - Visualizar la fotografía en Flutter

**Objetivo:** Verificar que Flutter muestre la fotografía en el detalle del reporte.

**Precondiciones:**

- Existe un reporte con una fotografía asociada.
- El backend y Flutter Web están disponibles.

**Datos de prueba:**

- Reporte PR-0003 con fotografía asociada.

**Pasos:**

1. Abrir la pantalla de confirmación del reporte.
2. Presionar el botón "Ver reporte".
3. Esperar la carga del detalle.
4. Revisar la sección "Fotografía reciente".
5. Comprobar que los demás datos del reporte continúen visibles.

**Resultado esperado:**

La fotografía aparece correctamente en la sección correspondiente y la pantalla continúa mostrando la descripción, las características y la información del extravío.

**Resultado obtenido:**

La fotografía apareció correctamente en el detalle del reporte PR-0003 y los demás datos del reporte continuaron visibles.

**Estado:** APROBADO

**Evidencia:** Pantalla de detalle del reporte PR-0003 incluida en `Evidencias.docx`.

**Observaciones:** La imagen fue cargada mediante la URL proporcionada por el backend y no afectó el funcionamiento de la pantalla.

---

## CP-HU2-07 - Consultar un reporte inexistente

**Objetivo:** Verificar la respuesta del backend cuando se utiliza un identificador de reporte inexistente.

**Precondiciones:**

- FastAPI se encuentra disponible.

**Datos de prueba:**

- `reporte_id = 99999`.

**Pasos:**

1. Abrir Swagger.
2. Ejecutar `GET /reportes/99999/fotografias`.
3. Revisar el código de estado.
4. Revisar el cuerpo de la respuesta.

**Resultado esperado:**

El backend responde con código 404 y muestra el mensaje "Reporte no encontrado."

**Resultado obtenido:**

El backend respondió con código 404 y mostró el mensaje "Reporte no encontrado."

**Estado:** APROBADO

**Evidencia:** Respuesta 404 incluida en `Evidencias.docx`.

**Observaciones:** No se creó ningún archivo ni registro adicional en PostgreSQL.

---

## CP-HU2-08 - Retirar una fotografía antes de publicar

**Objetivo:** Verificar que el usuario pueda retirar una fotografía seleccionada antes de publicar el reporte.

**Precondiciones:**

- El formulario de registro se encuentra abierto.
- El usuario tiene una imagen válida disponible.

**Datos de prueba:**

- Imagen JPG, PNG o WebP menor de 5 MB.

**Pasos:**

1. Seleccionar una fotografía válida.
2. Comprobar que aparezca la vista previa.
3. Presionar el botón con el icono de eliminar.
4. Revisar nuevamente la sección de fotografía.
5. Comprobar que la vista previa desaparezca.
6. Publicar el reporte sin volver a seleccionar una imagen.
7. Abrir el detalle del reporte.

**Resultado esperado:**

La vista previa desaparece, el archivo retirado no se envía al backend y el detalle muestra el mensaje "Fotografía pendiente".

**Resultado obtenido:**

La fotografía seleccionada fue retirada correctamente, la vista previa desapareció y el archivo no fue enviado al backend. El reporte pudo publicarse sin fotografía.

**Estado:** APROBADO

**Evidencia:** Prueba de retiro de selección incluida en `Evidencias.docx`.

**Observaciones:** No se creó un registro de fotografía para el archivo retirado.

---

# Resumen de ejecución

| Caso | Descripción | Estado |
|---|---|---|
| CP-HU2-01 | Cargar una imagen JPG válida | APROBADO |
| CP-HU2-02 | Cargar una imagen PNG válida | APROBADO |
| CP-HU2-03 | Rechazar un archivo que no sea imagen | APROBADO |
| CP-HU2-04 | Rechazar una imagen mayor de 5 MB | APROBADO |
| CP-HU2-05 | Consultar las fotografías de un reporte | APROBADO |
| CP-HU2-06 | Visualizar la fotografía en Flutter | APROBADO |
| CP-HU2-07 | Consultar un reporte inexistente | APROBADO |
| CP-HU2-08 | Retirar una fotografía antes de publicar | APROBADO |

## Resultado general

- Casos aprobados: 8
- Casos no aprobados: 0
- Casos bloqueados: 0
- Casos pendientes: 0
- Total de casos ejecutados: 8

## Comprobaciones técnicas realizadas

- `flutter analyze`: aprobado, sin problemas encontrados.
- `flutter test`: aprobado, todas las pruebas superadas.
- Compilación de `app/main.py`: aprobada.
- Compilación de `app/models/fotografia_reporte.py`: aprobada.
- Compilación de `app/schemas/fotografia_reporte.py`: aprobada.
- Compilación de `app/api/fotografias.py`: aprobada.
- Conexión con PostgreSQL: aprobada.
- Almacenamiento local de archivos: aprobado.
- Registro de metadatos en PostgreSQL: aprobado.
- Consulta de fotografías mediante FastAPI: aprobada.
- Visualización de la fotografía en Flutter Web: aprobada.

## Conclusión

La HU2 fue implementada y validada correctamente. El sistema permite seleccionar fotografías JPG, JPEG, PNG y WebP, mostrar una vista previa, retirar la selección antes de publicar y validar un tamaño máximo de 5 MB.

Después de crear el reporte, la fotografía es enviada al backend mediante `multipart/form-data`, guardada localmente con un nombre único y registrada en PostgreSQL. El sistema también permite consultar las fotografías asociadas y mostrar la imagen en el detalle del reporte.

Los ocho casos de prueba fueron ejecutados y aprobados. No se encontraron casos fallidos, bloqueados ni pendientes. Por lo tanto, la HU2 cumple con los criterios funcionales definidos para el Sprint 01.