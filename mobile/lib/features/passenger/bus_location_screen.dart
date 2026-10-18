import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BusLocationScreen extends StatelessWidget {
  final String busRegNumber;
  final String busName;
  final String routeName;
  final String companyName;
  final String currentStop;
  final String nextStop;
  final String eta;
  final double speedKmh;

  const BusLocationScreen({
    super.key,
    required this.busRegNumber,
    required this.busName,
    required this.routeName,
    this.companyName = 'St. George Motors Ernakulam',
    this.currentStop = 'Pump Junction (Stage 3)',
    this.nextStop = 'Kizhakkambalam (Stage 4)',
    this.eta = '4 mins',
    this.speedKmh = 42.0,
  });

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        companyName,
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
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
                Text(
                  'CURRENT LOCATION: $currentStop',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54),
                ),
                const Text(
                  'ON-TIME',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ),

          // Simulated Route Visualizer
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTimelineNode('Aluva Stand (Trip Start)', '10:00 AM', isPassed: true),
                _buildTimelineNode('Bank Junction', '10:08 AM', isPassed: true),
                _buildTimelineNode('Pump Junction', '10:15 AM', isPassed: true),
                _buildTimelineNode('Kizhakkambalam', '10:24 AM (~$eta)', isCurrent: true),
                _buildTimelineNode('Pattimattom', '10:35 AM', isUpcoming: true),
                _buildTimelineNode('Perumbavoor Stand (Trip End)', '10:48 AM', isUpcoming: true, isLast: true),
              ],
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
                Column(
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
                        'BUS IS APPROACHING HERE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                  ],
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPassed ? Colors.grey : AppTheme.primaryGreen,
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
