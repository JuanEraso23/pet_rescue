import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../screens/seleccionar_ubicacion_screen.dart';

/// HU18: centro inicial razonable (Pasto, Colombia) cuando el reporte
/// todavía no tiene coordenadas.
const LatLng ubicacionInicialPorDefecto = LatLng(1.2136, -77.2811);

/// HU18: la historia pide una ubicación aproximada; se conservan
/// 4 decimales (unos 11 m) para evitar precisión innecesaria.
LatLng redondearUbicacion(LatLng punto) {
  return LatLng(
    double.parse(punto.latitude.toStringAsFixed(4)),
    double.parse(punto.longitude.toStringAsFixed(4)),
  );
}

/// Capa de mosaicos de OpenStreetMap, compartida por el selector y el
/// mapa de solo lectura.
TileLayer capaMosaicosReporte() {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.pet_rescue_frontend',
  );
}

/// Atribución visible obligatoria del proveedor de mapas.
Widget atribucionMapaReporte() {
  return const SimpleAttributionWidget(
    source: Text('OpenStreetMap contributors'),
  );
}

Marker marcadorReporte(LatLng punto) {
  return Marker(
    point: punto,
    width: 44,
    height: 44,
    alignment: Alignment.topCenter,
    child: const Icon(Icons.location_on, color: Color(0xFFD64545), size: 44),
  );
}

/// HU18: mapa de solo lectura para el detalle del reporte. Se puede
/// desplazar y hacer zoom, pero no modifica el reporte.
class MapaReporte extends StatelessWidget {
  final LatLng ubicacion;
  final double altura;

  const MapaReporte({super.key, required this.ubicacion, this.altura = 220});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: altura,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: ubicacion,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            capaMosaicosReporte(),
            MarkerLayer(markers: [marcadorReporte(ubicacion)]),
            atribucionMapaReporte(),
          ],
        ),
      ),
    );
  }
}

/// HU18: campo de formulario para elegir o quitar la ubicación en el
/// mapa. No guarda nada por sí solo; solo informa el valor elegido.
class CampoUbicacionMapa extends StatelessWidget {
  final LatLng? ubicacion;
  final ValueChanged<LatLng?> onChanged;
  final bool habilitado;

  const CampoUbicacionMapa({
    super.key,
    required this.ubicacion,
    required this.onChanged,
    this.habilitado = true,
  });

  Future<void> _seleccionar(BuildContext context) async {
    final seleccion = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => SeleccionarUbicacionScreen(ubicacionInicial: ubicacion),
      ),
    );

    // null significa que el usuario canceló: no se modifica nada.
    if (seleccion != null) {
      onChanged(redondearUbicacion(seleccion));
    }
  }

  @override
  Widget build(BuildContext context) {
    final punto = ubicacion;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    punto == null
                        ? 'Ubicación en el mapa (opcional)'
                        : 'Ubicación seleccionada: '
                              '${punto.latitude.toStringAsFixed(4)}, '
                              '${punto.longitude.toStringAsFixed(4)}',
                  ),
                ),
              ],
            ),
            if (punto != null) ...[
              const SizedBox(height: 12),
              MapaReporte(ubicacion: punto, altura: 160),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: habilitado ? () => _seleccionar(context) : null,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(
                    punto == null ? 'Seleccionar en el mapa' : 'Cambiar zona',
                  ),
                ),
                if (punto != null)
                  TextButton.icon(
                    onPressed: habilitado ? () => onChanged(null) : null,
                    icon: const Icon(Icons.location_off_outlined),
                    label: const Text('Quitar del mapa'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
