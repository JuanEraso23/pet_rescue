class FotografiaReporte {
  final int id;
  final int reporteId;
  final String nombreArchivo;
  final String url;
  final String tipoMime;
  final int tamanoBytes;
  final DateTime fechaCreacion;

  const FotografiaReporte({
    required this.id,
    required this.reporteId,
    required this.nombreArchivo,
    required this.url,
    required this.tipoMime,
    required this.tamanoBytes,
    required this.fechaCreacion,
  });

  factory FotografiaReporte.fromJson(Map<String, dynamic> json) {
    return FotografiaReporte(
      id: json['id'] as int,
      reporteId: json['reporte_id'] as int,
      nombreArchivo: json['nombre_archivo'] as String,
      url: json['url'] as String,
      tipoMime: json['tipo_mime'] as String,
      tamanoBytes: json['tamano_bytes'] as int,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }

  String get urlCompleta {
    if (url.startsWith('http')) {
      return url;
    }

    return 'http://127.0.0.1:8000$url';
  }
}
