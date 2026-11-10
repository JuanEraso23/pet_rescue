class NotificacionCoincidencia {
  final int id;
  final int reporteId;
  final int reporteCoincidenteId;
  final String mensaje;
  final bool leida;
  final DateTime fechaCreacion;

  NotificacionCoincidencia({
    required this.id,
    required this.reporteId,
    required this.reporteCoincidenteId,
    required this.mensaje,
    required this.leida,
    required this.fechaCreacion,
  });

  factory NotificacionCoincidencia.fromJson(Map<String, dynamic> json) {
    return NotificacionCoincidencia(
      id: json['id'] as int,
      reporteId: json['reporte_id'] as int,
      reporteCoincidenteId: json['reporte_coincidente_id'] as int,
      mensaje: json['mensaje'] as String,
      leida: json['leida'] as bool? ?? false,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}