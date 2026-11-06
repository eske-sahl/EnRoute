import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';
import '../../widgets/bus_live_map_widget.dart';

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
  final VoidCallback? onBack;

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
    this.onBack,
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
    return ListenableBuilder(
      listenable: FleetState.instance,
      builder: (context, _) {
        final liveBus = FleetState.instance.getBusByReg(busRegNumber);

        final activeBus = liveBus ??
            BusModel(
              id: 'BUS-TEMP',
              regNumber: busRegNumber,
              busName: busName,
              category: category,
              routeName: routeName,
              stops: stops ?? [],
              companyName: companyName,
              currentStop: currentStop,
              nextStop: nextStop,
              eta: eta,
              driverName: driverName,
              conductorName: conductorName,
            );

        // Retrieve stops and sort in ascending order of time
        List<BusStopSchedule> activeStops = [];
        if (activeBus.stops.isNotEmpty) {
          activeStops = List.from(activeBus.stops);
        } else if (stops != null && stops!.isNotEmpty) {
          activeStops = List.from(stops!);
        }

        activeStops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));

        // Determine current stop index
        int currentIndex = -1;
        for (int i = 0; i < activeStops.length; i++) {
          if (activeStops[i].stopName.toLowerCase().contains(activeBus.currentStop.toLowerCase()) ||
              activeBus.currentStop.toLowerCase().contains(activeStops[i].stopName.toLowerCase())) {
            currentIndex = i;
            break;
          }
        }
        if (currentIndex == -1 && activeStops.isNotEmpty) {
          currentIndex = (activeStops.length ~/ 2).clamp(0, activeStops.length - 1);
        }

        final catColor = _getCategoryColor(activeBus.category);
        final isGpsLive = activeBus.isLiveGpsActive && activeBus.isTripActive;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.maybePop(context);
                }
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${activeBus.busName} (${activeBus.regNumber})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(activeBus.routeName, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGpsLive ? Colors.green.shade800 : Colors.amber.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isGpsLive ? Icons.gps_fixed : Icons.gps_not_fixed, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      isGpsLive ? 'LIVE ACTIVE' : 'OFFLINE / DEPOT',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. REAL INTERACTIVE OPENSTREETMAP SECTION
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                color: const Color(0xFF0F172A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BusLiveMapWidget(
                      bus: activeBus,
                      height: 240,
                      showControls: true,
                    ),
                    const SizedBox(height: 10),
                    // Live Telemetry Bar underneath map
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isGpsLive ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isGpsLive ? Icons.radar : Icons.location_off,
                                  size: 14,
                                  color: isGpsLive ? Colors.greenAccent : Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isGpsLive ? 'HARDWARE GPS BROADCAST' : 'GPS STANDBY',
                                      style: TextStyle(
                                        color: isGpsLive ? Colors.greenAccent : Colors.amber,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Next: ${activeBus.nextStop}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.2),
                            border: Border.all(color: catColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activeBus.category,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. STAGE PROGRESS & ETA HUD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppTheme.primaryGreen),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CURRENT STAGE LOCATION', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text(
                                  activeBus.currentStop,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: AppTheme.accentAmber),
                        const SizedBox(width: 4),
                        Text(
                          'ETA: ~${activeBus.eta}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. ROUTE TIMELINE NODES
              Expanded(
                child: activeStops.isEmpty
                    ? const Center(
                        child: Text(
                          'No timetable stops registered for this bus route schedule.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
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
                            context,
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
      },
    );
  }

  Widget _buildTimelineNode(BuildContext context, String stopName, String time,
      {bool isPassed = false, bool isCurrent = false, bool isUpcoming = false, bool isLast = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color nodeColor = isDark ? Colors.white24 : Colors.grey.shade300;
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
                color: isPassed ? AppTheme.primaryGreen : (isDark ? Colors.white24 : Colors.grey.shade300),
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
                          color: isCurrent ? AppTheme.primaryGreen : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (isCurrent)
                        const Text(
                          'BUS IS CURRENTLY HERE / APPROACHING',
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
