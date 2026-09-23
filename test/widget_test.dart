import 'package:flutter_test/flutter_test.dart';
import 'package:sap_b1_service_layer_demo/main.dart';

void main() {
  testWidgets('Vérifie le chargement de l\'écran de connexion', (WidgetTester tester) async {
    await tester.pumpWidget(const SapDemoApp());
    expect(find.text('SAP Service Layer Demo'), findsOneWidget);
  });
}
