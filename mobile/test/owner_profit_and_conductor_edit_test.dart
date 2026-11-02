import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/features/owner/tabs/owner_financials_tab.dart';
import 'package:mobile/features/owner/tabs/owner_dashboard_tab.dart';

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

  group('Owner Profit & Conductor Edit Suite', () {
    test('1. Conductor details update via FleetState.updateConductor', () {
      final fleet = FleetState.instance;
      expect(fleet.conductors.isNotEmpty, true);

      final cond = fleet.conductors.first;
      final originalName = cond.name;

      final updated = ConductorModel(
        id: cond.id,
        ownerId: cond.ownerId,
        name: 'Manoj Kumar Varghese',
        email: 'manoj.updated@stgeorge.com',
        userId: cond.userId,
        password: 'newsecretpassword99',
        phone: '+91 98470 99999',
        licenseNumber: 'KL-MVD-COND-9999',
        assignedBusReg: cond.assignedBusReg,
        assignedBusName: cond.assignedBusName,
        todayCollection: cond.todayCollection,
      );

      final ok = fleet.updateConductor(updated);
      expect(ok, true);

      final verified = fleet.conductors.firstWhere((c) => c.id == cond.id);
      expect(verified.name, 'Manoj Kumar Varghese');
      expect(verified.phone, '+91 98470 99999');
      expect(verified.password, 'newsecretpassword99');
      expect(verified.licenseNumber, 'KL-MVD-COND-9999');

      // Reset
      updated.name = originalName;
      fleet.updateConductor(updated);
    });

    test('2. FleetState.getProfitReportForOwner computes Daily, Weekly, Monthly and Yearly P&L correctly', () {
      final fleet = FleetState.instance;

      // Daily Report
      final dailyReport = fleet.getProfitReportForOwner(testOwner.id, OwnerTimeframe.daily);
      expect(dailyReport.timeframe, OwnerTimeframe.daily);
      expect(dailyReport.timeframeLabel, 'Daily (Today)');
      expect(dailyReport.grossRevenue > 0, true);
      expect(dailyReport.netProfit > 0, true);
      // Net Profit margin should be ~21%
      expect(dailyReport.profitMarginPercent >= 20.0 && dailyReport.profitMarginPercent <= 22.0, true);
      // Fuel expense ~42%
      expect((dailyReport.fuelExpense / dailyReport.grossRevenue * 100).round(), 42);
      // Crew wages ~24%
      expect((dailyReport.crewWages / dailyReport.grossRevenue * 100).round(), 24);

      // Weekly Report (7x)
      final weeklyReport = fleet.getProfitReportForOwner(testOwner.id, OwnerTimeframe.weekly);
      expect(weeklyReport.timeframe, OwnerTimeframe.weekly);
      expect(weeklyReport.timeframeLabel, 'Weekly (Last 7 Days)');
      expect(weeklyReport.grossRevenue, closeTo(dailyReport.grossRevenue * 7, 0.1));
      expect(weeklyReport.netProfit, closeTo(dailyReport.netProfit * 7, 0.1));

      // Monthly Report (30x)
      final monthlyReport = fleet.getProfitReportForOwner(testOwner.id, OwnerTimeframe.monthly);
      expect(monthlyReport.timeframe, OwnerTimeframe.monthly);
      expect(monthlyReport.grossRevenue, closeTo(dailyReport.grossRevenue * 30, 0.1));
      expect(monthlyReport.netProfit, closeTo(dailyReport.netProfit * 30, 0.1));

      // Yearly Report (350x)
      final yearlyReport = fleet.getProfitReportForOwner(testOwner.id, OwnerTimeframe.yearly);
      expect(yearlyReport.timeframe, OwnerTimeframe.yearly);
      expect(yearlyReport.grossRevenue, closeTo(dailyReport.grossRevenue * 350, 0.1));
      expect(yearlyReport.netProfit, closeTo(dailyReport.netProfit * 350, 0.1));

      // Bus breakdowns
      expect(dailyReport.busBreakdowns.isNotEmpty, true);
      for (final bus in dailyReport.busBreakdowns) {
        expect(bus.grossRevenue > 0, true);
        expect(bus.netProfit > 0, true);
        expect(bus.fuelExpense > 0, true);
      }
    });

    testWidgets('3. OwnerFinancialsTab renders Daily, Weekly, Monthly, Yearly chips and updates metrics on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: OwnerFinancialsTab(owner: testOwner),
        ),
      );
      await tester.pumpAndSettle();

      // Check timeframe chips exist
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);

      // Verify Operating Expenses Breakdown & Legend
      expect(find.text('Operating Expenses Breakdown'), findsOneWidget);
      expect(find.textContaining('Fuel (42%)'), findsOneWidget);
      expect(find.textContaining('Crew (24%)'), findsOneWidget);
      expect(find.textContaining('Maint (8%)'), findsOneWidget);
      expect(find.textContaining('Tax (5%)'), findsOneWidget);

      // Tap Weekly chip
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.textContaining('WEEKLY (LAST 7 DAYS)'), findsOneWidget);

      // Tap Monthly chip
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      expect(find.textContaining('MONTHLY (CURRENT MONTH)'), findsOneWidget);

      // Tap Yearly chip
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();
      expect(find.textContaining('YEARLY (ANNUAL FY)'), findsOneWidget);

      // Verify creator footer is present
      expect(find.textContaining('Sahl Saleem & Fathima Riyas'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('4. OwnerDashboardTab renders timeframe pills and responds to selection', (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 900));

      bool navigatedToFinancials = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerDashboardTab(
              owner: testOwner,
              onNavigateToConductorTab: () {},
              onNavigateToFinancialsTab: () {
                navigatedToFinancials = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Timeframe pills on dashboard
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);

      // Tap Weekly on dashboard
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.textContaining('WEEKLY (LAST 7 DAYS)'), findsOneWidget);

      // Tap link to financials
      final linkFinder = find.textContaining('View Fuel, Wages & Bus-by-Bus P&L Statement');
      expect(linkFinder, findsOneWidget);
      await tester.tap(linkFinder);
      await tester.pumpAndSettle();
      expect(navigatedToFinancials, true);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
