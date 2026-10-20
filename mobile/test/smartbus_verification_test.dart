import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/fleet_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('SmartBus Kerala Verification Tests', () {
    test('1. Authentication Validation - Invalid credentials rejected', () {
      final state = FleetState.instance;

      // Unregistered email / phone
      final stranger = state.authenticatePassenger('stranger@gmail.com', 'password123');
      expect(stranger, isNull, reason: 'Stranger with non-registered mail must be rejected');

      // Wrong password
      final wrongPass = state.authenticatePassenger('passenger@gmail.com', 'wrongpassword');
      expect(wrongPass, isNull, reason: 'Wrong password must be rejected');

      // Valid Anjali Nair credentials
      final anjali = state.authenticatePassenger('passenger@gmail.com', 'password123');
      expect(anjali, isNotNull);
      expect(anjali!.name, 'Anjali Nair');
      expect(anjali.id, 'SBK-KL-987263');

      // Valid Rahul Menon credentials
      final rahul = state.authenticatePassenger('rahul@gmail.com', 'password123');
      expect(rahul, isNotNull);
      expect(rahul!.name, 'Rahul Menon');
      expect(rahul.id, 'SBK-KL-554120');
    });

    test('2. Passenger Profile & Wallet Isolation', () {
      final state = FleetState.instance;

      final anjali = state.findPassengerByIdOrPhone('SBK-KL-987263')!;
      final rahul = state.findPassengerByIdOrPhone('SBK-KL-554120')!;
      final meera = state.findPassengerByIdOrPhone('SBK-KL-339811')!;

      // Verify distinct wallets
      expect(anjali.walletBalance, 250.0);
      expect(rahul.walletBalance, 120.0);
      expect(meera.walletBalance, 450.0);

      // Verify lookup by mobile number
      expect(state.findPassengerByIdOrPhone('9847000004')?.id, anjali.id);
      expect(state.findPassengerByIdOrPhone('9847000005')?.id, rahul.id);
      expect(state.findPassengerByIdOrPhone('9847000006')?.id, meera.id);

      // Verify top-up strictly affects only target passenger
      state.topUpPassengerWallet(anjali.id, 50.0);
      expect(anjali.walletBalance, 300.0);
      expect(rahul.walletBalance, 120.0, reason: "Rahul's wallet must remain unchanged");
    });

    test('3. Optional Passenger ID & Walk-in / Unknown Ticketing', () {
      final state = FleetState.instance;
      final anjaliInitialWallet = state.findPassengerByIdOrPhone('SBK-KL-987263')!.walletBalance;
      final rahulInitialWallet = state.findPassengerByIdOrPhone('SBK-KL-554120')!.walletBalance;

      // Issue ticket as Unknown Walk-in
      final walkInTicket = IssuedTicketModel(
        id: 'TCK-WALKIN-1',
        ticketNumber: 'KL-SBK-1910-1005',
        busRegNumber: 'KL-07-CD-4501',
        busName: 'St. George Motors',
        conductorId: 'COND-1',
        conductorName: 'Suresh Kumar',
        passengerId: 'Unknown',
        passengerName: 'Unknown',
        boardingStop: 'Aluva Stand',
        destStop: 'Kalamassery Premier',
        fare: 15.0,
        category: 'General',
        paymentMode: 'CASH',
        cashGiven: 20.0,
        changeReturned: 5.0,
        issuedAt: DateTime.now(),
      );

      state.issueTicket(walkInTicket);

      // 1. Wallets must NOT be debited
      final anjaliWalletAfter = state.findPassengerByIdOrPhone('SBK-KL-987263')!.walletBalance;
      final rahulWalletAfter = state.findPassengerByIdOrPhone('SBK-KL-554120')!.walletBalance;
      expect(anjaliWalletAfter, anjaliInitialWallet, reason: "Anjali's wallet must NEVER be debited for walk-in tickets");
      expect(rahulWalletAfter, rahulInitialWallet, reason: "Rahul's wallet must NEVER be debited for walk-in tickets");

      // 2. Ticket history must NOT appear in Anjali or Rahul profiles
      final anjaliTickets = state.getTicketsForPassenger('SBK-KL-987263');
      final rahulTickets = state.getTicketsForPassenger('SBK-KL-554120');
      expect(anjaliTickets.any((t) => t.id == 'TCK-WALKIN-1'), isFalse);
      expect(rahulTickets.any((t) => t.id == 'TCK-WALKIN-1'), isFalse);

      // 3. Ticket appears in bus & conductor logs
      final bus = state.getBusByReg('KL-07-CD-4501')!;
      expect(bus.ticketsCount, greaterThan(0));
      expect(state.issuedTickets.any((t) => t.id == 'TCK-WALKIN-1'), isTrue);
    });

    test('4. Connected Passenger Smart Wallet Debit & History Isolation', () {
      final state = FleetState.instance;

      final anjali = state.findPassengerByIdOrPhone('SBK-KL-987263')!;
      final rahul = state.findPassengerByIdOrPhone('SBK-KL-554120')!;

      final initialAnjaliBalance = anjali.walletBalance;
      final initialRahulBalance = rahul.walletBalance;

      // Conductor connects Rahul Menon via manual ID typing or scanner
      final connectedTicket = IssuedTicketModel(
        id: 'TCK-RAHUL-1',
        ticketNumber: 'KL-SBK-1910-1006',
        busRegNumber: 'KL-07-CD-4501',
        busName: 'St. George Motors',
        conductorId: 'COND-1',
        conductorName: 'Suresh Kumar',
        passengerId: rahul.id,
        passengerName: rahul.name,
        boardingStop: 'Kalamassery Premier',
        destStop: 'Edappally Toll',
        fare: 5.0, // Student Concession
        category: 'Student Concession',
        paymentMode: 'SMART_WALLET',
        issuedAt: DateTime.now(),
      );

      state.issueTicket(connectedTicket);

      // Verify ONLY Rahul's wallet is debited
      expect(rahul.walletBalance, initialRahulBalance - 5.0);
      expect(anjali.walletBalance, initialAnjaliBalance, reason: "Anjali's wallet must remain completely untouched");

      // Verify ticket appears ONLY in Rahul's history
      final rahulTickets = state.getTicketsForPassenger(rahul.id);
      expect(rahulTickets.any((t) => t.id == 'TCK-RAHUL-1'), isTrue);

      final anjaliTickets = state.getTicketsForPassenger(anjali.id);
      expect(anjaliTickets.any((t) => t.id == 'TCK-RAHUL-1'), isFalse);
    });

    test('5. Owner Signup & Authentication', () {
      final state = FleetState.instance;

      // Seed owner authentication
      final seedOwner = state.authenticateOwner('owner@stgeorge.com', 'password123');
      expect(seedOwner, isNotNull);
      expect(seedOwner!.companyName, 'St. George Motors Ernakulam');

      // Register new owner
      final newOwner = state.registerOwner(
        name: 'Mathew Thomas',
        email: 'mathew@keralaexpress.in',
        phone: '9847112233',
        password: 'securepass123',
        companyName: 'Kerala Express Lines',
      );

      expect(newOwner.id, startsWith('OWNER-'));
      expect(newOwner.name, 'Mathew Thomas');
      expect(newOwner.companyName, 'Kerala Express Lines');

      // Authenticate new owner via email
      final authByEmail = state.authenticateOwner('mathew@keralaexpress.in', 'securepass123');
      expect(authByEmail, isNotNull);
      expect(authByEmail!.name, 'Mathew Thomas');

      // Authenticate new owner via phone
      final authByPhone = state.authenticateOwner('9847112233', 'securepass123');
      expect(authByPhone, isNotNull);
      expect(authByPhone!.id, newOwner.id);

      // Invalid credentials rejected
      expect(state.authenticateOwner('mathew@keralaexpress.in', 'wrongpassword'), isNull);
      expect(state.authenticateOwner('unregistered@owner.com', 'password123'), isNull);
    });

    test('6. Delete Account in each portal (Passenger, Owner, Conductor)', () {
      final state = FleetState.instance;

      // 1. Delete Passenger
      final tempPassenger = state.registerPassenger(
        name: 'Temp Passenger',
        email: 'temp.passenger@gmail.com',
        phone: '9999990001',
        password: 'pass',
        concessionCategory: 'General',
      );
      expect(state.authenticatePassenger('temp.passenger@gmail.com', 'pass'), isNotNull);

      final passengerDeleted = state.deletePassenger(tempPassenger.id);
      expect(passengerDeleted, isTrue);
      expect(state.authenticatePassenger('temp.passenger@gmail.com', 'pass'), isNull);
      expect(state.findPassengerByIdOrPhone(tempPassenger.id), isNull);

      // 2. Delete Owner
      final tempOwner = state.registerOwner(
        name: 'Temp Owner',
        email: 'temp.owner@transits.com',
        phone: '9999990002',
        password: 'pass',
        companyName: 'Temp Transports',
      );
      expect(state.authenticateOwner('temp.owner@transits.com', 'pass'), isNotNull);

      final ownerDeleted = state.deleteOwner(tempOwner.id);
      expect(ownerDeleted, isTrue);
      expect(state.authenticateOwner('temp.owner@transits.com', 'pass'), isNull);
      expect(state.findOwnerByIdOrPhone(tempOwner.id), isNull);

      // 3. Delete Conductor
      final tempConductor = ConductorModel(
        id: 'COND-TEMP',
        name: 'Temp Conductor',
        email: 'temp.cond@test.com',
        userId: 'tempcond1',
        password: 'condpassword',
        phone: '9999990003',
        licenseNumber: 'KL-COND-999',
        assignedBusReg: 'KL 07 CD 4589',
        assignedBusName: 'SpeedWings',
      );
      state.conductors.add(tempConductor);
      expect(state.conductors.any((c) => c.id == 'COND-TEMP'), isTrue);

      final conductorDeleted = state.deleteConductor('COND-TEMP');
      expect(conductorDeleted, isTrue);
      expect(state.conductors.any((c) => c.id == 'COND-TEMP'), isFalse);
    });

    test('7. New Owner Profile starts completely empty and isolated from other operators', () {
      final state = FleetState.instance;

      // Register completely new owner
      final newOwner = state.registerOwner(
        name: 'Varghese John',
        email: 'varghese@malabartransits.com',
        phone: '9847223344',
        password: 'pass',
        companyName: 'Malabar Transits Kannur',
      );

      // Verify empty profile
      final ownerBuses = state.getBusesForOwner(newOwner.id);
      final ownerConductors = state.getConductorsForOwner(newOwner.id);
      expect(ownerBuses.isEmpty, isTrue, reason: 'New owner must NOT inherit other operators\' buses');
      expect(ownerConductors.isEmpty, isTrue, reason: 'New owner must NOT inherit other operators\' conductors');
      expect(state.getTotalCollectionForOwner(newOwner.id), 0.0);
      expect(state.getActiveBusesCountForOwner(newOwner.id), 0);
      expect(state.getTotalTicketsSoldForOwner(newOwner.id), 0);
      expect(state.getWalletCollectionForOwner(newOwner.id), 0.0);
      expect(state.getCashInHandForOwner(newOwner.id), 0.0);

      // Register a bus for this owner
      final newBus = BusModel(
        id: 'BUS-MALABAR-1',
        ownerId: newOwner.id,
        regNumber: 'KL 13 AB 7788',
        busName: 'Malabar Queen',
        category: 'Limited Stop Bus (Red-Whiteline)',
        startPoint: 'Kannur Stand',
        destPoint: 'Thalassery Stand',
        routeName: 'Kannur Stand - Thalassery Stand',
        stops: [
          BusStopSchedule(stopName: 'Kannur Stand', time: '08:00 AM'),
          BusStopSchedule(stopName: 'Thalassery Stand', time: '08:45 AM'),
        ],
        companyName: newOwner.companyName,
        todayCollection: 1500.0,
        ticketsCount: 45,
        isActive: true,
      );
      state.addBus(newBus);

      // Verify bus appears ONLY for new owner, not for St. George Motors (OWNER-1)
      expect(state.getBusesForOwner(newOwner.id).length, 1);
      expect(state.getBusesForOwner(newOwner.id).first.busName, 'Malabar Queen');
      expect(state.getBusesForOwner('OWNER-1').any((b) => b.regNumber == 'KL 13 AB 7788'), isFalse);
      expect(state.getTotalCollectionForOwner(newOwner.id), 1500.0);
    });

    test('8. New Passenger Profile starts with clean 0.0 balance and isolated transactions ledger', () {
      final state = FleetState.instance;

      // Register new passenger
      final newPassenger = state.registerPassenger(
        name: 'Arjun Das',
        email: 'arjun@gmail.com',
        phone: '9847998877',
        password: 'password123',
      );

      // Verify clean 0.0 balance (NOT 150, NOT 250)
      expect(newPassenger.walletBalance, 0.0, reason: 'New passenger balance must start at clean 0.0 rupees');

      // Verify empty transaction ledger (NOT inheriting Anjali Nair's preset transactions)
      final newPassengerTx = state.getTransactionsForPassenger(newPassenger.id);
      expect(newPassengerTx.isEmpty, isTrue, reason: 'New passenger must have an empty transaction ledger');

      // Anjali Nair's wallet and ledger must remain untouched
      final anjali = state.findPassengerByIdOrPhone('SBK-KL-987263')!;
      expect(anjali.walletBalance, greaterThan(0.0));
      expect(state.getTransactionsForPassenger(anjali.id).isNotEmpty, isTrue);

      // Arjun Das tops up 100 rupees
      state.topUpPassengerWallet(newPassenger.id, 100.0, source: 'GPay Recharge');
      expect(newPassenger.walletBalance, 100.0);

      // Ledger now contains exactly 1 top-up transaction
      final updatedTx = state.getTransactionsForPassenger(newPassenger.id);
      expect(updatedTx.length, 1);
      expect(updatedTx.first.amount, 100.0);
      expect(updatedTx.first.type, 'RECHARGE');
      expect(updatedTx.first.passengerId, newPassenger.id);

      // Anjali's ledger still does NOT have Arjun's transaction
      expect(state.getTransactionsForPassenger(anjali.id).any((tx) => tx.passengerId == newPassenger.id), isFalse);
    });

    test('9. Conductor Dashboard Ticket Scoping & No Preset Tickets', () {
      final state = FleetState.instance;

      // Verify no preset dummy tickets like TCK-001 or TCK-002 exist in state
      expect(state.issuedTickets.any((t) => t.id == 'TCK-001'), isFalse,
          reason: 'Dummy preset ticket TCK-001 must not exist');
      expect(state.issuedTickets.any((t) => t.id == 'TCK-002'), isFalse,
          reason: 'Dummy preset ticket TCK-002 must not exist');

      const busA = 'KL 07 CD 4589'; // SpeedWings
      const busB = 'KL 07 CE 1204'; // Royal Super Express

      // Initially no tickets for busB
      expect(state.getTicketsForBus(busB).isEmpty, isTrue);

      // Issue 6 tickets specifically for busB
      for (int i = 1; i <= 6; i++) {
        state.issueTicket(
          IssuedTicketModel(
            id: 'TCK-BUSB-$i',
            ticketNumber: 'KL-SBK-2010-${1000 + i}',
            busRegNumber: busB,
            busName: 'Royal Super Express',
            conductorId: 'COND-2',
            conductorName: 'Mathew Thomas',
            passengerId: 'Unknown',
            passengerName: 'Passenger $i',
            boardingStop: 'Ernakulam South',
            destStop: 'Kottayam Stand',
            fare: 45.0,
            category: 'General',
            paymentMode: 'CASH',
            cashGiven: 50.0,
            changeReturned: 5.0,
            issuedAt: DateTime.now().add(Duration(minutes: i)),
          ),
        );
      }

      // getTicketsForBus returns only busB tickets
      final busBTickets = state.getTicketsForBus(busB);
      expect(busBTickets.length, 6);
      expect(busBTickets.every((t) => t.busRegNumber == busB), isTrue);

      // busA must not contain any busB tickets
      final busATickets = state.getTicketsForBus(busA);
      expect(busATickets.any((t) => t.busRegNumber == busB), isFalse);

      // Conductor dashboard takes latest 5 tickets
      final latest5 = busBTickets.take(5).toList();
      expect(latest5.length, 5);
      // Latest ticket issued is at index 0 (TCK-BUSB-6)
      expect(latest5.first.id, 'TCK-BUSB-6');
    });
  });
}



