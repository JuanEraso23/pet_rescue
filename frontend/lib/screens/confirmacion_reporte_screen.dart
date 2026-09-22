import 'package:flutter/material.dart';

import '../models/reporte.dart';
import 'detalle_reporte_screen.dart';

class ConfirmacionReporteScreen extends StatelessWidget {
  final ReporteCreado reporte;

  const ConfirmacionReporteScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Reporte publicado'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF42B8A6),
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Reporte publicado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B4E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  reporte.mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _DatoResumen(
                          etiqueta: 'Código del reporte',
                          valor: reporte.codigo,
                        ),
                        const Divider(),
                        _DatoResumen(etiqueta: 'Estado', valor: reporte.estado),
                        const Divider(),
                        _DatoResumen(
                          etiqueta: 'Fecha de creación',
                          valor: _formatearFecha(reporte.fechaCreacion),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              DetalleReporteScreen(reporteId: reporte.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver reporte'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');

    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}

class _DatoResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _DatoResumen({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: const TextStyle(color: Color(0xFF667781)),
          ),
        ),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
