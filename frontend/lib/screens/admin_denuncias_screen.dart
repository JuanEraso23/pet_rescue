import 'package:flutter/material.dart';
import '../models/denuncia_reporte.dart';
import '../services/reporte_service.dart'; // O donde tengas el servicio de Jaider

class AdminDenunciasScreen extends StatefulWidget {
  const AdminDenunciasScreen({super.key});

  @override
  State<AdminDenunciasScreen> createState() => _AdminDenunciasScreenState();
}

class _AdminDenunciasScreenState extends State<AdminDenunciasScreen> {
  final ReporteService _service = ReporteService();
  List<DenunciaReporte> _denuncias = [];
  String _filtroEstado = 'Pendiente';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDenuncias();
  }

  Future<void> _cargarDenuncias() async {
    setState(() => _cargando = true);
    try {
      // Necesitaremos crear este método en el servicio
      final denuncias = await _service.listarDenunciasAdmin(estado: _filtroEstado);
      if (!mounted) return;
      setState(() => _denuncias = denuncias);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _revisarDenuncia(DenunciaReporte denuncia, String decision) async {
    final TextEditingController obsController = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿$decision denuncia?'),
        content: TextField(
          controller: obsController,
          decoration: const InputDecoration(labelText: 'Observación administrativa (opcional)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(decision),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _service.revisarDenuncia(
          denunciaId: denuncia.id!,
          estado: decision == 'Aprobar' ? 'Aprobada' : 'Rechazada',
          observacion: obsController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Denuncia revisada.')));
        _cargarDenuncias(); // Recargar la lista
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar Denuncias'),
        actions: [
          IconButton(onPressed: _cargarDenuncias, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              initialValue: _filtroEstado,
              decoration: const InputDecoration(labelText: 'Filtrar por estado', border: OutlineInputBorder()),
              items: ['Pendiente', 'Aprobada', 'Rechazada', 'Todas']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _filtroEstado = val);
                  _cargarDenuncias();
                }
              },
            ),
          ),
          // Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _denuncias.isEmpty
                    ? const Center(child: Text('No hay denuncias para este filtro.'))
                    : ListView.builder(
                        itemCount: _denuncias.length,
                        itemBuilder: (context, index) {
                          final d = _denuncias[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('Reporte ID: ${d.reporteId} - Motivo: ${d.motivo}'),
                              subtitle: Text('Estado: ${d.estado}'),
                              trailing: d.estado == 'Pendiente'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          tooltip: 'Aprobar',
                                          onPressed: () => _revisarDenuncia(d, 'Aprobar'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          tooltip: 'Rechazar',
                                          onPressed: () => _revisarDenuncia(d, 'Rechazar'),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}