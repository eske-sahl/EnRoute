import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';
import '../bus_detail_page.dart';

class OwnerBusListTab extends StatefulWidget {
  final OwnerModel owner;
  final VoidCallback onNavigateToConductorTab;

  const OwnerBusListTab({
    super.key,
    required this.owner,
    required this.onNavigateToConductorTab,
  });

  @override
  State<OwnerBusListTab> createState() => _OwnerBusListTabState();
}

class _OwnerBusListTabState extends State<OwnerBusListTab> {
  Color _getCategoryColor(String category) {
    if (category.contains('Red') || category.contains('Limited')) {
      return const Color(0xFFC62828);
    } else if (category.contains('Blue') || category.contains('Ordinary')) {
      return const Color(0xFF1565C0);
    } else {
      return const Color(0xFF2E7D32);
    }
  }

  void _showRegisterBusModal() {
    // Required fields
    final regCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String selectedCategory = 'Limited Stop Bus (Red-Whiteline)';

    // Optional fields
    final startPointCtrl = TextEditingController();
    final destPointCtrl = TextEditingController();
    final seatsCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final cleanerCtrl = TextEditingController();
    final ownerConductors = FleetState.instance.getConductorsForOwner(widget.owner.id);
    String selectedConductor = ownerConductors.isNotEmpty 
        ? ownerConductors.first.name 
        : 'Unassigned';

    // Optional intermediate stops
    List<Map<String, String>> intermediateStops = [];

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
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
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                              SizedBox(width: 8),
                              Text('Register New Bus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
                        ],
                      ),
                      const Text(
                        'Submit vehicle details to register this bus in your fleet. Registration number is permanent and cannot be modified later.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // Section 1: Required Information Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.red, size: 14),
                            SizedBox(width: 6),
                            Text('REQUIRED FIELDS', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1. Registration Number (Required)
                      TextFormField(
                        controller: regCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Registration Number (Kerala Plate) *',
                          hintText: 'e.g. KL 07 CD 4589',
                          prefixIcon: const Icon(Icons.pin, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          helperText: 'Permanent Kerala RTO registration plate (Immutable)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Registration Number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // 2. Bus Name (Required)
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Bus Display Name *',
                          hintText: 'e.g. SpeedWings / Kochi Express',
                          prefixIcon: const Icon(Icons.directions_bus_filled, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bus Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // 3. Category (Required)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Kerala Bus Category & Livery *',
                          prefixIcon: const Icon(Icons.palette, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        initialValue: selectedCategory,
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
                            setModalState(() => selectedCategory = val);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Section 2: Optional Information Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey, size: 14),
                            SizedBox(width: 6),
                            Text('OPTIONAL FIELDS (Can be modified anytime / by assigned conductor)', 
                              style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Route: Start Point - Destination Point (Optional)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: startPointCtrl,
                              decoration: InputDecoration(
                                labelText: 'Start Point (Optional)',
                                hintText: 'e.g. Aluva Stand',
                                prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: destPointCtrl,
                              decoration: InputDecoration(
                                labelText: 'Destination (Optional)',
                                hintText: 'e.g. Angamaly',
                                prefixIcon: const Icon(Icons.location_on, color: Colors.red, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Intermediate Stops & Departure Timings (Optional)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Stops & Timing Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                intermediateStops.add({'stop': 'New Stop', 'time': '08:00 AM'});
                              });
                            },
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Add Stop', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const Text(
                        'Note: Conductor can also add, edit or modify intermediate stops & timings in their portal.',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      ...intermediateStops.asMap().entries.map((entry) {
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
                                  onChanged: (val) => intermediateStops[idx]['stop'] = val,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: item['time'],
                                  decoration: InputDecoration(
                                    labelText: 'Time',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onChanged: (val) => intermediateStops[idx]['time'] = val,
                                ),
                              ),
                              if (intermediateStops.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
                                  onPressed: () {
                                    setModalState(() {
                                      intermediateStops.removeAt(idx);
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 10),

                      // Seats (Optional)
                      TextFormField(
                        controller: seatsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Passenger Seating Capacity (Optional)',
                          hintText: '48',
                          prefixIcon: const Icon(Icons.event_seat, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Workers: Driver & Cleaner (Optional)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: driverCtrl,
                              decoration: InputDecoration(
                                labelText: 'Driver Name (Optional)',
                                prefixIcon: const Icon(Icons.airline_seat_recline_normal, color: AppTheme.primaryGreen, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: cleanerCtrl,
                              decoration: InputDecoration(
                                labelText: 'Cleaner (Optional)',
                                prefixIcon: const Icon(Icons.cleaning_services, color: AppTheme.primaryGreen, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Workers: Assigned Conductor (Optional)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Assigned Conductor (Optional)',
                          prefixIcon: const Icon(Icons.badge, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        initialValue: selectedConductor,
                        items: [
                          const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned (Assign Later)')),
                          ...FleetState.instance.getConductorsForOwner(widget.owner.id).map((c) {
                            return DropdownMenuItem(value: c.name, child: Text('${c.name} (${c.userId})'));
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedConductor = val);
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final start = startPointCtrl.text.trim().isNotEmpty ? startPointCtrl.text.trim() : 'Aluva Stand';
                          final dest = destPointCtrl.text.trim().isNotEmpty ? destPointCtrl.text.trim() : 'Angamaly Stand';
                          final seats = int.tryParse(seatsCtrl.text.trim()) ?? 48;
                          final driver = driverCtrl.text.trim().isNotEmpty ? driverCtrl.text.trim() : 'Unassigned';
                          final cleaner = cleanerCtrl.text.trim().isNotEmpty ? cleanerCtrl.text.trim() : 'Unassigned';

                          final scheduleList = intermediateStops.map((s) {
                            return BusStopSchedule(stopName: s['stop'] ?? 'Stop', time: s['time'] ?? '08:00 AM');
                          }).toList();
                          scheduleList.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));

                          final newBus = BusModel(
                            id: 'BUS-${DateTime.now().millisecondsSinceEpoch}',
                            ownerId: widget.owner.id,
                            regNumber: regCtrl.text.trim().toUpperCase(),
                            busName: nameCtrl.text.trim(),
                            category: selectedCategory,
                            startPoint: start,
                            destPoint: dest,
                            routeName: '$start - $dest',
                            stops: scheduleList,
                            seatingCapacity: seats,
                            driverName: driver,
                            cleanerName: cleaner,
                            conductorName: selectedConductor,
                            companyName: widget.owner.companyName,
                            ownerName: widget.owner.name,
                            ownerPhone: widget.owner.phone,
                            ownerEmail: widget.owner.email,
                            todayCollection: 0.0,
                            ticketsCount: 0,
                            isActive: true,
                            status: 'RUNNING_NOW',
                            isApprovedByAdmin: true,
                            currentStop: start,
                            nextStop: intermediateStops.length > 1 ? intermediateStops[1]['stop']! : dest,
                            eta: 'Departing soon',
                          );

                          // If conductor is assigned, update their assigned bus
                          if (selectedConductor != 'Unassigned') {
                            final condIdx = FleetState.instance.conductors.indexWhere((c) => c.name == selectedConductor);
                            if (condIdx != -1) {
                              FleetState.instance.conductors[condIdx].assignedBusReg = newBus.regNumber;
                              FleetState.instance.conductors[condIdx].assignedBusName = newBus.busName;
                            }
                          }

                          setState(() {
                            FleetState.instance.addBus(newBus);
                          });

                          Navigator.pop(modalCtx);

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.verified, color: AppTheme.primaryGreen),
                                    SizedBox(width: 8),
                                    Text('Bus Registered!'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${newBus.busName} (${newBus.regNumber})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Text('Category: ${newBus.category}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                    Text('Route: ${newBus.routeName}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Authenticity verified & added to your fleet! This bus and its route are now visible in Passenger Search and Conductor Portal.',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Save & Register Bus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
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
    final fleet = FleetState.instance;
    final ownerBuses = fleet.getBusesForOwner(widget.owner.id);
    final activeCount = ownerBuses.where((b) => b.isActive).length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Bus Fleet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${ownerBuses.length} registered vehicles • $activeCount Active', 
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _showRegisterBusModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register New Bus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (ownerBuses.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 14),
                      Text(
                        'No Buses Registered Under ${widget.owner.companyName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first private or city bus to the fleet by tapping "Register New Bus" above. Once registered, your routes, time schedules, and conductors will be tracked live.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...ownerBuses.map((bus) {
              final catColor = _getCategoryColor(bus.category);

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: bus.isActive ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade300,
                    width: bus.isActive ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusDetailPage(
                          bus: bus,
                          onNavigateToConductors: widget.onNavigateToConductorTab,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: bus.isActive
                                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.directions_bus,
                                        color: bus.isActive ? AppTheme.primaryGreen : Colors.grey.shade600,
                                        size: 26,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          bus.isActive ? Icons.check_circle : Icons.cancel,
                                          color: bus.isActive ? Colors.green : Colors.red,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300),
                                          ),
                                          child: Text(
                                            bus.isActive ? 'ACTIVE' : 'INACTIVE',
                                            style: TextStyle(
                                              color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(bus.regNumber,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ADMIN APPROVED',
                                style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Livery Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: catColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                bus.category,
                                style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Route: ${bus.routeName}',
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Row(
                              children: [
                                Text('Manage Details', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.primaryGreen),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            const AppCreatorFooter(),
          ],
        ),
      ),
    );
  }
}
