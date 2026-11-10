import 'package:flutter/material.dart';

import '../models/gestion_reporte.dart';
import '../models/revision_reporte.dart';
import '../services/admin_reporte_service.dart';

class AdminGestionReporteScreen extends StatefulWidget {
  final ReporteAdminDetalle reporte;

  const AdminGestionReporteScreen({super.key, required this.reporte});

  @override
  State<AdminGestionReporteScreen> createState() =>
      _AdminGestionReporteScreenState();
}

class _AdminGestionReporteScreenState extends State<AdminGestionReporteScreen> {
  final AdminReporteService _service = AdminReporteService();

  final TextEditingController _motivoController = TextEditingController();

  late String _estadoGestion;

  late Future<List<ReportePrincipalResumen>> _candidatos;

  int? _reportePrincipalId;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    _estadoGestion = widget.reporte.estadoGestion;

    _reportePrincipalId = widget.reporte.reportePrincipalId;

    _motivoController.text = widget.reporte.motivoGestion ?? '';

    _cargarCandidatos();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void _cargarCandidatos() {
    _candidatos = _service.consultarCandidatosPrincipales(widget.reporte.id);
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');

    final mes = fecha.month.toString().padLeft(2, '0');

    final hora = fecha.hour.toString().padLeft(2, '0');

    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year} '
        '$hora:$minuto';
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

  Future<bool> _confirmarGestion() async {
    final mensaje = switch (_estadoGestion) {
      'Duplicado' =>
        '¿Confirmas que deseas marcar '
            '${widget.reporte.codigo} como duplicado?',
      'Desactualizado' =>
        '¿Confirmas que deseas marcar '
            '${widget.reporte.codigo} como desactualizado?',
      _ =>
        '¿Confirmas que deseas restaurar '
            '${widget.reporte.codigo} como vigente?',
    };

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar gestión'),
          content: Text(mensaje),
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

    return confirmado == true;
  }

  Future<void> _guardarGestion() async {
    final motivo = _motivoController.text.trim();

    if (_estadoGestion == 'Duplicado' && _reportePrincipalId == null) {
      _mostrarMensaje('Debes seleccionar el reporte principal.', esError: true);
      return;
    }

    if (_estadoGestion != 'Vigente' && motivo.isEmpty) {
      _mostrarMensaje(
        'Debes registrar el motivo de la gestión.',
        esError: true,
      );
      return;
    }

    final confirmado = await _confirmarGestion();

    if (!confirmado || !mounted) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final resultado = await _service.gestionarReporte(
        reporteId: widget.reporte.id,
        estadoGestion: _estadoGestion,
        reportePrincipalId: _estadoGestion == 'Duplicado'
            ? _reportePrincipalId
            : null,
        motivoGestion: _estadoGestion == 'Vigente' ? null : motivo,
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

  Widget _construirResumen() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reporte seleccionado',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B4E),
              ),
            ),
            const SizedBox(height: 14),
            _FilaGestion(etiqueta: 'Código', valor: widget.reporte.codigo),
            _FilaGestion(etiqueta: 'Título', valor: widget.reporte.titulo),
            _FilaGestion(
              etiqueta: 'Mascota',
              valor: widget.reporte.nombreMascota ?? 'No registrada',
            ),
            _FilaGestion(etiqueta: 'Especie', valor: widget.reporte.especie),
            _FilaGestion(
              etiqueta: 'Estado operativo',
              valor: widget.reporte.estado,
            ),
            _FilaGestion(
              etiqueta: 'Revisión',
              valor: widget.reporte.estadoRevision,
            ),
            _FilaGestion(
              etiqueta: 'Gestión actual',
              valor: widget.reporte.estadoGestion,
            ),
            if (widget.reporte.codigoReportePrincipal != null)
              _FilaGestion(
                etiqueta: 'Reporte principal',
                valor: widget.reporte.codigoReportePrincipal!,
              ),
            if (widget.reporte.fechaGestion != null)
              _FilaGestion(
                etiqueta: 'Fecha de gestión',
                valor: _formatearFecha(widget.reporte.fechaGestion!),
              ),
            if (widget.reporte.motivoGestion != null)
              _FilaGestion(
                etiqueta: 'Motivo anterior',
                valor: widget.reporte.motivoGestion!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirSelectorEstado() {
    return DropdownButtonFormField<String>(
      initialValue: _estadoGestion,
      decoration: const InputDecoration(
        labelText: 'Estado de gestión',
        prefixIcon: Icon(Icons.rule_folder_outlined),
      ),
      items: const [
        DropdownMenuItem(value: 'Vigente', child: Text('Vigente')),
        DropdownMenuItem(value: 'Duplicado', child: Text('Duplicado')),
        DropdownMenuItem(
          value: 'Desactualizado',
          child: Text('Desactualizado'),
        ),
      ],
      onChanged: _guardando
          ? null
          : (valor) {
              if (valor == null) {
                return;
              }

              setState(() {
                _estadoGestion = valor;

                if (valor != 'Duplicado') {
                  _reportePrincipalId = null;
                }

                if (valor == 'Vigente') {
                  _motivoController.clear();
                }
              });
            },
    );
  }

  Widget _construirSelectorPrincipal() {
    return FutureBuilder<List<ReportePrincipalResumen>>(
      future: _candidatos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.error.toString().replaceFirst('Exception: ', ''),
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(_cargarCandidatos);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar candidatos'),
              ),
            ],
          );
        }

        final candidatos = snapshot.data ?? <ReportePrincipalResumen>[];

        final valorActualValido = candidatos.any(
          (candidato) => candidato.id == _reportePrincipalId,
        );

        return DropdownButtonFormField<int>(
          key: ValueKey(
            'principal-$_reportePrincipalId-'
            '${candidatos.length}',
          ),
          initialValue: valorActualValido ? _reportePrincipalId : null,
          decoration: const InputDecoration(
            labelText: 'Reporte principal',
            prefixIcon: Icon(Icons.account_tree_outlined),
            helperText:
                'Selecciona el reporte que '
                'debe conservarse como principal.',
          ),
          items: candidatos
              .map(
                (candidato) => DropdownMenuItem<int>(
                  value: candidato.id,
                  child: Text(
                    candidato.descripcionSelector,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _guardando
              ? null
              : (valor) {
                  setState(() {
                    _reportePrincipalId = valor;
                  });
                },
        );
      },
    );
  }

  Widget _construirFormulario() {
    final requiereMotivo = _estadoGestion != 'Vigente';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión administrativa',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B4E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'La gestión de duplicados o '
              'desactualizados es independiente '
              'del estado operativo y de la '
              'revisión de contenido.',
              style: TextStyle(color: Color(0xFF667781)),
            ),
            const SizedBox(height: 18),
            _construirSelectorEstado(),
            if (_estadoGestion == 'Duplicado') ...[
              const SizedBox(height: 16),
              _construirSelectorPrincipal(),
            ],
            if (requiereMotivo) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _motivoController,
                enabled: !_guardando,
                maxLength: 1000,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Motivo de la gestión',
                  hintText: _estadoGestion == 'Duplicado'
                      ? 'Explica por qué corresponde '
                            'al mismo caso.'
                      : 'Explica por qué la información '
                            'está desactualizada.',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
            ],
            if (_estadoGestion == 'Vigente') ...[
              const SizedBox(height: 16),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF667781)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Restaurar como vigente '
                      'eliminará el reporte principal, '
                      'el motivo y la fecha de la '
                      'gestión anterior.',
                      style: TextStyle(color: Color(0xFF667781)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardarGestion,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Guardar gestión'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar reporte')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _construirResumen(),
          const SizedBox(height: 16),
          _construirFormulario(),
        ],
      ),
    );
  }
}

class _FilaGestion extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaGestion({required this.etiqueta, required this.valor});

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
