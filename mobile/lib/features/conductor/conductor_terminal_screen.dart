import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConductorTerminalScreen extends StatefulWidget {
  final VoidCallback onEndTrip;
  final Function(double fare) onTicketIssued;

  const ConductorTerminalScreen({
    super.key,
    required this.onEndTrip,
    required this.onTicketIssued,
  });

  @override
  State<ConductorTerminalScreen> createState() => _ConductorTerminalScreenState();
}

class _ConductorTerminalScreenState extends State<ConductorTerminalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerAnimCtrl;

  String _boardingStop = 'Aluva Stand';
  String _destStop = 'Kizhakkambalam';
  String _concessionType = 'General'; // 'General', 'Student Concession', 'Senior'
  String _paymentMode = 'WALLET'; // 'WALLET', 'CASH', 'UPI'

  double _calculatedFare = 18.0;
  double _totalCollection = 480.0;
  int _ticketsIssued = 24;
  bool _passengerScanned = false;
  final String _scannedPassengerName = 'Anjali Nair';

  final List<Map<String, dynamic>> _stops = [
    {'name': 'Aluva Stand', 'stage': 1},
    {'name': 'Bank Junction', 'stage': 2},
    {'name': 'Pump Junction', 'stage': 3},
    {'name': 'Kizhakkambalam', 'stage': 4},
    {'name': 'Pattimattom', 'stage': 5},
    {'name': 'Perumbavoor Stand', 'stage': 6},
  ];

  @override
  void initState() {
    super.initState();
    _scannerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerAnimCtrl.dispose();
    super.dispose();
  }

  void _recalcFare() {
    int bIndex = _stops.indexWhere((s) => s['name'] == _boardingStop);
    int dIndex = _stops.indexWhere((s) => s['name'] == _destStop);
    double base = 10.0;
    if (dIndex > bIndex) {
      int stages = dIndex - bIndex;
      base = 10.0 + (stages - 1) * 2.5;
    }

    if (_concessionType == 'Student Concession') {
      base = (base * 0.5).clamp(2.0, 50.0); // 50% Kerala student concession
    }

    setState(() {
      _calculatedFare = base;
    });
  }

  void _simulateScan() {
    setState(() {
      _passengerScanned = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text('Passenger Verified: Anjali Nair (Wallet: ₹250.00)'),
          ],
        ),
        backgroundColor: AppTheme.darkSlate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleIssueTicket() {
    widget.onTicketIssued(_calculatedFare);
    setState(() {
      _totalCollection += _calculatedFare;
      _ticketsIssued += 1;
      _passengerScanned = false;
    });

    final ticketNo = 'SBK-20261018-${(1000 + _ticketsIssued)}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 28),
              SizedBox(width: 10),
              Text('Ticket Confirmed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fare Deducted:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${_calculatedFare.toStringAsFixed(1)} ($_paymentMode)',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _ticketRow('Ticket No', ticketNo),
              _ticketRow('Passenger', _scannedPassengerName),
              _ticketRow('Bus', 'KL 07 CD 4589 (SpeedWings)'),
              _ticketRow('Journey', '$_boardingStop ➔ $_destStop'),
              _ticketRow('Category', _concessionType),
              const Divider(height: 20),
              const Text(
                'Digital receipt synced to passenger wallet & server ledger.',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Next Passenger'),
            ),
          ],
        );
      },
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
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
            Text('Bus: KL 07 CD 4589 • SpeedWings Line', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live Trip Status HUD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          const Text('TRIP ACTIVE • GPS STREAMING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: widget.onEndTrip,
                        child: const Text('End Trip'),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCol('Total Collection', '₹${_totalCollection.toInt()}'),
                      _statCol('Tickets Issued', '$_ticketsIssued'),
                      _statCol('Current Stop', _boardingStop),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Animated Laser QR Scanner Viewfinder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _scannerAnimCtrl,
                    builder: (context, child) {
                      return Positioned(
                        top: 20 + (_scannerAnimCtrl.value * 150),
                        left: 40,
                        right: 40,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(color: Colors.redAccent.withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 2),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Viewfinder Frame Corners
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentAmber, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white24, size: 80),
                  ),

                  // Scan Simulation Trigger Button
                  Positioned(
                    bottom: 12,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _passengerScanned ? Colors.green : AppTheme.accentAmber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _simulateScan,
                      icon: Icon(_passengerScanned ? Icons.check : Icons.camera_alt, size: 16),
                      label: Text(
                        _passengerScanned ? 'Passenger ID Verified' : 'Tap to Scan QR Code',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Spot Ticketing Form Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Spot Ticketing Pad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),

                    // Boarding Stop Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Boarding Stop',
                        prefixIcon: const Icon(Icons.flight_takeoff, color: AppTheme.primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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

                    const SizedBox(height: 12),

                    // Destination Stop Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Destination Stop',
                        prefixIcon: const Icon(Icons.flight_land, color: Colors.red),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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

                    const SizedBox(height: 14),

                    // Concession Category Switcher
                    Row(
                      children: ['General', 'Student Concession'].map((type) {
                        final isSel = _concessionType == type;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSel ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.transparent,
                                side: BorderSide(color: isSel ? AppTheme.primaryGreen : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _concessionType = type;
                                  _recalcFare();
                                });
                              },
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? AppTheme.primaryGreen : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Payment Method Pill Selector
                    Row(
                      children: [
                        _paymentPill('Smart Wallet', 'WALLET', Icons.account_balance_wallet),
                        _paymentPill('Cash', 'CASH', Icons.money),
                        _paymentPill('UPI QR', 'UPI', Icons.qr_code_scanner),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Fare & Issue Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Fare:', style: TextStyle(fontSize: 15, color: Colors.grey)),
                        Text(
                          '₹${_calculatedFare.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _handleIssueTicket,
                      icon: const Icon(Icons.print, size: 20),
                      label: const Text('Issue Ticket & Debit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _statCol(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _paymentPill(String title, String modeKey, IconData icon) {
    final isSelected = _paymentMode == modeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMode = modeKey),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
