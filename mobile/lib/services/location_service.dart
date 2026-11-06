import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'fleet_state.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  StreamSubscription<Position>? _positionSubscription;
  String? _activeBusReg;
  Position? _lastKnownPosition;

  bool get isBroadcasting => _positionSubscription != null;
  String? get activeBusReg => _activeBusReg;
  Position? get lastPosition => _lastKnownPosition;

  /// Check hardware GPS status and request OS permissions realistically
  Future<bool> checkAndRequestPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check physical hardware GPS status
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        final shouldOpen = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.location_off_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Device Location (GPS) is OFF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            content: const Text(
              'Your physical device location service is currently disabled. '
              'To broadcast real-time GPS tracking to passengers and the fleet owner, please turn ON Location in your device settings.',
              style: TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Open Location Settings'),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );

        if (shouldOpen == true) {
          await Geolocator.openLocationSettings();
          // Give user a moment to toggle and check again
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
      }

      if (!serviceEnabled) {
        return false;
      }
    }

    // 2. Check and request OS location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Cannot broadcast live device GPS.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        final openAppSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.lock_person, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Location Permission Blocked', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            content: const Text(
              'Location permissions are permanently denied for EnRoute. '
              'Please grant location permissions in App Settings to enable live hardware GPS broadcast.',
              style: TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.settings),
                label: const Text('Open App Settings'),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );

        if (openAppSettings == true) {
          await Geolocator.openAppSettings();
        }
      }
      return false;
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  /// Get current instantaneous device hardware position
  Future<Position?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      _lastKnownPosition = pos;
      return pos;
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) _lastKnownPosition = last;
        return last;
      } catch (_) {
        return null;
      }
    }
  }

  /// Start live continuous GPS tracking and broadcast for the conductor's bus
  Future<bool> startBroadcasting(BuildContext context, String busRegNumber) async {
    final hasPerm = await checkAndRequestPermission(context);
    if (!hasPerm) {
      return false;
    }

    stopBroadcasting();

    _activeBusReg = busRegNumber;

    // Immediately acquire first GPS fix
    final initialPos = await getCurrentPosition();
    if (initialPos != null) {
      _lastKnownPosition = initialPos;
      FleetState.instance.updateBusCoordinates(
        busRegNumber,
        initialPos.latitude,
        initialPos.longitude,
        speedKmh: (initialPos.speed * 3.6).clamp(0, 120),
        locationString: 'Live Conductor GPS (${initialPos.latitude.toStringAsFixed(4)}° N, ${initialPos.longitude.toStringAsFixed(4)}° E)',
      );
    }

    // Subscribe to continuous hardware position updates
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // update every 3 meters
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _lastKnownPosition = position;
        if (_activeBusReg != null) {
          final speedKmh = (position.speed * 3.6).clamp(0.0, 120.0);
          FleetState.instance.updateBusCoordinates(
            _activeBusReg!,
            position.latitude,
            position.longitude,
            speedKmh: speedKmh,
            locationString: 'Live Conductor GPS (${position.latitude.toStringAsFixed(4)}° N, ${position.longitude.toStringAsFixed(4)}° E)',
          );
        }
      },
      onError: (err) {
        debugPrint('Location stream error: $err');
      },
    );

    return true;
  }

  /// Stop live GPS broadcast
  void stopBroadcasting([String? busRegNumber]) {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    final reg = busRegNumber ?? _activeBusReg;
    _activeBusReg = null;
    if (reg != null) {
      final bus = FleetState.instance.getBusByReg(reg);
      if (bus != null) {
        bus.isLiveGpsActive = false;
      }
    }
  }
}
