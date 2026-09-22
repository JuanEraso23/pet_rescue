import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/reporte.dart';

class ReporteService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<ReporteCreado> crearReporte(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reportes'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(datos),
      );

      final cuerpo =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return ReporteCreado.fromJson(cuerpo);
      }

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception('No fue posible conectarse con el servidor.');
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta inválida.');
    }
  }

  Future<DetalleReporte> consultarReporte(int reporteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reportes/$reporteId'),
      );

      final cuerpo =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return DetalleReporte.fromJson(cuerpo);
      }

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception('No fue posible conectarse con el servidor.');
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta inválida.');
    }
  }

  String _obtenerMensajeError(Map<String, dynamic> cuerpo) {
    final detalle = cuerpo['detail'];

    if (detalle is String) {
      return detalle;
    }

    if (detalle is List && detalle.isNotEmpty) {
      final primero = detalle.first;

      if (primero is Map && primero['msg'] is String) {
        return primero['msg'] as String;
      }
    }

    return 'Ocurrió un error inesperado.';
  }
}
