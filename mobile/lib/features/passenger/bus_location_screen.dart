import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';

class BusLocationScreen extends StatelessWidget {
  final String busRegNumber;
  final String busName;
  final String routeName;
  final String companyName;
  final String currentStop;
  final String nextStop;
  final String eta;
  final double speedKmh;
  final List<BusStopSchedule>? stops;
  final String category;
  final String driverName;
  final String conductorName;

  const BusLocationScreen({
    super.key,
    required this.busRegNumber,
    required this.busName,
    required this.routeName,
    this.companyName = 'St. George Motors Ernakulam',
    this.currentStop = 'Pump Junction',
    this.nextStop = 'Kizhakkambalam',
    this.eta = '4 mins',
    this.speedKmh = 42.0,
    this.stops,
    this.category = 'Ordinary Bus (Blue-Whiteline)',
    this.driverName = 'Venu Pillai',
    this.conductorName = 'Suresh Kumar',
  });

  Color _getCategoryColor(String cat) {
    if (cat.contains('Red') || cat.contains('Limited')) {
      return const Color(0xFFC62828);
    } else if (cat.contains('Blue') || cat.contains('Ordinary')) {
      return const Color(0xFF1565C0);
    } else {
      return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve stops from passed param or lookup from fleet state
    List<BusStopSchedule> activeStops = [];
    if (stops != null && stops!.isNotEmpty) {
      activeStops = List.from(stops!);
    } else {
      final match = FleetState.instance.buses.where((b) => b.regNumber == busRegNumber).toList();
      if (match.isNotEmpty && match.first.stops.isNotEmpty) {
        activeStops = List.from(match.first.stops);
      }
    }

    // Always sort timeline in ascending order of scheduled time
    activeStops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));

    // Determine current stop index
    int currentIndex = -1;
    for (int i = 0; i < activeStops.length; i++) {
      if (activeStops[i].stopName.toLowerCase().contains(currentStop.toLowerCase()) ||
          currentStop.toLowerCase().contains(activeStops[i].stopName.toLowerCase())) {
        currentIndex = i;
        break;
      }
    }
    if (currentIndex == -1 && activeStops.isNotEmpty) {
      // Default to middle stop or second stop for running simulation
      currentIndex = (activeStops.length ~/ 2).clamp(0, activeStops.length - 1);
    }

    final catColor = _getCategoryColor(category);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$busName ($busRegNumber)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(routeName, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Live Map Telemetry HUD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF131A22), Color(0xFF1F2937)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        const Text(
                          'LIVE GPS BROADCAST ACTIVE (5s pulse)',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.2),
                        border: Border.all(color: catColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.directions_bus, color: AppTheme.accentAmber, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('APPROACHING NEXT STOP', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.1)),
                          Text(
                            nextStop,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ETA: ~$eta • Current Speed: ${speedKmh.toInt()} km/h',
                            style: const TextStyle(color: AppTheme.accentAmber, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Driver: $driverName', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text('Conductor: $conductorName', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Route Stage Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      'CURRENT LOCATION: $currentStop',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ON-SCHEDULE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Route Timeline in Ascending Order
          Expanded(
            child: activeStops.isEmpty
                ? const Center(
                    child: Text('No timetable stops registered for this bus route schedule.',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: activeStops.length,
                    itemBuilder: (context, index) {
                      final stop = activeStops[index];
                      final isPassed = index < currentIndex;
                      final isCurrent = index == currentIndex;
                      final isUpcoming = index > currentIndex;
                      final isLast = index == activeStops.length - 1;

                      return _buildTimelineNode(
                        stop.stopName,
                        stop.time,
                        isPassed: isPassed,
                        isCurrent: isCurrent,
                        isUpcoming: isUpcoming,
                        isLast: isLast,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String stopName, String time,
      {bool isPassed = false, bool isCurrent = false, bool isUpcoming = false, bool isLast = false}) {
    Color nodeColor = Colors.grey.shade300;
    if (isPassed) nodeColor = AppTheme.primaryGreen;
    if (isCurrent) nodeColor = AppTheme.accentAmber;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
                border: Border.all(color: isCurrent ? Colors.white : Colors.transparent, width: 2),
                boxShadow: isCurrent ? [BoxShadow(color: AppTheme.accentAmber.withValues(alpha: 0.5), blurRadius: 8)] : null,
              ),
              child: isPassed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : (isCurrent ? const Icon(Icons.location_on, size: 12, color: Colors.black87) : null),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 48,
                color: isPassed ? AppTheme.primaryGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stopName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: isCurrent ? AppTheme.primaryGreen : Colors.black87,
                        ),
                      ),
                      if (isCurrent)
                        const Text(
                          'BUS IS APPROACHING / CURRENT STAGE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.grey.shade100 : AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.grey : AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
