import 'package:flutter_test/flutter_test.dart';
import 'package:pov_admin/main.dart';

void main() {
  testWidgets('Admin smoke', (t) async {
    await t.pumpWidget(const PovAdminApp());
    expect(find.text('POV Admin'), findsOneWidget);
  });
}
