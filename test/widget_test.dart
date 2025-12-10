import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart' as app;

void main() {
  testWidgets('home title renders', (WidgetTester tester) async {
    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Raja Kost'), findsOneWidget);
  });
}
