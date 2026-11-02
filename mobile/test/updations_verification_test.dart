import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/splash/splash_screen.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/services/fleet_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Requested 6 Updations Tests', () {
    late FleetState fleet;

    setUp(() {
      fleet = FleetState.instance;
      fleet.conductors.clear();
      fleet.registeredOwners.clear();
      fleet.registeredPassengers.clear();
      fleet.buses.clear();
      fleet.issuedTickets.clear();

      // Seed standard test records
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

      fleet.registeredOwners.add(
        OwnerModel(
          id: 'OWNER-1',
          name: 'George Varghese',
          email: 'owner@stgeorge.com',
          phone: '9447012345',
          password: 'password123',
          companyName: 'St. George Motors',
          registeredAt: DateTime.now(),
        ),
      );

      fleet.registeredPassengers.add(
        PassengerModel(
          id: 'SBK-KL-987263',
          name: 'Anjali Nair',
          email: 'anjali.nair@gmail.com',
          phone: '9847000004',
          password: 'password123',
          walletBalance: 250.0,
          registeredAt: DateTime.now(),
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

    // 1. Welcoming Slides Splash Screen
    testWidgets('1. SplashScreen renders welcoming slides, app title, Malayalam subtitle, creator names and Skip', (tester) async {
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

      expect(find.text('EnRoute'), findsOneWidget);
      expect(find.text('സ്മാർട്ട് കേരള ബസ്സ് സർവീസ് & ടിക്കറ്റിംഗ്'), findsOneWidget);
      expect(find.textContaining('Sahl Saleem & Fathima Riyas'), findsOneWidget);
      expect(find.text('Live Kerala Bus Tracking'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
    });

    // 2. Unified Single Login Authentication & Role Auto-Detection
    test('2. Unified login automatically routes to Owner, Conductor, or Passenger portal', () {
      // Conductor using User ID
      final condResult = fleet.authenticateUnifiedUser(
        identifier: 'suresh.conductor',
        password: 'password123',
      );
      expect(condResult.success, isTrue);
      expect(condResult.role, equals('CONDUCTOR'));

      // Owner using Email
      final ownerResult = fleet.authenticateUnifiedUser(
        identifier: 'owner@stgeorge.com',
        password: 'password123',
      );
      expect(ownerResult.success, isTrue);
      expect(ownerResult.role, equals('OWNER'));

      // Owner using Phone Number
      final ownerPhoneResult = fleet.authenticateUnifiedUser(
        identifier: '9447012345',
        password: 'password123',
      );
      expect(ownerPhoneResult.success, isTrue);
      expect(ownerPhoneResult.role, equals('OWNER'));

      // Passenger using Passenger ID
      final passIdResult = fleet.authenticateUnifiedUser(
        identifier: 'SBK-KL-987263',
        password: 'password123',
      );
      expect(passIdResult.success, isTrue);
      expect(passIdResult.role, equals('PASSENGER'));

      // Passenger using Mobile Phone
      final passPhoneResult = fleet.authenticateUnifiedUser(
        identifier: '9847000004',
        password: 'password123',
      );
      expect(passPhoneResult.success, isTrue);
      expect(passPhoneResult.role, equals('PASSENGER'));
    });

    // 3. Conductor MUST enter user ID, not phone number
    test('3. Conductor login rejects conductor phone number, requires assigned User ID', () {
      final failPhone = fleet.authenticateUnifiedUser(
        identifier: '9847011001', // Conductor's phone
        password: 'password123',
      );
      // Because conductor must enter user ID like 'suresh.conductor'
      expect(failPhone.success, isFalse);

      final successId = fleet.authenticateUnifiedUser(
        identifier: 'suresh.conductor',
        password: 'password123',
      );
      expect(successId.success, isTrue);
      expect(successId.role, equals('CONDUCTOR'));
    });

    // 4. Default Passenger Account Creation & Hidden Bus Owner Option in LoginScreen UI
    testWidgets('4. LoginScreen default registration is Passenger, with hidden Bus Owner sign-up key', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(onLoginSuccess: (_, _, _, _) {}),
        ),
      );

      // Default state: Single Sign In page
      expect(find.text('Sign In to Portal'), findsOneWidget);
      expect(find.text('Create New Account'), findsOneWidget);

      // Tap Create New Account
      await tester.tap(find.text('Create New Account'));
      await tester.pumpAndSettle();

      // Form should be Passenger Account creation by default
      expect(find.text('Create Passenger Account'), findsAtLeastNWidgets(1));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('10-Digit Mobile Number'), findsOneWidget);

      // Semi-hidden key option for Bus Operator Sign Up is present
      expect(find.text('Bus Operator / Fleet Owner Sign Up'), findsOneWidget);
      expect(find.byIcon(Icons.vpn_key_rounded), findsOneWidget);

      // Tap the hidden key option
      await tester.tap(find.text('Bus Operator / Fleet Owner Sign Up'));
      await tester.pumpAndSettle();

      // Now Owner creation form appears
      expect(find.text('Register Bus Operator'), findsAtLeastNWidgets(1));
      expect(find.text('Bus Firm / Fleet Operator Name'), findsOneWidget);
      expect(find.text('Operator Owner Full Name'), findsOneWidget);
    });

    // 5. Conductor Fare Chart in Journey Tab & Auto Fare Calculation
    test('5. Conductor can assign stop-to-stop fares and calculation uses chart', () {
      final bus = fleet.getBusByReg('KL-07-CE-4401')!;

      // Initial fare calculation from default chart/tariff
      final initialFare = bus.getFareFor('Aluva Stand', 'Perumbavoor Stand');
      expect(initialFare, isNotNull);

      // Conductor assigns custom tariff: Aluva Stand -> Perumbavoor Stand = ₹35.0
      fleet.setBusStopFare(bus.regNumber, 'Aluva Stand', 'Perumbavoor Stand', 35.0);

      // When conductor or passenger calculates fare, it reflects ₹35.0
      expect(bus.getFareFor('Aluva Stand', 'Perumbavoor Stand'), equals(35.0));
      // Symmetrical return journey also returns ₹35.0
      expect(bus.getFareFor('Perumbavoor Stand', 'Aluva Stand'), equals(35.0));

      // Student Concession is always fixed at ₹5.0 per Kerala state rules
      expect(bus.getFareFor('Aluva Stand', 'Perumbavoor Stand', isStudent: true), equals(5.0));
    });

    // 6. Passenger Recently Travelled Points
    test('6. Passenger recently travelled points are extracted from their own tickets ledger', () {
      final passenger = fleet.registeredPassengers.first;

      // When passenger has no tickets
      expect(fleet.getTicketsForPassenger(passenger.id), isEmpty);

      // Issue ticket for passenger: Aluva Stand -> Pump Junction
      fleet.issueTicket(
        IssuedTicketModel(
          id: 'TKT-1',
          ticketNumber: 'ENR-9901',
          busRegNumber: 'KL-07-CE-4401',
          busName: 'St. George Speeder',
          conductorId: 'COND-1',
          conductorName: 'Suresh Kumar',
          passengerId: passenger.id,
          passengerName: passenger.name,
          boardingStop: 'Aluva Stand',
          destStop: 'Pump Junction',
          fare: 15.0,
          category: 'General',
          paymentMode: 'SMART_WALLET',
          issuedAt: DateTime.now(),
        ),
      );

      final tickets = fleet.getTicketsForPassenger(passenger.id);
      expect(tickets.length, equals(1));
      expect(tickets.first.boardingStop, equals('Aluva Stand'));
      expect(tickets.first.destStop, equals('Pump Junction'));

      // Another passenger has 0 tickets
      final otherTickets = fleet.getTicketsForPassenger('OTHER-PASS-99');
      expect(otherTickets, isEmpty);
    });
  });
}
