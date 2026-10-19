import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class ProfileTab extends StatefulWidget {
  final PassengerModel passenger;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.passenger,
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
                        Text(widget.passenger.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(widget.passenger.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'VERIFIED PASSENGER • ID: ${widget.passenger.id}',
                            style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
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
                _infoTile(Icons.tag, 'Passenger ID', widget.passenger.id),
                const Divider(height: 1),
                _infoTile(Icons.account_balance_wallet, 'Smart Wallet Balance', '₹${widget.passenger.walletBalance.toStringAsFixed(2)}'),
                const Divider(height: 1),
                _infoTile(Icons.phone, 'Mobile Number', '+91 ${widget.passenger.phone}'),
                const Divider(height: 1),
                _infoTile(Icons.location_city, 'Home Station', widget.passenger.homeStation),
                const Divider(height: 1),
                _infoTile(Icons.school, 'Concession Category', widget.passenger.concessionCategory),
                const Divider(height: 1),
                _infoTile(Icons.calendar_today, 'Registered Since', DateFormat('MMMM yyyy').format(widget.passenger.registeredAt)),
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

          const SizedBox(height: 20),

          // Reviews Section
          const Text('My Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 24),
              ),
              title: const Text('My Bus Reviews & Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: const Text('View and manage your submitted bus ratings', style: TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showMyReviewsModal(context),
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

  void _showMyReviewsModal(BuildContext context) {
    // Reviews from passenger Anjali Nair or all demo reviews
    final reviews = FleetState.instance.reviews;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (sheetCtx, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.rate_review, color: AppTheme.accentAmber),
                          SizedBox(width: 8),
                          Text('My Bus Ratings & Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      Text('${reviews.length} total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Ratings shared with Bus Owners and Conductors across Kerala',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 24),

                  if (reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Icon(Icons.star_border, size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('You have not submitted any reviews yet.', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 6),
                          Text('Search for any bus and tap "Rate & Give Feedback"',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ...reviews.map((r) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${r.busName} (${r.busRegNumber})',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Row(
                                    children: List.generate(5, (starIdx) {
                                      return Icon(
                                        starIdx < r.rating.round() ? Icons.star : Icons.star_border,
                                        color: AppTheme.accentAmber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(r.comment, style: const TextStyle(fontSize: 13, height: 1.3)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('By: ${r.passengerName}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('NOTIFIED TO OWNER & CREW',
                                        style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
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
