class ReporteAdminResumen {
  final int id;
  final String codigo;
  final String titulo;
  final String estado;
  final String estadoRevision;
  final String? nombreMascota;
  final String especie;
  final String ubicacionExtravio;
  final String fechaExtravio;
  final DateTime fechaCreacion;
  final DateTime? fechaRevision;

  const ReporteAdminResumen({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.estado,
    required this.estadoRevision,
    required this.nombreMascota,
    required this.especie,
    required this.ubicacionExtravio,
    required this.fechaExtravio,
    required this.fechaCreacion,
    required this.fechaRevision,
  });

  factory ReporteAdminResumen.fromJson(Map<String, dynamic> json) {
    return ReporteAdminResumen(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      estado: json['estado'] as String,
      estadoRevision: json['estado_revision'] as String,
      nombreMascota: json['nombre_mascota'] as String?,
      especie: json['especie'] as String,
      ubicacionExtravio: json['ubicacion_extravio'] as String,
      fechaExtravio: json['fecha_extravio'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaRevision: _fechaOpcional(json['fecha_revision']),
    );
  }
}

class ReporteAdminDetalle {
  final int id;
  final String codigo;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String estado;
  final String estadoRevision;

  final String ubicacionExtravio;
  final String fechaExtravio;
  final DateTime fechaCreacion;

  final DateTime? fechaRevision;
  final String? observacionRevision;

  final String? nombreMascota;
  final String especie;
  final String? raza;
  final String color;
  final String tamano;
  final int? edadAproximada;
  final String? senasParticulares;

  const ReporteAdminDetalle({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.estado,
    required this.estadoRevision,
    required this.ubicacionExtravio,
    required this.fechaExtravio,
    required this.fechaCreacion,
    required this.fechaRevision,
    required this.observacionRevision,
    required this.nombreMascota,
    required this.especie,
    required this.raza,
    required this.color,
    required this.tamano,
    required this.edadAproximada,
    required this.senasParticulares,
  });

  factory ReporteAdminDetalle.fromJson(Map<String, dynamic> json) {
    return ReporteAdminDetalle(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
      estadoRevision: json['estado_revision'] as String,
      ubicacionExtravio: json['ubicacion_extravio'] as String,
      fechaExtravio: json['fecha_extravio'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaRevision: _fechaOpcional(json['fecha_revision']),
      observacionRevision: json['observacion_revision'] as String?,
      nombreMascota: json['nombre_mascota'] as String?,
      especie: json['especie'] as String,
      raza: json['raza'] as String?,
      color: json['color'] as String,
      tamano: json['tamano'] as String,
      edadAproximada: json['edad_aproximada'] as int?,
      senasParticulares: json['senas_particulares'] as String?,
    );
  }
}

class ResultadoRevisionReporte {
  final int id;
  final String codigo;
  final String estadoRevision;
  final DateTime fechaRevision;
  final String? observacionRevision;
  final String mensaje;

  const ResultadoRevisionReporte({
    required this.id,
    required this.codigo,
    required this.estadoRevision,
    required this.fechaRevision,
    required this.observacionRevision,
    required this.mensaje,
  });

  factory ResultadoRevisionReporte.fromJson(Map<String, dynamic> json) {
    return ResultadoRevisionReporte(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      estadoRevision: json['estado_revision'] as String,
      fechaRevision: DateTime.parse(json['fecha_revision'] as String),
      observacionRevision: json['observacion_revision'] as String?,
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
