import 'package:flutter_test/flutter_test.dart';
import 'package:pet_rescue_frontend/main.dart';

void main() {
  testWidgets('Muestra la pantalla de reportes', (WidgetTester tester) async {
    await tester.pumpWidget(const PetRescueApp());

    await tester.pump();

    expect(find.text('Reportes de mascotas'), findsOneWidget);

    expect(find.text('Reportar mascota'), findsOneWidget);
  });
}
