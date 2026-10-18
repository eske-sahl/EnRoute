import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../bus_location_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with SingleTickerProviderStateMixin {
  late TabController _innerTabCtrl;

  // Inner Tab 1: Route Search State
  String _startPoint = 'Aluva Stand';
  String _endPoint = 'Perumbavoor Stand';
  bool _hasSearchedRoute = false;

  // Inner Tab 2: Bus Search by Reg Number State
  final _regSearchController = TextEditingController(text: 'KL 07 CD 4589');
  bool _hasFoundBus = false;
  BusModel? _foundBus;

  // Dynamic stops extracted from all buses registered/modified by owner & conductor
  List<String> get _dynamicStops {
    final stopsSet = <String>{};
    for (final b in FleetState.instance.buses) {
      if (b.startPoint.trim().isNotEmpty) stopsSet.add(b.startPoint.trim());
      if (b.destPoint.trim().isNotEmpty) stopsSet.add(b.destPoint.trim());
      for (final s in b.stops) {
        if (s.stopName.trim().isNotEmpty) stopsSet.add(s.stopName.trim());
      }
    }
    // Baseline Kerala stops
    stopsSet.addAll([
      'Aluva Stand',
      'Bank Junction',
      'Pump Junction',
      'Kizhakkambalam',
      'Pattimattom',
      'Perumbavoor Stand',
      'Angamaly Stand',
      'Ernakulam Kaloor',
      'Thoppumpady',
      'Vytilla Hub',
      'Kakkanad InfoPark',
    ]);
    final sortedList = stopsSet.toList()..sort();
    return sortedList;
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

  @override
  void initState() {
    super.initState();
    _innerTabCtrl = TabController(length: 2, vsync: this);
    _searchBusByReg(); // Pre-load default bus search
  }

  @override
  void dispose() {
    _innerTabCtrl.dispose();
    _regSearchController.dispose();
    super.dispose();
  }

  void _searchRoute() {
    setState(() {
      _hasSearchedRoute = true;
    });
  }

  void _searchBusByReg() {
    final query = _regSearchController.text.replaceAll(' ', '').toUpperCase();
    final match = FleetState.instance.buses.where((b) {
      return b.regNumber.replaceAll(' ', '').toUpperCase() == query;
    }).toList();

    setState(() {
      if (match.isNotEmpty) {
        _hasFoundBus = true;
        _foundBus = match.first;
      } else {
        _hasFoundBus = false;
        _foundBus = null;
      }
    });
  }

  void _openBusLiveLocation(BusModel bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusLocationScreen(
          busRegNumber: bus.regNumber,
          busName: bus.busName,
          routeName: bus.routeName,
          companyName: bus.companyName,
        ),
      ),
    );
  }

  List<BusModel> _getFilteredBuses() {
    if (!_hasSearchedRoute) return [];

    final startQuery = _startPoint.trim().toLowerCase();
    final endQuery = _endPoint.trim().toLowerCase();

    // Check buses where start/dest or any stops match the queried points
    final matches = FleetState.instance.buses.where((bus) {
      final text = '${bus.startPoint} ${bus.destPoint} ${bus.routeName} ${bus.stops.map((s) => s.stopName).join(" ")}'.toLowerCase();
      final hasStart = text.contains(startQuery);
      final hasEnd = text.contains(endQuery);
      return hasStart || hasEnd;
    }).toList();

    return matches.isNotEmpty ? matches : FleetState.instance.buses;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure selected points exist in dynamic stops list
    final allStops = _dynamicStops;
    if (!allStops.contains(_startPoint)) _startPoint = allStops.first;
    if (!allStops.contains(_endPoint)) _endPoint = allStops.length > 1 ? allStops[1] : allStops.first;

    return Column(
      children: [
        // Sub-Tabs Header
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _innerTabCtrl,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryGreen,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.alt_route, size: 20),
                text: 'Bus Route Search',
              ),
              Tab(
                icon: Icon(Icons.search, size: 20),
                text: 'Bus by Reg. Number',
              ),
            ],
          ),
        ),

        // Sub-Tabs Content
        Expanded(
          child: TabBarView(
            controller: _innerTabCtrl,
            children: [
              _buildRouteSearchTab(allStops),
              _buildBusRegSearchTab(),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // INNER TAB 1: BUS ROUTE SEARCH
  // -------------------------------------------------------------------------
  Widget _buildRouteSearchTab(List<String> allStops) {
    final filteredBuses = _getFilteredBuses();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route Input Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Find Buses on Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Real-time updates from owner fleet & conductor route changes', 
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 14),

                  // Start Point Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Trip Start Point',
                      prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    initialValue: _startPoint,
                    items: allStops.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _startPoint = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // End Point Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Trip End Point',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    initialValue: _endPoint,
                    items: allStops.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _endPoint = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _searchRoute,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Running Buses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bus Search Results
          if (_hasSearchedRoute) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Buses on $_startPoint ➔ $_endPoint',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text('${filteredBuses.length} Available', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            ...filteredBuses.map((bus) {
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
                  onTap: () => _openBusLiveLocation(bus),
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
                                        size: 24,
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
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            bus.isActive ? 'ACTIVE' : 'INACTIVE',
                                            style: TextStyle(
                                              color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(bus.regNumber, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${bus.seatingCapacity} Seats', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                Text('Driver: ${bus.driverName.split(" ").first}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Livery Category tag
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
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(bus.category, style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text('Route: ${bus.routeName}', style: const TextStyle(fontSize: 12, color: Colors.black87)),

                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 15, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${bus.startTime} ➔ ${bus.endTime}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                            const Row(
                              children: [
                                Text('Live Radar Track', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 11, color: AppTheme.primaryGreen),
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
          ] else ...[
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.directions_bus, size: 48, color: Colors.black26),
                  SizedBox(height: 10),
                  Text('Select start and end points and tap Search Running Buses', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // INNER TAB 2: BUS SEARCH BY REGISTRATION NUMBER
  // -------------------------------------------------------------------------
  Widget _buildBusRegSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Input Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Search by Kerala Bus Registration Plate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _regSearchController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Registration Number',
                            hintText: 'e.g. KL 07 CD 4589',
                            prefixIcon: const Icon(Icons.pin, color: AppTheme.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _searchBusByReg,
                        child: const Text('Find', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FleetState.instance.buses.take(3).map((b) {
                      return ActionChip(
                        label: Text(b.regNumber, style: const TextStyle(fontSize: 10)),
                        onPressed: () {
                          _regSearchController.text = b.regNumber;
                          _searchBusByReg();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Search Result Card
          if (_hasFoundBus && _foundBus != null) ...[
            Builder(builder: (context) {
              final bus = _foundBus!;
              final catColor = _getCategoryColor(bus.category);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bus.busName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(bus.regNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 14)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  bus.isActive ? Icons.sensors : Icons.power_settings_new,
                                  size: 12,
                                  color: bus.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  bus.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Category Livery
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: catColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.palette, color: catColor, size: 14),
                            const SizedBox(width: 6),
                            Text(bus.category, style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),

                      const Divider(height: 24),
                      _detailRow('Owner / Operator', bus.companyName),
                      _detailRow('Corridor Route', '${bus.startPoint} ➔ ${bus.destPoint}'),
                      _detailRow('Route Schedule', bus.routeName),
                      _detailRow('Service Timings', '${bus.startTime} to ${bus.endTime}'),
                      _detailRow('Driver', bus.driverName),
                      _detailRow('Cleaner / Helper', bus.cleanerName),
                      _detailRow('Assigned Conductor', bus.conductorName),
                      _detailRow('Seating Capacity', '${bus.seatingCapacity} Passenger Seats'),
                      _detailRow('Current Stop', bus.currentStop),
                      _detailRow('Next Stop', bus.nextStop),
                      const SizedBox(height: 12),

                      // Intermediate Stops Timetable
                      if (bus.stops.isNotEmpty) ...[
                        const Text('Scheduled Stops & Timetable:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 6),
                        ...bus.stops.map((s) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 8, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s.stopName, style: const TextStyle(fontSize: 12))),
                                Text(s.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                      ],

                      // Live Location Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentAmber,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _openBusLiveLocation(bus),
                          icon: const Icon(Icons.location_on),
                          label: const Text('View Current Live Radar Location', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No bus found with that registration plate.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
