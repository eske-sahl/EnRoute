import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class OwnerProfileTab extends StatefulWidget {
  final OwnerModel owner;
  final VoidCallback onLogout;

  const OwnerProfileTab({
    super.key,
    required this.owner,
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
                        Text(widget.owner.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.owner.companyName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'STATE ADMIN VERIFIED OPERATOR • ID: ${widget.owner.id}',
                            style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 20),

          // Passenger Reviews & Ratings Section (with notification badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Passenger Reviews & Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (fleet.getUnreadReviewsCountForOwner() > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${fleet.getUnreadReviewsCountForOwner()} NEW',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
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
              title: const Text('Fleet Reviews & Ratings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text(
                '${fleet.reviews.length} total passenger reviews across fleet',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (fleet.getUnreadReviewsCountForOwner() > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        '${fleet.getUnreadReviewsCountForOwner()} unread',
                        style: TextStyle(color: Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _showOwnerReviewsModal,
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
                _infoTile(Icons.phone, 'Official Contact', '+91 ${widget.owner.phone} • ${widget.owner.email}'),
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

          const SizedBox(height: 20),

          // Danger Zone / Account Deletion
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.red.shade200),
            ),
            color: Colors.red.shade50.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Permanently delete your bus operator account, fleet configurations, and conductor authorizations.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmDeleteAccount(context),
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: const Text('Delete Operator Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
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

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Delete Operator Account?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to permanently delete the operator account for ${widget.owner.name} (${widget.owner.companyName})?'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Operator ID ${widget.owner.id}, registered buses, and crew credentials will be permanently deactivated. This action cannot be undone.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                FleetState.instance.deleteOwner(widget.owner.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Operator account for ${widget.owner.name} has been permanently deleted.'),
                    backgroundColor: Colors.red.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                widget.onLogout();
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  void _showOwnerReviewsModal() {
    setState(() {
      FleetState.instance.markReviewsAsReadForOwner();
    });

    final reviews = FleetState.instance.reviews;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.accentAmber),
                          SizedBox(width: 8),
                          Text('Passenger Reviews & Ratings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      Text('${reviews.length} reviews', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Live feedback submitted across all St. George Motors buses',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 24),

                  if (reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('No passenger reviews yet for your fleet.', style: TextStyle(color: Colors.grey)),
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
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                        child: Text(
                                          r.passengerName.isNotEmpty ? r.passengerName[0] : 'P',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryGreen),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(r.passengerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
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
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${r.busName} (${r.busRegNumber})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryGreen),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(r.comment, style: const TextStyle(fontSize: 13, height: 1.3)),
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
