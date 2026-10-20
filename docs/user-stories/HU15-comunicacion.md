\# HU15 - Comunicación con quien publicó el reporte



\*\*Historia de usuario:\*\* Como usuario quiero comunicarme con la persona que publicó un reporte para intercambiar información sobre una posible coincidencia.



\## Decisión de alcance



HU15 utilizará el contacto seguro de HU5. Si el propietario autorizó visibilidad, la aplicación permitirá llamar, redactar un correo o copiar el dato. Si el contacto es privado, la aplicación mostrará “Contacto privado” y no ofrecerá acciones.



\## Estado del Backend



El backend de HU15 está \*\*100% funcional y listo\*\*. No requiere cambios adicionales, ya que aprovecha el endpoint de consulta de contacto implementado en HU5:



\- `GET /reportes/{reporte\_id}/contacto`



Este endpoint aplica la regla de privacidad automáticamente:

\- Si `mostrar\_publicamente` es `true`: devuelve el `valor\_contacto` real.

\- Si `mostrar\_publicamente` es `false`: devuelve `"Contacto privado"` y no expone el dato real.



\### Ejemplo de respuesta (Contacto Público)

```json

{

&#x20; "tipo\_contacto": "Telefono",

&#x20; "valor\_contacto": "3001234567",

&#x20; "mostrar\_publicamente": true

}

