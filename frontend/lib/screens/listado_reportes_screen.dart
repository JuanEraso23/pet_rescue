import 'package:flutter/material.dart';

import '../models/resumen_reporte.dart';
import '../services/reporte_service.dart';
import 'detalle_reporte_screen.dart';
import 'registro_reporte_screen.dart';

class ListadoReportesScreen extends StatefulWidget {
  const ListadoReportesScreen({super.key});

  @override
  State<ListadoReportesScreen> createState() {
    return _ListadoReportesScreenState();
  }
}

class _ListadoReportesScreenState extends State<ListadoReportesScreen> {
  final ReporteService _service = ReporteService();

  late Future<List<ResumenReporte>> _reportes;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  void _cargarReportes() {
    _reportes = _service.consultarReportesActivos();
  }

  Future<void> _actualizarReportes() async {
    setState(() {
      _cargarReportes();
    });

    await _reportes;
  }

  Future<void> _abrirRegistro() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegistroReporteScreen()));

    if (!mounted) {
      return;
    }

    await _actualizarReportes();
  }

  Future<void> _abrirDetalle(ResumenReporte reporte) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleReporteScreen(reporteId: reporte.id),
      ),
    );

    if (!mounted) {
      return;
    }

    await _actualizarReportes();
  }

  String _formatearFecha(String fecha) {
    final fechaConvertida = DateTime.tryParse(fecha);

    if (fechaConvertida == null) {
      return fecha;
    }

    final dia = fechaConvertida.day.toString().padLeft(2, '0');
    final mes = fechaConvertida.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fechaConvertida.year}';
  }

  Widget _construirImagen(ResumenReporte reporte) {
    final url = reporte.fotografiaUrlCompleta;

    if (url == null) {
      return Container(
        height: 190,
        width: double.infinity,
        color: const Color(0xFFE8F0F3),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 56,
              color: Color(0xFF667781),
            ),
            SizedBox(height: 10),
            Text(
              'Fotografía pendiente',
              style: TextStyle(
                color: Color(0xFF667781),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          final total = loadingProgress.expectedTotalBytes;

          final progreso = total == null
              ? null
              : loadingProgress.cumulativeBytesLoaded / total;

          return Center(child: CircularProgressIndicator(value: progreso));
        },
        errorBuilder: (context, error, stackTrace) {
          return const ColoredBox(
            color: Color(0xFFE8F0F3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 56,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No fue posible mostrar la fotografía.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirTarjeta(ResumenReporte reporte) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _abrirDetalle(reporte);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirImagen(reporte),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(reporte.codigo),
                        avatar: const Icon(Icons.tag, size: 18),
                      ),
                      Chip(
                        label: Text(reporte.estado),
                        avatar: const Icon(Icons.schedule_outlined, size: 18),
                        backgroundColor: const Color(0xFFFFF1C7),
                      ),
                      Chip(
                        label: Text(reporte.especie),
                        avatar: const Icon(Icons.pets, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    reporte.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF183B4E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DatoResumen(
                    icono: Icons.badge_outlined,
                    etiqueta: 'Mascota',
                    valor: reporte.nombreMascota ?? 'No registrada',
                  ),
                  _DatoResumen(
                    icono: Icons.location_on_outlined,
                    etiqueta: 'Ubicación',
                    valor: reporte.ubicacionExtravio,
                  ),
                  _DatoResumen(
                    icono: Icons.calendar_month_outlined,
                    etiqueta: 'Fecha',
                    valor: _formatearFecha(reporte.fechaExtravio),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        _abrirDetalle(reporte);
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver detalle'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista(List<ResumenReporte> reportes) {
    if (reportes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _actualizarReportes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 100),
            const Icon(Icons.pets_outlined, size: 80, color: Color(0xFF667781)),
            const SizedBox(height: 18),
            Text(
              'No hay reportes activos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF183B4E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cuando se registre una mascota extraviada, '
              'el reporte aparecerá en esta sección.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF667781)),
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                onPressed: _abrirRegistro,
                icon: const Icon(Icons.add),
                label: const Text('Crear reporte'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _actualizarReportes,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;

          final columnas = ancho >= 1100
              ? 3
              : ancho >= 700
              ? 2
              : 1;

          if (columnas == 1) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: reportes.length,
              separatorBuilder: (_, _) {
                return const SizedBox(height: 18);
              },
              itemBuilder: (context, index) {
                return _construirTarjeta(reportes[index]);
              },
            );
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: reportes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: columnas == 3 ? 0.78 : 0.82,
            ),
            itemBuilder: (context, index) {
              return _construirTarjeta(reportes[index]);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas extraviadas'),
        actions: [
          IconButton(
            onPressed: _actualizarReportes,
            tooltip: 'Actualizar reportes',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ResumenReporte>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _VistaErrorListado(
              mensaje: snapshot.error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              onReintentar: _actualizarReportes,
            );
          }

          final reportes = snapshot.data ?? <ResumenReporte>[];

          return _construirLista(reportes);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirRegistro,
        icon: const Icon(Icons.add),
        label: const Text('Reportar mascota'),
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _DatoResumen({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: const Color(0xFF007C83)),
          const SizedBox(width: 10),
          SizedBox(
            width: 74,
            child: Text(
              etiqueta,
              style: const TextStyle(color: Color(0xFF667781)),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaErrorListado extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onReintentar;

  const _VistaErrorListado({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar los reportes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B4E),
              ),
            ),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                onReintentar();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
