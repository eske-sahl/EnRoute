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

  final List<String> _keralaStops = [
    'Aluva Stand',
    'Bank Junction',
    'Pump Junction',
    'Kizhakkambalam',
    'Pattimattom',
    'Perumbavoor Stand',
    'Angamaly Stand',
    'Ernakulam Kaloor',
  ];

  // Inner Tab 2: Bus Search by Reg Number State
  final _regSearchController = TextEditingController(text: 'KL 07 CD 4589');
  bool _hasFoundBus = false;
  Map<String, dynamic>? _foundBusDetails;

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
        final b = match.first;
        _hasFoundBus = true;
        _foundBusDetails = {
          'reg': b.regNumber,
          'name': b.busName,
          'type': b.busType,
          'company': b.companyName,
          'routeSchedule': b.routeName,
          'startTime': b.startTime,
          'endTime': b.endTime,
          'driver': b.driverName,
          'conductor': b.conductorName,
          'capacity': '${b.seatingCapacity} Seats',
          'status': b.status,
          'currentStop': b.currentStop,
          'nextStop': b.nextStop,
        };
      } else {
        _hasFoundBus = false;
        _foundBusDetails = null;
      }
    });
  }

  void _openBusLiveLocation(Map<String, dynamic> bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusLocationScreen(
          busRegNumber: bus['reg'] ?? 'KL 07 CD 4589',
          busName: bus['name'] ?? 'SmartBus',
          routeName: bus['routeSchedule'] ?? '$_startPoint to $_endPoint',
          companyName: bus['company'] ?? 'Kerala Private Bus Operator',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _buildRouteSearchTab(),
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
  Widget _buildRouteSearchTab() {
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
                  const SizedBox(height: 14),

                  // Start Point Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Trip Start Point',
                      prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    initialValue: _startPoint,
                    items: _keralaStops.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _startPoint = val!),
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
                    items: _keralaStops.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _endPoint = val!),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _searchRoute,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Running Buses', style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text('${FleetState.instance.buses.length} Available', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            ...FleetState.instance.buses.map((bus) {
              final isRunning = bus.status == 'RUNNING_NOW';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openBusLiveLocation({
                    'reg': bus.regNumber,
                    'name': bus.busName,
                    'routeSchedule': bus.routeName,
                    'company': bus.companyName,
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text('(${bus.regNumber})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(bus.busType, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isRunning ? Colors.green.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isRunning ? 'RUNNING NOW' : 'SCHEDULED',
                                style: TextStyle(
                                  color: isRunning ? Colors.green.shade800 : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text('${bus.startTime} ➔ ${bus.endTime}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            const Row(
                              children: [
                                Text('Track Bus', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primaryGreen),
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
                  Text('Select start and end points and tap Search', style: TextStyle(color: Colors.grey)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _searchBusByReg,
                        child: const Text('Find'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Try: KL 07 CD 4589 or KL 07 CE 1204', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Search Result Card
          if (_hasFoundBus && _foundBusDetails != null) ...[
            Card(
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
                            Text(
                              _foundBusDetails!['name'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _foundBusDetails!['reg'],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _foundBusDetails!['status'],
                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _detailRow('Owner / Operator', _foundBusDetails!['company']),
                    _detailRow('Bus Type', _foundBusDetails!['type']),
                    _detailRow('Route Schedule', _foundBusDetails!['routeSchedule']),
                    _detailRow('Daily Timings', '${_foundBusDetails!['startTime']} to ${_foundBusDetails!['endTime']}'),
                    _detailRow('Driver', _foundBusDetails!['driver']),
                    _detailRow('Conductor', _foundBusDetails!['conductor']),
                    _detailRow('Seating Capacity', _foundBusDetails!['capacity']),
                    _detailRow('Current Stop', _foundBusDetails!['currentStop']),
                    _detailRow('Next Stop', _foundBusDetails!['nextStop']),
                    const SizedBox(height: 18),

                    // Live Location Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentAmber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _openBusLiveLocation(_foundBusDetails!),
                        icon: const Icon(Icons.location_on),
                        label: const Text('View Current Live Location', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            width: 120,
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
