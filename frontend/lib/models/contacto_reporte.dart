class ContactoReporte {
  final String tipoContacto;
  final String valorContacto;
  final bool mostrarPublicamente;

  const ContactoReporte({
    required this.tipoContacto,
    required this.valorContacto,
    required this.mostrarPublicamente,
  });

  factory ContactoReporte.fromJson(Map<String, dynamic> json) {
    return ContactoReporte(
      tipoContacto: json['tipo_contacto'] as String,
      valorContacto: json['valor_contacto'] as String,
      mostrarPublicamente: json['mostrar_publicamente'] as bool,
    );
  }
}
