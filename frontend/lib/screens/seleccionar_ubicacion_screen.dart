import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/mapa_reporte.dart';

/// HU18: permite pulsar una zona del mapa y devolverla con Confirmar.
/// Cancelar (o regresar) devuelve null y no cambia ningún dato.
/// No usa la ubicación actual del dispositivo.
class SeleccionarUbicacionScreen extends StatefulWidget {
  final LatLng? ubicacionInicial;

  const SeleccionarUbicacionScreen({super.key, this.ubicacionInicial});

  @override
  State<SeleccionarUbicacionScreen> createState() =>
      _SeleccionarUbicacionScreenState();
}

class _SeleccionarUbicacionScreenState
    extends State<SeleccionarUbicacionScreen> {
  LatLng? _seleccion;

  @override
  void initState() {
    super.initState();
    _seleccion = widget.ubicacionInicial;
  }

  void _cancelar() {
    Navigator.of(context).pop();
  }

  void _confirmar() {
    final seleccion = _seleccion;

    if (seleccion == null) {
      return;
    }

    Navigator.of(context).pop(redondearUbicacion(seleccion));
  }

  @override
  Widget build(BuildContext context) {
    final seleccion = _seleccion;

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar ubicación')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              seleccion == null
                  ? 'Pulsa en el mapa la zona aproximada del extravío.'
                  : 'Zona seleccionada: '
                        '${seleccion.latitude.toStringAsFixed(4)}, '
                        '${seleccion.longitude.toStringAsFixed(4)}',
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                    widget.ubicacionInicial ?? ubicacionInicialPorDefecto,
                initialZoom: widget.ubicacionInicial == null ? 13 : 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (_, punto) => setState(() => _seleccion = punto),
              ),
              children: [
                capaMosaicosReporte(),
                if (seleccion != null)
                  MarkerLayer(markers: [marcadorReporte(seleccion)]),
                atribucionMapaReporte(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelar,
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: seleccion == null ? null : _confirmar,
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
