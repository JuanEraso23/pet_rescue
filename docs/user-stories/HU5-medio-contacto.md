# HU5: Proporcionar un medio de contacto seguro

## Descripción

Como propietario de una mascota extraviada, quiero proporcionar un medio de contacto seguro para que las personas que tengan información sobre la mascota puedan comunicarse conmigo.

## Prioridad

Alta.

## Sprint

Sprint 01.

## Responsable principal

Juan Manuel Eraso Grijalba.

## Apoyo técnico

Jaider Andrés Narváez Cabrera.

## Product Owner

Diego Escobar Enríquez.

## Estado

Done.

## Objetivo

Permitir que el usuario registre un teléfono o un correo electrónico asociado con el reporte de la mascota, indicando si desea que el medio de contacto pueda mostrarse públicamente.

## Alcance

HU5 incluye las siguientes funcionalidades:

- Seleccionar el tipo de contacto.
- Registrar un número telefónico.
- Registrar un correo electrónico.
- Validar el formato del contacto.
- Asociar un único contacto con cada reporte.
- Indicar si el contacto puede mostrarse públicamente.
- Guardar la información en PostgreSQL.
- Consultar el contacto asociado con el reporte.
- Proteger el valor del contacto cuando sea privado.
- Mostrar el medio de contacto en el detalle del reporte.

## Fuera de alcance

HU5 no incluye:

- Chat interno.
- Mensajería instantánea.
- Verificación mediante SMS.
- Verificación automática del correo.
- Integración con WhatsApp.
- Inicio de sesión.
- Perfiles de usuario.
- Cifrado avanzado de datos personales.
- Múltiples contactos para un mismo reporte.

## Campos

### Tipo de contacto

Campo obligatorio.

Valores permitidos:

- `Telefono`
- `Correo`

### Valor del contacto

Campo obligatorio.

Debe contener el número telefónico o correo electrónico correspondiente con el tipo seleccionado.

### Mostrar públicamente

Campo booleano obligatorio.

Valores:

- `true`: el contacto puede mostrarse públicamente.
- `false`: el contacto debe permanecer protegido.

## Criterios de aceptación

1. El usuario puede seleccionar `Telefono` como tipo de contacto.
2. El usuario puede seleccionar `Correo` como tipo de contacto.
3. El usuario debe registrar un valor de contacto.
4. El sistema rechaza valores vacíos o compuestos únicamente por espacios.
5. Cuando el tipo seleccionado es `Telefono`, el sistema acepta únicamente un número válido de entre 7 y 15 dígitos.
6. El teléfono puede contener inicialmente espacios, guiones o el signo más.
7. El sistema normaliza el teléfono antes de almacenarlo.
8. Cuando el tipo seleccionado es `Correo`, el sistema valida que el valor tenga un formato de correo electrónico válido.
9. El correo electrónico se almacena en minúsculas.
10. Cada reporte puede tener un único medio de contacto.
11. El sistema rechaza un segundo contacto asociado con el mismo reporte.
12. El contacto queda asociado con un reporte existente.
13. Si el reporte no existe, el sistema devuelve un error `404`.
14. Si `mostrar_publicamente` es verdadero, el sistema devuelve el valor del contacto.
15. Si `mostrar_publicamente` es falso, el sistema devuelve el texto `Contacto privado`.
16. La información queda almacenada en PostgreSQL.
17. Flutter permite registrar el medio de contacto.
18. El detalle del reporte muestra el tipo y valor público del contacto.
19. El detalle del reporte protege el contacto cuando es privado.
20. La pantalla no falla cuando un reporte todavía no tiene contacto registrado.

## Reglas de negocio

- Cada reporte puede tener como máximo un contacto.
- El contacto debe pertenecer a un reporte existente.
- Un teléfono debe contener entre 7 y 15 dígitos después de su normalización.
- Un correo debe tener un formato válido.
- Los valores permitidos para el tipo de contacto son únicamente `Telefono` y `Correo`.
- Un contacto privado no debe revelar su valor en las consultas públicas.
- La eliminación de un reporte debe eliminar también su contacto asociado.
- No deben utilizarse datos personales reales durante las pruebas.
- El archivo `backend/.env` nunca debe subirse al repositorio.

## Persistencia

La información se almacena en la tabla:

```text
contacto_reporte