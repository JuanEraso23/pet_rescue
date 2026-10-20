import 'package:flutter/material.dart';

import '../services/reporte_service.dart';

class RegistroAvistamientoScreen extends StatefulWidget {
  final int reporteId;

  const RegistroAvistamientoScreen({super.key, required this.reporteId});

  @override
  State<RegistroAvistamientoScreen> createState() {
    return _RegistroAvistamientoScreenState();
  }
}

class _RegistroAvistamientoScreenState
    extends State<RegistroAvistamientoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ReporteService _service = ReporteService();

  final TextEditingController _descripcionController = TextEditingController();

  final TextEditingController _ubicacionController = TextEditingController();

  DateTime _fechaAvistamiento = DateTime.now();
  TimeOfDay? _horaAvistamiento;

  bool _guardando = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '${fecha.year}-$mes-$dia';
  }

  String _mostrarFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String? _formatearHora(TimeOfDay? hora) {
    if (hora == null) {
      return null;
    }

    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');

    return '$horas:$minutos:00';
  }

  String _mostrarHora(TimeOfDay hora) {
    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');

    return '$horas:$minutos';
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAvistamiento,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha del avistamiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha == null || !mounted) {
      return;
    }

    setState(() {
      _fechaAvistamiento = fecha;
    });
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaAvistamiento ?? TimeOfDay.now(),
      helpText: 'Seleccionar hora aproximada',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (hora == null || !mounted) {
      return;
    }

    setState(() {
      _horaAvistamiento = hora;
    });
  }

  void _eliminarHora() {
    setState(() {
      _horaAvistamiento = null;
    });
  }

  String? _validarDescripcion(String? valor) {
    final descripcion = valor?.trim() ?? '';

    if (descripcion.isEmpty) {
      return 'Ingresa una descripción del avistamiento.';
    }

    if (descripcion.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres.';
    }

    if (descripcion.length > 500) {
      return 'La descripción no puede superar 500 caracteres.';
    }

    return null;
  }

  String? _validarUbicacion(String? valor) {
    final ubicacion = valor?.trim() ?? '';

    if (ubicacion.isEmpty) {
      return 'Ingresa la ubicación aproximada.';
    }

    if (ubicacion.length < 3) {
      return 'La ubicación debe tener al menos 3 caracteres.';
    }

    if (ubicacion.length > 200) {
      return 'La ubicación no puede superar 200 caracteres.';
    }

    return null;
  }

  Future<void> _guardarAvistamiento() async {
    if (_guardando) {
      return;
    }

    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    final ahora = DateTime.now();

    final fechaSeleccionada = DateTime(
      _fechaAvistamiento.year,
      _fechaAvistamiento.month,
      _fechaAvistamiento.day,
    );

    final fechaActual = DateTime(ahora.year, ahora.month, ahora.day);

    if (fechaSeleccionada.isAfter(fechaActual)) {
      _mostrarMensaje(
        'La fecha del avistamiento no puede ser futura.',
        esError: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _service.registrarAvistamiento(
        reporteId: widget.reporteId,
        descripcion: _descripcionController.text,
        ubicacionAproximada: _ubicacionController.text,
        fechaAvistamiento: _formatearFecha(_fechaAvistamiento),
        horaAvistamiento: _formatearHora(_horaAvistamiento),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Avistamiento registrado correctamente.'),
            backgroundColor: Color(0xFF007C83),
          ),
        );

      Navigator.of(context).pop(true);
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
          _guardando = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar avistamiento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Card(
              color: Color(0xFFE8F3F8),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility_outlined, color: Color(0xFF007C83)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Registra únicamente información '
                        'aproximada y útil para localizar a '
                        'la mascota. Evita incluir datos '
                        'personales innecesarios.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _descripcionController,
              minLines: 4,
              maxLines: 7,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción del avistamiento',
                hintText: 'Describe cómo y dónde viste a la mascota.',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              validator: _validarDescripcion,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionController,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ubicación aproximada',
                hintText: 'Ejemplo: entrada del parque principal',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: _validarUbicacion,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha y hora',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF183B4E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF007C83),
                      ),
                      title: const Text('Fecha del avistamiento'),
                      subtitle: Text(_mostrarFecha(_fechaAvistamiento)),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: _seleccionarFecha,
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.schedule_outlined,
                        color: Color(0xFF007C83),
                      ),
                      title: const Text('Hora aproximada'),
                      subtitle: Text(
                        _horaAvistamiento == null
                            ? 'No registrada'
                            : _mostrarHora(_horaAvistamiento!),
                      ),
                      trailing: _horaAvistamiento == null
                          ? const Icon(Icons.access_time)
                          : IconButton(
                              onPressed: _eliminarHora,
                              tooltip: 'Eliminar hora',
                              icon: const Icon(Icons.clear),
                            ),
                      onTap: _seleccionarHora,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardarAvistamiento,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _guardando ? 'Guardando...' : 'Registrar avistamiento',
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _guardando
                  ? null
                  : () {
                      Navigator.of(context).pop(false);
                    },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
