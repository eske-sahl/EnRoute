import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('EnRoute app launches and shows login header and portal', (WidgetTester tester) async {
    await tester.pumpWidget(const EnRouteApp());
    await tester.pumpAndSettle();

    expect(find.text('EnRoute'), findsOneWidget);
    expect(find.text('Smart Kerala Transit & Live Ticketing'), findsOneWidget);
  });
}
