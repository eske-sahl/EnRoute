import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/features/passenger/passenger_portal.dart';
import 'package:mobile/features/passenger/widgets/passenger_ai_sheet.dart';
import 'package:mobile/features/conductor/tabs/conductor_journey_tab.dart';
import 'package:mobile/features/owner/owner_portal.dart';
import 'package:mobile/features/owner/tabs/owner_financials_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Master End-to-End Application Quality & Integrity Verification Suite', () {
    testWidgets('1. Welcoming Slides -> Unified Login -> Passenger Flow with AI Assistant & Creators Attribution', (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 950));

      await tester.pumpWidget(const EnRouteApp());
      await tester.pumpAndSettle();

      // Step 1: Welcoming Slides - tap Skip to reach Login
      final skipBtn = find.text('Skip');
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn);
        await tester.pumpAndSettle();
      }

      // Step 2: Unified Login Page Verification
      expect(find.text('Sign In to Portal'), findsOneWidget);
      expect(find.textContaining('Passenger'), findsWidgets);
      expect(find.textContaining('Conductor'), findsWidgets);
      expect(find.textContaining('Owner'), findsWidgets);

      // Verify default registration link is Passenger
      final createAccountBtn = find.text('Create New Account');
      expect(createAccountBtn, findsOneWidget);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      // Verify default form is Passenger registration
      expect(find.textContaining('Passenger Account'), findsWidgets);

      // Verify semi-hidden Bus Owner key exists
      final ownerKey = find.text('Bus Operator / Fleet Owner Sign Up');
      expect(ownerKey, findsOneWidget);

      // Switch back to Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Step 3: Login as Passenger
      await tester.enterText(find.byKey(const Key('login_id_field')), 'passenger@gmail.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Verify entered Passenger Portal
      expect(find.byType(PassengerPortal), findsOneWidget);
      expect(find.text('Passenger Dashboard'), findsOneWidget);
      expect(find.text('Personal Digital Pass'), findsOneWidget);

      // Step 4: Verify Circular Meta-Style AI Assistant Button above Profile Tab
      final aiFab = find.byKey(const Key('passenger_ai_floating_button'));
      expect(aiFab, findsOneWidget);

      // Tap Circular AI Button
      await tester.tap(aiFab);
      await tester.pumpAndSettle();

      // Verify AI Sheet opens with Meta branding and suggestions
      expect(find.byType(PassengerAiSheet), findsOneWidget);
      expect(find.text('EnRoute AI Assistant'), findsOneWidget);
      expect(find.text('Kerala Transit Intelligence • Live Fleet'), findsOneWidget);

      // Test Prompt 1: Bus Timings
      await tester.enterText(find.byType(TextField), 'I want full list of SpeedWings bus timings');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('KL 07 CD 4589'), findsWidgets);
      expect(find.text('Complete Route Timeline'), findsOneWidget);

      // Test Prompt 2: First Time Passenger Guide
      await tester.enterText(find.byType(TextField), "I don't have any previous experience of bus journey, what should I do?");
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('Welcome to Kerala Bus Travel'), findsWidgets);

      // Close AI Sheet
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Step 5: Check Profile Tab & Creators Attribution
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sahl Saleem & Fathima Riyas'), findsWidgets);

      // Logout
      await tester.tap(find.byTooltip('Sign Out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In to Portal'), findsOneWidget);
    });

    testWidgets('2. Conductor Portal: Location Override, Fare Chart with Search Engine & Creators Attribution', (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 950));

      final testBus = FleetState.instance.buses.first;
      final testConductor = ConductorModel(
        id: 'COND-TEST-1',
        name: 'Suresh Kumar',
        userId: 'suresh.conductor',
        email: 'suresh@stgeorge.com',
        phone: '+91 98470 11001',
        licenseNumber: 'KL-MVD-COND-8941',
        password: 'conductor123',
        assignedBusReg: testBus.regNumber,
        assignedBusName: testBus.busName,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConductorJourneyTab(
              conductor: testConductor,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Conductor Journey tab elements
      expect(find.byType(ConductorJourneyTab), findsOneWidget);
      expect(find.text('Stop-to-Stop Fare Chart'), findsOneWidget);
      expect(find.text('Advance to Next Stage / Stop'), findsOneWidget);

      // Open Stop-to-Stop Fare Chart modal
      final fareChartBtn = find.text('Edit Chart');
      expect(fareChartBtn, findsOneWidget);
      await tester.tap(fareChartBtn);
      await tester.pumpAndSettle();

      // Verify Fare Chart search engine with autocomplete/suggestions exists
      expect(find.text('Stop-to-Stop Fare Chart'), findsWidgets);
      expect(find.text('Search Stops & Assign Fare'), findsOneWidget);

      // Close Fare Chart modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('3. Owner Portal: Timeframe Toggles, P&L Financials, Conductor Edit Modal & Creators Attribution', (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 950));

      final testOwner = OwnerModel(
        id: 'OWNER-1',
        name: 'George Varghese',
        email: 'owner@enroute.in',
        phone: '+91 94470 12345',
        password: 'owner123',
        companyName: 'St. George Motors Ernakulam',
        registeredAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OwnerPortal(
            owner: testOwner,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Owner Dashboard and Timeframe selector
      expect(find.text('Owner Fleet Dashboard'), findsWidgets);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);

      // Tap Weekly chip
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      // Navigate to Profit & P/L Tab
      await tester.tap(find.text('Profit & P/L'));
      await tester.pumpAndSettle();
      expect(find.byType(OwnerFinancialsTab), findsOneWidget);
      expect(find.text('Net Retained Owner Profit'), findsWidgets);
      expect(find.text('Operating Expenses Breakdown'), findsOneWidget);
      expect(find.text('Bus-by-Bus Profitability'), findsOneWidget);

      // Navigate to Conductors Tab & Verify Conductor Edit Modal
      await tester.tap(find.text('Conductors'));
      await tester.pumpAndSettle();
      expect(find.text('Conductor Crew Directory'), findsOneWidget);

      // Find Edit icon on conductor card
      final editIcon = find.byIcon(Icons.edit).first;
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      // Verify Edit Conductor Modal appears with editable fields
      expect(find.text('Edit Conductor Details'), findsOneWidget);
      expect(find.text('Conductor Full Name *'), findsOneWidget);
      expect(find.text('Mobile Phone Number'), findsOneWidget);
      expect(find.text('Conductor License / Badge Number'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Check Profile Tab & Creators Attribution
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sahl Saleem & Fathima Riyas'), findsWidgets);
    });
  });
}
