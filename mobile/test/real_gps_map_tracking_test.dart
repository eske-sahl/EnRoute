import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/widgets/bus_live_map_widget.dart';
import 'package:mobile/features/passenger/bus_location_screen.dart';
import 'package:mobile/features/owner/bus_detail_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnRoute Real Hardware GPS & Interactive Map Tracking Suite', () {
    late BusModel testBus;

    setUp(() {
      testBus = BusModel(
        id: 'TEST-BUS-01',
        regNumber: 'KL 07 CD 4589',
        busName: 'SpeedWings Kerala',
        category: 'Limited Stop Bus (Red-Whiteline)',
        startPoint: 'Aluva Stand',
        destPoint: 'Ernakulam South',
        routeName: 'Aluva - Kalamassery - Kaloor - Ernakulam South',
        currentLatitude: 10.1076,
        currentLongitude: 76.3516,
        currentStop: 'Aluva Stand',
        nextStop: 'Companypady (~4 mins)',
        eta: '4 mins',
        isTripActive: true,
        isLiveGpsActive: true,
        stops: [
          BusStopSchedule(stopName: 'Aluva Stand', time: '08:00 AM'),
          BusStopSchedule(stopName: 'Companypady', time: '08:15 AM'),
          BusStopSchedule(stopName: 'Kalamassery Premier', time: '08:30 AM'),
          BusStopSchedule(stopName: 'Ernakulam South', time: '09:15 AM'),
        ],
      );

      // Register into fleet state
      final existingIdx = FleetState.instance.buses.indexWhere((b) => b.regNumber == testBus.regNumber);
      if (existingIdx != -1) {
        FleetState.instance.buses[existingIdx] = testBus;
      } else {
        FleetState.instance.buses.add(testBus);
      }
    });

    test('1. LocationService singleton is configured and stops broadcast cleanly', () {
      final locService = LocationService.instance;
      expect(locService, isNotNull);
      expect(locService.isBroadcasting, isFalse);

      locService.stopBroadcasting(testBus.regNumber);
      expect(locService.isBroadcasting, isFalse);
    });

    test('2. FleetState.updateBusCoordinates updates live coordinates & location string', () {
      const newLat = 10.0526;
      const newLng = 76.3268;
      const newSpeed = 48.5;

      FleetState.instance.updateBusCoordinates(
        testBus.regNumber,
        newLat,
        newLng,
        speedKmh: newSpeed,
        locationString: 'Live Conductor GPS Near Kalamassery Premier',
      );

      final updated = FleetState.instance.getBusByReg(testBus.regNumber)!;
      expect(updated.currentLatitude, equals(newLat));
      expect(updated.currentLongitude, equals(newLng));
      expect(updated.isLiveGpsActive, isTrue);
      expect(updated.conductorLocationString, contains('Kalamassery Premier'));
    });

    testWidgets('3. BusLiveMapWidget renders interactive map, bus marker and controls', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusLiveMapWidget(
              bus: testBus,
              height: 300,
              showControls: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify bus name and GPS status badge are rendered
      expect(find.text('SpeedWings Kerala'), findsOneWidget);
      expect(find.text('LIVE GPS TRACKING'), findsOneWidget);
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);

      // Verify OpenStreetMap attribution
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);

      // Verify floating map controls (+ and - zoom buttons and recenter)
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);

      // Test Zoom In button interaction
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Test Recenter button interaction
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();
    });

    testWidgets('4. Passenger BusLocationScreen embeds interactive map & live timetable', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1200));

      await tester.pumpWidget(
        MaterialApp(
          home: BusLocationScreen(
            busRegNumber: testBus.regNumber,
            busName: testBus.busName,
            routeName: testBus.routeName,
            currentStop: testBus.currentStop,
            nextStop: testBus.nextStop,
            eta: testBus.eta,
            stops: testBus.stops,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title & Reg Number
      expect(find.textContaining('SpeedWings Kerala'), findsWidgets);
      expect(find.textContaining('KL 07 CD 4589'), findsWidgets);

      // Map widget inside passenger screen
      expect(find.byType(BusLiveMapWidget), findsOneWidget);
      expect(find.text('LIVE ACTIVE'), findsOneWidget);

      // Timetable nodes
      expect(find.text('Aluva Stand'), findsWidgets);
      expect(find.text('Companypady'), findsOneWidget);
    });

    testWidgets('5. Owner BusDetailPage embeds live interactive map in telemetry section', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1200));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusDetailPage(
              bus: testBus,
              onNavigateToConductors: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Telemetry HUD and interactive map
      expect(find.text('LIVE CONDUCTOR GPS BROADCAST'), findsOneWidget);
      expect(find.byType(BusLiveMapWidget), findsOneWidget);
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    });
  });
}
