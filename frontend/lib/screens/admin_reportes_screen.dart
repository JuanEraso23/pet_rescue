import 'package:flutter/material.dart';

import '../models/revision_reporte.dart';
import '../services/admin_reporte_service.dart';
import 'admin_revision_reporte_screen.dart';

class AdminReportesScreen extends StatefulWidget {
  const AdminReportesScreen({super.key});

  @override
  State<AdminReportesScreen> createState() => _AdminReportesScreenState();
}

class _AdminReportesScreenState extends State<AdminReportesScreen> {
  final AdminReporteService _service = AdminReporteService();

  late Future<List<ReporteAdminResumen>> _reportes;

  String _estadoSeleccionado = 'Pendiente';

  bool _actualizando = false;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  void _cargarReportes() {
    _reportes = _service.consultarReportes(estadoRevision: _estadoSeleccionado);
  }

  Future<void> _actualizarReportes() async {
    setState(() {
      _actualizando = true;
      _cargarReportes();
    });

    try {
      await _reportes;
    } catch (_) {
      // El FutureBuilder presenta el error.
    } finally {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
    }
  }

  Future<void> _cambiarFiltro(String? estado) async {
    if (estado == null || estado == _estadoSeleccionado) {
      return;
    }

    setState(() {
      _estadoSeleccionado = estado;
      _actualizando = true;
      _cargarReportes();
    });

    try {
      await _reportes;
    } catch (_) {
      // El FutureBuilder presenta el error.
    } finally {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
    }
  }

  Future<void> _abrirRevision(ReporteAdminResumen reporte) async {
    final actualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminRevisionReporteScreen(reporteId: reporte.id),
      ),
    );

    if (!mounted || actualizado != true) {
      return;
    }

    await _actualizarReportes();
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');

    final mes = fecha.month.toString().padLeft(2, '0');

    final hora = fecha.hour.toString().padLeft(2, '0');

    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year} '
        '$hora:$minuto';
  }

  Color _colorRevision(String estado) {
    switch (estado) {
      case 'Aprobado':
        return const Color(0xFFDDF5EF);

      case 'Rechazado':
        return const Color(0xFFFDE2E2);

      default:
        return const Color(0xFFFFF1C7);
    }
  }

  IconData _iconoRevision(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Icons.verified_outlined;

      case 'Rechazado':
        return Icons.cancel_outlined;

      default:
        return Icons.pending_actions_outlined;
    }
  }

  Widget _construirEncabezado(int cantidad) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revisión de reportes',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF183B4E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Consulta la información publicada '
                'y registra una decisión '
                'administrativa.',
                style: TextStyle(color: Color(0xFF667781)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 225,
                    child: DropdownButtonFormField<String>(
                      initialValue: _estadoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Estado de revisión',
                        prefixIcon: Icon(Icons.fact_check_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'Pendiente',
                          child: Text('Pendiente'),
                        ),
                        DropdownMenuItem(
                          value: 'Aprobado',
                          child: Text('Aprobado'),
                        ),
                        DropdownMenuItem(
                          value: 'Rechazado',
                          child: Text('Rechazado'),
                        ),
                      ],
                      onChanged: _actualizando ? null : _cambiarFiltro,
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.description_outlined, size: 18),
                    label: Text(
                      '$cantidad '
                      '${cantidad == 1 ? 'reporte' : 'reportes'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF667781)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este módulo administrativo '
                      'es un prototipo. El proyecto '
                      'todavía no cuenta con '
                      'autenticación ni control real '
                      'de roles.',
                      style: TextStyle(color: Color(0xFF667781)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTarjeta(ReporteAdminResumen reporte) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _abrirRevision(reporte);
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.tag, size: 18),
                    label: Text(reporte.codigo),
                  ),
                  Chip(
                    avatar: Icon(
                      _iconoRevision(reporte.estadoRevision),
                      size: 18,
                    ),
                    label: Text(reporte.estadoRevision),
                    backgroundColor: _colorRevision(reporte.estadoRevision),
                  ),
                  Chip(
                    avatar: const Icon(Icons.flag_outlined, size: 18),
                    label: Text(reporte.estado),
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
              const SizedBox(height: 14),
              _DatoAdministrativo(
                icono: Icons.pets,
                etiqueta: 'Mascota',
                valor: reporte.nombreMascota ?? 'No registrada',
              ),
              _DatoAdministrativo(
                icono: Icons.category_outlined,
                etiqueta: 'Especie',
                valor: reporte.especie,
              ),
              _DatoAdministrativo(
                icono: Icons.location_on_outlined,
                etiqueta: 'Ubicación',
                valor: reporte.ubicacionExtravio,
              ),
              _DatoAdministrativo(
                icono: Icons.calendar_month_outlined,
                etiqueta: 'Extravío',
                valor: reporte.fechaExtravio,
              ),
              _DatoAdministrativo(
                icono: Icons.schedule_outlined,
                etiqueta: 'Publicado',
                valor: _formatearFecha(reporte.fechaCreacion),
              ),
              if (reporte.fechaRevision != null)
                _DatoAdministrativo(
                  icono: Icons.fact_check_outlined,
                  etiqueta: 'Revisado',
                  valor: _formatearFecha(reporte.fechaRevision!),
                ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    _abrirRevision(reporte);
                  },
                  icon: Icon(
                    reporte.estadoRevision == 'Pendiente'
                        ? Icons.fact_check_outlined
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    reporte.estadoRevision == 'Pendiente'
                        ? 'Revisar reporte'
                        : 'Ver revisión',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirLista(List<ReporteAdminResumen> reportes) {
    if (reportes.isEmpty) {
      return _VistaVaciaAdministrativa(
        estado: _estadoSeleccionado,
        onActualizar: _actualizarReportes,
      );
    }

    return RefreshIndicator(
      onRefresh: _actualizarReportes,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnas = constraints.maxWidth >= 1150
              ? 3
              : constraints.maxWidth >= 760
              ? 2
              : 1;

          if (columnas == 1) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: reportes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
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
              childAspectRatio: columnas == 3 ? 0.88 : 0.93,
            ),
            itemBuilder: (_, index) {
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
        title: const Text('Administración de reportes'),
        actions: [
          IconButton(
            onPressed: _actualizando ? null : _actualizarReportes,
            tooltip: 'Actualizar reportes',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ReporteAdminResumen>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_actualizando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _VistaErrorListadoAdmin(
              mensaje: snapshot.error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              onReintentar: _actualizarReportes,
            );
          }

          final reportes = snapshot.data ?? <ReporteAdminResumen>[];

          return Column(
            children: [
              _construirEncabezado(reportes.length),
              Expanded(child: _construirLista(reportes)),
            ],
          );
        },
      ),
    );
  }
}

class _DatoAdministrativo extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _DatoAdministrativo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: const Color(0xFF007C83)),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
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

class _VistaVaciaAdministrativa extends StatelessWidget {
  final String estado;
  final Future<void> Function() onActualizar;

  const _VistaVaciaAdministrativa({
    required this.estado,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 70),
          const Icon(
            Icons.fact_check_outlined,
            size: 80,
            color: Color(0xFF667781),
          ),
          const SizedBox(height: 18),
          Text(
            estado == 'Todos'
                ? 'No hay reportes administrativos'
                : 'No hay reportes en estado '
                      '$estado',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B4E),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Prueba otro filtro o actualiza '
            'el listado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF667781)),
          ),
        ],
      ),
    );
  }
}

class _VistaErrorListadoAdmin extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onReintentar;

  const _VistaErrorListadoAdmin({
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar '
              'los reportes administrativos.',
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
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
