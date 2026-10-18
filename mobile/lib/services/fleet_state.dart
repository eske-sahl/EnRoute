class BusModel {
  final String id;
  final String regNumber;
  final String busName;
  final String busType;
  final String routeName;
  final String startTime;
  final String endTime;
  final String conductorName;
  final String driverName;
  final String cleanerName;
  final String companyName;
  final int seatingCapacity;
  double todayCollection;
  int ticketsCount;
  final String status; // 'RUNNING_NOW', 'PENDING_ADMIN', 'SCHEDULED'
  final bool isApprovedByAdmin;
  final String currentStop;
  final String nextStop;
  final String eta;

  BusModel({
    required this.id,
    required this.regNumber,
    required this.busName,
    required this.busType,
    required this.routeName,
    required this.startTime,
    required this.endTime,
    required this.conductorName,
    required this.driverName,
    required this.cleanerName,
    required this.companyName,
    required this.seatingCapacity,
    this.todayCollection = 0.0,
    this.ticketsCount = 0,
    this.status = 'RUNNING_NOW',
    this.isApprovedByAdmin = true,
    this.currentStop = 'Pump Junction',
    this.nextStop = 'Kizhakkambalam (~4 mins)',
    this.eta = '4 mins',
  });
}

class ConductorModel {
  final String id;
  final String loginId;
  final String password;
  final String name;
  final String phone;
  final String badgeNumber;
  final String assignedBusReg;
  final String assignedBusName;
  double todayCollection;

  ConductorModel({
    required this.id,
    required this.loginId,
    required this.password,
    required this.name,
    required this.phone,
    required this.badgeNumber,
    required this.assignedBusReg,
    required this.assignedBusName,
    this.todayCollection = 0.0,
  });
}

class FleetState {
  static final FleetState instance = FleetState._internal();
  FleetState._internal();

  final List<BusModel> buses = [
    BusModel(
      id: 'BUS-1',
      regNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      busType: 'Ordinary Line Service',
      routeName: 'Aluva - Perumbavoor (via Kizhakkambalam, R-14)',
      startTime: '06:00 AM',
      endTime: '08:30 PM',
      conductorName: 'Suresh Kumar',
      driverName: 'Venu Pillai (Badge #KL4201)',
      cleanerName: 'Mani K.',
      companyName: 'St. George Motors Ernakulam',
      seatingCapacity: 48,
      todayCollection: 6420.0,
      ticketsCount: 168,
      status: 'RUNNING_NOW',
      isApprovedByAdmin: true,
      currentStop: 'Pump Junction (Stage 3)',
      nextStop: 'Kizhakkambalam (Stage 4)',
      eta: '4 mins',
    ),
    BusModel(
      id: 'BUS-2',
      regNumber: 'KL 07 CE 1204',
      busName: 'GreenCity Express',
      busType: 'Fast Passenger (FP)',
      routeName: 'Ernakulam Kaloor - Thoppumpady (R-08)',
      startTime: '06:30 AM',
      endTime: '09:00 PM',
      conductorName: 'Biju Varghese',
      driverName: 'Antony Joseph',
      cleanerName: 'Saji T.',
      companyName: 'St. George Motors Ernakulam',
      seatingCapacity: 52,
      todayCollection: 7840.0,
      ticketsCount: 202,
      status: 'RUNNING_NOW',
      isApprovedByAdmin: true,
      currentStop: 'Menaka Junction',
      nextStop: 'Thevara Ferry (~6 mins)',
      eta: '6 mins',
    ),
    BusModel(
      id: 'BUS-3',
      regNumber: 'KL 07 BQ 9981',
      busName: 'St. Marys Line',
      busType: 'Ordinary Line Service',
      routeName: 'Vytilla - Kakkanad InfoPark (R-22)',
      startTime: '07:00 AM',
      endTime: '08:00 PM',
      conductorName: 'Rajesh M.',
      driverName: 'Pradeep Kumar',
      cleanerName: 'Babu N.',
      companyName: 'St. George Motors Ernakulam',
      seatingCapacity: 48,
      todayCollection: 4220.0,
      ticketsCount: 116,
      status: 'RUNNING_NOW',
      isApprovedByAdmin: true,
      currentStop: 'Palarivattom Bypass',
      nextStop: 'Kakkanad Stand (~8 mins)',
      eta: '8 mins',
    ),
  ];

  final List<ConductorModel> conductors = [
    ConductorModel(
      id: 'COND-1',
      loginId: 'suresh.conductor',
      password: 'password123',
      name: 'Suresh Kumar',
      phone: '+91 98470 11001',
      badgeNumber: 'KL-MVD-8941',
      assignedBusReg: 'KL 07 CD 4589',
      assignedBusName: 'SpeedWings',
      todayCollection: 6420.0,
    ),
    ConductorModel(
      id: 'COND-2',
      loginId: 'biju.conductor',
      password: 'password123',
      name: 'Biju Varghese',
      phone: '+91 98470 11002',
      badgeNumber: 'KL-MVD-9214',
      assignedBusReg: 'KL 07 CE 1204',
      assignedBusName: 'GreenCity Express',
      todayCollection: 7840.0,
    ),
    ConductorModel(
      id: 'COND-3',
      loginId: 'rajesh.conductor',
      password: 'password123',
      name: 'Rajesh M.',
      phone: '+91 98470 11003',
      badgeNumber: 'KL-MVD-7731',
      assignedBusReg: 'KL 07 BQ 9981',
      assignedBusName: 'St. Marys Line',
      todayCollection: 4220.0,
    ),
  ];

  // Aggregated Stats
  double get totalCollection => buses.fold(0.0, (sum, b) => sum + b.todayCollection);
  int get totalTicketsSold => buses.fold(0, (sum, b) => sum + b.ticketsCount);
  int get activeBusesCount => buses.where((b) => b.isApprovedByAdmin).length;
  double get walletCollection => totalCollection * 0.65; // 65% digital wallet
  double get cashInHand => totalCollection * 0.35; // 35% cash

  void addBus(BusModel bus) {
    buses.add(bus);
  }

  void addConductor(ConductorModel conductor) {
    conductors.add(conductor);
  }
}
