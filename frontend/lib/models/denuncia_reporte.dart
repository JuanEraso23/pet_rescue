class DenunciaReporte {
  final int? id;
  final int reporteId;
  final String motivo;
  final String? descripcion;
  final String estado;
  final DateTime? fechaCreacion;

  DenunciaReporte({
    this.id,
    required this.reporteId,
    required this.motivo,
    this.descripcion,
    this.estado = 'Pendiente',
    this.fechaCreacion,
  });

  factory DenunciaReporte.fromJson(Map<String, dynamic> json) {
    return DenunciaReporte(
      id: json['id'] as int?,
      reporteId: json['reporte_id'] as int,
      motivo: json['motivo'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String? ?? 'Pendiente',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reporte_id': reporteId,
      'motivo': motivo,
      if (descripcion != null && descripcion!.isNotEmpty) 
        'descripcion': descripcion,
    };
  }
}