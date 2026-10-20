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

  // Connected Passenger (Optional - null indicates Walk-in / Unknown)
  PassengerModel? _connectedPassenger;
  int _connectionTab = 0; // 0: QR Scanner, 1: Type ID/Mobile
  final _manualIdController = TextEditingController();

  // Ticketing Pad State
  final _boardingController = TextEditingController();
  final _destController = TextEditingController();
  String _category = 'General'; // 'General', 'Student Concession'
  String _paymentMode = 'CASH'; // 'SMART_WALLET', 'CASH', 'UPI', 'SPLIT'

  // Conductor Fare Assignment Controller (Conductor can edit / adjust directly)
  final _fareController = TextEditingController(text: '10.0');

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
    FleetState.instance.addListener(_onFleetChanged);
  }

  void _onFleetChanged() {
    if (mounted) {
      final found = FleetState.instance.getBusByReg(widget.conductor.assignedBusReg);
      if (found != null) {
        _bus = found;
      }
      setState(() {});
    }
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

    _syncFareWithStage();
  }

  @override
  void dispose() {
    FleetState.instance.removeListener(_onFleetChanged);
    _scannerAnimCtrl.dispose();
    _boardingController.dispose();
    _destController.dispose();
    _fareController.dispose();
    _manualIdController.dispose();
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
      _syncFareWithStage();
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
      _syncFareWithStage();
    });
  }

  // Calculate standard stage fare based on route schedule & Kerala tariff rules
  double _calculateStageFare() {
    if (_category == 'Student Concession') {
      return 5.0; // Kerala Student Concession fixed at ₹5
    }

    // General Tariff
    int bIndex = _bus.stops.indexWhere((s) => s.stopName.toLowerCase() == _boardingController.text.trim().toLowerCase());
    int dIndex = _bus.stops.indexWhere((s) => s.stopName.toLowerCase() == _destController.text.trim().toLowerCase());

    if (bIndex == -1) bIndex = 0;
    if (dIndex == -1) dIndex = _bus.stops.length > 1 ? _bus.stops.length - 1 : 1;

    int stages = (dIndex - bIndex).abs();
    if (stages == 0) stages = 1;

    return (10.0 + (stages - 1) * 3.5).clamp(10.0, 75.0);
  }

  void _syncFareWithStage() {
    final stageFare = _calculateStageFare();
    _fareController.text = stageFare.toStringAsFixed(1);
  }

  void _adjustFare(double delta) {
    final current = double.tryParse(_fareController.text.trim()) ?? _calculateStageFare();
    final updated = (current + delta).clamp(1.0, 500.0);
    setState(() {
      _fareController.text = updated.toStringAsFixed(1);
    });
  }

  double get _currentAssignedFare {
    return double.tryParse(_fareController.text.trim()) ?? _calculateStageFare();
  }

  // ---------------------------------------------------------------------------
  // Passenger Connection Methods
  // ---------------------------------------------------------------------------
  void _connectPassenger(PassengerModel passenger) {
    setState(() {
      _connectedPassenger = passenger;
      if (passenger.concessionCategory.toLowerCase().contains('student')) {
        _category = 'Student Concession';
      }
      _syncFareWithStage();
      _paymentMode = 'SMART_WALLET';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent),
            const SizedBox(width: 8),
            Text('Passenger Connected: ${passenger.name} (${passenger.id}) • Balance: ₹${passenger.walletBalance.toStringAsFixed(1)}'),
          ],
        ),
        backgroundColor: AppTheme.darkSlate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _disconnectPassenger() {
    setState(() {
      _connectedPassenger = null;
      _manualIdController.clear();
      if (_paymentMode == 'SMART_WALLET') {
        _paymentMode = 'CASH';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched to Walk-in Mode (Unknown / Unlinked passenger). Record saved in conductor portal only.'),
        backgroundColor: Colors.brown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _findAndConnectManual() {
    final query = _manualIdController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Passenger ID or Mobile Number to search.')),
      );
      return;
    }

    final found = FleetState.instance.findPassengerByIdOrPhone(query);
    if (found != null) {
      _connectPassenger(found);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No passenger found matching "$query". You can issue ticket as Unknown walk-in.'),
          backgroundColor: Colors.orange.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showScanPassengerDialog() {
    final passengers = FleetState.instance.registeredPassengers;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text('Simulate QR Code Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Select a passenger whose personal QR pass is being scanned:',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 20),
              ...passengers.map((p) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('ID: ${p.id} • ${p.concessionCategory}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${p.walletBalance.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13)),
                        const Text('Wallet', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _connectPassenger(p);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
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
    final fare = _currentAssignedFare;
    final paymentMode = _isSplitEnabled ? 'SPLIT' : _paymentMode;
    final cashGiven = double.tryParse(_cashGivenController.text.trim()) ?? fare;
    final splitCash = double.tryParse(_splitCashController.text.trim()) ?? (fare / 2);
    final splitUpi = double.tryParse(_splitUpiController.text.trim()) ?? (fare / 2);

    final isConnected = _connectedPassenger != null;
    final passengerId = isConnected ? _connectedPassenger!.id : 'Unknown';
    final passengerName = isConnected ? _connectedPassenger!.name : 'Unknown';

    // Smart Wallet validation
    if (paymentMode == 'SMART_WALLET') {
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Smart Wallet requires a connected Passenger account. Please select Cash or UPI for Unknown passenger.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_connectedPassenger!.walletBalance < fare) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient Smart Wallet balance (₹${_connectedPassenger!.walletBalance.toStringAsFixed(1)}). Ticket fare is ₹${fare.toStringAsFixed(1)}. Please choose Cash or UPI.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    void finalizeTicket() {
      final ticketNum = 'KL-SBK-${DateFormat("ddMM").format(DateTime.now())}-${(1000 + FleetState.instance.issuedTickets.length + 1)}';

      final ticket = IssuedTicketModel(
        id: 'TCK-${DateTime.now().millisecondsSinceEpoch}',
        ticketNumber: ticketNum,
        busRegNumber: _bus.regNumber,
        busName: _bus.busName,
        conductorId: widget.conductor.id,
        conductorName: widget.conductor.name,
        passengerId: passengerId,
        passengerName: passengerName,
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
        // Refresh local connected passenger balance if connected
        if (isConnected) {
          _connectedPassenger = FleetState.instance.registeredPassengers.firstWhere((p) => p.id == passengerId);
        }
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
        final isUnknown = ticket.passengerId == 'Unknown';

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
                        const Text('Passenger Name & ID:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('${ticket.passengerName} (${ticket.passengerId})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isUnknown ? Colors.brown : AppTheme.primaryGreen,
                            )),
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
                        const Text('TOTAL ASSIGNED FARE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('₹${ticket.fare.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUnknown ? Colors.amber.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUnknown
                      ? 'Walk-in Record: Saved in Conductor & Bus logs only. No passenger profile debited or modified.'
                      : 'Linked Record: ₹${ticket.fare.toStringAsFixed(1)} debited ONLY from ${ticket.passengerName}\'s wallet.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isUnknown ? Colors.brown.shade800 : Colors.green.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
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
    final assignedFare = _currentAssignedFare;
    final stageFare = _calculateStageFare();
    final latestTickets = FleetState.instance.getTicketsForBus(_bus.regNumber).take(5).toList();

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
          // 2. PASSENGER CONNECTION SECTION (DUAL METHOD: QR OR TYPE ID)
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
                          Icon(Icons.link, color: AppTheme.primaryGreen),
                          SizedBox(width: 8),
                          Text('Passenger Link (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _connectedPassenger != null ? Colors.green.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _connectedPassenger != null ? Colors.green.shade300 : Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _connectedPassenger != null ? Icons.check_circle : Icons.person_outline,
                              size: 12,
                              color: _connectedPassenger != null ? Colors.green : Colors.brown,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _connectedPassenger != null ? 'CONNECTED' : 'WALK-IN (UNKNOWN)',
                              style: TextStyle(
                                color: _connectedPassenger != null ? Colors.green.shade800 : Colors.brown.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connecting is optional. If not connected, ticket is issued to "Unknown" with no profile linked and saved only in conductor\'s logs.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  // Connection Mode Switcher: QR Scanner vs Type ID
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _connectionTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _connectionTab == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _connectionTab == 0
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_scanner,
                                      size: 16, color: _connectionTab == 0 ? AppTheme.primaryGreen : Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '1. Camera QR Scanner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _connectionTab == 0 ? FontWeight.bold : FontWeight.normal,
                                      color: _connectionTab == 0 ? Colors.black87 : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _connectionTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _connectionTab == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _connectionTab == 1
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.keyboard,
                                      size: 16, color: _connectionTab == 1 ? AppTheme.primaryGreen : Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '2. Type Passenger ID',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _connectionTab == 1 ? FontWeight.bold : FontWeight.normal,
                                      color: _connectionTab == 1 ? Colors.black87 : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Option A: QR Code Scanner Viewfinder
                  if (_connectionTab == 0) ...[
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF131A22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5), width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(Icons.crop_free, size: 100, color: Colors.white.withValues(alpha: 0.15)),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _scannerAnimCtrl,
                            builder: (context, child) {
                              return Align(
                                alignment: Alignment(0, (_scannerAnimCtrl.value * 2) - 1),
                                child: Container(
                                  height: 2,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    boxShadow: [
                                      BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 2),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code, color: Colors.white70, size: 30),
                              const SizedBox(height: 6),
                              Text(
                                _connectedPassenger != null
                                    ? 'Connected: ${_connectedPassenger!.name}'
                                    : 'Point camera at Passenger Portal QR Code',
                                style: TextStyle(
                                  color: _connectedPassenger != null ? Colors.greenAccent : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showScanPassengerDialog,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(
                        _connectedPassenger != null ? 'Re-scan / Switch Passenger QR' : 'Scan Passenger QR Pass',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],

                  // Option B: Manual Type Passenger ID / Mobile
                  if (_connectionTab == 1) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualIdController,
                            decoration: InputDecoration(
                              labelText: 'Passenger ID or Mobile Number',
                              hintText: 'e.g. SBK-KL-987263 or 9847000004',
                              prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryGreen),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _findAndConnectManual(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _findAndConnectManual,
                          child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Quick test buttons
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        const Text('Quick ID fill:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ActionChip(
                          label: const Text('Anjali: SBK-KL-987263', style: TextStyle(fontSize: 10)),
                          onPressed: () {
                            _manualIdController.text = 'SBK-KL-987263';
                            _findAndConnectManual();
                          },
                        ),
                        ActionChip(
                          label: const Text('Rahul: SBK-KL-554120', style: TextStyle(fontSize: 10)),
                          onPressed: () {
                            _manualIdController.text = 'SBK-KL-554120';
                            _findAndConnectManual();
                          },
                        ),
                        ActionChip(
                          label: const Text('Meera: SBK-KL-339811', style: TextStyle(fontSize: 10)),
                          onPressed: () {
                            _manualIdController.text = 'SBK-KL-339811';
                            _findAndConnectManual();
                          },
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Status Card: Connected Passenger vs Walk-in Mode
                  if (_connectedPassenger != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
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
                                      Text(_connectedPassenger!.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('ID: ${_connectedPassenger!.id} • ${_connectedPassenger!.phone}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(currency.format(_connectedPassenger!.walletBalance),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 14)),
                                  const Text('Wallet Balance', style: TextStyle(color: Colors.grey, fontSize: 9)),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Concession: ${_connectedPassenger!.concessionCategory}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                onPressed: _disconnectPassenger,
                                icon: const Icon(Icons.link_off, size: 16),
                                label: const Text('Disconnect (Walk-in)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.person_off_outlined, color: Colors.brown, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Walk-in Passenger Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
                                Text('Tickets will be issued to: Unknown (ID: Unknown). Smart Wallet disabled; use Cash or UPI.',
                                    style: TextStyle(fontSize: 11, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  const Text('Stops suggestions are restricted strictly to places saved on this bus schedule.',
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
                                    _syncFareWithStage();
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
                                    _syncFareWithStage();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. Category: General vs Student Concession (₹5)
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
                            if (val) {
                              setState(() {
                                _category = 'General';
                                _syncFareWithStage();
                              });
                            }
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
                            if (val) {
                              setState(() {
                                _category = 'Student Concession';
                                _syncFareWithStage();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. Conductor Fare Assignment & Calculation Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calculate, color: AppTheme.primaryGreen, size: 20),
                                SizedBox(width: 6),
                                Text('Conductor Fare Assignment',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Text('Auto-Stage: ₹${stageFare.toStringAsFixed(1)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Conductor can calculate & directly assign or adjust the passenger fare (e.g. luggage, special stage).',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _fareController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGreen),
                                decoration: InputDecoration(
                                  labelText: 'Assigned Fare',
                                  prefixText: '₹ ',
                                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGreen),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => setState(() => _syncFareWithStage()),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Quick step adjustments
                        Wrap(
                          spacing: 6,
                          children: [
                            ActionChip(
                              label: const Text('- ₹5', style: TextStyle(fontSize: 11)),
                              onPressed: () => _adjustFare(-5),
                            ),
                            ActionChip(
                              label: const Text('- ₹1', style: TextStyle(fontSize: 11)),
                              onPressed: () => _adjustFare(-1),
                            ),
                            ActionChip(
                              label: const Text('+ ₹1', style: TextStyle(fontSize: 11)),
                              onPressed: () => _adjustFare(1),
                            ),
                            ActionChip(
                              label: const Text('+ ₹5', style: TextStyle(fontSize: 11)),
                              onPressed: () => _adjustFare(5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Payment Modes: Smart Wallet (Default for connected), Cash, UPI QR
                  const Text('Payment Mode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildPaymentChip(
                        'Smart Wallet',
                        'SMART_WALLET',
                        Icons.account_balance_wallet,
                        enabled: _connectedPassenger != null,
                      ),
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
                              const Text('Liquid Cash Handling',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
                              Text('Assigned Fare: ₹${assignedFare.toStringAsFixed(1)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                                final given = double.tryParse(_cashGivenController.text.trim()) ?? assignedFare;
                                final change = (given - assignedFare).clamp(0.0, 9999.0);
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
                                      _splitCashController.text = (assignedFare / 2).toStringAsFixed(1);
                                      _splitUpiController.text = (assignedFare / 2).toStringAsFixed(1);
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

                  // Calculated & Assigned Fare Display & Issue Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ASSIGNED FARE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                          Text(
                            '₹${assignedFare.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                          Text(
                            _connectedPassenger != null
                                ? 'For: ${_connectedPassenger!.name}'
                                : 'For: Unknown (Walk-in)',
                            style: TextStyle(fontSize: 11, color: _connectedPassenger != null ? AppTheme.primaryGreen : Colors.brown),
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
              Text('Latest Issued Tickets (${_bus.busName})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${latestTickets.length} recent', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          if (latestTickets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No tickets issued yet for ${_bus.busName} (${_bus.regNumber}).',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
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
                  subtitle: Text('${t.ticketNumber} • ${t.passengerName} (${t.passengerId}) • ${t.paymentMode}',
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

  Widget _buildPaymentChip(String label, String mode, IconData icon, {bool enabled = true}) {
    final isSelected = _paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!enabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Smart Wallet requires a connected Passenger account. Connect passenger via QR or ID first.'),
                backgroundColor: Colors.brown,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          setState(() {
            _paymentMode = mode;
            if (mode != 'CASH') _isSplitEnabled = false;
          });
        },
        child: Opacity(
          opacity: enabled ? 1.0 : 0.45,
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
      ),
    );
  }
}
