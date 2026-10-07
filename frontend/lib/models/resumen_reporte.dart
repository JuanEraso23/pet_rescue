class ResumenReporte {
  static const String baseUrl = 'http://127.0.0.1:8000';

  final int id;
  final String codigo;
  final String titulo;
  final String estado;
  final String? nombreMascota;
  final String especie;
  final String ubicacionExtravio;
  final String fechaExtravio;
  final DateTime fechaCreacion;
  final String? fotografiaUrl;

  const ResumenReporte({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.estado,
    required this.nombreMascota,
    required this.especie,
    required this.ubicacionExtravio,
    required this.fechaExtravio,
    required this.fechaCreacion,
    required this.fotografiaUrl,
  });

  String? get fotografiaUrlCompleta {
    final url = fotografiaUrl;

    if (url == null || url.isEmpty) {
      return null;
    }

    if (url.startsWith('http')) {
      return url;
    }

    return '$baseUrl$url';
  }

  factory ResumenReporte.fromJson(Map<String, dynamic> json) {
    return ResumenReporte(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      estado: json['estado'] as String,
      nombreMascota: json['nombre_mascota'] as String?,
      especie: json['especie'] as String,
      ubicacionExtravio: json['ubicacion_extravio'] as String,
      fechaExtravio: json['fecha_extravio'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fotografiaUrl: json['fotografia_url'] as String?,
    );
  }
}
