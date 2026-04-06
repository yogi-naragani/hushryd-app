import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hushryd_admin/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HushRydAdminApp()),
    );
    expect(find.text('HushRyd Admin'), findsOneWidget);
  });
}
