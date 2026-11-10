class ReportePrincipalResumen {
  final int id;
  final String codigo;
  final String titulo;
  final String estado;
  final String estadoRevision;
  final String estadoGestion;
  final String? nombreMascota;
  final String especie;

  const ReportePrincipalResumen({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.estado,
    required this.estadoRevision,
    required this.estadoGestion,
    required this.nombreMascota,
    required this.especie,
  });

  factory ReportePrincipalResumen.fromJson(Map<String, dynamic> json) {
    return ReportePrincipalResumen(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      estado: json['estado'] as String,
      estadoRevision: json['estado_revision'] as String,
      estadoGestion: json['estado_gestion'] as String,
      nombreMascota: json['nombre_mascota'] as String?,
      especie: json['especie'] as String,
    );
  }

  String get descripcionSelector {
    final mascota = nombreMascota?.trim().isNotEmpty == true
        ? nombreMascota!.trim()
        : 'Sin nombre';

    return '$codigo · $mascota · $especie';
  }
}

class ResultadoGestionReporte {
  final int id;
  final String codigo;
  final String estadoGestion;

  final int? reportePrincipalId;
  final String? codigoReportePrincipal;

  final String? motivoGestion;
  final DateTime? fechaGestion;

  final String mensaje;

  const ResultadoGestionReporte({
    required this.id,
    required this.codigo,
    required this.estadoGestion,
    required this.reportePrincipalId,
    required this.codigoReportePrincipal,
    required this.motivoGestion,
    required this.fechaGestion,
    required this.mensaje,
  });

  factory ResultadoGestionReporte.fromJson(Map<String, dynamic> json) {
    return ResultadoGestionReporte(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      estadoGestion: json['estado_gestion'] as String,
      reportePrincipalId: json['reporte_principal_id'] as int?,
      codigoReportePrincipal: json['codigo_reporte_principal'] as String?,
      motivoGestion: json['motivo_gestion'] as String?,
      fechaGestion: _fechaOpcional(json['fecha_gestion']),
      mensaje: json['mensaje'] as String,
    );
  }
}

DateTime? _fechaOpcional(dynamic valor) {
  if (valor is! String || valor.isEmpty) {
    return null;
  }

  return DateTime.tryParse(valor);
}
