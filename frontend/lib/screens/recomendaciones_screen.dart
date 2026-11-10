import 'package:flutter/material.dart';

/// HU22: recomendaciones para quien perdió o encontró una mascota.
/// El contenido es estático y no depende del backend.
class RecomendacionesScreen extends StatelessWidget {
  const RecomendacionesScreen({super.key});

  static const List<_Recomendacion> _mascotaPerdida = [
    _Recomendacion(
      Icons.travel_explore_outlined,
      'Revisa la zona del extravío y consulta con vecinos o '
      'establecimientos cercanos.',
    ),
    _Recomendacion(
      Icons.photo_camera_outlined,
      'Publica información clara y una fotografía reciente.',
    ),
    _Recomendacion(
      Icons.update_outlined,
      'Mantén el reporte actualizado y revisa los avistamientos.',
    ),
    _Recomendacion(
      Icons.privacy_tip_outlined,
      'Evita divulgar datos personales innecesarios.',
    ),
    _Recomendacion(
      Icons.task_alt_outlined,
      'Marca el reporte como resuelto cuando corresponda.',
    ),
  ];

  static const List<_Recomendacion> _mascotaEncontrada = [
    _Recomendacion(
      Icons.badge_outlined,
      'Verifica si tiene placa o indicios de identificación.',
    ),
    _Recomendacion(
      Icons.manage_search_outlined,
      'Consulta los reportes existentes antes de crear información '
      'duplicada.',
    ),
    _Recomendacion(
      Icons.place_outlined,
      'Registra una ubicación aproximada y una fotografía.',
    ),
    _Recomendacion(
      Icons.water_drop_outlined,
      'Proporciona agua y un espacio seguro cuando sea posible.',
    ),
    _Recomendacion(
      Icons.health_and_safety_outlined,
      'No pongas en riesgo tu seguridad ni la del animal.',
    ),
    _Recomendacion(
      Icons.local_hospital_outlined,
      'Contacta servicios veterinarios o autoridades competentes '
      'cuando corresponda.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '¿Qué hacer si pierdes o encuentras una mascota?',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estas recomendaciones te ayudan a actuar con rapidez y '
                      'aumentar las posibilidades de reunir a la mascota con '
                      'su familia.',
                      style: tema.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, restricciones) {
                        final anchoTarjeta = restricciones.maxWidth >= 720
                            ? (restricciones.maxWidth - 16) / 2
                            : restricciones.maxWidth;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: anchoTarjeta,
                              child: const _TarjetaRecomendaciones(
                                titulo: 'Mascota perdida',
                                icono: Icons.pets,
                                recomendaciones: _mascotaPerdida,
                              ),
                            ),
                            SizedBox(
                              width: anchoTarjeta,
                              child: const _TarjetaRecomendaciones(
                                titulo: 'Mascota encontrada',
                                icono: Icons.volunteer_activism_outlined,
                                recomendaciones: _mascotaEncontrada,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const _AvisoSeguridad(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recomendacion {
  final IconData icono;
  final String texto;

  const _Recomendacion(this.icono, this.texto);
}

class _TarjetaRecomendaciones extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<_Recomendacion> recomendaciones;

  const _TarjetaRecomendaciones({
    required this.titulo,
    required this.icono,
    required this.recomendaciones,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: tema.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final recomendacion in recomendaciones)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      recomendacion.icono,
                      size: 20,
                      color: tema.colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(recomendacion.texto)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvisoSeguridad extends StatelessWidget {
  const _AvisoSeguridad();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tema.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: tema.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Seguridad y privacidad: comparte solo la información '
              'necesaria, reúnete en lugares públicos y no entregues datos '
              'personales o dinero a cambio de información.',
              style: TextStyle(color: tema.colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
