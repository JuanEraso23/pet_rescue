# Casos de prueba de HU8

## Información general

- Historia: HU8, consultar el detalle público de un reporte.
- Sprint: Sprint 2.
- Responsable de ejecución: Juan Manuel Eraso Grijalba.
- Product Owner: Diego Escobar Enríquez.
- Backend: FastAPI.
- Frontend: Flutter Web.
- Base de datos: PostgreSQL.
- Estado general: En ejecución.

---

## CP-HU8-01: Consultar un detalle público completo

### Condiciones previas

- FastAPI está ejecutándose.
- Flutter Web está ejecutándose.
- PostgreSQL está disponible.
- Existe un reporte con todos los datos registrados.

### Pasos

1. Abrir el detalle público.
2. Esperar la carga de la información.
3. Revisar cada sección de la pantalla.

### Resultado esperado

El detalle muestra:

- Código.
- Tipo.
- Estado.
- Fecha de publicación.
- Título.
- Fotografía.
- Descripción.
- Características físicas.
- Información del extravío.
- Medio de contacto.


---

## CP-HU8-02: Consultar un reporte sin fotografía

### Condiciones previas

- Existe un reporte sin fotografía.

### Pasos

1. Abrir el detalle.
2. Revisar la sección `Fotografía reciente`.

### Resultado esperado

El sistema muestra:

```text
Fotografía pendiente
```

La pantalla no presenta errores.


---

## CP-HU8-03: Mostrar un contacto público

### Condiciones previas

- Existe un reporte con contacto público.

### Resultado esperado

El detalle muestra:

- Tipo de contacto.
- Valor completo.
- Visibilidad `Publico`.


---

## CP-HU8-04: Proteger un contacto privado

### Condiciones previas

- Existe un reporte con `mostrar_publicamente` en `false`.

### Resultado esperado

El detalle muestra:

```text
Contacto privado
```

La visibilidad aparece como:

```text
Privado
```

El teléfono o correo real no aparece.


---

## CP-HU8-05: Consultar un reporte sin contacto

### Condiciones previas

- Existe un reporte sin contacto asociado.

### Resultado esperado

El detalle muestra:

```text
Medio de contacto no registrado
```

La pantalla continúa funcionando.

---

## CP-HU8-06: Mostrar campos opcionales ausentes

### Condiciones previas

Existe un reporte sin uno o varios de estos datos:

- Nombre.
- Raza.
- Edad aproximada.
- Señas particulares.
- Hora del extravío.

### Resultado esperado

El detalle reemplaza los valores ausentes por textos controlados:

```text
No registrado
No registrada
No registradas
```

No aparece `null`.


---

## CP-HU8-07: Consultar un reporte inexistente

### Datos de entrada

```text
reporte_id = 99999
```

### Pasos

1. Solicitar el detalle del reporte inexistente.
2. Revisar la respuesta del backend o la pantalla de error.

### Resultado esperado

- FastAPI devuelve `404 Not Found`.
- Flutter muestra un mensaje controlado.
- La pantalla permite reintentar.
- La aplicación no se cierra.


---

## CP-HU8-08: Mostrar un reporte encontrado

### Condiciones previas

- Existe un reporte con estado `Encontrado`.

### Resultado esperado

- El chip muestra `Encontrado`.
- Se utiliza el color e icono correspondientes.
- El sistema indica que el reporte está en un estado final.
- En modo gestión, las acciones dejan de estar disponibles.


---

## CP-HU8-09: Mostrar un reporte cerrado

### Condiciones previas

- Existe un reporte con estado `Cerrado`.

### Resultado esperado

- El chip muestra `Cerrado`.
- Se utiliza el color e icono correspondientes.
- El sistema indica que el reporte está en un estado final.
- No se muestran acciones adicionales de actualización.


---

## CP-HU8-10: Diferenciar el modo público y el modo de gestión

### Prueba del modo público

Abrir el detalle mediante:

```dart
DetalleReporteScreen(
  reporteId: reporteId,
)
```

### Resultado esperado del modo público

- Se muestra `Información pública del reporte`.
- No aparecen botones para cambiar el estado.
- La información pública continúa visible.

### Prueba del modo de gestión

Abrir el detalle mediante:

```dart
DetalleReporteScreen(
  reporteId: reporte.id,
  permitirGestion: true,
)
```

### Resultado esperado del modo de gestión

- Se muestra `Vista del reporte publicado`.
- Si el estado es `Activo`, aparecen las acciones de actualización.
- Si el estado es final, aparece la indicación correspondiente.

---

## CP-HU8-11: Actualizar la información mediante deslizamiento

### Pasos

1. Abrir el detalle.
2. Realizar el gesto de actualización.
3. Esperar la recarga.

### Resultado esperado

Se vuelven a consultar:

- Reporte.
- Estado.
- Fotografías.
- Medio de contacto.

La pantalla conserva la información y no presenta errores.


---

## CP-HU8-12: Verificar diseño adaptable

### Pasos

1. Abrir el detalle en una ventana amplia.
2. Reducir el ancho de la ventana.
3. Revisar chips, tarjetas, textos e imágenes.

### Resultado esperado

- No existen desbordamientos.
- Los chips cambian de línea mediante `Wrap`.
- Los textos permanecen legibles.
- Las secciones conservan su estructura.
- La fotografía se ajusta al espacio disponible.


---

## Comprobaciones técnicas

### Flutter Analyze

Comando:

```powershell
flutter analyze
```

Resultado obtenido:

```text
No issues found!
```

Estado:

```text
Aprobado
```

### Flutter Test

Comando:

```powershell
flutter test
```

Resultado obtenido:

```text
All tests passed!
```

Estado:

```text
Aprobado
```

---

## Resumen de resultados

- Casos aprobados: Pendiente de consolidación.
- Casos fallidos: Pendiente de consolidación.
- Casos bloqueados: Pendiente de consolidación.
- Errores críticos: Ninguno identificado.
- Estado de HU8: En ejecución.

## Evidencias

Las capturas se almacenan en:

```text
docs/evidence/hu8/
```

## Criterio de aprobación

HU8 puede considerarse aprobada cuando:

- El detalle público reúne la información requerida.
- La fotografía se muestra o se controla su ausencia.
- Los campos opcionales no generan errores.
- Los contactos públicos se muestran.
- Los contactos privados permanecen protegidos.
- Los reportes inexistentes se controlan.
- Los estados se representan correctamente.
- El modo público no muestra acciones de gestión.
- El modo de gestión conserva las acciones correspondientes.
- Las pruebas técnicas terminan sin errores.
- Las evidencias están disponibles.
- El Product Owner valida el resultado.