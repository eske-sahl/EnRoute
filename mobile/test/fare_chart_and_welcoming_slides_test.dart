import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/splash/splash_screen.dart';
import 'package:mobile/features/conductor/tabs/conductor_journey_tab.dart';
import 'package:mobile/services/fleet_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Updates: Welcoming Slides, Overflow Fix, Search Engine & Fare Editing Tests', () {
    late FleetState fleet;

    setUp(() {
      fleet = FleetState.instance;
      fleet.conductors.clear();
      fleet.registeredOwners.clear();
      fleet.registeredPassengers.clear();
      fleet.buses.clear();
      fleet.issuedTickets.clear();

      fleet.conductors.add(
        ConductorModel(
          id: 'COND-1',
          userId: 'suresh.conductor',
          name: 'Suresh Kumar',
          email: 'suresh@stgeorge.com',
          phone: '9847011001',
          password: 'password123',
          licenseNumber: 'KL-07-2018-9921',
          assignedBusReg: 'KL-07-CE-4401',
          assignedBusName: 'St. George Speeder',
        ),
      );

      fleet.buses.add(
        BusModel(
          id: 'BUS-1',
          regNumber: 'KL-07-CE-4401',
          busName: 'St. George Speeder',
          companyName: 'St. George Motors',
          category: 'Fast Passenger',
          routeName: 'Aluva - Perumbavoor Super Fast',
          startPoint: 'Aluva Stand',
          destPoint: 'Perumbavoor Stand',
          stops: [
            BusStopSchedule(stopName: 'Aluva Stand', time: '06:30 AM'),
            BusStopSchedule(stopName: 'Bank Junction', time: '06:40 AM'),
            BusStopSchedule(stopName: 'Pump Junction', time: '06:50 AM'),
            BusStopSchedule(stopName: 'Perumbavoor Stand', time: '07:15 AM'),
          ],
        ),
      );
    });

    // 1. Welcoming Slides Onboarding
    testWidgets('1. Welcoming slides allow swiping, Next button, and Get Started on final slide', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool finished = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinish: () => finished = true,
          ),
        ),
      );

      // Slide 1 verification
      expect(find.text('Live Kerala Bus Tracking'), findsOneWidget);
      expect(find.text('REAL-TIME GPS TELEMATICS'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Advance to Slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Instant QR & Smart Wallet'), findsOneWidget);
      expect(find.text('CASHLESS CONTACTLESS TRAVEL'), findsOneWidget);

      // Advance to Slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Unified Transit Ecosystem'), findsOneWidget);
      expect(find.text('Get Started • ആരംഭിക്കുക'), findsOneWidget);

      // Finish Onboarding
      await tester.tap(find.text('Get Started • ആരംഭിക്കുക'));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
    });

    // 2. Stop-to-Stop Fare Chart Card Header doesn't overflow on small screens
    testWidgets('2. Stop-to-Stop Fare Chart header renders without overflow on 360px screen', (tester) async {
      tester.view.physicalSize = const Size(360, 640); // Standard narrow mobile width
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConductorJourneyTab(
              conductor: fleet.conductors.first,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop-to-Stop Fare Chart'), findsOneWidget);
      expect(find.text('Edit Chart'), findsOneWidget);
      // Verify no RenderFlex overflow exception
      expect(tester.takeException(), isNull);
    });

    // 3. Search Engine with Suggestion Droplists & Fare Editing
    testWidgets('3. Fare Chart modal features stop search droplists, delta buttons and custom fare assignment', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConductorJourneyTab(
              conductor: fleet.conductors.first,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Edit Chart modal
      await tester.tap(find.text('Edit Chart'));
      await tester.pumpAndSettle();

      // Verify modal opened and search fields exist
      expect(find.text('Stop-to-Stop Fare Chart'), findsWidgets);
      expect(find.text('From Stop (Boarding)'), findsOneWidget);
      expect(find.text('To Stop (Destination)'), findsOneWidget);
      expect(find.text('Save Fare to Route Chart'), findsOneWidget);

      // Verify custom fare assignment works in FleetState
      final bus = fleet.buses.first;
      bus.setCustomFare('Aluva Stand', 'Perumbavoor Stand', 35.0);
      expect(bus.getFareFor('Aluva Stand', 'Perumbavoor Stand'), equals(35.0));

      // Verify reverse pair auto-matches custom fare
      expect(bus.getFareFor('Perumbavoor Stand', 'Aluva Stand'), equals(35.0));

      // Remove custom tariff reverts to stage formula
      bus.removeCustomFare('Aluva Stand', 'Perumbavoor Stand');
      expect(bus.getFareFor('Aluva Stand', 'Perumbavoor Stand'), isNot(equals(35.0)));
    });
  });
}
