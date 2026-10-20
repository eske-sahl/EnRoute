import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'api_service.dart';

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

  Map<String, dynamic> toJson() => {
    'stopName': stopName,
    'time': time,
  };

  factory BusStopSchedule.fromJson(Map<String, dynamic> json) => BusStopSchedule(
    stopName: json['stopName'] as String,
    time: json['time'] as String,
  );
}

class PassengerModel {
  final String id; // e.g. 'SBK-KL-987263'
  String name;
  String email;
  String phone;
  String password;
  double walletBalance;
  String homeStation;
  String concessionCategory; // 'General / Adult Standard', 'Student Concession'
  DateTime registeredAt;

  PassengerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.walletBalance = 0.0, // Clean 0 balance for new signups
    this.homeStation = 'Aluva Stand, Ernakulam',
    this.concessionCategory = 'General / Adult Standard',
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    'walletBalance': walletBalance,
    'homeStation': homeStation,
    'concessionCategory': concessionCategory,
    'registeredAt': registeredAt.toIso8601String(),
  };

  factory PassengerModel.fromJson(Map<String, dynamic> json) => PassengerModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    password: json['password'] as String,
    walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    homeStation: (json['homeStation'] as String?) ?? 'Aluva Stand, Ernakulam',
    concessionCategory: (json['concessionCategory'] as String?) ?? 'General / Adult Standard',
    registeredAt: DateTime.tryParse(json['registeredAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class OwnerModel {
  final String id; // e.g. 'OWNER-1'
  String name;
  String email;
  String phone;
  String password;
  String companyName; // e.g. 'St. George Motors Ernakulam'
  bool isVerified;
  DateTime registeredAt;

  OwnerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.companyName,
    this.isVerified = true,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    'companyName': companyName,
    'isVerified': isVerified,
    'registeredAt': registeredAt.toIso8601String(),
  };

  factory OwnerModel.fromJson(Map<String, dynamic> json) => OwnerModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    password: json['password'] as String,
    companyName: json['companyName'] as String,
    isVerified: (json['isVerified'] as bool?) ?? true,
    registeredAt: DateTime.tryParse(json['registeredAt'] as String? ?? '') ?? DateTime.now(),
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'busRegNumber': busRegNumber,
    'busName': busName,
    'passengerName': passengerName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'isReadByOwner': isReadByOwner,
    'isReadByConductor': isReadByConductor,
  };

  factory BusReviewModel.fromJson(Map<String, dynamic> json) => BusReviewModel(
    id: json['id'] as String,
    busRegNumber: json['busRegNumber'] as String,
    busName: json['busName'] as String,
    passengerName: json['passengerName'] as String,
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    isReadByOwner: (json['isReadByOwner'] as bool?) ?? false,
    isReadByConductor: (json['isReadByConductor'] as bool?) ?? false,
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticketNumber': ticketNumber,
    'busRegNumber': busRegNumber,
    'busName': busName,
    'conductorId': conductorId,
    'conductorName': conductorName,
    'passengerId': passengerId,
    'passengerName': passengerName,
    'boardingStop': boardingStop,
    'destStop': destStop,
    'fare': fare,
    'category': category,
    'paymentMode': paymentMode,
    'cashGiven': cashGiven,
    'changeReturned': changeReturned,
    'splitCash': splitCash,
    'splitUpi': splitUpi,
    'issuedAt': issuedAt.toIso8601String(),
  };

  factory IssuedTicketModel.fromJson(Map<String, dynamic> json) => IssuedTicketModel(
    id: json['id'] as String,
    ticketNumber: json['ticketNumber'] as String,
    busRegNumber: json['busRegNumber'] as String,
    busName: json['busName'] as String,
    conductorId: json['conductorId'] as String,
    conductorName: json['conductorName'] as String,
    passengerId: json['passengerId'] as String,
    passengerName: json['passengerName'] as String,
    boardingStop: json['boardingStop'] as String,
    destStop: json['destStop'] as String,
    fare: (json['fare'] as num).toDouble(),
    category: json['category'] as String,
    paymentMode: json['paymentMode'] as String,
    cashGiven: (json['cashGiven'] as num?)?.toDouble() ?? 0.0,
    changeReturned: (json['changeReturned'] as num?)?.toDouble() ?? 0.0,
    splitCash: (json['splitCash'] as num?)?.toDouble() ?? 0.0,
    splitUpi: (json['splitUpi'] as num?)?.toDouble() ?? 0.0,
    issuedAt: DateTime.tryParse(json['issuedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class WalletTransactionModel {
  final String id;
  final String passengerId;
  final String title;
  final String busOrSource;
  final double amount; // positive for top-up, negative for fare
  final String type; // 'RECHARGE', 'WALLET', 'UPI', 'CASH'
  final DateTime timestamp;
  final String status;

  WalletTransactionModel({
    required this.id,
    required this.passengerId,
    required this.title,
    required this.busOrSource,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.status = 'SUCCESS',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'passengerId': passengerId,
    'title': title,
    'busOrSource': busOrSource,
    'amount': amount,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
  };

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) => WalletTransactionModel(
    id: json['id'] as String,
    passengerId: json['passengerId'] as String,
    title: json['title'] as String,
    busOrSource: json['busOrSource'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: json['type'] as String,
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    status: (json['status'] as String?) ?? 'SUCCESS',
  );
}

class BusModel {
  final String id;
  final String ownerId; // Isolated to registering bus owner
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
    this.ownerId = 'OWNER-1',
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'regNumber': regNumber,
    'busName': busName,
    'category': category,
    'startPoint': startPoint,
    'destPoint': destPoint,
    'routeName': routeName,
    'stops': stops.map((s) => s.toJson()).toList(),
    'seatingCapacity': seatingCapacity,
    'driverName': driverName,
    'cleanerName': cleanerName,
    'conductorName': conductorName,
    'companyName': companyName,
    'todayCollection': todayCollection,
    'ticketsCount': ticketsCount,
    'isActive': isActive,
    'status': status,
    'isApprovedByAdmin': isApprovedByAdmin,
    'currentStop': currentStop,
    'nextStop': nextStop,
    'eta': eta,
    'ownerName': ownerName,
    'ownerPhone': ownerPhone,
    'ownerEmail': ownerEmail,
    'conductorPhone': conductorPhone,
    'conductorEmail': conductorEmail,
    'isTripActive': isTripActive,
    'currentStageIndex': currentStageIndex,
    'currentLatitude': currentLatitude,
    'currentLongitude': currentLongitude,
    'conductorLocationString': conductorLocationString,
  };

  factory BusModel.fromJson(Map<String, dynamic> json) => BusModel(
    id: json['id'] as String,
    ownerId: (json['ownerId'] as String?) ?? 'OWNER-1',
    regNumber: json['regNumber'] as String,
    busName: json['busName'] as String,
    category: json['category'] as String,
    startPoint: (json['startPoint'] as String?) ?? 'Aluva Stand',
    destPoint: (json['destPoint'] as String?) ?? 'Perumbavoor Stand',
    routeName: (json['routeName'] as String?) ?? '',
    stops: (json['stops'] as List<dynamic>?)
            ?.map((e) => BusStopSchedule.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [],
    seatingCapacity: (json['seatingCapacity'] as num?)?.toInt() ?? 48,
    driverName: (json['driverName'] as String?) ?? 'Unassigned',
    cleanerName: (json['cleanerName'] as String?) ?? 'Unassigned',
    conductorName: (json['conductorName'] as String?) ?? 'Unassigned',
    companyName: (json['companyName'] as String?) ?? '',
    todayCollection: (json['todayCollection'] as num?)?.toDouble() ?? 0.0,
    ticketsCount: (json['ticketsCount'] as num?)?.toInt() ?? 0,
    isActive: (json['isActive'] as bool?) ?? true,
    status: (json['status'] as String?) ?? 'RUNNING_NOW',
    isApprovedByAdmin: (json['isApprovedByAdmin'] as bool?) ?? true,
    currentStop: (json['currentStop'] as String?) ?? '',
    nextStop: (json['nextStop'] as String?) ?? '',
    eta: (json['eta'] as String?) ?? '',
    ownerName: (json['ownerName'] as String?) ?? '',
    ownerPhone: (json['ownerPhone'] as String?) ?? '',
    ownerEmail: (json['ownerEmail'] as String?) ?? '',
    conductorPhone: (json['conductorPhone'] as String?) ?? '',
    conductorEmail: (json['conductorEmail'] as String?) ?? '',
    isTripActive: (json['isTripActive'] as bool?) ?? false,
    currentStageIndex: (json['currentStageIndex'] as num?)?.toInt() ?? 0,
    currentLatitude: (json['currentLatitude'] as num?)?.toDouble() ?? 10.0,
    currentLongitude: (json['currentLongitude'] as num?)?.toDouble() ?? 76.0,
    conductorLocationString: (json['conductorLocationString'] as String?) ?? '',
  );
}

class ConductorModel {
  final String id;
  final String ownerId; // Isolated to provisioning owner
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
    this.ownerId = 'OWNER-1',
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'email': email,
    'userId': userId,
    'password': password,
    'phone': phone,
    'licenseNumber': licenseNumber,
    'assignedBusReg': assignedBusReg,
    'assignedBusName': assignedBusName,
    'todayCollection': todayCollection,
  };

  factory ConductorModel.fromJson(Map<String, dynamic> json) => ConductorModel(
    id: json['id'] as String,
    ownerId: (json['ownerId'] as String?) ?? 'OWNER-1',
    name: json['name'] as String,
    email: json['email'] as String,
    userId: json['userId'] as String,
    password: json['password'] as String,
    phone: json['phone'] as String,
    licenseNumber: json['licenseNumber'] as String,
    assignedBusReg: (json['assignedBusReg'] as String?) ?? '',
    assignedBusName: (json['assignedBusName'] as String?) ?? '',
    todayCollection: (json['todayCollection'] as num?)?.toDouble() ?? 0.0,
  );
}

class FleetState extends ChangeNotifier {
  static final FleetState instance = FleetState._internal();
  FleetState._internal() {
    _initDefaultSeedData();
  }

  bool _isStorageLoaded = false;

  // In-Memory Multi-Tenant Registries
  final List<PassengerModel> registeredPassengers = [];
  final List<OwnerModel> registeredOwners = [];
  final List<ConductorModel> conductors = [];
  final List<BusModel> buses = [];
  final List<IssuedTicketModel> issuedTickets = [];
  final List<WalletTransactionModel> walletTransactions = [];
  final List<BusReviewModel> reviews = [];

  void _initDefaultSeedData() {
    registeredPassengers.addAll([
      PassengerModel(
        id: 'SBK-KL-987263',
        name: 'Anjali Nair',
        email: 'passenger@gmail.com',
        phone: '9847000004',
        password: 'password123',
        walletBalance: 250.0,
        homeStation: 'Aluva Stand, Ernakulam',
        concessionCategory: 'General / Adult Standard',
        registeredAt: DateTime(2026, 10, 1),
      ),
      PassengerModel(
        id: 'SBK-KL-554120',
        name: 'Rahul Menon',
        email: 'rahul@gmail.com',
        phone: '9847000005',
        password: 'password123',
        walletBalance: 120.0,
        homeStation: 'Perumbavoor Stand',
        concessionCategory: 'Student Concession',
        registeredAt: DateTime(2026, 10, 5),
      ),
      PassengerModel(
        id: 'SBK-KL-339811',
        name: 'Meera Pillai',
        email: 'meera@gmail.com',
        phone: '9847000006',
        password: 'password123',
        walletBalance: 450.0,
        homeStation: 'Ernakulam Kaloor',
        concessionCategory: 'General / Adult Standard',
        registeredAt: DateTime(2026, 10, 10),
      ),
    ]);

    registeredOwners.addAll([
      OwnerModel(
        id: 'OWNER-1',
        name: 'George Varghese',
        email: 'owner@stgeorge.com',
        phone: '9447012345',
        password: 'password123',
        companyName: 'St. George Motors Ernakulam',
        isVerified: true,
        registeredAt: DateTime(2026, 10, 1),
      ),
    ]);

    conductors.addAll([
      ConductorModel(
        id: 'COND-1',
        ownerId: 'OWNER-1',
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
        ownerId: 'OWNER-1',
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
        ownerId: 'OWNER-1',
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
    ]);

    buses.addAll([
      BusModel(
        id: 'BUS-1',
        ownerId: 'OWNER-1',
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
        isActive: false,
        status: 'STOPPED / DEPOT',
        isApprovedByAdmin: true,
        currentStop: 'Depot (Aluva Stand)',
        nextStop: 'Trip not started',
        eta: 'Halted',
        ownerName: 'George Varghese',
        ownerPhone: '+91 94470 12345',
        ownerEmail: 'owner@stgeorge.com',
        conductorPhone: '+91 98470 11001',
        conductorEmail: 'suresh@stgeorge.com',
        isTripActive: false,
        currentStageIndex: 0,
        currentLatitude: 10.1076,
        currentLongitude: 76.3516,
        conductorLocationString: 'Aluva Stand Depot (Resting)',
      ),
      BusModel(
        id: 'BUS-2',
        ownerId: 'OWNER-1',
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
        isActive: false,
        status: 'STOPPED / DEPOT',
        isApprovedByAdmin: true,
        currentStop: 'Depot (Kaloor Stand)',
        nextStop: 'Trip not started',
        eta: 'Halted',
        ownerName: 'George Varghese',
        ownerPhone: '+91 94470 12345',
        ownerEmail: 'owner@stgeorge.com',
        conductorPhone: '+91 98470 11002',
        conductorEmail: 'biju@stgeorge.com',
        isTripActive: false,
        currentStageIndex: 0,
        currentLatitude: 9.9816,
        currentLongitude: 76.2750,
        conductorLocationString: 'Kaloor Stand Depot (Resting)',
      ),
      BusModel(
        id: 'BUS-3',
        ownerId: 'OWNER-1',
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
        isActive: false,
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
    ]);

    walletTransactions.addAll([
      WalletTransactionModel(
        id: 'TX-9041',
        passengerId: 'SBK-KL-987263',
        title: 'Bus Ticket: Aluva ➔ Kizhakkambalam',
        busOrSource: 'SpeedWings (KL 07 CD 4589)',
        amount: -18.0,
        type: 'WALLET',
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      WalletTransactionModel(
        id: 'TX-9032',
        passengerId: 'SBK-KL-987263',
        title: 'Demo Wallet Top-Up',
        busOrSource: 'Net Banking / UPI Ref #89123',
        amount: 200.0,
        type: 'RECHARGE',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    reviews.addAll([
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
    ]);
  }

  // Asynchronous Storage Initializer (Persists data across hot restarts & web reloads)
  Future<void> initialize() async {
    if (_isStorageLoaded) return;
    await StorageService.instance.init();

    final savedPassengers = StorageService.instance.loadList(StorageService.keyPassengers);
    final savedOwners = StorageService.instance.loadList(StorageService.keyOwners);
    final savedConductors = StorageService.instance.loadList(StorageService.keyConductors);
    final savedBuses = StorageService.instance.loadList(StorageService.keyBuses);
    final savedTickets = StorageService.instance.loadList(StorageService.keyTickets);
    final savedTx = StorageService.instance.loadList(StorageService.keyTransactions);
    final savedReviews = StorageService.instance.loadList(StorageService.keyReviews);

    if (savedPassengers != null) {
      registeredPassengers.clear();
      registeredPassengers.addAll(savedPassengers.map((e) => PassengerModel.fromJson(e)));
    } else {
      await _persistPassengers();
    }

    if (savedOwners != null) {
      registeredOwners.clear();
      registeredOwners.addAll(savedOwners.map((e) => OwnerModel.fromJson(e)));
    } else {
      await _persistOwners();
    }

    if (savedConductors != null) {
      conductors.clear();
      conductors.addAll(savedConductors.map((e) => ConductorModel.fromJson(e)));
    } else {
      await _persistConductors();
    }

    if (savedBuses != null) {
      buses.clear();
      buses.addAll(savedBuses.map((e) => BusModel.fromJson(e)));
      for (final b in buses) {
        b.isTripActive = false;
        b.isActive = false;
        b.status = 'STOPPED / DEPOT';
      }
      await _persistBuses();
    } else {
      await _persistBuses();
    }

    if (savedTickets != null) {
      issuedTickets.clear();
      issuedTickets.addAll(
        savedTickets
            .map((e) => IssuedTicketModel.fromJson(e))
            .where((t) => !t.id.startsWith('TCK-00')),
      );
      await _persistTickets();
    } else {
      await _persistTickets();
    }

    if (savedTx != null) {
      walletTransactions.clear();
      walletTransactions.addAll(savedTx.map((e) => WalletTransactionModel.fromJson(e)));
    } else {
      await _persistTransactions();
    }

    if (savedReviews != null) {
      reviews.clear();
      reviews.addAll(savedReviews.map((e) => BusReviewModel.fromJson(e)));
    } else {
      await _persistReviews();
    }

    _isStorageLoaded = true;
    notifyListeners();

    // Asynchronously synchronize with backend data store
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    try {
      final backend = await ApiService.fetchBackendData();
      if (backend != null) {
        // Merge passengers from backend
        if (backend['passengers'] is List) {
          final list = backend['passengers'] as List;
          for (final item in list) {
            if (item is Map) {
              final id = item['id']?.toString() ?? '';
              final idx = registeredPassengers.indexWhere((p) => p.id == id);
              if (idx == -1) {
                registeredPassengers.add(PassengerModel(
                  id: id,
                  name: item['fullName']?.toString() ?? 'Passenger',
                  email: item['email']?.toString() ?? '',
                  phone: item['phoneNumber']?.toString() ?? '',
                  password: 'password123',
                  walletBalance: (item['walletBalance'] as num?)?.toDouble() ?? 0.0,
                  homeStation: item['homeStation']?.toString() ?? 'Aluva Stand',
                  concessionCategory: item['concessionCategory']?.toString() ?? 'General / Adult Standard',
                  registeredAt: DateTime.tryParse(item['registeredAt']?.toString() ?? '') ?? DateTime.now(),
                ));
              }
            }
          }
          await _persistPassengers();
        }

        // Merge buses from backend
        if (backend['buses'] is List) {
          final list = backend['buses'] as List;
          for (final item in list) {
            if (item is Map) {
              final reg = item['regNumber']?.toString() ?? '';
              final idx = buses.indexWhere((b) => b.regNumber.toUpperCase() == reg.toUpperCase());
              if (idx == -1) {
                buses.add(BusModel(
                  id: 'BUS-${buses.length + 1}',
                  ownerId: 'OWNER-1',
                  regNumber: reg,
                  busName: item['busName']?.toString() ?? 'Bus',
                  category: item['category']?.toString() ?? 'Ordinary Bus',
                  startPoint: item['startPoint']?.toString() ?? 'Aluva Stand',
                  destPoint: item['destPoint']?.toString() ?? 'Perumbavoor Stand',
                  routeName: item['route']?.toString() ?? '$reg Route',
                  stops: [],
                  companyName: 'St. George Motors Ernakulam',
                  todayCollection: (item['todayCollection'] as num?)?.toDouble() ?? 0.0,
                  ticketsCount: (item['ticketsSold'] as num?)?.toInt() ?? 0,
                  isActive: false,
                  status: 'STOPPED / DEPOT',
                  isTripActive: false,
                ));
              }
            }
          }
          await _persistBuses();
        }

        // Push unified state up to backend
        _pushStateToBackend();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _pushStateToBackend() {
    ApiService.syncData({
      'passengers': registeredPassengers.map((p) => {
        'id': p.id,
        'fullName': p.name,
        'email': p.email,
        'phoneNumber': p.phone,
        'walletBalance': p.walletBalance,
        'concessionCategory': p.concessionCategory,
        'homeStation': p.homeStation,
        'status': 'ACTIVE',
        'registeredAt': p.registeredAt.toIso8601String(),
      }).toList(),
      'buses': buses.map((b) => {
        'regNumber': b.regNumber,
        'busName': b.busName,
        'category': b.category,
        'route': b.routeName,
        'startPoint': b.startPoint,
        'destPoint': b.destPoint,
        'seatingCapacity': b.seatingCapacity,
        'isTripActive': b.isTripActive,
        'status': b.status,
        'todayCollection': b.todayCollection,
        'ticketsSold': b.ticketsCount,
      }).toList(),
      'conductors': conductors.map((c) => {
        'id': c.id,
        'fullName': c.name,
        'userId': c.userId,
        'phoneNumber': c.phone,
        'licenseNumber': c.licenseNumber,
        'assignedBusReg': c.assignedBusReg,
        'assignedBusName': c.assignedBusName,
        'role': 'ROLE_CONDUCTOR',
        'status': 'ACTIVE',
      }).toList(),
      'tickets': issuedTickets.map((t) => t.toJson()).toList(),
    });
  }

  // Persistence helpers
  Future<void> _persistPassengers() async {
    await StorageService.instance.saveList(
      StorageService.keyPassengers,
      registeredPassengers.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> _persistOwners() async {
    await StorageService.instance.saveList(
      StorageService.keyOwners,
      registeredOwners.map((o) => o.toJson()).toList(),
    );
  }

  Future<void> _persistConductors() async {
    await StorageService.instance.saveList(
      StorageService.keyConductors,
      conductors.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> _persistBuses() async {
    await StorageService.instance.saveList(
      StorageService.keyBuses,
      buses.map((b) => b.toJson()).toList(),
    );
  }

  Future<void> _persistTickets() async {
    await StorageService.instance.saveList(
      StorageService.keyTickets,
      issuedTickets.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> _persistTransactions() async {
    await StorageService.instance.saveList(
      StorageService.keyTransactions,
      walletTransactions.map((tx) => tx.toJson()).toList(),
    );
  }

  Future<void> _persistReviews() async {
    await StorageService.instance.saveList(
      StorageService.keyReviews,
      reviews.map((r) => r.toJson()).toList(),
    );
  }

  // Passenger Methods
  double get passengerWalletBalance =>
      registeredPassengers.isNotEmpty ? registeredPassengers.first.walletBalance : 0.0;
  set passengerWalletBalance(double val) {
    if (registeredPassengers.isNotEmpty) {
      registeredPassengers.first.walletBalance = val;
      _persistPassengers();
      notifyListeners();
    }
  }

  void topUpPassengerWallet(String passengerId, double amount, {String source = 'UPI / Net Banking'}) {
    final pIndex = registeredPassengers.indexWhere((p) => p.id == passengerId);
    if (pIndex != -1) {
      registeredPassengers[pIndex].walletBalance += amount;
      walletTransactions.insert(
        0,
        WalletTransactionModel(
          id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
          passengerId: passengerId,
          title: 'Transit Wallet Top-Up',
          busOrSource: source,
          amount: amount,
          type: 'RECHARGE',
          timestamp: DateTime.now(),
        ),
      );
      _persistPassengers();
      _persistTransactions();
      _pushStateToBackend();
      notifyListeners();
    }
  }

  PassengerModel? authenticatePassenger(String identifier, String password) {
    try {
      final clean = identifier.trim().toLowerCase();
      return registeredPassengers.firstWhere(
        (p) =>
            (p.email.toLowerCase() == clean || p.phone == clean || p.id.toLowerCase() == clean) &&
            p.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  PassengerModel? findPassengerByIdOrPhone(String query) {
    try {
      final clean = query.trim().toLowerCase();
      return registeredPassengers.firstWhere(
        (p) =>
            p.id.toLowerCase() == clean ||
            p.phone.toLowerCase() == clean ||
            p.email.toLowerCase() == clean ||
            p.name.toLowerCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  PassengerModel registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
    String concessionCategory = 'General / Adult Standard',
  }) {
    final newId = 'SBK-KL-${100000 + registeredPassengers.length + 1}';
    final passenger = PassengerModel(
      id: newId,
      name: name,
      email: email,
      phone: phone,
      password: password,
      walletBalance: 0.0, // Clean 0 balance as requested
      concessionCategory: concessionCategory,
      registeredAt: DateTime.now(),
    );
    registeredPassengers.add(passenger);
    _persistPassengers();
    _pushStateToBackend();
    notifyListeners();
    return passenger;
  }

  List<IssuedTicketModel> getTicketsForPassenger(String passengerId) {
    return issuedTickets.where((t) => t.passengerId == passengerId).toList();
  }

  List<IssuedTicketModel> getTicketsForBus(String busRegNumber) {
    final clean = busRegNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return issuedTickets.where((t) {
      final tBus = t.busRegNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      return tBus == clean;
    }).toList();
  }

  List<WalletTransactionModel> getTransactionsForPassenger(String passengerId) {
    return walletTransactions.where((t) => t.passengerId == passengerId).toList();
  }

  bool deletePassenger(String passengerId) {
    final idx = registeredPassengers.indexWhere((p) => p.id == passengerId);
    if (idx != -1) {
      registeredPassengers.removeAt(idx);
      walletTransactions.removeWhere((t) => t.passengerId == passengerId);
      _persistPassengers();
      _persistTransactions();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Owner Methods & Multi-Tenant Isolation
  OwnerModel? authenticateOwner(String identifier, String password) {
    try {
      final clean = identifier.trim().toLowerCase();
      return registeredOwners.firstWhere(
        (o) =>
            (o.email.toLowerCase() == clean ||
             o.phone == clean ||
             o.id.toLowerCase() == clean ||
             (clean == 'owner' && o.id == 'OWNER-1')) &&
            o.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  OwnerModel? findOwnerByIdOrPhone(String query) {
    try {
      final clean = query.trim().toLowerCase();
      return registeredOwners.firstWhere(
        (o) =>
            o.id.toLowerCase() == clean ||
            o.phone.toLowerCase() == clean ||
            o.email.toLowerCase() == clean ||
            o.name.toLowerCase() == clean ||
            o.companyName.toLowerCase().contains(clean),
      );
    } catch (_) {
      return null;
    }
  }

  OwnerModel registerOwner({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String companyName,
  }) {
    final newId = 'OWNER-${DateTime.now().millisecondsSinceEpoch}';
    final owner = OwnerModel(
      id: newId,
      name: name,
      email: email,
      phone: phone,
      password: password,
      companyName: companyName,
      isVerified: true,
      registeredAt: DateTime.now(),
    );
    registeredOwners.add(owner);
    _persistOwners();
    notifyListeners();
    return owner; // Completely empty fleet profile!
  }

  bool deleteOwner(String ownerId) {
    final idx = registeredOwners.indexWhere((o) => o.id == ownerId);
    if (idx != -1) {
      registeredOwners.removeAt(idx);
      buses.removeWhere((b) => b.ownerId == ownerId);
      conductors.removeWhere((c) => c.ownerId == ownerId);
      _persistOwners();
      _persistBuses();
      _persistConductors();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Owner-Specific Fleet Queries
  List<BusModel> getBusesForOwner(String ownerId) {
    return buses.where((b) => b.ownerId == ownerId).toList();
  }

  List<ConductorModel> getConductorsForOwner(String ownerId) {
    return conductors.where((c) => c.ownerId == ownerId).toList();
  }

  double getTotalCollectionForOwner(String ownerId) {
    final ownerBuses = getBusesForOwner(ownerId);
    return ownerBuses.fold<double>(0.0, (sum, b) => sum + b.todayCollection);
  }

  int getActiveBusesCountForOwner(String ownerId) {
    return getBusesForOwner(ownerId).where((b) => b.isActive).length;
  }

  int getTotalTicketsSoldForOwner(String ownerId) {
    return getBusesForOwner(ownerId).fold<int>(0, (sum, b) => sum + b.ticketsCount);
  }

  double getWalletCollectionForOwner(String ownerId) {
    return getTotalCollectionForOwner(ownerId) * 0.65;
  }

  double getCashInHandForOwner(String ownerId) {
    return getTotalCollectionForOwner(ownerId) * 0.35;
  }

  int getUnreadReviewsCountForOwner([String? ownerId]) {
    if (ownerId == null) {
      return reviews.where((r) => !r.isReadByOwner).length;
    }
    final ownerBusRegs = getBusesForOwner(ownerId).map((b) => b.regNumber.toUpperCase()).toSet();
    return reviews.where((r) => !r.isReadByOwner && ownerBusRegs.contains(r.busRegNumber.toUpperCase())).length;
  }

  // Conductor Methods
  ConductorModel? authenticateConductor(String userId, String password) {
    try {
      return conductors.firstWhere(
        (c) => c.userId.trim().toLowerCase() == userId.trim().toLowerCase() && c.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  bool deleteConductor(String conductorId) {
    final idx = conductors.indexWhere((c) => c.id == conductorId);
    if (idx != -1) {
      conductors.removeAt(idx);
      _persistConductors();
      notifyListeners();
      return true;
    }
    return false;
  }

  void addConductor(ConductorModel conductor) {
    conductors.add(conductor);
    _persistConductors();
    _pushStateToBackend();
    notifyListeners();
  }

  // Global / General Fleet Queries
  double get totalCollection => buses.fold(0.0, (sum, b) => sum + b.todayCollection);
  int get totalTicketsSold => buses.fold(0, (sum, b) => sum + b.ticketsCount);
  int get activeBusesCount => buses.where((b) => b.isActive).length;
  double get walletCollection => totalCollection * 0.65;
  double get cashInHand => totalCollection * 0.35;

  void addBus(BusModel bus) {
    bus.sortStops();
    buses.add(bus);
    _persistBuses();
    _pushStateToBackend();
    notifyListeners();
  }

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
      _persistBuses();
      _pushStateToBackend();
      notifyListeners();
    }
  }

  BusModel? getBusByReg(String regNumber) {
    try {
      return buses.firstWhere((b) => b.regNumber.toUpperCase() == regNumber.toUpperCase());
    } catch (_) {
      return buses.isNotEmpty ? buses.first : null;
    }
  }

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

    // If Smart Wallet, debit ONLY that connected passenger's wallet
    if (ticket.paymentMode == 'SMART_WALLET' && ticket.passengerId != 'Unknown') {
      final pIndex = registeredPassengers.indexWhere((p) => p.id == ticket.passengerId);
      if (pIndex != -1) {
        registeredPassengers[pIndex].walletBalance =
            (registeredPassengers[pIndex].walletBalance - ticket.fare).clamp(0.0, 99999.0);
        
        walletTransactions.insert(
          0,
          WalletTransactionModel(
            id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
            passengerId: ticket.passengerId,
            title: 'Bus Ticket: ${ticket.boardingStop} ➔ ${ticket.destStop}',
            busOrSource: '${ticket.busName} (${ticket.busRegNumber})',
            amount: -ticket.fare,
            type: 'WALLET',
            timestamp: ticket.issuedAt,
          ),
        );
      }
    }

    _persistTickets();
    _persistBuses();
    _persistConductors();
    _persistPassengers();
    _persistTransactions();
    _pushStateToBackend();
    notifyListeners();
  }

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
    _persistReviews();
    notifyListeners();
  }

  int getUnreadReviewsCountForConductor(String busReg) {
    return reviews.where((r) => r.busRegNumber == busReg && !r.isReadByConductor).length;
  }

  void markReviewsAsReadForOwner([String? ownerId]) {
    if (ownerId == null) {
      for (final r in reviews) {
        r.isReadByOwner = true;
      }
    } else {
      final ownerBuses = getBusesForOwner(ownerId).map((b) => b.regNumber.toUpperCase()).toSet();
      for (final r in reviews) {
        if (ownerBuses.contains(r.busRegNumber.toUpperCase())) {
          r.isReadByOwner = true;
        }
      }
    }
    _persistReviews();
    notifyListeners();
  }

  void markReviewsAsReadForConductor(String busReg) {
    for (final r in reviews) {
      if (r.busRegNumber == busReg) {
        r.isReadByConductor = true;
      }
    }
    _persistReviews();
    notifyListeners();
  }

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
    _persistBuses();
    notifyListeners();
  }

  void setBusManualCurrentStop(String busReg, String stopName, {String? nextStopName}) {
    final bus = getBusByReg(busReg);
    if (bus == null) return;

    bus.currentStop = stopName;
    bus.conductorLocationString = '$stopName (Conductor Manual Stop Override)';

    final idx = bus.stops.indexWhere((s) => s.stopName.trim().toLowerCase() == stopName.trim().toLowerCase());
    if (idx >= 0) {
      bus.currentStageIndex = idx;
      if (idx < bus.stops.length - 1) {
        bus.nextStop = '${bus.stops[idx + 1].stopName} (~3 mins)';
      } else {
        bus.nextStop = '${bus.destPoint} (Destination Reached)';
      }
    } else if (nextStopName != null) {
      bus.nextStop = nextStopName;
    }

    _persistBuses();
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
      _persistBuses();
      notifyListeners();
    }
  }
}
