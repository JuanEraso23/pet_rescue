import 'package:flutter_test/flutter_test.dart';
import 'package:pet_rescue_frontend/main.dart';

void main() {
  testWidgets('Muestra la pantalla de registro de una mascota perdida', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetRescueApp());

    expect(find.text('Reportar mascota perdida'), findsOneWidget);

    expect(find.text('Información del reporte'), findsOneWidget);
  });
}
