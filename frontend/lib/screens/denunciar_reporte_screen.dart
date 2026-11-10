import 'package:flutter/material.dart';
import '../models/denuncia_reporte.dart';
import '../services/reporte_service.dart'; // Asegúrate de que esta ruta sea correcta

class DenunciarReporteScreen extends StatefulWidget {
  final int reporteId;
  final String codigoReporte;

  const DenunciarReporteScreen({
    super.key,
    required this.reporteId,
    required this.codigoReporte,
  });

  @override
  State<DenunciarReporteScreen> createState() => _DenunciarReporteScreenState();
}

class _DenunciarReporteScreenState extends State<DenunciarReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final ReporteService _reporteService = ReporteService();

  String _motivoSeleccionado = 'Falsa';
  bool _enviando = false;

  final List<String> _motivos = [
    'Falsa',
    'Duplicada',
    'Inadecuada',
    'Desactualizada',
    'Otro',
  ];

  Future<void> _enviarDenuncia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    try {
      final denuncia = DenunciaReporte(
        reporteId: widget.reporteId,
        motivo: _motivoSeleccionado,
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );

      // Asegúrate de tener este método en tu ReporteService
      await _reporteService.crearDenuncia(denuncia);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denuncia enviada correctamente.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar denuncia: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Denunciar ${widget.codigoReporte}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _motivoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Motivo de la denuncia',
                border: OutlineInputBorder(),
              ),
              items: _motivos
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _motivoSeleccionado = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _enviando ? null : _enviarDenuncia,
              icon: _enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.report),
              label: Text(_enviando ? 'Enviando...' : 'Enviar denuncia'),
            ),
          ],
        ),
      ),
    );
  }
}