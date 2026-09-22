import 'package:flutter/material.dart';

import '../services/reporte_service.dart';
import 'confirmacion_reporte_screen.dart';

class RegistroReporteScreen extends StatefulWidget {
  const RegistroReporteScreen({super.key});

  @override
  State<RegistroReporteScreen> createState() {
    return _RegistroReporteScreenState();
  }
}

class _RegistroReporteScreenState extends State<RegistroReporteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ReporteService _service = ReporteService();

  final TextEditingController _tituloController = TextEditingController();

  final TextEditingController _descripcionController = TextEditingController();

  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _razaController = TextEditingController();

  final TextEditingController _colorController = TextEditingController();

  final TextEditingController _edadController = TextEditingController();

  final TextEditingController _senasController = TextEditingController();

  final TextEditingController _ubicacionController = TextEditingController();

  String? _especie;
  String? _tamano;
  DateTime? _fechaExtravio;
  TimeOfDay? _horaExtravio;

  bool _cargando = false;

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

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaExtravio = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        _horaExtravio = hora;
      });
    }
  }

  Future<void> _publicarReporte() async {
    FocusScope.of(context).unfocus();

    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    if (_especie == null) {
      _mostrarMensaje('Selecciona la especie.');
      return;
    }

    if (_tamano == null) {
      _mostrarMensaje('Selecciona el tamaño.');
      return;
    }

    if (_fechaExtravio == null) {
      _mostrarMensaje('Selecciona la fecha del extravío.');
      return;
    }

    setState(() {
      _cargando = true;
    });

    final datos = <String, dynamic>{
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'especie': _especie,
      'nombre': _textoOpcional(_nombreController.text),
      'raza': _textoOpcional(_razaController.text),
      'color': _colorController.text.trim(),
      'tamano': _tamano,
      'edad_aproximada': _edadOpcional(),
      'senas_particulares': _textoOpcional(_senasController.text),
      'ubicacion_extravio': _ubicacionController.text.trim(),
      'fecha_extravio': _formatearFecha(_fechaExtravio!),
      'hora_extravio': _formatearHora(_horaExtravio),
    };

    try {
      final reporte = await _service.crearReporte(datos);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConfirmacionReporteScreen(reporte: reporte),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  String? _textoOpcional(String texto) {
    final valor = texto.trim();

    if (valor.isEmpty) {
      return null;
    }

    return valor;
  }

  int? _edadOpcional() {
    final texto = _edadController.text.trim();

    if (texto.isEmpty) {
      return null;
    }

    return int.tryParse(texto);
  }

  String _formatearFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');

    final dia = fecha.day.toString().padLeft(2, '0');

    return '${fecha.year}-$mes-$dia';
  }

  String? _formatearHora(TimeOfDay? hora) {
    if (hora == null) {
      return null;
    }

    final horas = hora.hour.toString().padLeft(2, '0');

    final minutos = hora.minute.toString().padLeft(2, '0');

    return '$horas:$minutos';
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String? _validarTexto(String? valor, String nombre, int minimo) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return '$nombre es obligatorio.';
    }

    if (texto.length < minimo) {
      return '$nombre debe tener mínimo '
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar mascota perdida')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Información del reporte',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF183B4E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa la información para '
                'publicar el reporte.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del reporte',
                  hintText: 'Ejemplo: Max se perdió',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (valor) {
                  return _validarTexto(valor, 'El título', 3);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText:
                      'Describe brevemente '
                      'lo ocurrido',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (valor) {
                  return _validarTexto(valor, 'La descripción', 10);
                },
              ),
              const SizedBox(height: 28),
              Text(
                'Características de la mascota',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF183B4E),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _especie,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: const ['Perro', 'Gato', 'Ave', 'Roedor', 'Otro'].map((
                  especie,
                ) {
                  return DropdownMenuItem(value: especie, child: Text(especie));
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _especie = valor;
                  });
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecciona la especie.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la mascota',
                  hintText: 'Opcional',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  hintText: 'Opcional',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color principal',
                  prefixIcon: Icon(Icons.palette),
                ),
                validator: (valor) {
                  return _validarTexto(valor, 'El color', 2);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tamano,
                decoration: const InputDecoration(
                  labelText: 'Tamaño',
                  prefixIcon: Icon(Icons.straighten),
                ),
                items: const ['Pequeño', 'Mediano', 'Grande'].map((tamano) {
                  return DropdownMenuItem(value: tamano, child: Text(tamano));
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _tamano = valor;
                  });
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecciona el tamaño.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Edad aproximada',
                  hintText: 'Opcional',
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: _validarEdad,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senasController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Señas particulares',
                  hintText:
                      'Marcas, cicatrices '
                      'o accesorios',
                  prefixIcon: Icon(Icons.search),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Información del extravío',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF183B4E),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación aproximada',
                  hintText: 'Ejemplo: Sector centro',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (valor) {
                  return _validarTexto(valor, 'La ubicación', 3);
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Fecha del extravío'),
                  subtitle: Text(
                    _fechaExtravio == null
                        ? 'Seleccionar fecha'
                        : _formatearFecha(_fechaExtravio!),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _seleccionarFecha,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Hora aproximada'),
                  subtitle: Text(
                    _horaExtravio == null
                        ? 'Opcional'
                        : _horaExtravio!.format(context),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _seleccionarHora,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _cargando ? null : _publicarReporte,
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.publish),
                  label: Text(_cargando ? 'Publicando...' : 'Publicar reporte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
