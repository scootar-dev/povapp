import 'package:flutter_test/flutter_test.dart';
import 'package:pov_customer/main.dart';

void main() {
  testWidgets('POV Customer smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PovCustomerApp());
    expect(find.text('POV STUDIO'), findsOneWidget);
  });
}
