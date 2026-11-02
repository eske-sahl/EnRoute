import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('EnRoute app launches and shows login header and portal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const EnRouteApp());
    await tester.pumpAndSettle();

    expect(find.text('EnRoute'), findsOneWidget);
    // Tap Skip on welcoming slides to enter login screen
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Smart Kerala Transit & Live Ticketing'), findsOneWidget);
  });
}
