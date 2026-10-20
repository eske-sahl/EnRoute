import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';

class BusDetailPage extends StatefulWidget {
  final BusModel bus;
  final VoidCallback onNavigateToConductors;

  const BusDetailPage({
    super.key,
    required this.bus,
    required this.onNavigateToConductors,
  });

  @override
  State<BusDetailPage> createState() => _BusDetailPageState();
}

class _BusDetailPageState extends State<BusDetailPage> {
  late String _busName;
  late String _category;
  late String _startPoint;
  late String _destPoint;
  late List<BusStopSchedule> _stops;
  late int _seats;
  late String _driver;
  late String _cleaner;
  late String _conductor;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _syncFromBus();
  }

  void _syncFromBus() {
    widget.bus.sortStops();
    _busName = widget.bus.busName;
    _category = widget.bus.category;
    _startPoint = widget.bus.startPoint;
    _destPoint = widget.bus.destPoint;
    _stops = List.from(widget.bus.stops);
    _stops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));
    _seats = widget.bus.seatingCapacity;
    _driver = widget.bus.driverName;
    _cleaner = widget.bus.cleanerName;
    _conductor = widget.bus.conductorName;
    _isActive = widget.bus.isActive;
  }

  Color _getCategoryColor(String category) {
    if (category.contains('Red') || category.contains('Limited')) {
      return const Color(0xFFC62828);
    } else if (category.contains('Blue') || category.contains('Ordinary')) {
      return const Color(0xFF1565C0);
    } else {
      return const Color(0xFF2E7D32);
    }
  }

  void _toggleActiveStatus(bool active) {
    setState(() {
      _isActive = active;
      widget.bus.isActive = active;
      widget.bus.status = active ? 'RUNNING_NOW' : 'IN_DEPOT';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bus status set to ${active ? "ACTIVE (Running on Route)" : "INACTIVE (In Depot)"}'),
        backgroundColor: active ? AppTheme.primaryGreen : Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditBusModal() {
    final nameCtrl = TextEditingController(text: _busName);
    String selectedCat = _category;
    final startCtrl = TextEditingController(text: _startPoint);
    final destCtrl = TextEditingController(text: _destPoint);
    final seatsCtrl = TextEditingController(text: '$_seats');
    final driverCtrl = TextEditingController(text: _driver);
    final cleanerCtrl = TextEditingController(text: _cleaner);
    String selectedCond = _conductor;
    bool editIsActive = _isActive;

    // Editable copy of stops
    List<Map<String, String>> editStops = _stops.map((s) {
      return {'stop': s.stopName, 'time': s.time};
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Edit Bus Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const Text(
                      'Owners can modify any vehicle parameters except the permanent RTO Registration Number.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Immutable Reg Number Display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.grey, size: 20),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('REGISTRATION NUMBER (LOCKED)', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text(widget.bus.regNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('IMMUTABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Active / Inactive Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bus Operational Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(editIsActive ? 'ACTIVE (Operating on Route)' : 'INACTIVE (Off Route / In Depot)',
                          style: TextStyle(color: editIsActive ? Colors.green : Colors.grey, fontSize: 12)),
                      value: editIsActive,
                      activeThumbColor: AppTheme.primaryGreen,
                      onChanged: (val) {
                        setModalState(() => editIsActive = val);
                      },
                    ),
                    const Divider(height: 16),

                    // Bus Name
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Bus Display Name',
                        prefixIcon: const Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Kerala Bus Category & Livery',
                        prefixIcon: const Icon(Icons.palette, color: AppTheme.primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      initialValue: selectedCat,
                      items: const [
                        DropdownMenuItem(
                          value: 'Limited Stop Bus (Red-Whiteline)',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xFFC62828), size: 14),
                              SizedBox(width: 8),
                              Text('Limited Stop Bus (Red-Whiteline)', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Ordinary Bus (Blue-Whiteline)',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xFF1565C0), size: 14),
                              SizedBox(width: 8),
                              Text('Ordinary Bus (Blue-Whiteline)', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'City Bus (Green-Whiteline)',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xFF2E7D32), size: 14),
                              SizedBox(width: 8),
                              Text('City Bus (Green-Whiteline)', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCat = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Route: Start Point - Destination Point
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startCtrl,
                            decoration: InputDecoration(
                              labelText: 'Start Point',
                              prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: destCtrl,
                            decoration: InputDecoration(
                              labelText: 'Destination Point',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.red, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Intermediate Stops & Timings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Intermediate Stops & Timetable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              editStops.add({'stop': 'New Stop', 'time': '08:00 AM'});
                            });
                          },
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Add Stop', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...editStops.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: item['stop'],
                                decoration: InputDecoration(
                                  labelText: 'Stop #${idx + 1}',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (val) => editStops[idx]['stop'] = val,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: item['time'],
                                decoration: InputDecoration(
                                  labelText: 'Departure',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (val) => editStops[idx]['time'] = val,
                              ),
                            ),
                            if (editStops.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
                                onPressed: () {
                                  setModalState(() {
                                    editStops.removeAt(idx);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    // Seats
                    TextField(
                      controller: seatsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Passenger Seating Capacity',
                        prefixIcon: const Icon(Icons.event_seat, color: AppTheme.primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Workers: Driver & Cleaner
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: driverCtrl,
                            decoration: InputDecoration(
                              labelText: 'Driver Name',
                              prefixIcon: const Icon(Icons.airline_seat_recline_normal, color: AppTheme.primaryGreen, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: cleanerCtrl,
                            decoration: InputDecoration(
                              labelText: 'Cleaner Name',
                              prefixIcon: const Icon(Icons.cleaning_services, color: AppTheme.primaryGreen, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Workers: Conductor
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Assigned Conductor',
                        prefixIcon: const Icon(Icons.badge, color: AppTheme.primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      initialValue: (FleetState.instance.getConductorsForOwner(widget.bus.ownerId).any((c) => c.name == selectedCond))
                          ? selectedCond
                          : 'Unassigned',
                      items: [
                        const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned')),
                        ...FleetState.instance.getConductorsForOwner(widget.bus.ownerId).map((c) {
                          return DropdownMenuItem(value: c.name, child: Text('${c.name} (${c.userId})'));
                        }),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCond = val);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final updatedStops = editStops.map((s) {
                          return BusStopSchedule(stopName: s['stop'] ?? 'Stop', time: s['time'] ?? '08:00 AM');
                        }).toList();
                        updatedStops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));

                        FleetState.instance.updateBus(
                          regNumber: widget.bus.regNumber,
                          busName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _busName,
                          category: selectedCat,
                          startPoint: startCtrl.text.trim().isNotEmpty ? startCtrl.text.trim() : _startPoint,
                          destPoint: destCtrl.text.trim().isNotEmpty ? destCtrl.text.trim() : _destPoint,
                          seats: int.tryParse(seatsCtrl.text.trim()) ?? _seats,
                          driver: driverCtrl.text.trim().isNotEmpty ? driverCtrl.text.trim() : _driver,
                          cleaner: cleanerCtrl.text.trim().isNotEmpty ? cleanerCtrl.text.trim() : _cleaner,
                          conductor: selectedCond,
                          isActive: editIsActive,
                          stops: updatedStops,
                        );

                        // If conductor was selected, update their assigned bus
                        if (selectedCond != 'Unassigned') {
                          final cIdx = FleetState.instance.conductors.indexWhere((c) => c.name == selectedCond);
                          if (cIdx != -1) {
                            FleetState.instance.conductors[cIdx].assignedBusReg = widget.bus.regNumber;
                            FleetState.instance.conductors[cIdx].assignedBusName = widget.bus.busName;
                          }
                        }

                        setState(() {
                          _syncFromBus();
                        });

                        Navigator.pop(sheetCtx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.bus.busName} updated successfully! (Reg Num ${widget.bus.regNumber} preserved)'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Save & Apply Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(_category);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_busName Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.bus.regNumber, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Bus Configuration',
            onPressed: _showEditBusModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Live Operational Status & Collection Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.darkCardGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Active/Inactive toggle chip
                      GestureDetector(
                        onTap: () => _toggleActiveStatus(!_isActive),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isActive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isActive ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isActive ? Icons.sensors : Icons.power_settings_new,
                                color: _isActive ? Colors.greenAccent : Colors.redAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isActive ? 'ACTIVE ON ROUTE' : 'INACTIVE / DEPOT',
                                style: TextStyle(
                                  color: _isActive ? Colors.greenAccent : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Immutable Reg Plate
                      Row(
                        children: [
                          const Icon(Icons.lock, color: AppTheme.accentAmber, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            widget.bus.regNumber,
                            style: const TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TODAY\'S LIVE EARNINGS', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.bus.todayCollection.toStringAsFixed(1)}',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TICKETS ISSUED', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1)),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.bus.ticketsCount} tickets',
                            style: const TextStyle(color: AppTheme.accentAmber, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current: ${widget.bus.currentStop}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('Next: ${widget.bus.nextStop}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Kerala Livery & Category Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Bus Classification & Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _showEditBusModal,
                          icon: const Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                          label: const Text('Edit', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: catColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.palette, color: catColor, size: 18),
                          const SizedBox(width: 8),
                          Text(_category, style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Bus Name', _busName),
                    _infoRow('Registration No.', '${widget.bus.regNumber} (Immutable)'),
                    _infoRow('Seating Capacity', '$_seats Passenger Seats'),
                    _infoRow('Owner Company', widget.bus.companyName),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 3. Route & Stops Timetable Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.alt_route, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Route & Timetable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _showEditBusModal,
                          icon: const Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                          label: const Text('Modify', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(),
                    _infoRow('Route Corridor', '$_startPoint ➔ $_destPoint'),
                    _infoRow('Service Timings', '${widget.bus.startTime} to ${widget.bus.endTime}'),
                    const SizedBox(height: 12),
                    const Text('Stops & Timing Schedule:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (_stops.isEmpty)
                      const Text('No intermediate stops scheduled yet. Assigned conductor can add stops.', style: TextStyle(color: Colors.grey, fontSize: 12))
                    else
                      Column(
                        children: _stops.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final stop = entry.value;
                          final isFirst = idx == 0;
                          final isLast = idx == _stops.length - 1;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isFirst ? Icons.trip_origin : (isLast ? Icons.location_on : Icons.circle),
                                  size: 14,
                                  color: isFirst ? AppTheme.primaryGreen : (isLast ? Colors.red : Colors.grey),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    stop.stopName,
                                    style: TextStyle(
                                      fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(stop.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 4. Workers / Crew Assigned Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.badge, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Assigned Bus Crew & Workers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _showEditBusModal,
                          icon: const Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                          label: const Text('Reassign', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Conductor Item
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        child: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen),
                      ),
                      title: Text(_conductor, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Conductor • App Login ID assigned by Owner'),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToConductors();
                      },
                    ),

                    const Divider(height: 16),

                    // Driver Details
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.15),
                        child: const Icon(Icons.airline_seat_recline_normal, color: Colors.blue),
                      ),
                      title: Text(_driver, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Primary Driver • Heavy Vehicle License'),
                    ),

                    const Divider(height: 16),

                    // Cleaner Details
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withValues(alpha: 0.15),
                        child: const Icon(Icons.cleaning_services, color: Colors.orange),
                      ),
                      title: Text(_cleaner, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Cleaner / Vehicle Attendant'),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
