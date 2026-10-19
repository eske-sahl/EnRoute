import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/fleet_state.dart';

void main() {

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
  });
}
