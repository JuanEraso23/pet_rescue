import 'package:flutter/material.dart';

import '../models/fotografia_reporte.dart';
import '../models/reporte.dart';
import '../services/reporte_service.dart';

class DetalleReporteScreen extends StatefulWidget {
  final int reporteId;

  const DetalleReporteScreen({super.key, required this.reporteId});

  @override
  State<DetalleReporteScreen> createState() {
    return _DetalleReporteScreenState();
  }
}

class _DetalleReporteScreenState extends State<DetalleReporteScreen> {
  final ReporteService _service = ReporteService();

  late Future<DetalleReporte> _reporte;
  late Future<List<FotografiaReporte>> _fotografias;

  @override
  void initState() {
    super.initState();

    _cargarInformacion();
  }

  void _cargarInformacion() {
    _reporte = _service.consultarReporte(widget.reporteId);

    _fotografias = _service.consultarFotografias(widget.reporteId);
  }

  void _reintentar() {
    setState(() {
      _cargarInformacion();
    });
  }

  Widget _construirFotografia() {
    return FutureBuilder<List<FotografiaReporte>>(
      future: _fotografias,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.broken_image_outlined,
                    size: 50,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No fue posible cargar la fotografia.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _reintentar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final fotografias = snapshot.data ?? <FotografiaReporte>[];

        if (fotografias.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 54,
                    color: Color(0xFF667781),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fotografia pendiente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B4E),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Este reporte todavia no tiene '
                    'una fotografia asociada.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final fotografia = fotografias.first;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  fotografia.urlCompleta,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    final total = loadingProgress.expectedTotalBytes;

                    final progreso = total == null
                        ? null
                        : loadingProgress.cumulativeBytesLoaded / total;

                    return Center(
                      child: CircularProgressIndicator(value: progreso),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 54,
                            color: Colors.redAccent,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No fue posible mostrar '
                            'la fotografia.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: Color(0xFF007C83)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fotografia.nombreArchivo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del reporte')),
      body: FutureBuilder<DetalleReporte>(
        future: _reporte,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _VistaError(
              mensaje: snapshot.error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              onReintentar: _reintentar,
            );
          }

          if (!snapshot.hasData) {
            return _VistaError(
              mensaje: 'No se encontro la informacion del reporte.',
              onReintentar: _reintentar,
            );
          }

          final reporte = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _cargarInformacion();
              });

              await Future.wait([_reporte, _fotografias]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Chip(
                      label: Text(reporte.tipo),
                      avatar: const Icon(Icons.pets, size: 18),
                    ),
                    Chip(
                      label: Text(reporte.estado),
                      backgroundColor: const Color(0xFFDDF5EF),
                    ),
                    Chip(label: Text(reporte.codigo)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  reporte.titulo,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF183B4E),
                  ),
                ),
                const SizedBox(height: 20),
                _SeccionDetalle(
                  titulo: 'Fotografia reciente',
                  children: [_construirFotografia()],
                ),
                const SizedBox(height: 16),
                _SeccionDetalle(
                  titulo: 'Descripción del reporte',
                  children: [Text(reporte.descripcion)],
                ),
                const SizedBox(height: 16),
                _SeccionDetalle(
                  titulo: 'Características de la mascota',
                  children: [
                    _FilaDato(
                      etiqueta: 'Nombre',
                      valor: reporte.nombreMascota ?? 'No registrado',
                    ),
                    _FilaDato(etiqueta: 'Especie', valor: reporte.especie),
                    _FilaDato(
                      etiqueta: 'Raza',
                      valor: reporte.raza ?? 'No registrada',
                    ),
                    _FilaDato(etiqueta: 'Color', valor: reporte.color),
                    _FilaDato(etiqueta: 'Tamaño', valor: reporte.tamano),
                    _FilaDato(
                      etiqueta: 'Edad aproximada',
                      valor: reporte.edadAproximada == null
                          ? 'No registrada'
                          : '${reporte.edadAproximada} años',
                    ),
                    _FilaDato(
                      etiqueta: 'Señas particulares',
                      valor: reporte.senasParticulares ?? 'No registradas',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SeccionDetalle(
                  titulo: 'Información del extravío',
                  children: [
                    _FilaDato(
                      etiqueta: 'Ubicación',
                      valor: reporte.ubicacionExtravio,
                    ),
                    _FilaDato(etiqueta: 'Fecha', valor: reporte.fechaExtravio),
                    _FilaDato(
                      etiqueta: 'Hora',
                      valor: reporte.horaExtravio ?? 'No registrada',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeccionDetalle extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SeccionDetalle({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B4E),
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              etiqueta,
              style: const TextStyle(color: Color(0xFF667781)),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _VistaError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
