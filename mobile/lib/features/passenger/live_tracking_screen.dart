import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String routeName;
  final String busRegNumber;

  const LiveTrackingScreen({
    super.key,
    this.routeName = 'Aluva Stand - Perumbavoor Stand (via Kizhakkambalam)',
    this.busRegNumber = 'KL 07 CD 4589',
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final double _speedKmh = 42.0;
  final int _etaMinutes = 4;
  bool _alertEnabled = false;

  final List<Map<String, dynamic>> _stops = [
    {'name': 'Aluva Stand', 'stage': 1, 'time': '10:00 AM', 'status': 'PASSED'},
    {'name': 'Bank Junction', 'stage': 2, 'time': '10:08 AM', 'status': 'PASSED'},
    {'name': 'Pump Junction', 'stage': 3, 'time': '10:15 AM', 'status': 'PASSED'},
    {'name': 'Kizhakkambalam', 'stage': 4, 'time': '10:24 AM', 'status': 'APPROACHING'},
    {'name': 'Pattimattom', 'stage': 5, 'time': '10:35 AM', 'status': 'UPCOMING'},
    {'name': 'Perumbavoor Stand', 'stage': 6, 'time': '10:48 AM', 'status': 'UPCOMING'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Bus Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.busRegNumber, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_alertEnabled ? Icons.notifications_active : Icons.notifications_none),
            color: _alertEnabled ? AppTheme.accentAmber : Colors.white,
            tooltip: 'Arrival Alert',
            onPressed: () {
              setState(() {
                _alertEnabled = !_alertEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_alertEnabled
                      ? 'Arrival Alert set! You will be notified 2 stops before Kizhakkambalam.'
                      : 'Arrival alert disabled.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Simulated Live Map & Telemetry HUD
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
                // Top Telemetry Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'GPS SIGNAL: EXCELLENT (3s ping)',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
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
                        'Route R-14',
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Speed and Next Stop HUD Card
                Row(
                  children: [
                    // Moving Bus Icon Graphic
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.directions_bus, color: AppTheme.accentAmber, size: 36),
                          SizedBox(height: 4),
                          Text('IN TRANSIT', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NEXT STOP', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2)),
                          const Text(
                            'Kizhakkambalam',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Approaching in ~$_etaMinutes mins • ${_speedKmh.toInt()} km/h',
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

          // Route Stops Timeline Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.shade100,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STAGE STOPS TIMELINE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'SCHEDULED ARRIVAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Sequential Route Stage Stops Timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _stops.length,
              itemBuilder: (context, index) {
                final stop = _stops[index];
                final isPassed = stop['status'] == 'PASSED';
                final isCurrent = stop['status'] == 'APPROACHING';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Node Column
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppTheme.accentAmber
                                : (isPassed ? AppTheme.primaryGreen : Colors.grey.shade300),
                            border: Border.all(
                              color: isCurrent ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppTheme.accentAmber.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isPassed
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : (isCurrent
                                  ? const Icon(Icons.location_on, size: 12, color: Colors.black)
                                  : null),
                        ),
                        if (index < _stops.length - 1)
                          Container(
                            width: 3,
                            height: 50,
                            color: isPassed ? AppTheme.primaryGreen : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Stop Information
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      stop['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                        color: isCurrent
                                            ? AppTheme.primaryGreen
                                            : (isPassed ? Colors.black87 : Colors.grey.shade600),
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentAmber.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'BUS HERE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Stage ${stop['stage']} • Kerala Stage Carriage Tariff',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            Text(
                              stop['time'],
                              style: TextStyle(
                                fontSize: 13,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
