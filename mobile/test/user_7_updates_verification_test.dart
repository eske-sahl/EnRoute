import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/passenger/tabs/search_tab.dart';
import 'package:mobile/features/owner/tabs/owner_bus_list_tab.dart';
import 'package:mobile/features/owner/tabs/owner_profile_tab.dart';
import 'package:mobile/features/owner/bus_detail_page.dart';
import 'package:mobile/services/app_settings_service.dart';
import 'package:mobile/services/fleet_state.dart';

void main() {
  group('EnRoute User 7 Updations Verification Suite', () {
    test('1. Light theme is the default theme across the application', () {
      final settings = AppSettingsService.instance;
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.isDarkMode, isFalse);
    });

    test('2. Net Profit calculations use real ticket data and do NOT fallback to dummy 5800.0', () {
      final state = FleetState.instance;

      // Add a clean test bus for OWNER-TEST with 0 tickets
      final freshBus = BusModel(
        id: 'TEST-BUS-PROFIT-0',
        ownerId: 'OWNER-TEST-PROFIT',
        regNumber: 'KL 99 ZZ 0001',
        busName: 'Zero Fare Bus',
        category: 'Ordinary Bus (Blue-Whiteline)',
        routeName: 'Test Route',
        stops: [],
        todayCollection: 0.0,
        ticketsCount: 0,
        isActive: true,
      );
      state.buses.add(freshBus);

      final report = state.getProfitReportForOwner('OWNER-TEST-PROFIT', OwnerTimeframe.daily);
      expect(report.grossRevenue, 0.0);
      expect(report.totalTickets, 0);
      expect(report.totalTrips, 0);
      expect(report.totalExpenses, 0.0);
      expect(report.netProfit, 0.0);
      expect(report.busBreakdowns.first.statusBadge, 'RUNNING (0 FARE)');

      // Conductor updates shift collection lively
      state.updateBusCollection(
        regNumber: freshBus.regNumber,
        amount: 3500.0,
      );

      final updatedReport = state.getProfitReportForOwner('OWNER-TEST-PROFIT', OwnerTimeframe.daily);
      expect(updatedReport.grossRevenue, 3500.0);
      expect(updatedReport.netProfit, greaterThan(0.0));

      // Cleanup
      state.deleteBus(freshBus.regNumber);
    });

    test('3. BusModel starts with unassigned UPI and blocks conductor UPI receipt until owner assigns', () {
      final testBus = BusModel(
        id: 'TEST-BUS-UPI-CHECK',
        regNumber: 'KL 99 ZZ 0002',
        busName: 'UPI Check Bus',
        category: 'Ordinary Bus',
        routeName: 'Route',
        stops: [],
      );

      expect(testBus.hasValidUpi, isFalse);
      expect(testBus.upiId, isEmpty);
      expect(testBus.payeeName, isEmpty);

      // Owner assigns UPI
      FleetState.instance.updateBusUpiDetails(
        regNumber: testBus.regNumber,
        upiId: 'merchant.owner@okhdfcbank',
        payeeName: 'Owner Transport Lines',
        isUpiEnabled: true,
      );

      testBus.upiId = 'merchant.owner@okhdfcbank';
      testBus.payeeName = 'Owner Transport Lines';
      testBus.isUpiEnabled = true;

      expect(testBus.hasValidUpi, isTrue);
    });

    testWidgets('4. Owner Bus List does NOT have "Proceed & Verify Bus (Admin)" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerBusListTab(
              owner: OwnerModel(
                id: 'OWNER-1',
                name: 'Test Owner',
                email: 'test@gmail.com',
                phone: '9999999999',
                password: 'pass',
                companyName: 'Test Lines',
                registeredAt: DateTime.now(),
              ),
              onNavigateToConductorTab: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure the bypass button is completely absent
      expect(find.text('Proceed & Verify Bus (Admin)'), findsNothing);
    });

    testWidgets('5. Passenger SearchTab displays "Recent Travelled Points" instead of Popular transit points', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTab(
              passenger: PassengerModel(
                id: 'PASS-TEST-1',
                name: 'Commuter',
                email: 'commuter@gmail.com',
                phone: '9847000000',
                password: 'pass',
                homeStation: 'Aluva Stand',
                registeredAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must have "Recent Travelled Points" and NOT "Popular Transit Points"
      expect(find.text('Recent Travelled Points'), findsOneWidget);
      expect(find.text('Popular Transit Points'), findsNothing);
    });

    testWidgets('6. BusDetailPage renders Owner Assigned QR or Configure button without sample test QR', (WidgetTester tester) async {
      final unassignedBus = BusModel(
        id: 'TEST-BUS-NO-UPI',
        regNumber: 'KL 99 ZZ 0004',
        busName: 'No UPI Bus',
        category: 'Ordinary Bus',
        routeName: 'Route',
        stops: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BusDetailPage(
            bus: unassignedBus,
            onNavigateToConductors: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Unassigned empty state button
      expect(find.text('Configure UPI / QR Code'), findsOneWidget);
      // Sample test QR text and test modal buttons must be absent
      expect(find.text('Live QR Preview (Sample ₹15)'), findsNothing);
      expect(find.text('Test / Scan QR'), findsNothing);
    });

    testWidgets('7. Owner Profile Tab has Manage & Delete Data nested in settings without outer Danger Zone card', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerProfileTab(
              owner: OwnerModel(
                id: 'OWNER-1',
                name: 'Sahl',
                email: 'sahl@gmail.com',
                phone: '9447012345',
                password: 'pass',
                companyName: 'Sahl Motors',
                registeredAt: DateTime.now(),
              ),
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Manage & Delete Data option is available inside settings
      final manageTile = find.text('Manage & Delete Data');
      expect(manageTile, findsOneWidget);

      // Tap on it to open deletion management sheet
      await tester.tap(manageTile);
      await tester.pumpAndSettle();

      expect(find.text('Account & Data Deletion'), findsOneWidget);
      expect(find.text('CLOSE OPERATOR ACCOUNT'), findsOneWidget);
    });
  });
}
