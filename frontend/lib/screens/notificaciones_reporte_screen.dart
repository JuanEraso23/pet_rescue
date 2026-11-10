import 'package:flutter/material.dart';
import '../models/notificacion_coincidencia.dart';
import '../services/reporte_service.dart';

class NotificacionesReporteScreen extends StatefulWidget {
  final int reporteId;

  const NotificacionesReporteScreen({super.key, required this.reporteId});

  @override
  State<NotificacionesReporteScreen> createState() => _NotificacionesReporteScreenState();
}

class _NotificacionesReporteScreenState extends State<NotificacionesReporteScreen> {
  final ReporteService _service = ReporteService();
  List<NotificacionCoincidencia> _notificaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _cargando = true);
    try {
      final notificaciones = await _service.listarNotificaciones(widget.reporteId);
      if (!mounted) return;
      setState(() => _notificaciones = notificaciones);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _marcarComoLeida(NotificacionCoincidencia n) async {
    try {
      await _service.marcarNotificacionLeida(widget.reporteId, n.id);
      _cargarNotificaciones();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones de coincidencias')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? const Center(child: Text('No se encontraron posibles coincidencias.'))
              : ListView.builder(
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final n = _notificaciones[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          n.leida ? Icons.notifications_none : Icons.notifications_active,
                          color: n.leida ? Colors.grey : Colors.blue,
                        ),
                        title: Text(n.mensaje),
                        subtitle: Text('Fecha: ${n.fechaCreacion.toString().substring(0, 10)}'),
                        trailing: n.leida
                            ? null
                            : TextButton(
                                onPressed: () => _marcarComoLeida(n),
                                child: const Text('Marcar leída'),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}