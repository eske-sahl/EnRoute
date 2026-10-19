import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class ConductorDashboardTab extends StatefulWidget {
  final ConductorModel conductor;
  final VoidCallback onNavigateToJourney;

  const ConductorDashboardTab({
    super.key,
    required this.conductor,
    required this.onNavigateToJourney,
  });

  @override
  State<ConductorDashboardTab> createState() => _ConductorDashboardTabState();
}

class _ConductorDashboardTabState extends State<ConductorDashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerAnimCtrl;

  // Selected Bus
  late BusModel _bus;

  // Connected Passenger Info (Scanned from Passenger Portal)
  bool _passengerConnected = false;
  String _passengerName = 'Anjali Nair';
  String _passengerId = 'PASS-1004';
  String _passengerPhone = '+91 98470 00004';

  // Ticketing Pad State
  final _boardingController = TextEditingController();
  final _destController = TextEditingController();
  String _category = 'General'; // 'General', 'Student Concession'
  String _paymentMode = 'SMART_WALLET'; // 'SMART_WALLET', 'CASH', 'UPI', 'SPLIT'

  // Cash & Split Payment Controllers
  final _cashGivenController = TextEditingController(text: '50');
  final _splitCashController = TextEditingController(text: '10');
  final _splitUpiController = TextEditingController(text: '10');
  bool _isSplitEnabled = false;

  // Autocomplete Suggestions for Stops
  List<String> _boardingSuggestions = [];
  List<String> _destSuggestions = [];
  bool _showBoardingSuggestions = false;
  bool _showDestSuggestions = false;

  @override
  void initState() {
    super.initState();
    _scannerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initBus();
  }

  void _initBus() {
    final found = FleetState.instance.getBusByReg(widget.conductor.assignedBusReg);
    _bus = found ?? FleetState.instance.buses.first;

    // Default stops from bus route schedule
    if (_bus.stops.isNotEmpty) {
      _boardingController.text = _bus.stops.first.stopName;
      _destController.text = _bus.stops.length > 3 ? _bus.stops[3].stopName : _bus.stops.last.stopName;
    } else {
      _boardingController.text = _bus.startPoint;
      _destController.text = _bus.destPoint;
    }
  }

  @override
  void dispose() {
    _scannerAnimCtrl.dispose();
    _boardingController.dispose();
    _destController.dispose();
    _cashGivenController.dispose();
    _splitCashController.dispose();
    _splitUpiController.dispose();
    super.dispose();
  }

  // Strictly filter suggestions to places saved in this particular bus schedule
  List<String> get _busSavedPlaces {
    final places = <String>{};
    if (_bus.startPoint.isNotEmpty) places.add(_bus.startPoint);
    if (_bus.destPoint.isNotEmpty) places.add(_bus.destPoint);
    for (final s in _bus.stops) {
      if (s.stopName.isNotEmpty) places.add(s.stopName);
    }
    return places.toList();
  }

  void _onBoardingChanged(String val) {
    setState(() {
      if (val.trim().isEmpty) {
        _boardingSuggestions = [];
        _showBoardingSuggestions = false;
      } else {
        _boardingSuggestions = _busSavedPlaces
            .where((p) => p.toLowerCase().contains(val.trim().toLowerCase()))
            .toList();
        _showBoardingSuggestions = _boardingSuggestions.isNotEmpty;
      }
    });
  }

  void _onDestChanged(String val) {
    setState(() {
      if (val.trim().isEmpty) {
        _destSuggestions = [];
        _showDestSuggestions = false;
      } else {
        _destSuggestions = _busSavedPlaces
            .where((p) => p.toLowerCase().contains(val.trim().toLowerCase()))
            .toList();
        _showDestSuggestions = _destSuggestions.isNotEmpty;
      }
    });
  }

  // Calculate fare based on route stages & concession rule
  double _calculateFare() {
    if (_category == 'Student Concession') {
      return 5.0; // Kerala Student Concession fixed at ₹5 only
    }

    // General Tariff
    int bIndex = _bus.stops.indexWhere((s) => s.stopName.toLowerCase() == _boardingController.text.trim().toLowerCase());
    int dIndex = _bus.stops.indexWhere((s) => s.stopName.toLowerCase() == _destController.text.trim().toLowerCase());

    if (bIndex == -1) bIndex = 0;
    if (dIndex == -1) dIndex = _bus.stops.length - 1;

    int stages = (dIndex - bIndex).abs();
    if (stages == 0) stages = 1;

    return (10.0 + (stages - 1) * 3.5).clamp(10.0, 60.0);
  }

  void _simulateScanPassengerQr() {
    setState(() {
      _passengerConnected = true;
      _passengerName = 'Anjali Nair';
      _passengerId = 'PASS-1004';
      _passengerPhone = '+91 98470 00004';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.greenAccent),
            const SizedBox(width: 8),
            Text('Passenger Connected: $_passengerName (Wallet: ₹${FleetState.instance.passengerWalletBalance.toStringAsFixed(1)})'),
          ],
        ),
        backgroundColor: AppTheme.darkSlate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleTrip() {
    final newActiveState = !_bus.isTripActive;
    setState(() {
      FleetState.instance.setTripActive(_bus.regNumber, newActiveState);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newActiveState
              ? 'Trip Started! GPS Location Broadcast ACTIVE. Sharing live updates to passengers & owner.'
              : 'Trip Stopped. Location broadcast paused.',
        ),
        backgroundColor: newActiveState ? AppTheme.primaryGreen : Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUpiQrModal(double fare, VoidCallback onPaymentConfirmed) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.qr_code_2, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              const Text('UPI Dynamic Spot QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pay ₹${fare.toStringAsFixed(1)} to ${_bus.busName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGreen)),
              const SizedBox(height: 4),
              Text('VPA: smartbus.${_bus.regNumber.replaceAll(" ", "").toLowerCase()}@upi',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: 'upi://pay?pa=smartbus.${_bus.regNumber.replaceAll(" ", "").toLowerCase()}@upi&pn=${_bus.busName}&am=${fare.toStringAsFixed(1)}&cu=INR',
                  version: QrVersions.auto,
                  size: 180,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Scan using any UPI App: GPay, PhonePe, Paytm, BHIM',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              onPressed: () {
                Navigator.pop(ctx);
                onPaymentConfirmed();
              },
              child: const Text('Confirm Payment Received'),
            ),
          ],
        );
      },
    );
  }

  void _handleIssueTicket() {
    final fare = _calculateFare();
    final paymentMode = _isSplitEnabled ? 'SPLIT' : _paymentMode;
    final cashGiven = double.tryParse(_cashGivenController.text.trim()) ?? fare;
    final splitCash = double.tryParse(_splitCashController.text.trim()) ?? (fare / 2);
    final splitUpi = double.tryParse(_splitUpiController.text.trim()) ?? (fare / 2);

    void finalizeTicket() {
      final ticketNum = 'KL-SBK-${DateFormat("ddMM").format(DateTime.now())}-${(1000 + FleetState.instance.issuedTickets.length + 1)}';

      final ticket = IssuedTicketModel(
        id: 'TCK-${DateTime.now().millisecondsSinceEpoch}',
        ticketNumber: ticketNum,
        busRegNumber: _bus.regNumber,
        busName: _bus.busName,
        conductorId: widget.conductor.id,
        conductorName: widget.conductor.name,
        passengerId: _passengerConnected ? _passengerId : 'PASS-WALK-IN',
        passengerName: _passengerConnected ? _passengerName : 'Walk-in Passenger',
        boardingStop: _boardingController.text.trim(),
        destStop: _destController.text.trim(),
        fare: fare,
        category: _category,
        paymentMode: paymentMode,
        cashGiven: paymentMode == 'CASH' ? cashGiven : 0.0,
        changeReturned: paymentMode == 'CASH' ? (cashGiven - fare).clamp(0.0, 9999.0) : 0.0,
        splitCash: paymentMode == 'SPLIT' ? splitCash : 0.0,
        splitUpi: paymentMode == 'SPLIT' ? splitUpi : 0.0,
        issuedAt: DateTime.now(),
      );

      setState(() {
        FleetState.instance.issueTicket(ticket);
      });

      _showTicketIssuedReceipt(ticket);
    }

    if (paymentMode == 'UPI') {
      _showUpiQrModal(fare, finalizeTicket);
    } else {
      finalizeTicket();
    }
  }

  void _showTicketIssuedReceipt(IssuedTicketModel ticket) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 28),
              SizedBox(width: 10),
              Text('Ticket Issued!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(ticket.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(ticket.busRegNumber, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ticket No:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(ticket.ticketNumber, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Route:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('${ticket.boardingStop} ➔ ${ticket.destStop}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Type & Category:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(ticket.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Mode:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(ticket.paymentMode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    if (ticket.paymentMode == 'CASH' && ticket.changeReturned > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cash Given / Change:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('₹${ticket.cashGiven.toInt()} (Return: ₹${ticket.changeReturned.toInt()})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange)),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL FARE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('₹${ticket.fare.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Synchronized in real-time with Passenger Portal Ticket History and Owner Dashboard.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK / Next Passenger'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final fare = _calculateFare();
    final latestTickets = FleetState.instance.issuedTickets.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------------------------------------------------------------------
          // 1. TOP CARD: Live Telemetry, Status & Start/Stop Trip Button
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.darkCardGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_bus.busName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(_bus.regNumber, style: const TextStyle(color: AppTheme.accentAmber, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _bus.isTripActive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _bus.isTripActive ? Colors.greenAccent : Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _bus.isTripActive ? Icons.sensors : Icons.power_settings_new,
                            size: 14,
                            color: _bus.isTripActive ? Colors.greenAccent : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _bus.isTripActive ? 'RUNNING NOW' : 'STOPPED / DEPOT',
                            style: TextStyle(
                              color: _bus.isTripActive ? Colors.greenAccent : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TODAY\'S COLLECTION', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1)),
                        const SizedBox(height: 2),
                        Text(currency.format(_bus.todayCollection),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TICKETS ISSUED', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1)),
                        const SizedBox(height: 2),
                        Text('${_bus.ticketsCount} tickets',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentAmber)),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),

                // Current Stop & Next Stop Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT STAGE / STOP', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(_bus.currentStop,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('APPROACHING NEXT', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(_bus.nextStop,
                              style: const TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Start/Stop Trip Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bus.isTripActive ? Colors.red.shade700 : AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _toggleTrip,
                  icon: Icon(_bus.isTripActive ? Icons.stop_circle : Icons.play_circle_fill),
                  label: Text(
                    _bus.isTripActive ? 'Stop / End Current Trip' : 'Start Trip & Broadcast Live GPS',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // 2. CAM SCANNER SECTION
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen),
                          SizedBox(width: 8),
                          Text('Passenger Identity Scanner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      if (_passengerConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.check, size: 12, color: Colors.green),
                              SizedBox(width: 4),
                              Text('CONNECTED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Scan passenger QR pass to automatically connect & enable Smart Wallet debit.',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 14),

                  // Simulated Camera Viewfinder with Laser
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Viewfinder corners
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Icon(Icons.crop_free, size: 120, color: Colors.white.withValues(alpha: 0.15)),
                          ),
                        ),
                        // Animated Scanning Laser Line
                        AnimatedBuilder(
                          animation: _scannerAnimCtrl,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scannerAnimCtrl.value * 2) - 1),
                              child: Container(
                                height: 2,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  boxShadow: [
                                    BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Overlay instruction
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code, color: Colors.white70, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              _passengerConnected ? 'Passenger Connected: $_passengerName' : 'Point camera at Passenger Portal QR Code',
                              style: TextStyle(
                                color: _passengerConnected ? Colors.greenAccent : Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Simulate Scan Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _passengerConnected ? Colors.grey.shade700 : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _simulateScanPassengerQr,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(_passengerConnected ? 'Re-scan Another Passenger QR' : 'Scan Passenger QR Pass (Simulate)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),

                  if (_passengerConnected) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_passengerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('ID: $_passengerId • $_passengerPhone', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currency.format(FleetState.instance.passengerWalletBalance),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 14)),
                              const Text('Wallet Balance', style: TextStyle(color: Colors.grey, fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // 3. TICKETING PAD (FORM)
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.confirmation_number, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text('Ticketing Pad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Suggestions are restricted strictly to places saved on this bus schedule.',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 14),

                  // 1. Boarding Stop (Type with route place suggestions)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _boardingController,
                        onChanged: _onBoardingChanged,
                        decoration: InputDecoration(
                          labelText: 'Boarding Stop',
                          prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      if (_showBoardingSuggestions)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 140),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _boardingSuggestions.length,
                            itemBuilder: (ctx, i) {
                              final place = _boardingSuggestions[i];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.place, size: 16, color: AppTheme.primaryGreen),
                                title: Text(place, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                onTap: () {
                                  setState(() {
                                    _boardingController.text = place;
                                    _showBoardingSuggestions = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. Destination Stop (Type with route place suggestions)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _destController,
                        onChanged: _onDestChanged,
                        decoration: InputDecoration(
                          labelText: 'Destination Stop',
                          prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      if (_showDestSuggestions)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 140),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _destSuggestions.length,
                            itemBuilder: (ctx, i) {
                              final place = _destSuggestions[i];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.place, size: 16, color: Colors.red),
                                title: Text(place, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                onTap: () {
                                  setState(() {
                                    _destController.text = place;
                                    _showDestSuggestions = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. Category: General (Default) vs Student Concession (₹5 only)
                  const Text('Passenger Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('General (Standard)'),
                          selected: _category == 'General',
                          selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          onSelected: (val) {
                            if (val) setState(() => _category = 'General');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.school, size: 16, color: Colors.orange),
                          label: const Text('Student Concession (₹5)'),
                          selected: _category == 'Student Concession',
                          selectedColor: Colors.orange.withValues(alpha: 0.15),
                          onSelected: (val) {
                            if (val) setState(() => _category = 'Student Concession');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 4. Payment Modes: Smart Wallet (Default), Cash, UPI QR
                  const Text('Payment Mode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildPaymentChip('Smart Wallet', 'SMART_WALLET', Icons.account_balance_wallet),
                      const SizedBox(width: 6),
                      _buildPaymentChip('Cash', 'CASH', Icons.payments_outlined),
                      const SizedBox(width: 6),
                      _buildPaymentChip('UPI QR', 'UPI', Icons.qr_code_2),
                    ],
                  ),

                  // Cash Details & Split Payment options
                  if (_paymentMode == 'CASH') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Liquid Cash Handling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
                              Text('Ticket Fare: ₹${fare.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cashGivenController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Cash Given by Passenger',
                                    prefixText: '₹ ',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Builder(builder: (context) {
                                final given = double.tryParse(_cashGivenController.text.trim()) ?? fare;
                                final change = (given - fare).clamp(0.0, 9999.0);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Change to Return:', style: TextStyle(fontSize: 10, color: Colors.brown)),
                                    Text('₹${change.toStringAsFixed(1)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                                  ],
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 10),
                          // Split Payment Toggle: Few as Cash, Few as UPI
                          Row(
                            children: [
                              Checkbox(
                                value: _isSplitEnabled,
                                activeColor: AppTheme.primaryGreen,
                                onChanged: (val) {
                                  setState(() {
                                    _isSplitEnabled = val ?? false;
                                    if (_isSplitEnabled) {
                                      _splitCashController.text = (fare / 2).toStringAsFixed(1);
                                      _splitUpiController.text = (fare / 2).toStringAsFixed(1);
                                    }
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text('Split Payment: Pay few as Cash & few as UPI',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),

                          if (_isSplitEnabled) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _splitCashController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Cash (₹)', border: OutlineInputBorder(), isDense: true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _splitUpiController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'UPI (₹)', border: OutlineInputBorder(), isDense: true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Calculated Fare Display & Issue Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CALCULATED FARE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                          Text(
                            '₹${fare.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _handleIssueTicket,
                        icon: const Icon(Icons.print, size: 20),
                        label: const Text('Issue Ticket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // 4. RECENT 5 TICKETS SHORT LIST
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Latest Issued Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${latestTickets.length} recent', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          ...latestTickets.map((t) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  child: const Icon(Icons.confirmation_number, color: AppTheme.primaryGreen, size: 18),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${t.boardingStop} ➔ ${t.destStop}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('₹${t.fare.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  ],
                ),
                subtitle: Text('${t.ticketNumber} • ${t.category} • ${t.paymentMode}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: Text(DateFormat('hh:mm a').format(t.issuedAt),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String label, String mode, IconData icon) {
    final isSelected = _paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _paymentMode = mode;
          if (mode != 'CASH') _isSplitEnabled = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.black87),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
