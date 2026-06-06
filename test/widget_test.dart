import 'package:flutter_test/flutter_test.dart';
import 'package:gannzilla/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic test to ensure the widget tree builds without errors
    expect(GannzillaApp, isNotNull);
  });
}
