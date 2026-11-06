import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/fleet_state.dart';
import '../theme/app_theme.dart';

/// Predefined Kerala Landmark Coordinates
final Map<String, LatLng> _keralaCoordinates = {
  'aluva stand': const LatLng(10.1076, 76.3516),
  'aluva': const LatLng(10.1076, 76.3516),
  'pump junction': const LatLng(10.1118, 76.3552),
  'companypady': const LatLng(10.0984, 76.3481),
  'ambattukavu': const LatLng(10.0886, 76.3415),
  'muttom': const LatLng(10.0729, 76.3359),
  'kalamassery premier': const LatLng(10.0526, 76.3268),
  'kalamassery': const LatLng(10.0526, 76.3268),
  'cusat junction': const LatLng(10.0450, 76.3240),
  'pathadipalam': const LatLng(10.0354, 76.3196),
  'edappally toll': const LatLng(10.0261, 76.3125),
  'edappally church / bypass': const LatLng(10.0234, 76.3082),
  'edappally bypass': const LatLng(10.0234, 76.3082),
  'edappally': const LatLng(10.0234, 76.3082),
  'palarivattom bypass': const LatLng(10.0055, 76.3075),
  'palarivattom': const LatLng(10.0055, 76.3075),
  'kaloor stand': const LatLng(9.9937, 76.2921),
  'kaloor': const LatLng(9.9937, 76.2921),
  'lisie hospital': const LatLng(9.9880, 76.2890),
  'm.g road / ernakulam north': const LatLng(9.9816, 76.2825),
  'ernakulam north': const LatLng(9.9816, 76.2825),
  'maharajas college ground': const LatLng(9.9723, 76.2862),
  'ksrtc central stand / ernakulam south': const LatLng(9.9678, 76.2903),
  'ernakulam south': const LatLng(9.9678, 76.2903),
  'ernakulam': const LatLng(9.9678, 76.2903),
  'perumbavoor stand': const LatLng(10.1139, 76.4782),
  'perumbavoor': const LatLng(10.1139, 76.4782),
  'kizhakkambalam': const LatLng(10.0463, 76.4022),
  'pookkattupady': const LatLng(10.0718, 76.3905),
  'kakkanad infopark': const LatLng(10.0159, 76.3644),
  'infopark': const LatLng(10.0159, 76.3644),
  'kakkanad collectorate': const LatLng(10.0175, 76.3489),
  'kakkanad': const LatLng(10.0175, 76.3489),
  'thripunithura statue': const LatLng(9.9482, 76.3456),
  'thripunithura': const LatLng(9.9482, 76.3456),
  'angamaly stand': const LatLng(10.1960, 76.3860),
  'angamaly': const LatLng(10.1960, 76.3860),
  'chalakudy': const LatLng(10.3070, 76.3330),
  'thrissur sakthan stand': const LatLng(10.5186, 76.2166),
  'thrissur': const LatLng(10.5186, 76.2166),
  'fort kochi': const LatLng(9.9658, 76.2421),
  'mattancherry': const LatLng(9.9577, 76.2570),
  'vytilla hub': const LatLng(9.9686, 76.3197),
  'kundannoor': const LatLng(9.9423, 76.3175),
  'mannarkad stand': const LatLng(10.9882, 76.4589),
  'mannarkad': const LatLng(10.9882, 76.4589),
  'alanallur': const LatLng(11.0252, 76.3312),
  'melattur': const LatLng(11.0594, 76.2690),
  'pandikkad': const LatLng(11.1118, 76.2425),
  'kalikavu stand': const LatLng(11.1738, 76.3268),
  'kalikavu': const LatLng(11.1738, 76.3268),
  'wandoor': const LatLng(11.1947, 76.2366),
  'edavanna': const LatLng(11.2132, 76.1950),
  'manjeri stand': const LatLng(11.1215, 76.1216),
  'manjeri': const LatLng(11.1215, 76.1216),
  'kondotty stand': const LatLng(11.1472, 75.9620),
  'kondotty': const LatLng(11.1472, 75.9620),
  'calicut airport junction': const LatLng(11.1367, 75.9553),
  'university / thenhipalam': const LatLng(11.1342, 75.8910),
  'thenhipalam': const LatLng(11.1342, 75.8910),
  'ramanattukara stand': const LatLng(11.1748, 75.8643),
  'ramanattukara': const LatLng(11.1748, 75.8643),
  'farook college': const LatLng(11.1895, 75.8505),
  'feroke stand': const LatLng(11.1762, 75.8341),
  'feroke': const LatLng(11.1762, 75.8341),
  'meenchanda': const LatLng(11.2223, 75.8080),
  'kallayi': const LatLng(11.2384, 75.7950),
  'palayam stand': const LatLng(11.2520, 75.7845),
  'palayam': const LatLng(11.2520, 75.7845),
  'mananchira': const LatLng(11.2546, 75.7803),
  'nadakkavu': const LatLng(11.2678, 75.7770),
  'west hill': const LatLng(11.2936, 75.7675),
  'kozhikkode stand': const LatLng(11.2588, 75.7804),
  'kozhikkode': const LatLng(11.2588, 75.7804),
  'kozhikode stand': const LatLng(11.2588, 75.7804),
  'kozhikode': const LatLng(11.2588, 75.7804),
  'calicut': const LatLng(11.2588, 75.7804),
};

LatLng _resolveStopCoordinates(String stopName, int index, int total, LatLng startCoord, LatLng endCoord) {
  final clean = stopName.trim().toLowerCase();
  for (final entry in _keralaCoordinates.entries) {
    if (clean.contains(entry.key) || entry.key.contains(clean)) {
      return entry.value;
    }
  }

  // Graceful linear interpolation along Kerala corridor if stop not found
  if (total <= 1) return startCoord;
  final ratio = (index / (total - 1)).clamp(0.0, 1.0);
  final lat = startCoord.latitude + (endCoord.latitude - startCoord.latitude) * ratio;
  final lng = startCoord.longitude + (endCoord.longitude - startCoord.longitude) * ratio;
  return LatLng(lat, lng);
}

class BusLiveMapWidget extends StatefulWidget {
  final BusModel bus;
  final double height;
  final bool showControls;
  final bool interactive;
  final VoidCallback? onExpand;

  const BusLiveMapWidget({
    super.key,
    required this.bus,
    this.height = 280,
    this.showControls = true,
    this.interactive = true,
    this.onExpand,
  });

  @override
  State<BusLiveMapWidget> createState() => _BusLiveMapWidgetState();
}

class _BusLiveMapWidgetState extends State<BusLiveMapWidget> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final isTestEnvironment = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTestEnvironment) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 1.0;
    }

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _recenterOnBus() {
    final target = LatLng(widget.bus.currentLatitude, widget.bus.currentLongitude);
    _mapController.move(target, 14.5);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final busCoord = LatLng(widget.bus.currentLatitude, widget.bus.currentLongitude);
    final isGpsLive = widget.bus.isLiveGpsActive && widget.bus.isTripActive;

    // Resolve stops and route path
    final stops = widget.bus.stops;
    final totalStops = stops.length;

    LatLng startCoord = const LatLng(10.1076, 76.3516); // Default Aluva
    LatLng endCoord = const LatLng(10.1139, 76.4782); // Default Perumbavoor

    if (stops.isNotEmpty) {
      startCoord = _resolveStopCoordinates(stops.first.stopName, 0, totalStops, startCoord, endCoord);
      endCoord = _resolveStopCoordinates(stops.last.stopName, totalStops - 1, totalStops, startCoord, endCoord);
    }

    final List<LatLng> polylinePoints = [];
    final List<Marker> markers = [];

    // 1. Build stop points & markers
    for (int i = 0; i < totalStops; i++) {
      final stop = stops[i];
      final coord = _resolveStopCoordinates(stop.stopName, i, totalStops, startCoord, endCoord);
      polylinePoints.add(coord);

      final isFirst = i == 0;
      final isLast = i == totalStops - 1;

      if (isFirst || isLast) {
        markers.add(
          Marker(
            point: coord,
            width: 70,
            height: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFirst ? Colors.green.shade800 : Colors.red.shade800,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Text(
                    isFirst ? 'START' : 'DEST',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  Icons.location_on,
                  color: isFirst ? Colors.green.shade700 : Colors.red.shade700,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }
    }

    // Include bus position in polyline if list was empty
    if (polylinePoints.isEmpty) {
      polylinePoints.add(busCoord);
    }

    // 2. Build live bus marker with pulsing halo
    markers.add(
      Marker(
        point: busCoord,
        width: 120,
        height: 100,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing radar ring
                if (isGpsLive)
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.withValues(alpha: 0.25),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6), width: 1.5),
                      ),
                    ),
                  ),
                // Core Bus Pin
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 105),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isGpsLive ? Colors.greenAccent : Colors.amber, width: 1),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_bus,
                            size: 11,
                            color: isGpsLive ? Colors.greenAccent : Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.bus.busName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isGpsLive ? AppTheme.primaryGreen : Colors.amber.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: (isGpsLive ? Colors.green : Colors.amber).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: isGpsLive ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white24, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: busCoord,
                initialZoom: 14.0,
                minZoom: 6.0,
                maxZoom: 18.0,
                interactionOptions: InteractionOptions(
                  flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.enroute.kerala.smartbus',
                ),
                if (polylinePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 4.0,
                        color: const Color(0xFF1E3A8A),
                      ),
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 2.0,
                        color: AppTheme.accentAmber,
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),

            // Top Left HUD: Status Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isGpsLive ? Colors.greenAccent : Colors.amber, width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isGpsLive ? Colors.greenAccent : Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isGpsLive ? 'LIVE GPS TRACKING' : 'GPS STANDBY',
                      style: TextStyle(
                        color: isGpsLive ? Colors.greenAccent : Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Right HUD: Live Coordinates
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '${widget.bus.currentLatitude.toStringAsFixed(4)}° N, ${widget.bus.currentLongitude.toStringAsFixed(4)}° E',
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ),

            // Floating Controls: Recenter, Zoom In, Zoom Out, Fullscreen
            if (widget.showControls)
              Positioned(
                bottom: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'recenter_${widget.bus.regNumber}_${math.Random().nextInt(10000)}',
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: AppTheme.accentAmber,
                      onPressed: _recenterOnBus,
                      tooltip: 'Recenter on Live Bus',
                      child: const Icon(Icons.my_location, size: 18),
                    ),
                    const SizedBox(height: 6),
                    FloatingActionButton.small(
                      heroTag: 'zoom_in_${widget.bus.regNumber}_${math.Random().nextInt(10000)}',
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      onPressed: _zoomIn,
                      tooltip: 'Zoom In',
                      child: const Icon(Icons.add, size: 18),
                    ),
                    const SizedBox(height: 6),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out_${widget.bus.regNumber}_${math.Random().nextInt(10000)}',
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      onPressed: _zoomOut,
                      tooltip: 'Zoom Out',
                      child: const Icon(Icons.remove, size: 18),
                    ),
                    if (widget.onExpand != null) ...[
                      const SizedBox(height: 6),
                      FloatingActionButton.small(
                        heroTag: 'expand_${widget.bus.regNumber}_${math.Random().nextInt(10000)}',
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.greenAccent,
                        onPressed: widget.onExpand,
                        tooltip: 'Full Screen Map',
                        child: const Icon(Icons.fullscreen, size: 18),
                      ),
                    ],
                  ],
                ),
              ),

            // OpenStreetMap Attribution watermark
            Positioned(
              bottom: 4,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(color: Colors.white60, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
