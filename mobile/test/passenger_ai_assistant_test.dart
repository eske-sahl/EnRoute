import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/services/passenger_ai_service.dart';
import 'package:mobile/features/passenger/passenger_portal.dart';
import 'package:mobile/features/passenger/widgets/passenger_ai_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PassengerModel testPassenger;

  setUp(() {
    testPassenger = PassengerModel(
      id: 'SBK-KL-TEST-001',
      name: 'Fathima',
      email: 'fathima@test.com',
      phone: '+91 98470 22001',
      password: 'password123',
      walletBalance: 250.0,
      homeStation: 'Kozhikkode Stand',
      concessionCategory: 'General / Adult Standard',
      registeredAt: DateTime(2026, 1, 1),
    );
  });

  group('Passenger AI Assistant Intelligence & Whole App Data Grounding Suite', () {
    test('1. AI answers specific bus timings with complete stop schedule', () async {
      // Query 1: Sana
      final reply1 = await PassengerAiService.instance.processQuery(
        'I want full list of Sana bus timings',
        passenger: testPassenger,
      );
      expect(reply1.isUser, false);
      expect(reply1.text.contains('Sana'), true);
      expect(reply1.text.contains('KL 10 AZ 4589'), true);
      expect(reply1.text.contains('Mannarkad Stand'), true);
      expect(reply1.text.contains('Kozhikkode Stand'), true);
      expect(reply1.scheduleList != null, true);
      expect(reply1.scheduleList!.length >= 4, true);

      // Verify specific timings
      final stops = reply1.scheduleList!.map((s) => s.stopName).toList();
      expect(stops.contains('Mannarkad Stand'), true);
      expect(stops.contains('Alanallur'), true);
      expect(stops.contains('Melattur'), true);
      expect(stops.contains('Pandikkad'), true);
      expect(stops.contains('Kozhikkode Stand'), true);

      // Query 2: Arafa
      final reply2 = await PassengerAiService.instance.processQuery(
        'Show full list of Arafa bus timings',
        passenger: testPassenger,
      );
      expect(reply2.text.contains('Arafa'), true);
      expect(reply2.text.contains('KL 10 CE 1204'), true);
      expect(reply2.scheduleList!.any((s) => s.stopName.contains('Kalikavu Stand')), true);
      expect(reply2.scheduleList!.any((s) => s.stopName.contains('Kozhikkode Stand')), true);

      // Query 3: Generic timings query without naming bus lists the fleet
      final reply3 = await PassengerAiService.instance.processQuery(
        'I want full list of a bus timings',
        passenger: testPassenger,
      );
      expect(reply3.text.contains('Sana'), true);
      expect(reply3.text.contains('Arafa'), true);
      expect(reply3.text.contains('Sanha'), true);
    });

    test('2. AI answers journey planning: "I want to go from there to there, what should i do"', () async {
      // Direct journey query
      final reply = await PassengerAiService.instance.processQuery(
        'I want to go from Mannarkad to Kozhikkode, what should I do?',
        passenger: testPassenger,
      );
      expect(reply.isUser, false);
      expect(reply.text.contains('Sana'), true);
      expect(reply.text.contains('Mannarkad'), true);
      expect(reply.text.contains('Kozhikkode'), true);
      expect(reply.text.contains('Boarding Time'), true);
      expect(reply.text.contains('Fare'), true);
      expect(reply.text.contains('Step-by-Step Instructions'), true);

      // Connecting journey query (Mannarkad to West Hill)
      final connectingReply = await PassengerAiService.instance.processQuery(
        'I want to go from Mannarkad to West Hill, what should I do?',
        passenger: testPassenger,
      );
      expect(connectingReply.isUser, false);
      expect(connectingReply.text.isNotEmpty, true);

      // Open-ended journey query
      final openReply = await PassengerAiService.instance.processQuery(
        'I want to go from there to there, what should i do',
        passenger: testPassenger,
      );
      expect(openReply.text.contains('EnRoute Smart Journey Planner'), true);
      expect(openReply.quickSuggestions!.isNotEmpty, true);
    });

    test('3. AI answers beginner query: "I don\'t have any previous experience of bus journey, for getting bus and reach the destination what should i do.."', () async {
      final reply = await PassengerAiService.instance.processQuery(
        "I don't have any previous experience of bus journey, for getting bus and reach the destination what should i do..",
        passenger: testPassenger,
      );
      expect(reply.isUser, false);
      expect(reply.text.contains('Welcome to Kerala Bus Travel'), true);
      expect(reply.text.contains('Locate Your Bus Stop'), true);
      expect(reply.text.contains('Spotting Your Bus & Route Colors'), true);
      expect(reply.text.contains('Signaling & Boarding Safely'), true);
      expect(reply.text.contains('Ticketing & Payment'), true);
      expect(reply.text.contains('During Your Journey & Live Tracking'), true);
      expect(reply.text.contains('Getting Down at Your Destination'), true);
      expect(reply.highlightBullets!.isNotEmpty, true);
    });

    test('4. AI answers live running status & fare inquiries', () async {
      final liveReply = await PassengerAiService.instance.processQuery(
        'Which buses are running right now?',
        passenger: testPassenger,
      );
      expect(liveReply.text.contains('Live Fleet Telemetry'), true);
      expect(liveReply.text.contains('Registered Fleet'), true);

      final fareReply = await PassengerAiService.instance.processQuery(
        'What is the fare from Aluva to Kizhakkambalam?',
        passenger: testPassenger,
      );
      expect(fareReply.text.contains('Kerala Stage Carriage Fare Structure'), true);
      expect(fareReply.text.contains('Minimum Fare'), true);
    });
  });

  group('Passenger Portal Meta-style AI Floating Button UI Suite', () {
    testWidgets('5. PassengerPortal renders circular AI button above Profile tab and opens AI Sheet on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: PassengerPortal(
            passenger: testPassenger,
            isOnline: true,
            onTopUp: (_) {},
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the circular floating action button exists
      final aiFabFinder = find.byKey(const Key('passenger_ai_floating_button'));
      expect(aiFabFinder, findsOneWidget);

      // Verify "AI" badge or auto_awesome icon is inside the button
      expect(find.descendant(of: aiFabFinder, matching: find.byIcon(Icons.auto_awesome)), findsOneWidget);

      // Tap on the Meta-style AI button
      await tester.tap(aiFabFinder);
      await tester.pumpAndSettle();

      // Verify the PassengerAiSheet modal opened
      expect(find.byType(PassengerAiSheet), findsOneWidget);
      expect(find.text('EnRoute AI Assistant'), findsOneWidget);
      expect(find.text('Kerala Transit Intelligence • Live Fleet'), findsOneWidget);

      // Verify initial suggested prompts exist
      expect(find.text('Full list of Sana bus timings'), findsWidgets);

      // Enter a question and submit via send button
      await tester.enterText(find.byType(TextField), 'I want full list of Sana bus timings');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump(); // Start async processing
      await tester.pump(const Duration(milliseconds: 500)); // Advance delayed timer
      await tester.pumpAndSettle();

      // Verify user message and AI response appear
      expect(find.textContaining('KL 10 AZ 4589'), findsWidgets);
      expect(find.text('Complete Route Timeline'), findsOneWidget);
    });
  });
}
