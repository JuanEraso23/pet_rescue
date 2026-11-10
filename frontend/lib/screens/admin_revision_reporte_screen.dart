import 'package:flutter/material.dart';

import '../models/revision_reporte.dart';
import '../services/admin_reporte_service.dart';
import 'admin_gestion_reporte_screen.dart';

class AdminRevisionReporteScreen extends StatefulWidget {
  final int reporteId;

  const AdminRevisionReporteScreen({super.key, required this.reporteId});

  @override
  State<AdminRevisionReporteScreen> createState() =>
      _AdminRevisionReporteScreenState();
}

class _AdminRevisionReporteScreenState
    extends State<AdminRevisionReporteScreen> {
  final AdminReporteService _service = AdminReporteService();

  final TextEditingController _observacionController = TextEditingController();

  late Future<ReporteAdminDetalle> _reporte;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  void _cargarReporte() {
    _reporte = _service.consultarReporte(widget.reporteId);
  }

  Future<void> _reintentar() async {
    setState(_cargarReporte);

    try {
      await _reporte;
    } catch (_) {
      // El FutureBuilder presenta el error.
    }
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

  Color _colorGestion(String estado) {
    switch (estado) {
      case 'Duplicado':
        return const Color(0xFFE5E7FF);

      case 'Desactualizado':
        return const Color(0xFFFDE2E2);

      default:
        return const Color(0xFFDDF5EF);
    }
  }

  IconData _iconoGestion(String estado) {
    switch (estado) {
      case 'Duplicado':
        return Icons.copy_all_outlined;

      case 'Desactualizado':
        return Icons.history_toggle_off_outlined;

      default:
        return Icons.check_circle_outline;
    }
  }

  void _mostrarMensaje(String mensaje, {required bool esError}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? Colors.redAccent : const Color(0xFF007C83),
        ),
      );
  }

  Future<void> _abrirGestion(ReporteAdminDetalle reporte) async {
    final actualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminGestionReporteScreen(reporte: reporte),
      ),
    );

    if (!mounted || actualizado != true) {
      return;
    }

    setState(_cargarReporte);

    try {
      await _reporte;
    } catch (_) {
      // El FutureBuilder presenta el error.
    }
  }

  Future<void> _solicitarDecision({
    required ReporteAdminDetalle reporte,
    required String decision,
  }) async {
    final esRechazo = decision == 'Rechazado';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(esRechazo ? 'Rechazar reporte' : 'Aprobar reporte'),
          content: Text(
            esRechazo
                ? '¿Confirmas que deseas rechazar '
                      'el reporte ${reporte.codigo}? '
                      'La observación será obligatoria.'
                : '¿Confirmas que deseas aprobar '
                      'el reporte ${reporte.codigo}?',
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
              style: esRechazo
                  ? FilledButton.styleFrom(backgroundColor: Colors.redAccent)
                  : null,
              child: Text(esRechazo ? 'Rechazar' : 'Aprobar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !mounted) {
      return;
    }

    await _guardarDecision(decision: decision);
  }

  Future<void> _guardarDecision({required String decision}) async {
    final observacion = _observacionController.text.trim();

    if (decision == 'Rechazado' && observacion.isEmpty) {
      _mostrarMensaje(
        'Debes registrar una observación '
        'para rechazar el reporte.',
        esError: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final resultado = await _service.revisarReporte(
        reporteId: widget.reporteId,
        estadoRevision: decision,
        observacionRevision: observacion.isEmpty ? null : observacion,
      );

      if (!mounted) {
        return;
      }

      _mostrarMensaje(resultado.mensaje, esError: false);

      Navigator.of(context).pop(true);
    } catch (error) {
      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Widget _construirEstadoRevision(ReporteAdminDetalle reporte) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Chip(
          avatar: Icon(_iconoRevision(reporte.estadoRevision), size: 18),
          label: Text(
            'Revisión: '
            '${reporte.estadoRevision}',
          ),
          backgroundColor: _colorRevision(reporte.estadoRevision),
        ),
        Chip(
          avatar: Icon(_iconoGestion(reporte.estadoGestion), size: 18),
          label: Text('Gestión: ${reporte.estadoGestion}'),
          backgroundColor: _colorGestion(reporte.estadoGestion),
        ),
        Chip(
          avatar: const Icon(Icons.flag_outlined, size: 18),
          label: Text('Estado: ${reporte.estado}'),
        ),
        Chip(
          avatar: const Icon(Icons.pets, size: 18),
          label: Text(reporte.tipo),
        ),
      ],
    );
  }

  Widget _construirInformacionReporte(ReporteAdminDetalle reporte) {
    return _SeccionAdministrativa(
      titulo: 'Información del reporte',
      children: [
        _FilaAdministrativa(etiqueta: 'Código', valor: reporte.codigo),
        _FilaAdministrativa(etiqueta: 'Título', valor: reporte.titulo),
        _FilaAdministrativa(
          etiqueta: 'Descripción',
          valor: reporte.descripcion,
        ),
        _FilaAdministrativa(
          etiqueta: 'Ubicación',
          valor: reporte.ubicacionExtravio,
        ),
        _FilaAdministrativa(
          etiqueta: 'Fecha del extravío',
          valor: reporte.fechaExtravio,
        ),
        _FilaAdministrativa(
          etiqueta: 'Publicado',
          valor: _formatearFecha(reporte.fechaCreacion),
        ),
      ],
    );
  }

  Widget _construirInformacionMascota(ReporteAdminDetalle reporte) {
    return _SeccionAdministrativa(
      titulo: 'Información de la mascota',
      children: [
        _FilaAdministrativa(
          etiqueta: 'Nombre',
          valor: reporte.nombreMascota ?? 'No registrado',
        ),
        _FilaAdministrativa(etiqueta: 'Especie', valor: reporte.especie),
        _FilaAdministrativa(
          etiqueta: 'Raza',
          valor: reporte.raza ?? 'No registrada',
        ),
        _FilaAdministrativa(etiqueta: 'Color', valor: reporte.color),
        _FilaAdministrativa(etiqueta: 'Tamaño', valor: reporte.tamano),
        _FilaAdministrativa(
          etiqueta: 'Edad aproximada',
          valor: reporte.edadAproximada == null
              ? 'No registrada'
              : '${reporte.edadAproximada} años',
        ),
        _FilaAdministrativa(
          etiqueta: 'Señas particulares',
          valor: reporte.senasParticulares ?? 'No registradas',
        ),
      ],
    );
  }

  Widget _construirGestionActual(ReporteAdminDetalle reporte) {
    return _SeccionAdministrativa(
      titulo: 'Gestión del reporte',
      children: [
        _FilaAdministrativa(
          etiqueta: 'Clasificación',
          valor: reporte.estadoGestion,
        ),
        if (reporte.codigoReportePrincipal != null)
          _FilaAdministrativa(
            etiqueta: 'Reporte principal',
            valor: reporte.codigoReportePrincipal!,
          ),
        if (reporte.motivoGestion != null)
          _FilaAdministrativa(
            etiqueta: 'Motivo',
            valor: reporte.motivoGestion!,
          ),
        if (reporte.fechaGestion != null)
          _FilaAdministrativa(
            etiqueta: 'Fecha',
            valor: _formatearFecha(reporte.fechaGestion!),
          ),
        if (reporte.estadoGestion == 'Vigente')
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'El reporte no está marcado como '
              'duplicado ni desactualizado.',
              style: TextStyle(color: Color(0xFF667781)),
            ),
          ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () {
            _abrirGestion(reporte);
          },
          icon: const Icon(Icons.rule_folder_outlined),
          label: Text(
            reporte.estadoGestion == 'Vigente'
                ? 'Gestionar reporte'
                : 'Modificar gestión',
          ),
        ),
      ],
    );
  }

  Widget _construirRevisionAnterior(ReporteAdminDetalle reporte) {
    return _SeccionAdministrativa(
      titulo: 'Resultado de la revisión',
      children: [
        _FilaAdministrativa(
          etiqueta: 'Decisión',
          valor: reporte.estadoRevision,
        ),
        _FilaAdministrativa(
          etiqueta: 'Fecha',
          valor: reporte.fechaRevision == null
              ? 'No registrada'
              : _formatearFecha(reporte.fechaRevision!),
        ),
        _FilaAdministrativa(
          etiqueta: 'Observación',
          valor: reporte.observacionRevision ?? 'Sin observación',
        ),
        const SizedBox(height: 8),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF667781)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Este reporte ya tiene una '
                'decisión administrativa y '
                'no puede revisarse nuevamente.',
                style: TextStyle(color: Color(0xFF667781)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirFormularioRevision(ReporteAdminDetalle reporte) {
    return _SeccionAdministrativa(
      titulo: 'Registrar decisión',
      children: [
        const Text(
          'Revisa que la información sea '
          'apropiada, clara y comprensible. '
          'La observación es obligatoria '
          'cuando se rechaza un reporte.',
          style: TextStyle(color: Color(0xFF667781)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _observacionController,
          enabled: !_guardando,
          maxLength: 1000,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Observación administrativa',
            hintText: 'Describe el resultado de la revisión',
            prefixIcon: Icon(Icons.fact_check_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _guardando
                  ? null
                  : () {
                      _solicitarDecision(
                        reporte: reporte,
                        decision: 'Aprobado',
                      );
                    },
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined),
              label: const Text('Aprobar reporte'),
            ),
            OutlinedButton.icon(
              onPressed: _guardando
                  ? null
                  : () {
                      _solicitarDecision(
                        reporte: reporte,
                        decision: 'Rechazado',
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Rechazar reporte'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisión administrativa')),
      body: FutureBuilder<ReporteAdminDetalle>(
        future: _reporte,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _VistaErrorAdministrativa(
              mensaje: snapshot.error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              onReintentar: _reintentar,
            );
          }

          final reporte = snapshot.data;

          if (reporte == null) {
            return _VistaErrorAdministrativa(
              mensaje: 'No se encontró el reporte.',
              onReintentar: _reintentar,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _construirEstadoRevision(reporte),
              const SizedBox(height: 18),
              _construirInformacionReporte(reporte),
              const SizedBox(height: 16),
              _construirInformacionMascota(reporte),
              const SizedBox(height: 16),
              _construirGestionActual(reporte),
              const SizedBox(height: 16),
              if (reporte.estadoRevision == 'Pendiente')
                _construirFormularioRevision(reporte)
              else
                _construirRevisionAnterior(reporte),
            ],
          );
        },
      ),
    );
  }
}

class _SeccionAdministrativa extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SeccionAdministrativa({required this.titulo, required this.children});

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

class _FilaAdministrativa extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaAdministrativa({required this.etiqueta, required this.valor});

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

class _VistaErrorAdministrativa extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onReintentar;

  const _VistaErrorAdministrativa({
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
            const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar '
              'la revisión administrativa.',
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
