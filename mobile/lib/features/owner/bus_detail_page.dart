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
  late String _routeName;
  late String _startTime;
  late String _endTime;

  @override
  void initState() {
    super.initState();
    _routeName = widget.bus.routeName;
    _startTime = widget.bus.startTime;
    _endTime = widget.bus.endTime;
  }

  void _showEditRouteDialog() {
    final routeCtrl = TextEditingController(text: _routeName);
    final startCtrl = TextEditingController(text: _startTime);
    final endCtrl = TextEditingController(text: _endTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Manage Bus Route & Timings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: routeCtrl,
                decoration: const InputDecoration(labelText: 'Route Name & Suffix', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startCtrl,
                      decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endCtrl,
                      decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _routeName = routeCtrl.text;
                  _startTime = startCtrl.text;
                  _endTime = endCtrl.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bus Route & Timetable updated successfully!')),
                );
              },
              child: const Text('Save Changes'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.bus.busName} Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.bus.regNumber, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live Operational Status & Collection Card
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
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.bus.status,
                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        widget.bus.regNumber,
                        style: const TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                          const Text('TICKETS SOLD', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1)),
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

            const SizedBox(height: 20),

            // Route Management Card
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
                            Text('Route Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _showEditRouteDialog,
                          icon: const Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                          label: const Text('Edit', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(),
                    _infoRow('Assigned Route', _routeName),
                    _infoRow('Daily Timings', '$_startTime to $_endTime'),
                    _infoRow('Bus Type', widget.bus.busType),
                    _infoRow('Seating Capacity', '${widget.bus.seatingCapacity} Passenger Seats'),
                    _infoRow('Owner Company', widget.bus.companyName),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Workers / Crew Assigned Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.badge, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text('Assigned Bus Crew & Workers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(height: 20),

                    // Conductor Button
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        child: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen),
                      ),
                      title: Text(widget.bus.conductorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Conductor • Tap to view conductor profile & credentials'),
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
                      title: Text(widget.bus.driverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Primary Driver • Heavy Vehicle Permit Valid'),
                    ),

                    const Divider(height: 16),

                    // Cleaner Details
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withValues(alpha: 0.15),
                        child: const Icon(Icons.cleaning_services, color: Colors.orange),
                      ),
                      title: Text(widget.bus.cleanerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Cleaner / Bus Attendant'),
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
