import 'package:flutter/foundation.dart';

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

class BusReviewModel {
  final String id;
  final String busRegNumber;
  final String busName;
  final String passengerName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;
  bool isReadByOwner;
  bool isReadByConductor;

  BusReviewModel({
    required this.id,
    required this.busRegNumber,
    required this.busName,
    required this.passengerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isReadByOwner = false,
    this.isReadByConductor = false,
  });
}

class IssuedTicketModel {
  final String id;
  final String ticketNumber;
  final String busRegNumber;
  final String busName;
  final String conductorId;
  final String conductorName;
  final String passengerId;
  final String passengerName;
  final String boardingStop;
  final String destStop;
  final double fare;
  final String category; // 'General', 'Student Concession'
  final String paymentMode; // 'SMART_WALLET', 'CASH', 'UPI', 'SPLIT'
  final double cashGiven;
  final double changeReturned;
  final double splitCash;
  final double splitUpi;
  final DateTime issuedAt;

  IssuedTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.busRegNumber,
    required this.busName,
    required this.conductorId,
    required this.conductorName,
    required this.passengerId,
    required this.passengerName,
    required this.boardingStop,
    required this.destStop,
    required this.fare,
    required this.category,
    required this.paymentMode,
    this.cashGiven = 0.0,
    this.changeReturned = 0.0,
    this.splitCash = 0.0,
    this.splitUpi = 0.0,
    required this.issuedAt,
  });

  String get destinationStop => destStop;
  DateTime get timestamp => issuedAt;
  bool get isStudentConcession => category.toLowerCase().contains('student');
  String get paymentModeLabel {
    switch (paymentMode) {
      case 'SMART_WALLET':
        return 'Smart Transit Wallet (Instant auto-debit)';
      case 'CASH':
        return 'Liquid Cash Handover';
      case 'UPI':
        return 'Dynamic UPI QR Scan';
      case 'SPLIT':
        return 'Split Payment (Cash + UPI)';
      default:
        return paymentMode;
    }
  }
  double? get cashTendered => cashGiven > 0 ? cashGiven : null;
  double? get cashChangeGiven => changeReturned > 0 ? changeReturned : null;
  bool get isSplitPayment => paymentMode == 'SPLIT' || (splitCash > 0 && splitUpi > 0);
  double? get splitCashAmount => splitCash > 0 ? splitCash : null;
  double? get splitUpiAmount => splitUpi > 0 ? splitUpi : null;
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

  // Contact Information for Direct Passenger Connection
  String ownerName;
  String ownerPhone;
  String ownerEmail;
  String conductorPhone;
  String conductorEmail;

  // Live Trip & GPS Telemetry (Managed by Conductor)
  bool isTripActive;
  int currentStageIndex;
  double currentLatitude;
  double currentLongitude;
  String conductorLocationString;

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
    this.ownerName = 'George Varghese (Owner)',
    this.ownerPhone = '+91 94470 12345',
    this.ownerEmail = 'owner@stgeorge.com',
    this.conductorPhone = '+91 98470 11001',
    this.conductorEmail = 'suresh@stgeorge.com',
    this.isTripActive = true,
    this.currentStageIndex = 2,
    this.currentLatitude = 10.1076,
    this.currentLongitude = 76.3516,
    this.conductorLocationString = 'Near Pump Junction, Aluva (Conductor Device GPS)',
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

class FleetState extends ChangeNotifier {
  static final FleetState instance = FleetState._internal();
  FleetState._internal();

  // Shared Passenger Demo Wallet (synchronized across conductor ticketing and passenger app)
  double passengerWalletBalance = 250.0;

  void topUpPassengerWallet(double amount) {
    passengerWalletBalance += amount;
    notifyListeners();
  }

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
      ownerName: 'George Varghese',
      ownerPhone: '+91 94470 12345',
      ownerEmail: 'owner@stgeorge.com',
      conductorPhone: '+91 98470 11001',
      conductorEmail: 'suresh@stgeorge.com',
      isTripActive: true,
      currentStageIndex: 2,
      currentLatitude: 10.1076,
      currentLongitude: 76.3516,
      conductorLocationString: 'Pump Junction, Aluva (Conductor Live GPS)',
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
      ownerName: 'George Varghese',
      ownerPhone: '+91 94470 12345',
      ownerEmail: 'owner@stgeorge.com',
      conductorPhone: '+91 98470 11002',
      conductorEmail: 'biju@stgeorge.com',
      isTripActive: true,
      currentStageIndex: 1,
      currentLatitude: 9.9816,
      currentLongitude: 76.2750,
      conductorLocationString: 'Menaka Marine Drive, Ernakulam (Live GPS)',
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
      ownerName: 'George Varghese',
      ownerPhone: '+91 94470 12345',
      ownerEmail: 'owner@stgeorge.com',
      conductorPhone: '+91 98470 11003',
      conductorEmail: 'rajesh@stgeorge.com',
      isTripActive: false,
      currentStageIndex: 0,
      currentLatitude: 9.9678,
      currentLongitude: 76.3195,
      conductorLocationString: 'Vytilla Mobility Hub Depot (Resting)',
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

  // Seeded Issued Tickets History
  final List<IssuedTicketModel> issuedTickets = [
    IssuedTicketModel(
      id: 'TCK-001',
      ticketNumber: 'KL-SBK-2610-0042',
      busRegNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      conductorId: 'COND-1',
      conductorName: 'Suresh Kumar',
      passengerId: 'PASS-1004',
      passengerName: 'Anjali Nair',
      boardingStop: 'Aluva Stand',
      destStop: 'Kizhakkambalam',
      fare: 18.0,
      category: 'General',
      paymentMode: 'SMART_WALLET',
      issuedAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    IssuedTicketModel(
      id: 'TCK-002',
      ticketNumber: 'KL-SBK-2610-0043',
      busRegNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      conductorId: 'COND-1',
      conductorName: 'Suresh Kumar',
      passengerId: 'PASS-1008',
      passengerName: 'Rahul Pillai',
      boardingStop: 'Bank Junction',
      destStop: 'Pattimattom',
      fare: 5.0,
      category: 'Student Concession',
      paymentMode: 'CASH',
      cashGiven: 10.0,
      changeReturned: 5.0,
      issuedAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    IssuedTicketModel(
      id: 'TCK-003',
      ticketNumber: 'KL-SBK-2610-0044',
      busRegNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      conductorId: 'COND-1',
      conductorName: 'Suresh Kumar',
      passengerId: 'PASS-1012',
      passengerName: 'Deepa Menon',
      boardingStop: 'Pump Junction',
      destStop: 'Perumbavoor Stand',
      fare: 22.0,
      category: 'General',
      paymentMode: 'UPI',
      issuedAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    IssuedTicketModel(
      id: 'TCK-004',
      ticketNumber: 'KL-SBK-2610-0045',
      busRegNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      conductorId: 'COND-1',
      conductorName: 'Suresh Kumar',
      passengerId: 'PASS-1015',
      passengerName: 'Kiran Das',
      boardingStop: 'Bank Junction',
      destStop: 'Kizhakkambalam',
      fare: 15.0,
      category: 'General',
      paymentMode: 'SPLIT',
      splitCash: 10.0,
      splitUpi: 5.0,
      issuedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  // Seeded Passenger Reviews & Ratings
  final List<BusReviewModel> reviews = [
    BusReviewModel(
      id: 'REV-001',
      busRegNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      passengerName: 'Anjali Nair',
      rating: 5.0,
      comment: 'Very punctual and clean bus. Conductor was polite and digital wallet ticketing took 2 seconds!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isReadByOwner: false,
      isReadByConductor: false,
    ),
    BusReviewModel(
      id: 'REV-002',
      busRegNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      passengerName: 'Gopakumar K.',
      rating: 4.5,
      comment: 'Smooth driving on Aluva-Perumbavoor route. GPS tracking was accurate.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isReadByOwner: false,
      isReadByConductor: false,
    ),
    BusReviewModel(
      id: 'REV-003',
      busRegNumber: 'KL 07 CE 1204',
      busName: 'GreenCity Express',
      passengerName: 'Rohit George',
      rating: 4.0,
      comment: 'Good service across Menaka. Air conditioning would be even better.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isReadByOwner: true,
      isReadByConductor: true,
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

  BusModel? getBusByReg(String regNumber) {
    try {
      return buses.firstWhere((b) => b.regNumber.toUpperCase() == regNumber.toUpperCase());
    } catch (_) {
      return buses.isNotEmpty ? buses.first : null;
    }
  }

  // Issue Ticket and reconcile across Conductor, Bus, and Passenger Wallet
  void issueTicket(IssuedTicketModel ticket) {
    issuedTickets.insert(0, ticket);

    // Update Bus stats
    final bus = getBusByReg(ticket.busRegNumber);
    if (bus != null) {
      bus.todayCollection += ticket.fare;
      bus.ticketsCount += 1;
    }

    // Update Conductor stats
    final condIdx = conductors.indexWhere((c) => c.id == ticket.conductorId || c.name == ticket.conductorName);
    if (condIdx != -1) {
      conductors[condIdx].todayCollection += ticket.fare;
    }

    // If Smart Wallet, debit passenger demo wallet
    if (ticket.paymentMode == 'SMART_WALLET') {
      passengerWalletBalance = (passengerWalletBalance - ticket.fare).clamp(0.0, 99999.0);
    } else if (ticket.paymentMode == 'SPLIT' && ticket.splitUpi > 0) {
      // Split portion handled
    }
    notifyListeners();
  }

  // Add review and trigger notification
  void addReview({
    required String busId,
    required String busRegNumber,
    required String busName,
    required String passengerName,
    required double rating,
    required String comment,
  }) {
    final review = BusReviewModel(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch}',
      busRegNumber: busRegNumber,
      busName: busName,
      passengerName: passengerName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      isReadByOwner: false,
      isReadByConductor: false,
    );
    reviews.insert(0, review);
    notifyListeners();
  }

  int getUnreadReviewsCountForOwner() {
    return reviews.where((r) => !r.isReadByOwner).length;
  }

  int getUnreadReviewsCountForConductor(String busReg) {
    return reviews.where((r) => r.busRegNumber == busReg && !r.isReadByConductor).length;
  }

  void markReviewsAsReadForOwner() {
    for (final r in reviews) {
      r.isReadByOwner = true;
    }
    notifyListeners();
  }

  void markReviewsAsReadForConductor(String busReg) {
    for (final r in reviews) {
      if (r.busRegNumber == busReg) {
        r.isReadByConductor = true;
      }
    }
    notifyListeners();
  }

  // Live Location and Stage Progression by Conductor
  void advanceBusStage(String busReg) {
    final bus = getBusByReg(busReg);
    if (bus == null || bus.stops.isEmpty) return;

    int nextIndex = (bus.currentStageIndex + 1) % bus.stops.length;
    bus.currentStageIndex = nextIndex;
    bus.currentStop = bus.stops[nextIndex].stopName;

    int futureIndex = (nextIndex + 1) % bus.stops.length;
    bus.nextStop = '${bus.stops[futureIndex].stopName} (~3 mins)';
    bus.eta = '3 mins';
    bus.conductorLocationString = '${bus.stops[nextIndex].stopName} (Conductor Live Device Location)';
    notifyListeners();
  }

  void setTripActive(String busReg, bool active) {
    final bus = getBusByReg(busReg);
    if (bus != null) {
      bus.isTripActive = active;
      bus.isActive = active;
      bus.status = active ? 'RUNNING_NOW' : 'STOPPED';
      if (!active) {
        bus.currentStop = 'Trip Completed (At Stand)';
        bus.nextStop = 'Standing at Destination';
        bus.eta = 'Halted';
      }
      notifyListeners();
    }
  }
}
