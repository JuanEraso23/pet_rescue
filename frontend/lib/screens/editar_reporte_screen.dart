import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../services/reporte_service.dart';

class EditarReporteScreen extends StatefulWidget {
  final DetalleReporte reporte;

  const EditarReporteScreen({super.key, required this.reporte});

  @override
  State<EditarReporteScreen> createState() {
    return _EditarReporteScreenState();
  }
}

class _EditarReporteScreenState extends State<EditarReporteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ReporteService _service = ReporteService();

  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _nombreController;
  late final TextEditingController _razaController;
  late final TextEditingController _colorController;
  late final TextEditingController _edadController;
  late final TextEditingController _senasController;
  late final TextEditingController _ubicacionController;

  late String _especie;
  late String _tamano;
  late DateTime _fechaExtravio;
  TimeOfDay? _horaExtravio;

  bool _guardando = false;

  static const List<String> _especies = [
    'Perro',
    'Gato',
    'Ave',
    'Roedor',
    'Otro',
  ];

  static const List<String> _tamanos = ['Pequeño', 'Mediano', 'Grande'];

  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(text: widget.reporte.titulo);

    _descripcionController = TextEditingController(
      text: widget.reporte.descripcion,
    );

    _nombreController = TextEditingController(
      text: widget.reporte.nombreMascota ?? '',
    );

    _razaController = TextEditingController(text: widget.reporte.raza ?? '');

    _colorController = TextEditingController(text: widget.reporte.color);

    _edadController = TextEditingController(
      text: widget.reporte.edadAproximada?.toString() ?? '',
    );

    _senasController = TextEditingController(
      text: widget.reporte.senasParticulares ?? '',
    );

    _ubicacionController = TextEditingController(
      text: widget.reporte.ubicacionExtravio,
    );

    _especie = widget.reporte.especie;
    _tamano = widget.reporte.tamano;

    _fechaExtravio =
        DateTime.tryParse(widget.reporte.fechaExtravio) ?? DateTime.now();

    _horaExtravio = _convertirHora(widget.reporte.horaExtravio);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _nombreController.dispose();
    _razaController.dispose();
    _colorController.dispose();
    _edadController.dispose();
    _senasController.dispose();
    _ubicacionController.dispose();

    super.dispose();
  }

  TimeOfDay? _convertirHora(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }

    final partes = valor.split(':');

    if (partes.length < 2) {
      return null;
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) {
      return null;
    }

    return TimeOfDay(hour: hora, minute: minuto);
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

  String? _textoOpcional(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty) {
      return null;
    }

    return texto;
  }

  int? _edadOpcional() {
    final texto = _edadController.text.trim();

    if (texto.isEmpty) {
      return null;
    }

    return int.tryParse(texto);
  }

  String? _validarTexto(String? valor, String nombre, int minimo) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return '$nombre es obligatorio.';
    }

    if (texto.length < minimo) {
      return '$nombre debe tener al menos '
          '$minimo caracteres.';
    }

    return null;
  }

  String? _validarEdad(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return null;
    }

    final edad = int.tryParse(texto);

    if (edad == null) {
      return 'La edad debe ser un número entero.';
    }

    if (edad < 0) {
      return 'La edad no puede ser negativa.';
    }

    return null;
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaExtravio,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha del extravío',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha == null || !mounted) {
      return;
    }

    setState(() {
      _fechaExtravio = fecha;
    });
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaExtravio ?? TimeOfDay.now(),
      helpText: 'Seleccionar hora aproximada',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (hora == null || !mounted) {
      return;
    }

    setState(() {
      _horaExtravio = hora;
    });
  }

  void _eliminarHora() {
    setState(() {
      _horaExtravio = null;
    });
  }

  Map<String, dynamic> _construirCambios() {
    final cambios = <String, dynamic>{};

    final titulo = _tituloController.text.trim();

    if (titulo != widget.reporte.titulo) {
      cambios['titulo'] = titulo;
    }

    final descripcion = _descripcionController.text.trim();

    if (descripcion != widget.reporte.descripcion) {
      cambios['descripcion'] = descripcion;
    }

    final nombre = _textoOpcional(_nombreController.text);

    if (nombre != widget.reporte.nombreMascota) {
      cambios['nombre_mascota'] = nombre;
    }

    if (_especie != widget.reporte.especie) {
      cambios['especie'] = _especie;
    }

    final raza = _textoOpcional(_razaController.text);

    if (raza != widget.reporte.raza) {
      cambios['raza'] = raza;
    }

    final color = _colorController.text.trim();

    if (color != widget.reporte.color) {
      cambios['color'] = color;
    }

    if (_tamano != widget.reporte.tamano) {
      cambios['tamano'] = _tamano;
    }

    final edad = _edadOpcional();

    if (edad != widget.reporte.edadAproximada) {
      cambios['edad_aproximada'] = edad;
    }

    final senas = _textoOpcional(_senasController.text);

    if (senas != widget.reporte.senasParticulares) {
      cambios['senas_particulares'] = senas;
    }

    final ubicacion = _ubicacionController.text.trim();

    if (ubicacion != widget.reporte.ubicacionExtravio) {
      cambios['ubicacion_extravio'] = ubicacion;
    }

    final fecha = _formatearFecha(_fechaExtravio);

    if (fecha != widget.reporte.fechaExtravio) {
      cambios['fecha_extravio'] = fecha;
    }

    final hora = _formatearHora(_horaExtravio);

    if (hora != widget.reporte.horaExtravio) {
      cambios['hora_extravio'] = hora;
    }

    return cambios;
  }

  Future<void> _guardarCambios() async {
    if (_guardando) {
      return;
    }

    FocusScope.of(context).unfocus();

    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    final fechaActual = DateTime.now();

    final hoy = DateTime(fechaActual.year, fechaActual.month, fechaActual.day);

    final fechaSeleccionada = DateTime(
      _fechaExtravio.year,
      _fechaExtravio.month,
      _fechaExtravio.day,
    );

    if (fechaSeleccionada.isAfter(hoy)) {
      _mostrarMensaje(
        'La fecha del extravío no puede ser futura.',
        esError: true,
      );
      return;
    }

    final cambios = _construirCambios();

    if (cambios.isEmpty) {
      _mostrarMensaje('No realizaste cambios en el reporte.', esError: true);
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final mensaje = await _service.actualizarReporte(
        reporteId: widget.reporte.id,
        cambios: cambios,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: const Color(0xFF007C83),
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

  Widget _construirEncabezadoSeccion(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, color: const Color(0xFF007C83)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B4E),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar información')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: const Color(0xFFE8F3F8),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.edit_note_outlined,
                      color: Color(0xFF007C83),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Estás editando el reporte '
                        '${widget.reporte.codigo}. '
                        'El estado, el contacto y las '
                        'fotografías se administran '
                        'por separado.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _construirEncabezadoSeccion(
              'Información del reporte',
              Icons.description_outlined,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              enabled: !_guardando,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título del reporte',
                prefixIcon: Icon(Icons.title_outlined),
              ),
              validator: (valor) {
                return _validarTexto(valor, 'El título', 3);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descripcionController,
              enabled: !_guardando,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              validator: (valor) {
                return _validarTexto(valor, 'La descripción', 10);
              },
            ),
            const SizedBox(height: 28),
            _construirEncabezadoSeccion(
              'Características de la mascota',
              Icons.pets_outlined,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              enabled: !_guardando,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre de la mascota (opcional)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _especie,
              decoration: const InputDecoration(
                labelText: 'Especie',
                prefixIcon: Icon(Icons.pets),
              ),
              items: _especies.map((especie) {
                return DropdownMenuItem(value: especie, child: Text(especie));
              }).toList(),
              onChanged: _guardando
                  ? null
                  : (valor) {
                      if (valor == null) {
                        return;
                      }

                      setState(() {
                        _especie = valor;
                      });
                    },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _razaController,
              enabled: !_guardando,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Raza (opcional)',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _colorController,
              enabled: !_guardando,
              maxLength: 50,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.palette_outlined),
              ),
              validator: (valor) {
                return _validarTexto(valor, 'El color', 2);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _tamano,
              decoration: const InputDecoration(
                labelText: 'Tamaño',
                prefixIcon: Icon(Icons.straighten_outlined),
              ),
              items: _tamanos.map((tamano) {
                return DropdownMenuItem(value: tamano, child: Text(tamano));
              }).toList(),
              onChanged: _guardando
                  ? null
                  : (valor) {
                      if (valor == null) {
                        return;
                      }

                      setState(() {
                        _tamano = valor;
                      });
                    },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _edadController,
              enabled: !_guardando,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad aproximada (opcional)',
                suffixText: 'años',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: _validarEdad,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _senasController,
              enabled: !_guardando,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Señas particulares (opcional)',
                prefixIcon: Icon(Icons.search_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            _construirEncabezadoSeccion(
              'Información del extravío',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionController,
              enabled: !_guardando,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ubicación aproximada',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (valor) {
                return _validarTexto(valor, 'La ubicación', 3);
              },
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF007C83),
                      ),
                      title: const Text('Fecha del extravío'),
                      subtitle: Text(_mostrarFecha(_fechaExtravio)),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: _guardando ? null : _seleccionarFecha,
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
                        _horaExtravio == null
                            ? 'No registrada'
                            : _mostrarHora(_horaExtravio!),
                      ),
                      trailing: _horaExtravio == null
                          ? const Icon(Icons.access_time)
                          : IconButton(
                              onPressed: _guardando ? null : _eliminarHora,
                              tooltip: 'Eliminar hora',
                              icon: const Icon(Icons.clear),
                            ),
                      onTap: _guardando ? null : _seleccionarHora,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardarCambios,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
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
