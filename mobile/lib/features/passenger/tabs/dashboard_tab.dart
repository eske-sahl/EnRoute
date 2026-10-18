import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

class DashboardTab extends StatelessWidget {
  final String passengerName;
  final double walletBalance;
  final Function(double) onTopUp;

  const DashboardTab({
    super.key,
    required this.passengerName,
    required this.walletBalance,
    required this.onTopUp,
  });

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Money to Demo Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Select an amount to recharge your travel balance:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [50.0, 100.0, 200.0, 500.0].map((amt) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      onTopUp(amt);
                      Navigator.pop(context);
                    },
                    child: Text('₹${amt.toInt()}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  void _showQrFullscreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Passenger Identity Pass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Show this to Conductor for Ticketing', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                QrImageView(
                  data: 'SBK_PASSENGER_UID_987263',
                  version: QrVersions.auto,
                  size: 220.0,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryGreen),
                ),
                const SizedBox(height: 16),
                const Text('ID: SBK-KL-987263', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final recentTickets = [
      {
        'bus': 'KL 07 CD 4589 (SpeedWings)',
        'route': 'Aluva ➔ Kizhakkambalam',
        'fare': 18.0,
        'date': 'Today, 09:40 AM',
        'status': 'COMPLETED',
        'ref': 'SBK-20261018-0042',
      },
      {
        'bus': 'KL 07 CE 1204 (GreenCity)',
        'route': 'Perumbavoor ➔ Pattimattom',
        'fare': 12.0,
        'date': 'Yesterday, 05:15 PM',
        'status': 'COMPLETED',
        'ref': 'SBK-20261017-8912',
      },
      {
        'bus': 'KL 07 BQ 9981 (St. Marys)',
        'route': 'Aluva ➔ Pump Junction',
        'fare': 10.0,
        'date': '16 Oct, 11:20 AM',
        'status': 'COMPLETED',
        'ref': 'SBK-20261016-3301',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Wallet Balance Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.busGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DIGITAL TRANSIT WALLET',
                        style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currency.format(walletBalance),
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showTopUpSheet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Money'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showTopUpSheet(context),
                      icon: const Icon(Icons.bolt, size: 18),
                      label: const Text('Quick Recharge'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Personal Scanner / QR Code Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Digital Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Conductor scans this to issue tickets', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: AppTheme.primaryGreen),
                        tooltip: 'Enlarge QR',
                        onPressed: () => _showQrFullscreen(context),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  GestureDetector(
                    onTap: () => _showQrFullscreen(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: 'SBK_PASSENGER_UID_987263',
                        version: QrVersions.auto,
                        size: 150.0,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('SBK-KL-987263', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Ticket History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Ticket History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${recentTickets.length} journeys', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          ...recentTickets.map((ticket) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.confirmation_num, color: AppTheme.primaryGreen),
                ),
                title: Text(ticket['route'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${ticket['bus']} • ${ticket['date']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${(ticket['fare'] as double).toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 15)),
                    const Text('PAID', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
