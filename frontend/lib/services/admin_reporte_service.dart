import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gestion_reporte.dart';
import '../models/revision_reporte.dart';

class AdminReporteService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<ReporteAdminResumen>> consultarReportes({
    String? estadoRevision,
  }) async {
    try {
      final parametros = <String, String>{};

      final estadoLimpio = estadoRevision?.trim();

      if (estadoLimpio != null &&
          estadoLimpio.isNotEmpty &&
          estadoLimpio != 'Todos') {
        parametros['estado_revision'] = estadoLimpio;
      }

      final uri = Uri.parse('$baseUrl/admin/reportes')
          .replace(queryParameters: parametros.isEmpty ? null : parametros);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final contenido = jsonDecode(utf8.decode(response.bodyBytes));

        if (contenido is! List) {
          throw const FormatException();
        }

        return contenido
            .map(
              (elemento) => ReporteAdminResumen.fromJson(
                elemento as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      final cuerpo = _decodificarMapa(response);

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse '
        'con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una '
        'respuesta inválida.',
      );
    }
  }

  Future<ReporteAdminDetalle> consultarReporte(int reporteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/reportes/$reporteId'),
      );

      final cuerpo = _decodificarMapa(response);

      if (response.statusCode == 200) {
        return ReporteAdminDetalle.fromJson(cuerpo);
      }

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse '
        'con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una '
        'respuesta inválida.',
      );
    }
  }

  Future<ResultadoRevisionReporte> revisarReporte({
    required int reporteId,
    required String estadoRevision,
    String? observacionRevision,
  }) async {
    try {
      final observacionLimpia = observacionRevision?.trim();

      final response = await http.patch(
        Uri.parse(
          '$baseUrl/admin/reportes/'
          '$reporteId/revision',
        ),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'estado_revision': estadoRevision,
          'observacion_revision':
              observacionLimpia == null || observacionLimpia.isEmpty
              ? null
              : observacionLimpia,
        }),
      );

      final cuerpo = _decodificarMapa(response);

      if (response.statusCode == 200) {
        return ResultadoRevisionReporte.fromJson(cuerpo);
      }

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse '
        'con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una '
        'respuesta inválida.',
      );
    }
  }

  Future<List<ReportePrincipalResumen>> consultarCandidatosPrincipales(
    int reporteId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/admin/reportes/'
          '$reporteId/candidatos-principales',
        ),
      );

      if (response.statusCode == 200) {
        final contenido = jsonDecode(utf8.decode(response.bodyBytes));

        if (contenido is! List) {
          throw const FormatException();
        }

        return contenido
            .map(
              (elemento) => ReportePrincipalResumen.fromJson(
                elemento as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      final cuerpo = _decodificarMapa(response);

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse '
        'con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una '
        'respuesta inválida.',
      );
    }
  }

  Future<ResultadoGestionReporte> gestionarReporte({
    required int reporteId,
    required String estadoGestion,
    int? reportePrincipalId,
    String? motivoGestion,
  }) async {
    try {
      final motivoLimpio = motivoGestion?.trim();

      final response = await http.patch(
        Uri.parse(
          '$baseUrl/admin/reportes/'
          '$reporteId/gestion',
        ),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'estado_gestion': estadoGestion,
          'reporte_principal_id': reportePrincipalId,
          'motivo_gestion': motivoLimpio == null || motivoLimpio.isEmpty
              ? null
              : motivoLimpio,
        }),
      );

      final cuerpo = _decodificarMapa(response);

      if (response.statusCode == 200) {
        return ResultadoGestionReporte.fromJson(cuerpo);
      }

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse '
        'con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una '
        'respuesta inválida.',
      );
    }
  }

  Map<String, dynamic> _decodificarMapa(http.Response response) {
    final contenido = jsonDecode(utf8.decode(response.bodyBytes));

    if (contenido is! Map<String, dynamic>) {
      throw const FormatException();
    }

    return contenido;
  }

  String _obtenerMensajeError(Map<String, dynamic> cuerpo) {
    final detalle = cuerpo['detail'];

    if (detalle is String && detalle.trim().isNotEmpty) {
      return detalle;
    }

    if (detalle is List && detalle.isNotEmpty) {
      final primerError = detalle.first;

      if (primerError is Map) {
        final mensaje = primerError['msg'];

        if (mensaje is String && mensaje.trim().isNotEmpty) {
          return mensaje;
        }
      }
    }

    return 'No fue posible completar '
        'la operación administrativa.';
  }
}
