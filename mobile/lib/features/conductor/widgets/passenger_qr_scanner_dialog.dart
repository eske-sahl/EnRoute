import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class PassengerQrScannerDialog extends StatefulWidget {
  final Function(PassengerModel passenger) onPassengerDetected;

  const PassengerQrScannerDialog({
    super.key,
    required this.onPassengerDetected,
  });

  @override
  State<PassengerQrScannerDialog> createState() => _PassengerQrScannerDialogState();
}

class _PassengerQrScannerDialogState extends State<PassengerQrScannerDialog> with SingleTickerProviderStateMixin {
  late MobileScannerController _controller;
  late AnimationController _animController;
  bool _hasProcessed = false;
  final bool _cameraError = false;
  final String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasProcessed) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue ?? barcode.displayValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        final passenger = _resolvePassengerFromQr(rawValue.trim());
        if (passenger != null) {
          _hasProcessed = true;
          Navigator.of(context).pop();
          widget.onPassengerDetected(passenger);
          return;
        }
      }
    }
  }

  PassengerModel? _resolvePassengerFromQr(String raw) {
    String cleanId = raw.trim();

    // Check if format is SMARTBUS:PASSENGER:SBK-KL-XXXXXX
    if (cleanId.toUpperCase().contains('SMARTBUS:PASSENGER:')) {
      cleanId = cleanId.replaceAll(RegExp(r'SMARTBUS:PASSENGER:', caseSensitive: false), '').trim();
    } else if (cleanId.startsWith('{') && cleanId.contains('id')) {
      // Check if JSON format
      try {
        final parsed = jsonDecode(cleanId);
        if (parsed is Map && parsed['id'] != null) {
          cleanId = parsed['id'].toString().trim();
        }
      } catch (_) {}
    }

    return FleetState.instance.findPassengerByIdOrPhone(cleanId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF131A22),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt, color: AppTheme.primaryGreen, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Live Passenger QR Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Camera / Viewfinder Area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!_cameraError)
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) {
                        return _buildCameraFallback(
                          'Camera permission denied or camera device unavailable on this browser: ${error.errorCode}',
                        );
                      },
                    )
                  else
                    _buildCameraFallback(_errorMessage),

                  // Viewfinder Target Frame
                  if (!_cameraError)
                    Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryGreen, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Glowing Laser Scanning Bar
                            AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Align(
                                  alignment: Alignment(0, (_animController.value * 2) - 1),
                                  child: Container(
                                    height: 3,
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent.withValues(alpha: 0.9),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Top Prompt Overlay
                  Positioned(
                    top: 16,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.greenAccent, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Point conductor device camera at passenger QR pass',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Camera Controls (Torch & Camera Switch)
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: Colors.white24),
                          onPressed: () => _controller.toggleTorch(),
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          tooltip: 'Toggle Flash',
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: Colors.white24),
                          onPressed: () => _controller.switchCamera(),
                          icon: const Icon(Icons.cameraswitch, color: Colors.white),
                          tooltip: 'Flip Camera',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Fallback Selector for Browsers without physical webcam
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1217),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Quick Test Simulation / Backup Selection:',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: FleetState.instance.registeredPassengers.map((p) {
                      return ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, size: 12, color: AppTheme.primaryGreen),
                        ),
                        label: Text('${p.name} (${p.id})', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        backgroundColor: Colors.white10,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onPassengerDetected(p);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFallback(String reason) {
    return Container(
      color: const Color(0xFF131A22),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, color: Colors.orangeAccent, size: 48),
          const SizedBox(height: 14),
          const Text(
            'Camera Feed Unavailable',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Select any passenger below to connect instantly:',
            style: TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
