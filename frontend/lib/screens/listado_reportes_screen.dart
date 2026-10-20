import 'package:flutter/material.dart';

import '../models/resumen_reporte.dart';
import '../services/reporte_service.dart';
import 'detalle_reporte_screen.dart';
import 'registro_reporte_screen.dart';

class ListadoReportesScreen extends StatefulWidget {
  const ListadoReportesScreen({super.key});

  @override
  State<ListadoReportesScreen> createState() => _ListadoReportesScreenState();
}

class _ListadoReportesScreenState extends State<ListadoReportesScreen> {
  final ReporteService _service = ReporteService();
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _edadMaximaController = TextEditingController();
  final TextEditingController _senasController = TextEditingController();

  late Future<List<ResumenReporte>> _reportes;

  String _especieSeleccionada = 'Todas';
  String _estadoSeleccionado = 'Todos';
  String _tamanoSeleccionado = 'Todos';
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  bool _aplicandoFiltros = false;
  bool _mostrarCaracteristicas = false;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _ubicacionController.dispose();
    _razaController.dispose();
    _colorController.dispose();
    _edadMaximaController.dispose();
    _senasController.dispose();
    super.dispose();
  }

  int? _obtenerEdadMaxima() {
    final texto = _edadMaximaController.text.trim();
    if (texto.isEmpty) return null;
    return int.tryParse(texto);
  }

  void _cargarReportes() {
    _reportes = _service.consultarReportes(
      especie: _especieSeleccionada,
      ubicacion: _ubicacionController.text,
      fechaDesde: _fechaDesde,
      fechaHasta: _fechaHasta,
      raza: _razaController.text,
      color: _colorController.text,
      tamano: _tamanoSeleccionado,
      edadMaxima: _obtenerEdadMaxima(),
      senas: _senasController.text,
    );
  }

  Future<void> _actualizarReportes() async {
    setState(_cargarReportes);
    await _reportes;
  }

  Future<void> _aplicarFiltros() async {
    if (_fechaDesde != null &&
        _fechaHasta != null &&
        _fechaDesde!.isAfter(_fechaHasta!)) {
      _mostrarMensaje(
        'La fecha inicial no puede ser posterior a la fecha final.',
        esError: true,
      );
      return;
    }

    final edadTexto = _edadMaximaController.text.trim();
    if (edadTexto.isNotEmpty) {
      final edad = int.tryParse(edadTexto);
      if (edad == null || edad < 0) {
        _mostrarMensaje(
          'La edad máxima debe ser un número entero mayor o igual a cero.',
          esError: true,
        );
        return;
      }
    }

    setState(() {
      _aplicandoFiltros = true;
      _cargarReportes();
    });

    try {
      await _reportes;
    } catch (_) {
      // FutureBuilder presenta el error.
    } finally {
      if (mounted) setState(() => _aplicandoFiltros = false);
    }
  }

  Future<void> _limpiarFiltros() async {
    _busquedaController.clear();
    _ubicacionController.clear();
    _razaController.clear();
    _colorController.clear();
    _edadMaximaController.clear();
    _senasController.clear();

    setState(() {
      _especieSeleccionada = 'Todas';
      _estadoSeleccionado = 'Todos';
      _tamanoSeleccionado = 'Todos';
      _fechaDesde = null;
      _fechaHasta = null;
      _mostrarCaracteristicas = false;
      _aplicandoFiltros = true;
      _cargarReportes();
    });

    try {
      await _reportes;
    } catch (_) {
      // FutureBuilder presenta el error.
    } finally {
      if (mounted) setState(() => _aplicandoFiltros = false);
    }
  }

  Future<void> _abrirRegistro() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegistroReporteScreen()));
    if (mounted) await _actualizarReportes();
  }

  Future<void> _abrirDetalle(ResumenReporte reporte) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleReporteScreen(reporteId: reporte.id),
      ),
    );
    if (mounted) await _actualizarReportes();
  }

  Future<void> _abrirGestion(ResumenReporte reporte) async {
    if (reporte.estado != 'Activo') {
      _mostrarMensaje(
        'Solo se pueden gestionar reportes activos.',
        esError: true,
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DetalleReporteScreen(reporteId: reporte.id, permitirGestion: true),
      ),
    );
    if (mounted) await _actualizarReportes();
  }

  Future<void> _seleccionarFecha({required bool desde}) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: desde
          ? (_fechaDesde ?? DateTime.now())
          : (_fechaHasta ?? _fechaDesde ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: desde ? 'Seleccionar fecha inicial' : 'Seleccionar fecha final',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha == null || !mounted) return;
    setState(() {
      if (desde) {
        _fechaDesde = fecha;
      } else {
        _fechaHasta = fecha;
      }
    });
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

  List<ResumenReporte> _filtrarLocalmente(List<ResumenReporte> reportes) {
    final texto = _busquedaController.text.trim().toLowerCase();
    return reportes.where((reporte) {
      final coincideTexto =
          texto.isEmpty ||
          reporte.codigo.toLowerCase().contains(texto) ||
          reporte.titulo.toLowerCase().contains(texto) ||
          (reporte.nombreMascota ?? '').toLowerCase().contains(texto) ||
          reporte.ubicacionExtravio.toLowerCase().contains(texto);
      final coincideEstado =
          _estadoSeleccionado == 'Todos' ||
          reporte.estado == _estadoSeleccionado;
      return coincideTexto && coincideEstado;
    }).toList();
  }

  bool get _hayFiltros =>
      _busquedaController.text.trim().isNotEmpty ||
      _ubicacionController.text.trim().isNotEmpty ||
      _razaController.text.trim().isNotEmpty ||
      _colorController.text.trim().isNotEmpty ||
      _edadMaximaController.text.trim().isNotEmpty ||
      _senasController.text.trim().isNotEmpty ||
      _especieSeleccionada != 'Todas' ||
      _estadoSeleccionado != 'Todos' ||
      _tamanoSeleccionado != 'Todos' ||
      _fechaDesde != null ||
      _fechaHasta != null;

  String _formatearFecha(String fecha) {
    final valor = DateTime.tryParse(fecha);
    return valor == null ? fecha : _formatearDateTime(valor);
  }

  String _formatearDateTime(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Encontrado':
        return const Color(0xFFDDF5EF);
      case 'Cerrado':
        return const Color(0xFFE2E8F0);
      default:
        return const Color(0xFFFFF1C7);
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Encontrado':
        return Icons.check_circle_outline;
      case 'Cerrado':
        return Icons.lock_outline;
      default:
        return Icons.schedule_outlined;
    }
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String etiqueta,
    required String ayuda,
    required IconData icono,
    TextInputType? teclado,
  }) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        enabled: !_aplicandoFiltros,
        keyboardType: teclado,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: ayuda,
          prefixIcon: Icon(icono),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _selectorFecha({
    required String etiqueta,
    required DateTime? fecha,
    required bool desde,
  }) {
    return SizedBox(
      width: 220,
      child: OutlinedButton(
        onPressed: _aplicandoFiltros
            ? null
            : () => _seleccionarFecha(desde: desde),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fecha == null ? etiqueta : _formatearDateTime(fecha),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (fecha != null)
              IconButton(
                tooltip: 'Limpiar $etiqueta',
                onPressed: _aplicandoFiltros
                    ? null
                    : () => setState(() {
                        if (desde) {
                          _fechaDesde = null;
                        } else {
                          _fechaHasta = null;
                        }
                      }),
                icon: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirFiltros(int cantidadResultados) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _busquedaController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Buscar reportes',
                  hintText: 'Código, título, mascota o ubicación',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _busquedaController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar búsqueda',
                          onPressed: () => setState(_busquedaController.clear),
                          icon: const Icon(Icons.close),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('especie-$_especieSeleccionada'),
                      initialValue: _especieSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Especie',
                        prefixIcon: Icon(Icons.pets),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                        DropdownMenuItem(value: 'Perro', child: Text('Perro')),
                        DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                        DropdownMenuItem(value: 'Ave', child: Text('Ave')),
                        DropdownMenuItem(
                          value: 'Roedor',
                          child: Text('Roedor'),
                        ),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: _aplicandoFiltros
                          ? null
                          : (valor) => setState(
                              () => _especieSeleccionada = valor ?? 'Todas',
                            ),
                    ),
                  ),
                  _campoTexto(
                    controller: _ubicacionController,
                    etiqueta: 'Ubicación',
                    ayuda: 'Ejemplo: parque',
                    icono: Icons.location_on_outlined,
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('estado-$_estadoSeleccionado'),
                      initialValue: _estadoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'Activo',
                          child: Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value: 'Encontrado',
                          child: Text('Encontrado'),
                        ),
                        DropdownMenuItem(
                          value: 'Cerrado',
                          child: Text('Cerrado'),
                        ),
                      ],
                      onChanged: (valor) => setState(
                        () => _estadoSeleccionado = valor ?? 'Todos',
                      ),
                    ),
                  ),
                  _selectorFecha(
                    etiqueta: 'Fecha desde',
                    fecha: _fechaDesde,
                    desde: true,
                  ),
                  _selectorFecha(
                    etiqueta: 'Fecha hasta',
                    fecha: _fechaHasta,
                    desde: false,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                initiallyExpanded: _mostrarCaracteristicas,
                onExpansionChanged: (valor) {
                  setState(() => _mostrarCaracteristicas = valor);
                },
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Características físicas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Raza, color, tamaño, edad y señas particulares',
                ),
                leading: const Icon(Icons.tune_outlined),
                childrenPadding: const EdgeInsets.only(bottom: 12),
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _campoTexto(
                        controller: _razaController,
                        etiqueta: 'Raza',
                        ayuda: 'Ejemplo: mestizo',
                        icono: Icons.pets_outlined,
                      ),
                      _campoTexto(
                        controller: _colorController,
                        etiqueta: 'Color',
                        ayuda: 'Ejemplo: negro',
                        icono: Icons.palette_outlined,
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('tamano-$_tamanoSeleccionado'),
                          initialValue: _tamanoSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Tamaño',
                            prefixIcon: Icon(Icons.straighten_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Todos',
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem(
                              value: 'Pequeño',
                              child: Text('Pequeño'),
                            ),
                            DropdownMenuItem(
                              value: 'Mediano',
                              child: Text('Mediano'),
                            ),
                            DropdownMenuItem(
                              value: 'Grande',
                              child: Text('Grande'),
                            ),
                          ],
                          onChanged: _aplicandoFiltros
                              ? null
                              : (valor) => setState(
                                  () => _tamanoSeleccionado = valor ?? 'Todos',
                                ),
                        ),
                      ),
                      _campoTexto(
                        controller: _edadMaximaController,
                        etiqueta: 'Edad máxima',
                        ayuda: 'Ejemplo: 5',
                        icono: Icons.cake_outlined,
                        teclado: TextInputType.number,
                      ),
                      _campoTexto(
                        controller: _senasController,
                        etiqueta: 'Señas particulares',
                        ayuda: 'Ejemplo: collar azul',
                        icono: Icons.description_outlined,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _aplicandoFiltros ? null : _aplicarFiltros,
                    icon: _aplicandoFiltros
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.filter_alt_outlined),
                    label: const Text('Aplicar filtros'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _hayFiltros && !_aplicandoFiltros
                        ? _limpiarFiltros
                        : null,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Limpiar filtros'),
                  ),
                  Text(
                    '$cantidadResultados '
                    '${cantidadResultados == 1 ? 'resultado' : 'resultados'}',
                    style: const TextStyle(
                      color: Color(0xFF667781),
                      fontWeight: FontWeight.w600,
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

  Widget _construirImagen(ResumenReporte reporte) {
    final url = reporte.fotografiaUrlCompleta;
    if (url == null) {
      return Container(
        height: 190,
        width: double.infinity,
        color: const Color(0xFFE8F0F3),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 56,
              color: Color(0xFF667781),
            ),
            SizedBox(height: 10),
            Text(
              'Fotografía pendiente',
              style: TextStyle(
                color: Color(0xFF667781),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Color(0xFFE8F0F3),
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 56,
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirTarjeta(ResumenReporte reporte) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirDetalle(reporte),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirImagen(reporte),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(reporte.codigo)),
                      Chip(
                        label: Text(reporte.estado),
                        avatar: Icon(_iconoEstado(reporte.estado), size: 18),
                        backgroundColor: _colorEstado(reporte.estado),
                      ),
                      Chip(label: Text(reporte.especie)),
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
                  const SizedBox(height: 12),
                  _DatoResumen(
                    icono: Icons.badge_outlined,
                    etiqueta: 'Mascota',
                    valor: reporte.nombreMascota ?? 'No registrada',
                  ),
                  _DatoResumen(
                    icono: Icons.location_on_outlined,
                    etiqueta: 'Ubicación',
                    valor: reporte.ubicacionExtravio,
                  ),
                  _DatoResumen(
                    icono: Icons.calendar_month_outlined,
                    etiqueta: 'Fecha',
                    valor: _formatearFecha(reporte.fechaExtravio),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _abrirDetalle(reporte),
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Ver detalle'),
                      ),
                      if (reporte.estado == 'Activo')
                        OutlinedButton.icon(
                          onPressed: () => _abrirGestion(reporte),
                          icon: const Icon(Icons.settings_outlined),
                          label: const Text('Gestionar reporte'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista(List<ResumenReporte> reportes) {
    if (reportes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 70),
          const Icon(
            Icons.search_off_outlined,
            size: 80,
            color: Color(0xFF667781),
          ),
          const SizedBox(height: 18),
          const Text(
            'No se encontraron reportes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B4E),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Prueba con otros criterios o limpia los filtros.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: _limpiarFiltros,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpiar filtros'),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        if (columnas == 1) {
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reportes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 18),
            itemBuilder: (_, index) => _construirTarjeta(reportes[index]),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reportes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: columnas == 3 ? 0.78 : 0.82,
          ),
          itemBuilder: (_, index) => _construirTarjeta(reportes[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de mascotas'),
        actions: [
          IconButton(
            onPressed: _aplicandoFiltros ? null : _actualizarReportes,
            tooltip: 'Actualizar reportes',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ResumenReporte>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_aplicandoFiltros) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _VistaErrorListado(
              mensaje: snapshot.error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              onReintentar: _actualizarReportes,
            );
          }

          final reportes = snapshot.data ?? <ResumenReporte>[];
          final filtrados = _filtrarLocalmente(reportes);

          return Column(
            children: [
              _construirFiltros(filtrados.length),
              Expanded(child: _construirLista(filtrados)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirRegistro,
        icon: const Icon(Icons.add),
        label: const Text('Reportar mascota'),
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _DatoResumen({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: const Color(0xFF007C83)),
          const SizedBox(width: 10),
          SizedBox(
            width: 74,
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

class _VistaErrorListado extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onReintentar;

  const _VistaErrorListado({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar los reportes.',
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
