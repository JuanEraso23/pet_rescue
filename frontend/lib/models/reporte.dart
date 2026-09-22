class ReporteCreado {
  final int id;
  final String codigo;
  final String estado;
  final DateTime fechaCreacion;
  final String mensaje;

  const ReporteCreado({
    required this.id,
    required this.codigo,
    required this.estado,
    required this.fechaCreacion,
    required this.mensaje,
  });

  factory ReporteCreado.fromJson(Map<String, dynamic> json) {
    return ReporteCreado(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      estado: json['estado'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      mensaje: json['mensaje'] as String,
    );
  }
}

class DetalleReporte {
  final int id;
  final String codigo;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String estado;
  final String ubicacionExtravio;
  final String fechaExtravio;
  final String? horaExtravio;
  final String? nombreMascota;
  final String especie;
  final String? raza;
  final String color;
  final String tamano;
  final int? edadAproximada;
  final String? senasParticulares;

  const DetalleReporte({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.estado,
    required this.ubicacionExtravio,
    required this.fechaExtravio,
    required this.horaExtravio,
    required this.nombreMascota,
    required this.especie,
    required this.raza,
    required this.color,
    required this.tamano,
    required this.edadAproximada,
    required this.senasParticulares,
  });

  factory DetalleReporte.fromJson(Map<String, dynamic> json) {
    final mascota = json['mascota'] as Map<String, dynamic>;

    return DetalleReporte(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
      ubicacionExtravio: json['ubicacion_extravio'] as String,
      fechaExtravio: json['fecha_extravio'] as String,
      horaExtravio: json['hora_extravio'] as String?,
      nombreMascota: mascota['nombre'] as String?,
      especie: mascota['especie'] as String,
      raza: mascota['raza'] as String?,
      color: mascota['color'] as String,
      tamano: mascota['tamano'] as String,
      edadAproximada: mascota['edad_aproximada'] as int?,
      senasParticulares: mascota['senas_particulares'] as String?,
    );
  }
}
