int parseTimeToMinutes(String timeStr) {
  try {
    final clean = timeStr.trim().toUpperCase();
    final isPM = clean.contains('PM');
    final isAM = clean.contains('AM');
    final raw = clean.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = raw.split(':');
    if (parts.length >= 2) {
      int hour = int.parse(parts[0].trim());
      int minute = int.parse(parts[1].trim());
      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return hour * 60 + minute;
    }
  } catch (_) {}
  return 0;
}

class BusStopSchedule {
  String stopName;
  String time;

  BusStopSchedule({required this.stopName, required this.time});
}

class BusModel {
  final String id;
  final String regNumber; // Immutable after registration
  String busName;
  String category; // 'Limited Stop Bus (Red-Whiteline)', 'Ordinary Bus (Blue-Whiteline)', 'City Bus (Green-Whiteline)'
  String startPoint;
  String destPoint;
  String routeName;
  List<BusStopSchedule> stops;
  int seatingCapacity;
  String driverName;
  String cleanerName;
  String conductorName;
  String companyName;
  double todayCollection;
  int ticketsCount;
  bool isActive; // Active or Inactive
  String status; // 'RUNNING_NOW', 'IN_DEPOT', 'MAINTENANCE'
  bool isApprovedByAdmin;
  String currentStop;
  String nextStop;
  String eta;

  BusModel({
    required this.id,
    required this.regNumber,
    required this.busName,
    required this.category,
    this.startPoint = 'Aluva Stand',
    this.destPoint = 'Perumbavoor Stand',
    required this.routeName,
    required this.stops,
    this.seatingCapacity = 48,
    this.driverName = 'Unassigned',
    this.cleanerName = 'Unassigned',
    this.conductorName = 'Unassigned',
    this.companyName = 'St. George Motors Ernakulam',
    this.todayCollection = 0.0,
    this.ticketsCount = 0,
    this.isActive = true,
    this.status = 'RUNNING_NOW',
    this.isApprovedByAdmin = true,
    this.currentStop = 'Pump Junction',
    this.nextStop = 'Kizhakkambalam (~4 mins)',
    this.eta = '4 mins',
  }) {
    sortStops();
  }

  void sortStops() {
    stops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));
  }

  String get busType => category;
  String get startTime => stops.isNotEmpty ? stops.first.time : '06:30 AM';
  String get endTime => stops.isNotEmpty ? stops.last.time : '08:00 PM';
}

class ConductorModel {
  final String id;
  String name;
  String email;
  String userId; // App Login ID
  String password; // App Login Password
  String phone;
  String licenseNumber; // MVD Conductor Badge/License
  String assignedBusReg;
  String assignedBusName;
  double todayCollection;

  ConductorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userId,
    required this.password,
    required this.phone,
    required this.licenseNumber,
    required this.assignedBusReg,
    required this.assignedBusName,
    this.todayCollection = 0.0,
  });

  String get loginId => userId;
  String get badgeNumber => licenseNumber;
}

class FleetState {
  static final FleetState instance = FleetState._internal();
  FleetState._internal();

  final List<BusModel> buses = [
    BusModel(
      id: 'BUS-1',
      regNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      category: 'Ordinary Bus (Blue-Whiteline)',
      startPoint: 'Aluva Stand',
      destPoint: 'Perumbavoor Stand',
      routeName: 'Aluva Stand - Perumbavoor Stand (via Kizhakkambalam)',
      stops: [
        BusStopSchedule(stopName: 'Aluva Stand', time: '10:00 AM'),
        BusStopSchedule(stopName: 'Bank Junction', time: '10:08 AM'),
        BusStopSchedule(stopName: 'Pump Junction', time: '10:15 AM'),
        BusStopSchedule(stopName: 'Kizhakkambalam', time: '10:24 AM'),
        BusStopSchedule(stopName: 'Pattimattom', time: '10:35 AM'),
        BusStopSchedule(stopName: 'Perumbavoor Stand', time: '10:48 AM'),
      ],
      seatingCapacity: 48,
      driverName: 'Venu Pillai (Badge #KL4201)',
      cleanerName: 'Mani K.',
      conductorName: 'Suresh Kumar',
      companyName: 'St. George Motors Ernakulam',
      todayCollection: 6420.0,
      ticketsCount: 168,
      isActive: true,
      status: 'RUNNING_NOW',
      isApprovedByAdmin: true,
      currentStop: 'Pump Junction (Stage 3)',
      nextStop: 'Kizhakkambalam (~4 mins)',
      eta: '4 mins',
    ),
    BusModel(
      id: 'BUS-2',
      regNumber: 'KL 07 CE 1204',
      busName: 'GreenCity Express',
      category: 'Limited Stop Bus (Red-Whiteline)',
      startPoint: 'Ernakulam Kaloor',
      destPoint: 'Thoppumpady',
      routeName: 'Ernakulam Kaloor - Thoppumpady (via Menaka)',
      stops: [
        BusStopSchedule(stopName: 'Kaloor Stand', time: '10:30 AM'),
        BusStopSchedule(stopName: 'Menaka Junction', time: '10:42 AM'),
        BusStopSchedule(stopName: 'Thevara Ferry', time: '10:55 AM'),
        BusStopSchedule(stopName: 'Thoppumpady', time: '11:15 AM'),
      ],
      seatingCapacity: 52,
      driverName: 'Antony Joseph',
      cleanerName: 'Saji T.',
      conductorName: 'Biju Varghese',
      companyName: 'St. George Motors Ernakulam',
      todayCollection: 7840.0,
      ticketsCount: 202,
      isActive: true,
      status: 'RUNNING_NOW',
      isApprovedByAdmin: true,
      currentStop: 'Menaka Junction',
      nextStop: 'Thevara Ferry (~6 mins)',
      eta: '6 mins',
    ),
    BusModel(
      id: 'BUS-3',
      regNumber: 'KL 07 BQ 9981',
      busName: 'City Rider',
      category: 'City Bus (Green-Whiteline)',
      startPoint: 'Vytilla Hub',
      destPoint: 'Kakkanad InfoPark',
      routeName: 'Vytilla Hub - Kakkanad InfoPark (via Palarivattom)',
      stops: [
        BusStopSchedule(stopName: 'Vytilla Hub', time: '11:00 AM'),
        BusStopSchedule(stopName: 'Palarivattom Bypass', time: '11:15 AM'),
        BusStopSchedule(stopName: 'Kakkanad Stand', time: '11:30 AM'),
        BusStopSchedule(stopName: 'InfoPark Express', time: '11:45 AM'),
      ],
      seatingCapacity: 48,
      driverName: 'Pradeep Kumar',
      cleanerName: 'Babu N.',
      conductorName: 'Rajesh M.',
      companyName: 'St. George Motors Ernakulam',
      todayCollection: 4220.0,
      ticketsCount: 116,
      isActive: false, // Inactive / In Depot
      status: 'IN_DEPOT',
      isApprovedByAdmin: true,
      currentStop: 'Vytilla Mobility Hub',
      nextStop: 'Scheduled at 02:00 PM',
      eta: 'Resting',
    ),
  ];

  final List<ConductorModel> conductors = [
    ConductorModel(
      id: 'COND-1',
      name: 'Suresh Kumar',
      email: 'suresh@stgeorge.com',
      userId: 'suresh.conductor',
      password: 'password123',
      phone: '+91 98470 11001',
      licenseNumber: 'KL-MVD-COND-8941',
      assignedBusReg: 'KL 07 CD 4589',
      assignedBusName: 'SpeedWings',
      todayCollection: 6420.0,
    ),
    ConductorModel(
      id: 'COND-2',
      name: 'Biju Varghese',
      email: 'biju@stgeorge.com',
      userId: 'biju.conductor',
      password: 'password123',
      phone: '+91 98470 11002',
      licenseNumber: 'KL-MVD-COND-9214',
      assignedBusReg: 'KL 07 CE 1204',
      assignedBusName: 'GreenCity Express',
      todayCollection: 7840.0,
    ),
    ConductorModel(
      id: 'COND-3',
      name: 'Rajesh M.',
      email: 'rajesh@stgeorge.com',
      userId: 'rajesh.conductor',
      password: 'password123',
      phone: '+91 98470 11003',
      licenseNumber: 'KL-MVD-COND-7731',
      assignedBusReg: 'KL 07 BQ 9981',
      assignedBusName: 'City Rider',
      todayCollection: 4220.0,
    ),
  ];

  // Aggregated Stats for Owner Dashboard
  double get totalCollection => buses.fold(0.0, (sum, b) => sum + b.todayCollection);
  int get totalTicketsSold => buses.fold(0, (sum, b) => sum + b.ticketsCount);
  int get activeBusesCount => buses.where((b) => b.isActive).length;
  double get walletCollection => totalCollection * 0.65; // 65% digital wallet
  double get cashInHand => totalCollection * 0.35; // 35% cash

  void addBus(BusModel bus) {
    bus.sortStops();
    buses.add(bus);
  }

  void addConductor(ConductorModel conductor) {
    conductors.add(conductor);
  }

  // Edit bus details (regNumber is immutable)
  void updateBus({
    required String regNumber,
    required String busName,
    required String category,
    required String startPoint,
    required String destPoint,
    required int seats,
    required String driver,
    required String cleaner,
    required String conductor,
    required bool isActive,
    List<BusStopSchedule>? stops,
  }) {
    final index = buses.indexWhere((b) => b.regNumber == regNumber);
    if (index != -1) {
      final b = buses[index];
      b.busName = busName;
      b.category = category;
      b.startPoint = startPoint;
      b.destPoint = destPoint;
      b.routeName = '$startPoint - $destPoint';
      b.seatingCapacity = seats;
      b.driverName = driver;
      b.cleanerName = cleaner;
      b.conductorName = conductor;
      b.isActive = isActive;
      b.status = isActive ? 'RUNNING_NOW' : 'IN_DEPOT';
      if (stops != null) {
        b.stops = stops;
        b.sortStops();
      }
    }
  }

  // Check if credentials match an owner-provisioned conductor
  ConductorModel? authenticateConductor(String userId, String password) {
    try {
      return conductors.firstWhere(
        (c) => c.userId.trim().toLowerCase() == userId.trim().toLowerCase() && c.password == password,
      );
    } catch (_) {
      return null;
    }
  }
}
