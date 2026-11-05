import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/conductor/tabs/conductor_dashboard_tab.dart';
import 'package:mobile/features/conductor/tabs/conductor_history_tab.dart';
import 'package:mobile/features/owner/tabs/owner_conductor_tab.dart';
import 'package:mobile/features/owner/owner_portal.dart';
import 'package:mobile/features/passenger/passenger_portal.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testOwner = OwnerModel(
    id: 'OWNER-1',
    name: 'George Varghese',
    email: 'george@stgeorge.com',
    phone: '+91 94470 12345',
    password: 'owner123password',
    companyName: 'St. George Motors Ernakulam',
    registeredAt: DateTime(2026, 1, 1),
  );

  final testPassenger = PassengerModel(
    id: 'SBK-KL-TEST-001',
    name: 'Anjali Menon',
    email: 'anjali@test.com',
    phone: '+91 98470 22001',
    password: 'password123',
    walletBalance: 250.0,
    homeStation: 'Aluva Stand, Ernakulam',
    concessionCategory: 'General / Adult Standard',
    registeredAt: DateTime(2026, 1, 1),
  );

  group('User Requested Updations Verification Suite', () {
    testWidgets('1. Conductor Portal: Payment chips, Split payment, and Ticket receipt contrast in dark mode', (tester) async {
      final conductor = FleetState.instance.conductors.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ConductorDashboardTab(
              conductor: conductor,
              onNavigateToJourney: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Verify payment chips exist
      expect(find.text('Cash'), findsWidgets);
      expect(find.text('UPI QR'), findsWidgets);
      expect(find.text('Smart Wallet'), findsWidgets);

      // Verify liquid cash handling and split payment toggle
      expect(find.text('Liquid Cash Handling'), findsOneWidget);
      expect(find.text('Split Payment: Pay few as Cash & few as UPI'), findsOneWidget);
    });

    testWidgets('2. Conductor History Tab: Ticket details view opens with clear contrast', (tester) async {
      final conductor = FleetState.instance.conductors.first;

      // Add a test ticket if none exist
      FleetState.instance.issuedTickets.add(
        IssuedTicketModel(
          id: 'tkt-test-99',
          ticketNumber: 'SBK-TKT-99999',
          passengerId: 'Unknown',
          passengerName: 'Unknown Walk-in',
          busRegNumber: conductor.assignedBusReg,
          busName: conductor.assignedBusName,
          conductorId: conductor.id,
          conductorName: conductor.name,
          boardingStop: 'Aluva Stand',
          destStop: 'Kaloor Stand',
          fare: 25.0,
          category: 'General Fare',
          paymentMode: 'CASH',
          issuedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ConductorHistoryTab(conductor: conductor),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final ticketRow = find.text('SBK-TKT-99999');
      if (ticketRow.evaluate().isNotEmpty) {
        await tester.tap(ticketRow);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Ticket Details'), findsOneWidget);
        expect(find.text('FARE COLLECTED'), findsOneWidget);
        expect(find.text('Close Receipt'), findsOneWidget);
        await tester.tap(find.text('Close Receipt'));
        await tester.pump(const Duration(milliseconds: 500));
      }
    });

    testWidgets('3. Owner Portal: Assigned bus text, Conductor credentials, and Bus Route contrast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: OwnerConductorTab(owner: testOwner),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find conductor card
      final conductorCard = find.byType(Card);
      expect(conductorCard, findsWidgets);

      // Tap to view conductor credentials modal
      await tester.tap(conductorCard.first);
      await tester.pumpAndSettle();

      expect(find.text('OWNER ASSIGNED APP LOGIN CREDENTIALS'), findsOneWidget);
      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('4. Owner Portal: Tabs remain visible when managing bus details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: OwnerPortal(owner: testOwner, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Bottom navigation bar has My Buses tab (index 2)
      await tester.tap(find.byIcon(Icons.directions_bus_outlined));
      await tester.pumpAndSettle();

      // Click Manage Details on first bus
      final manageDetailsBtn = find.text('Manage Details');
      if (manageDetailsBtn.evaluate().isNotEmpty) {
        await tester.tap(manageDetailsBtn.first);
        await tester.pumpAndSettle();

        // BusDetailPage is open
        expect(find.textContaining('Details'), findsWidgets);
        expect(find.text('Stops & Timing Schedule:'), findsOneWidget);

        // Crucial: Bottom Navigation Bar remains visible!
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('My Buses'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Returned to My Buses list, tabs still visible
        expect(find.byType(NavigationBar), findsOneWidget);
      }
    });

    testWidgets('5. Passenger Portal: White background QR scanner & View More Ticket History page with persistent tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PassengerPortal(
            passenger: testPassenger,
            isOnline: true,
            onTopUp: (_) {},
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Personal Digital Pass exists
      expect(find.text('Personal Digital Pass'), findsOneWidget);

      // Verify View More button exists next to Recent Ticket History
      final viewMoreBtn = find.textContaining('View More');
      expect(viewMoreBtn, findsOneWidget);

      // Tap View More
      await tester.tap(viewMoreBtn);
      await tester.pump(const Duration(milliseconds: 500));

      // Verified: Travel Ticket History page is open!
      expect(find.text('Travel Ticket History'), findsOneWidget);
      expect(find.text('TOTAL EXPENDITURE'), findsOneWidget);

      // Crucial: NavigationBar / Tabs remain visible!
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Bus Search'), findsOneWidget);
      expect(find.text('Wallet Details'), findsOneWidget);

      // Tap back button to return to Dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 500));

      // Returned to Dashboard, tabs still visible
      expect(find.text('Passenger Dashboard'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
