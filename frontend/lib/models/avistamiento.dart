class Avistamiento {
  final int id;
  final int reporteId;
  final String descripcion;
  final String ubicacionAproximada;
  final String fechaAvistamiento;
  final String? horaAvistamiento;
  final DateTime fechaCreacion;

  const Avistamiento({
    required this.id,
    required this.reporteId,
    required this.descripcion,
    required this.ubicacionAproximada,
    required this.fechaAvistamiento,
    required this.horaAvistamiento,
    required this.fechaCreacion,
  });

  factory Avistamiento.fromJson(Map<String, dynamic> json) {
    return Avistamiento(
      id: json['id'] as int,
      reporteId: json['reporte_id'] as int,
      descripcion: json['descripcion'] as String,
      ubicacionAproximada: json['ubicacion_aproximada'] as String,
      fechaAvistamiento: json['fecha_avistamiento'] as String,
      horaAvistamiento: json['hora_avistamiento'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }
}
