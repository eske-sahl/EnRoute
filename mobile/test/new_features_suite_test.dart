import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/services/storage_service.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('EnRoute 7 New User Features Suite', () {
    test('1 & 2. StorageService Session & Splash Flags', () {
      final storage = StorageService.instance;
      // Splash flag
      expect(storage.hasSeenSplash(), isFalse);

      // Session map persistence structure
      expect(storage.loadUserSession(), isNull);
    });

    test('3. Owner deletion of Bus and Conductor in FleetState', () {
      final fleet = FleetState.instance;

      // Add a test bus
      final testBus = BusModel(
        id: 'TEST-BUS-99',
        regNumber: 'KL 07 ZZ 9999',
        busName: 'Test Express',
        category: 'Limited Stop Bus (Red-Whiteline)',
        routeName: 'Aluva - Angamaly',
        stops: [],
      );
      fleet.addBus(testBus);
      expect(fleet.getBusByReg('KL 07 ZZ 9999'), isNotNull);

      // Add conductor assigned to this bus
      final testCond = ConductorModel(
        id: 'TEST-COND-99',
        name: 'Test Conductor',
        email: 'testcond@gmail.com',
        userId: 'test.conductor',
        password: 'password123',
        phone: '+91 99999 88888',
        licenseNumber: 'KL-07-COND-9999',
        assignedBusReg: 'KL 07 ZZ 9999',
        assignedBusName: 'Test Express',
      );
      fleet.addConductor(testCond);

      // Delete conductor
      final deletedCond = fleet.deleteConductor('TEST-COND-99');
      expect(deletedCond, isTrue);
      expect(fleet.conductors.any((c) => c.id == 'TEST-COND-99'), isFalse);

      // Delete bus
      final deletedBus = fleet.deleteBus('KL 07 ZZ 9999');
      expect(deletedBus, isTrue);
      expect(fleet.buses.any((b) => b.regNumber == 'KL 07 ZZ 9999'), isFalse);
    });

    test('4. Assigned Bus Crew phone numbers and updates', () {
      final fleet = FleetState.instance;
      final seedBus = fleet.buses.first;

      fleet.updateBusCrew(
        regNumber: seedBus.regNumber,
        driverName: 'Soman Pillai',
        driverPhone: '+91 98470 55112',
        cleanerName: 'Manoj Kumar',
        cleanerPhone: '+91 98470 55113',
      );

      final updated = fleet.getBusByReg(seedBus.regNumber)!;
      expect(updated.driverName, 'Soman Pillai');
      expect(updated.driverPhone, '+91 98470 55112');
      expect(updated.cleanerName, 'Manoj Kumar');
      expect(updated.cleanerPhone, '+91 98470 55113');
    });

    test('5. Conductor Trip & Live GPS Broadcast controls', () {
      final fleet = FleetState.instance;
      final bus = fleet.buses.first;

      // Start trip with GPS broadcast enabled
      fleet.setTripActive(bus.regNumber, true, broadcastGps: true);
      expect(bus.isTripActive, isTrue);
      expect(bus.isLiveGpsActive, isTrue);

      // Start trip with GPS broadcast disabled (optional)
      fleet.setTripActive(bus.regNumber, true, broadcastGps: false);
      expect(bus.isTripActive, isTrue);
      expect(bus.isLiveGpsActive, isFalse);

      // Stop trip
      fleet.setTripActive(bus.regNumber, false);
      expect(bus.isTripActive, isFalse);
      expect(bus.isLiveGpsActive, isFalse);
    });

    test('7. Bus Registration Sincerity Check & Admin Verification Workflow', () {
      final fleet = FleetState.instance;

      // Register new bus with sincerity fields
      final pendingBus = BusModel(
        id: 'BUS-PENDING-1',
        ownerId: 'OWNER-1',
        regNumber: 'KL 07 QQ 1122',
        busName: 'Highland Prince',
        category: 'Ordinary Bus (Blue-Whiteline)',
        routeName: 'Aluva - Kothamangalam',
        stops: [],
        ownerName: 'George Varghese',
        ownerPhone: '+91 94470 12345',
        chassisNumber: 'MB1-VIN-987210',
        permitNumber: 'KL/2026/MVD/0091',
        fitnessValidity: '31-Dec-2027',
        insurancePolicyNumber: 'NIC-KL-POL-8812',
        verificationStatus: 'WAITING_FOR_VERIFICATION',
        isApprovedByAdmin: false,
      );

      fleet.addBus(pendingBus);

      // Verify bus starts in WAITING_FOR_VERIFICATION
      expect(pendingBus.isWaitingForVerification, isTrue);
      expect(pendingBus.isApprovedByAdmin, isFalse);

      // Admin verification approval
      fleet.approveBusByAdmin('KL 07 QQ 1122');
      expect(pendingBus.isWaitingForVerification, isFalse);
      expect(pendingBus.verificationStatus, 'ADMIN_APPROVED');
      expect(pendingBus.isApprovedByAdmin, isTrue);

      // Clean up test bus
      fleet.deleteBus('KL 07 QQ 1122');
    });
  });
}
