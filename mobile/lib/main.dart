import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SmartBusKeralaApp());
}

class SmartBusKeralaApp extends StatelessWidget {
  const SmartBusKeralaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBus Kerala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00875A), // Kerala Bus Emerald
          primary: const Color(0xFF00875A),
          secondary: const Color(0xFFFFAB00), // Kerala Bus Amber Gold
          surface: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00875A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const RoleNavigationWrapper(),
    );
  }
}

class RoleNavigationWrapper extends StatefulWidget {
  const RoleNavigationWrapper({super.key});

  @override
  State<RoleNavigationWrapper> createState() => _RoleNavigationWrapperState();
}

class _RoleNavigationWrapperState extends State<RoleNavigationWrapper> {
  int _currentRoleIndex = 0; // 0: Passenger, 1: Conductor, 2: Owner
  double _walletBalance = 250.0;
  bool _isBackendConnected = false;
  String _serverUptime = '';

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
  }

  Future<void> _checkServerConnection() async {
    final health = await ApiService.asyncCheckHealth();
    if (health != null && mounted) {
      setState(() {
        _isBackendConnected = true;
        _serverUptime = 'v${health['version'] ?? '1.0.0'} • Online';
      });
    }
  }

  void _addWalletMoney(double amount) async {
    setState(() {
      _walletBalance += amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('₹${amount.toStringAsFixed(0)} credited to SmartBus Wallet!'),
          ],
        ),
        backgroundColor: const Color(0xFF00875A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deductWalletMoney(double amount) {
    if (_walletBalance >= amount) {
      setState(() {
        _walletBalance -= amount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      PassengerDashboardScreen(
        walletBalance: _walletBalance,
        isOnline: _isBackendConnected,
        serverStatus: _serverUptime,
        onTopUp: _addWalletMoney,
        onRefreshConnection: _checkServerConnection,
      ),
      ConductorScannerScreen(
        isOnline: _isBackendConnected,
        onTicketIssued: (fare) {
          _deductWalletMoney(fare);
        },
      ),
      OwnerFleetDashboardScreen(
        isOnline: _isBackendConnected,
      ),
    ];

    return Scaffold(
      body: screens[_currentRoleIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentRoleIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentRoleIndex = index;
          });
        },
        indicatorColor: const Color(0xFFFFAB00).withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF00875A)),
            label: 'Passenger',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner, color: Color(0xFF00875A)),
            label: 'Conductor',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus, color: Color(0xFF00875A)),
            label: 'Bus Owner',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. PASSENGER DASHBOARD SCREEN
// ---------------------------------------------------------------------------
class PassengerDashboardScreen extends StatelessWidget {
  final double walletBalance;
  final bool isOnline;
  final String serverStatus;
  final Function(double) onTopUp;
  final VoidCallback onRefreshConnection;

  const PassengerDashboardScreen({
    super.key,
    required this.walletBalance,
    required this.isOnline,
    required this.serverStatus,
    required this.onTopUp,
    required this.onRefreshConnection,
  });

  void _showRechargeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Up Demo Wallet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a demo recharge amount to test ticketing balance:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [50.0, 100.0, 200.0, 500.0].map((amt) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      onTopUp(amt);
                      Navigator.pop(context);
                    },
                    child: Text('₹${amt.toInt()}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SmartBus Kerala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFFFFAB00) : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'Connected to Backend (5001)' : 'Offline / Standalone',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Check Server Connection',
            onPressed: onRefreshConnection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Smart Wallet Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00875A), Color(0xFF005A3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00875A).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PASSENGER SMART WALLET',
                        style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFAB00),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currencyFormat.format(walletBalance),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00875A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showRechargeDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Money'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ledger: ₹250 initial credit, zero unpaid balances.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Ledger'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Digital QR Pass Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Journey Pass (QR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Icon(Icons.qr_code_2, color: Color(0xFF00875A), size: 28),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Hold this QR code up to the conductor terminal upon boarding',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: 'SBK_PASSENGER_UID_987263',
                        version: QrVersions.auto,
                        size: 180.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF00875A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Passenger Token: SBK-KL-987263',
                      style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Real-Time Bus Radar
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00875A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.radar, color: Color(0xFF00875A)),
                ),
                title: const Text('Live Bus Radar (Route R-14)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Aluva - Perumbavoor via Kizhakkambalam'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('LIVE GPS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connected to Socket.io namespace /tracking. Receiving GPS pings every 5s.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. CONDUCTOR SCANNER & SPOT TICKETING SCREEN
// ---------------------------------------------------------------------------
class ConductorScannerScreen extends StatefulWidget {
  final bool isOnline;
  final Function(double) onTicketIssued;

  const ConductorScannerScreen({
    super.key,
    required this.isOnline,
    required this.onTicketIssued,
  });

  @override
  State<ConductorScannerScreen> createState() => _ConductorScannerScreenState();
}

class _ConductorScannerScreenState extends State<ConductorScannerScreen> {
  String _boardingStop = 'Aluva Stand';
  String _destStop = 'Kizhakkambalam';
  double _calculatedFare = 18.0;
  double _tripTotalCollection = 142.0;
  int _tripTicketsCount = 8;

  final List<Map<String, dynamic>> _stops = [
    {'name': 'Aluva Stand', 'stage': 1},
    {'name': 'Bank Junction', 'stage': 2},
    {'name': 'Pump Junction', 'stage': 3},
    {'name': 'Kizhakkambalam', 'stage': 4},
    {'name': 'Pattimattom', 'stage': 5},
    {'name': 'Perumbavoor Stand', 'stage': 6},
  ];

  void _recalcFare() {
    int bIndex = _stops.indexWhere((s) => s['name'] == _boardingStop);
    int dIndex = _stops.indexWhere((s) => s['name'] == _destStop);
    if (dIndex > bIndex) {
      int stages = dIndex - bIndex;
      setState(() {
        _calculatedFare = 10.0 + (stages - 1) * 2.5;
      });
    } else {
      setState(() {
        _calculatedFare = 10.0;
      });
    }
  }

  void _issueTicket() {
    widget.onTicketIssued(_calculatedFare);
    setState(() {
      _tripTotalCollection += _calculatedFare;
      _tripTicketsCount += 1;
    });

    final ticketNumber = 'SBK-20261018-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF00875A)),
              SizedBox(width: 8),
              Text('Ticket Issued!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SmartBus Kerala Digital Pass', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              const Text('Bus: KL 07 CD 4589 (SpeedWings)'),
              Text('Boarding: $_boardingStop'),
              Text('Destination: $_destStop'),
              const SizedBox(height: 8),
              Text(
                'Fare Paid: ₹${_calculatedFare.toStringAsFixed(1)} (Wallet)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00875A), fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Ref: $ticketNumber', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conductor Terminal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Bus: KL 07 CD 4589 • SpeedWings', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Trip Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00875A), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('TRIP ACTIVE • GPS STREAMING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Collection: ₹$_tripTotalCollection ($_tripTicketsCount tickets)',
                          style: const TextStyle(color: Colors.black87, fontSize: 14)),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trip completed. Daily collection summary reconciled.')),
                      );
                    },
                    child: const Text('End Trip'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scanner Viewfinder Area
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Color(0xFFFFAB00), size: 90),
                  Positioned(
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Align Passenger QR inside viewfinder',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Spot Ticketing Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spot Ticketing & Stage Tariff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Boarding Stop',
                        prefixIcon: const Icon(Icons.flight_takeoff, color: Color(0xFF00875A)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      initialValue: _boardingStop,
                      items: _stops.map((s) => DropdownMenuItem(value: s['name'] as String, child: Text(s['name']))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _boardingStop = val!;
                          _recalcFare();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Destination Stop',
                        prefixIcon: const Icon(Icons.flight_land, color: Colors.red),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      initialValue: _destStop,
                      items: _stops.map((s) => DropdownMenuItem(value: s['name'] as String, child: Text(s['name']))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _destStop = val!;
                          _recalcFare();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Authoritative Fare:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text('₹${_calculatedFare.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _issueTicket,
                        icon: const Icon(Icons.confirmation_num),
                        label: const Text('Issue Ticket (Debit Wallet)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. OWNER FLEET DASHBOARD SCREEN
// ---------------------------------------------------------------------------
class OwnerFleetDashboardScreen extends StatelessWidget {
  final bool isOnline;

  const OwnerFleetDashboardScreen({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('St. George Motors • 4 Active Buses', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Revenue Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Text('Today\'s Total Revenue', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('₹12,480.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol('Active Trips', '8'),
                      _metricCol('Tickets Sold', '412'),
                      _metricCol('Wallet Debits', '₹8,240'),
                      _metricCol('Cash', '₹4,240'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Your Fleet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _busCard('KL 07 CD 4589', 'SpeedWings', 'Aluva - Perumbavoor', 'IN_TRANSIT', true),
            _busCard('KL 07 CE 1204', 'GreenCity Express', 'Ernakulam - Thoppumpady', 'IN_TRANSIT', true),
            _busCard('KL 07 BQ 9981', 'St. Marys Line', 'Vytilla - Kakkanad', 'SCHEDULED', false),
          ],
        ),
      ),
    );
  }

  Widget _metricCol(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _busCard(String reg, String name, String route, String status, bool isLive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLive ? const Color(0xFF00875A).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.directions_bus, color: isLive ? const Color(0xFF00875A) : Colors.grey),
        ),
        title: Text('$name ($reg)', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(route),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isLive ? Colors.green.shade800 : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
