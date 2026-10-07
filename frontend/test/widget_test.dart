import 'package:flutter_test/flutter_test.dart';
import 'package:pet_rescue_frontend/main.dart';

void main() {
  testWidgets('Muestra la pantalla de reportes activos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetRescueApp());

    await tester.pump();

    expect(find.text('Mascotas extraviadas'), findsOneWidget);

    expect(find.text('Reportar mascota'), findsOneWidget);
  });
}
