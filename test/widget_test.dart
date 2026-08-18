import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafedh_mobile/main.dart';

void main() {
  testWidgets('Hafedh App smoke test with Riverpod', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HafedhApp(),
      ),
    );
  });
}
