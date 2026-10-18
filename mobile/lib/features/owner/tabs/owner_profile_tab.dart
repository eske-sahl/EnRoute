import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class OwnerProfileTab extends StatefulWidget {
  final VoidCallback onLogout;

  const OwnerProfileTab({
    super.key,
    required this.onLogout,
  });

  @override
  State<OwnerProfileTab> createState() => _OwnerProfileTabState();
}

class _OwnerProfileTabState extends State<OwnerProfileTab> {
  bool _settlementAlerts = true;
  bool _gpsLostAlerts = true;

  @override
  Widget build(BuildContext context) {
    final fleet = FleetState.instance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Owner Profile Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                    child: const Icon(Icons.business, size: 40, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('George Varghese', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('St. George Motors Ernakulam', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'STATE ADMIN VERIFIED OPERATOR',
                            style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Business Credentials Section
          const Text('Operator Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _infoTile(Icons.verified, 'MVD Operator Permit', 'KL-MVD-OPERATOR-2018-9941'),
                const Divider(height: 1),
                _infoTile(Icons.directions_bus, 'Total Fleet Size', '${fleet.buses.length} Stage Carriages'),
                const Divider(height: 1),
                _infoTile(Icons.people, 'Registered Conductors', '${fleet.conductors.length} Crew Members'),
                const Divider(height: 1),
                _infoTile(Icons.phone, 'Official Contact', '+91 98470 00002 • owner@stgeorge.com'),
                const Divider(height: 1),
                _infoTile(Icons.location_on, 'Regional RTO Hub', 'Ernakulam RTO (KL-07)'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Fleet Automation Settings
          const Text('Fleet Alerts & Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.account_balance, color: AppTheme.primaryGreen),
                  title: const Text('Daily Shift Settlement Report', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Auto-reconcile cash and digital wallet at 09:00 PM', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _settlementAlerts,
                  onChanged: (val) => setState(() => _settlementAlerts = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: AppTheme.primaryGreen),
                  title: const Text('Stale GPS Disconnection Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Notify if a running bus loses GPS ping for >90s', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _gpsLostAlerts,
                  onChanged: (val) => setState(() => _gpsLostAlerts = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out of Owner Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
    );
  }
}
