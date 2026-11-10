import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_rescue_frontend/screens/seleccionar_ubicacion_screen.dart';
import 'package:pet_rescue_frontend/widgets/mapa_reporte.dart';

// HU18: pruebas del selector de ubicación y del redondeo de coordenadas.
void main() {
  Future<List<Object?>> abrirSelector(
    WidgetTester tester, {
    LatLng? inicial,
  }) async {
    final resultados = <Object?>[];

    await tester.binding.setSurfaceSize(const Size(800, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final r = await Navigator.of(context).push<LatLng>(
                MaterialPageRoute(
                  builder: (_) =>
                      SeleccionarUbicacionScreen(ubicacionInicial: inicial),
                ),
              );
              resultados.add(r);
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return resultados;
  }

  test('redondea a 4 decimales', () {
    final punto = redondearUbicacion(const LatLng(1.213678, -77.281149));
    expect(punto.latitude, 1.2137);
    expect(punto.longitude, -77.2811);
  });

  testWidgets('Confirmar está deshabilitado sin selección', (tester) async {
    await abrirSelector(tester);
    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.onPressed, isNull);
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('Cancelar devuelve null', (tester) async {
    final resultados = await abrirSelector(
      tester,
      inicial: const LatLng(1.2136, -77.2811),
    );
    await tester.tap(find.byType(FlutterMap));
    // flutter_map espera el tiempo de doble toque antes de emitir onTap.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(resultados, [null]);
  });

  testWidgets('pulsar el mapa y Confirmar devuelve la zona redondeada', (
    tester,
  ) async {
    final resultados = await abrirSelector(tester);
    await tester.tap(find.byType(FlutterMap));
    // flutter_map espera el tiempo de doble toque antes de emitir onTap.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Zona seleccionada'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(resultados, hasLength(1));
    final punto = resultados.single as LatLng;
    expect(punto.latitude, double.parse(punto.latitude.toStringAsFixed(4)));
    expect(punto.longitude, double.parse(punto.longitude.toStringAsFixed(4)));
    expect((punto.latitude - 1.2136).abs(), lessThan(0.1));
  });
}
