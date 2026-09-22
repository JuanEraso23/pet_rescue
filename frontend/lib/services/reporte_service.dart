import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/fotografia_reporte.dart';
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
      throw Exception('El servidor devolvio una respuesta invalida.');
    }
  }

  Future<FotografiaReporte> cargarFotografia({
    required int reporteId,
    required Uint8List bytes,
    required String nombreArchivo,
  }) async {
    try {
      final extension = nombreArchivo.split('.').last.toLowerCase();

      final MediaType tipoMime;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          tipoMime = MediaType('image', 'jpeg');
          break;

        case 'png':
          tipoMime = MediaType('image', 'png');
          break;

        case 'webp':
          tipoMime = MediaType('image', 'webp');
          break;

        default:
          throw Exception('Formato de fotografia no permitido.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reportes/$reporteId/fotografias'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          bytes,
          filename: nombreArchivo,
          contentType: tipoMime,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      final cuerpo =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return FotografiaReporte.fromJson(cuerpo);
      }

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception('No fue posible conectarse con el servidor.');
    } on FormatException {
      throw Exception('El servidor devolvio una respuesta invalida.');
    }
  }

  Future<List<FotografiaReporte>> consultarFotografias(int reporteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reportes/$reporteId/fotografias'),
      );

      if (response.statusCode == 200) {
        final cuerpo =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        return cuerpo
            .map(
              (elemento) =>
                  FotografiaReporte.fromJson(elemento as Map<String, dynamic>),
            )
            .toList();
      }

      final cuerpo =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      throw Exception(_obtenerMensajeError(cuerpo));
    } on http.ClientException {
      throw Exception('No fue posible conectarse con el servidor.');
    } on FormatException {
      throw Exception('El servidor devolvio una respuesta invalida.');
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
      throw Exception('El servidor devolvio una respuesta invalida.');
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

    return 'Ocurrio un error inesperado.';
  }
}
