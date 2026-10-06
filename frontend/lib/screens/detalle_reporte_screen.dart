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

  bool _actualizandoEstado = false;

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

  Future<void> _refrescarInformacion() async {
    setState(() {
      _cargarInformacion();
    });

    await Future.wait([_reporte, _fotografias]);
  }

  Future<void> _solicitarCambioEstado({
    required DetalleReporte reporte,
    required String nuevoEstado,
  }) async {
    if (_actualizandoEstado) {
      return;
    }

    final encontrado = nuevoEstado == 'Encontrado';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(encontrado ? 'Marcar como encontrada' : 'Cerrar reporte'),
          content: Text(
            encontrado
                ? '¿Confirmas que la mascota fue encontrada? '
                      'Después de guardar el cambio, el reporte '
                      'quedará en un estado final.'
                : '¿Confirmas que deseas cerrar este reporte? '
                      'Después de guardar el cambio, el reporte '
                      'quedará en un estado final.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _actualizandoEstado = true;
    });

    try {
      final mensaje = await _service.actualizarEstado(
        reporteId: reporte.id,
        estado: nuevoEstado,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _cargarInformacion();
      });

      await _reporte;

      if (!mounted) {
        return;
      }

      _mostrarMensaje(mensaje, esError: false);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _actualizandoEstado = false;
        });
      }
    }
  }

  void _mostrarMensaje(String mensaje, {required bool esError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? Colors.redAccent : const Color(0xFF007C83),
        ),
      );
  }

  bool _esEstadoFinal(String estado) {
    return estado == 'Encontrado' || estado == 'Cerrado';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Encontrado':
        return const Color(0xFFDDF5EF);

      case 'Cerrado':
        return const Color(0xFFE2E8F0);

      default:
        return const Color(0xFFFFF1C7);
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Encontrado':
        return Icons.check_circle_outline;

      case 'Cerrado':
        return Icons.lock_outline;

      default:
        return Icons.schedule_outlined;
    }
  }

  Widget _construirAccionesEstado(DetalleReporte reporte) {
    if (_esEstadoFinal(reporte.estado)) {
      return Card(
        color: _colorEstado(reporte.estado),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _iconoEstado(reporte.estado),
                color: const Color(0xFF183B4E),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporte ${reporte.estado.toLowerCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF183B4E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Este reporte se encuentra en un '
                      'estado final y ya no puede modificarse.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _SeccionDetalle(
      titulo: 'Actualizar estado',
      children: [
        const Text(
          'Selecciona una acción únicamente cuando '
          'tengas certeza sobre el estado del reporte.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _actualizandoEstado
                  ? null
                  : () {
                      _solicitarCambioEstado(
                        reporte: reporte,
                        nuevoEstado: 'Encontrado',
                      );
                    },
              icon: _actualizandoEstado
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como encontrada'),
            ),
            OutlinedButton.icon(
              onPressed: _actualizandoEstado
                  ? null
                  : () {
                      _solicitarCambioEstado(
                        reporte: reporte,
                        nuevoEstado: 'Cerrado',
                      );
                    },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Cerrar reporte'),
            ),
          ],
        ),
      ],
    );
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
                    'No fue posible cargar la fotografía.',
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
                    'Fotografía pendiente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B4E),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Este reporte todavía no tiene '
                    'una fotografía asociada.',
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
                            'la fotografía.',
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
              mensaje: 'No se encontró la información del reporte.',
              onReintentar: _reintentar,
            );
          }

          final reporte = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refrescarInformacion,
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
                      avatar: Icon(_iconoEstado(reporte.estado), size: 18),
                      backgroundColor: _colorEstado(reporte.estado),
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
                _construirAccionesEstado(reporte),
                const SizedBox(height: 16),
                _SeccionDetalle(
                  titulo: 'Fotografía reciente',
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
