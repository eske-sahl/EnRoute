import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProfileTab extends StatefulWidget {
  final String passengerName;
  final String email;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.passengerName,
    required this.email,
    required this.onLogout,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationsEnabled = true;
  bool _arrivalAlertsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, size: 40, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.passengerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(widget.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VERIFIED PASSENGER • ID: SBK-KL-987263',
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

          // Personal Details Section
          const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _infoTile(Icons.phone, 'Mobile Number', '+91 98470 00004'),
                const Divider(height: 1),
                _infoTile(Icons.location_city, 'Home Station', 'Aluva Stand, Ernakulam'),
                const Divider(height: 1),
                _infoTile(Icons.school, 'Concession Category', 'General / Adult Standard'),
                const Divider(height: 1),
                _infoTile(Icons.calendar_today, 'Registered Since', 'October 2026'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // App Settings Section
          const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ticket receipts & trip updates', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.radar, color: AppTheme.primaryGreen),
                  title: const Text('Live Arrival Vibration Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Vibrate 2 stops before destination', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _arrivalAlertsEnabled,
                  onChanged: (val) => setState(() => _arrivalAlertsEnabled = val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
                  title: const Text('App Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Current: $_selectedLanguage (മലയാളം support)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = _selectedLanguage == 'English' ? 'മലയാളം (Malayalam)' : 'English';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language set to $_selectedLanguage')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Big Red Logout Button
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
            label: const Text('Sign Out & Return to Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
