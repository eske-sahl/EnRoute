import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';
import '../bus_detail_page.dart';

class OwnerDashboardTab extends StatefulWidget {
  final OwnerModel owner;
  final VoidCallback onNavigateToConductorTab;

  const OwnerDashboardTab({
    super.key,
    required this.owner,
    required this.onNavigateToConductorTab,
  });

  @override
  State<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends State<OwnerDashboardTab> {
  Color _getCategoryColor(String category) {
    if (category.contains('Red') || category.contains('Limited')) {
      return const Color(0xFFC62828);
    } else if (category.contains('Blue') || category.contains('Ordinary')) {
      return const Color(0xFF1565C0);
    } else {
      return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final fleet = FleetState.instance;

    // Filter strictly buses owned by this operator
    final ownerBuses = fleet.getBusesForOwner(widget.owner.id);
    final totalCollection = fleet.getTotalCollectionForOwner(widget.owner.id);
    final activeBusesCount = fleet.getActiveBusesCountForOwner(widget.owner.id);
    final totalTicketsSold = fleet.getTotalTicketsSoldForOwner(widget.owner.id);
    final walletCollection = fleet.getWalletCollectionForOwner(widget.owner.id);
    final cashInHand = fleet.getCashInHandForOwner(widget.owner.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Summary Box
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.darkCardGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TODAY\'S TOTAL FLEET COLLECTION',
                      style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                        SizedBox(width: 6),
                        Text('LIVE RECONCILIATION', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currency.format(totalCollection),
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricItem('Active Buses', '$activeBusesCount', Colors.white),
                    _metricItem('Tickets Sold', '$totalTicketsSold', Colors.white),
                    _metricItem('Wallet (Direct)', currency.format(walletCollection), AppTheme.accentAmber),
                    _metricItem('Cash In Hand', currency.format(cashInHand), Colors.greenAccent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Bus List Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Operating Fleet Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('$activeBusesCount Active', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('(${ownerBuses.length} total)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Tap any bus below to inspect live operations, edit routes or toggle active status',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 14),

          // 3. List of Bus Buttons or Clean Empty State
          if (ownerBuses.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                child: Column(
                  children: [
                    Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, ${widget.owner.companyName}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You do not have any registered buses yet. Switch to the "My Bus Fleet" tab to register your first bus and start managing live routes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...ownerBuses.map((bus) {
              final catColor = _getCategoryColor(bus.category);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: bus.isActive ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade300,
                    width: bus.isActive ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusDetailPage(
                          bus: bus,
                          onNavigateToConductors: widget.onNavigateToConductorTab,
                        ),
                      ),
                    );
                    setState(() {});
                  },
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
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: bus.isActive
                                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.directions_bus,
                                        color: bus.isActive ? AppTheme.primaryGreen : Colors.grey.shade600,
                                        size: 26,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          bus.isActive ? Icons.check_circle : Icons.cancel,
                                          color: bus.isActive ? Colors.green : Colors.red,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          bus.busName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        // Active / Inactive Badge with Icon
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                bus.isActive ? Icons.sensors : Icons.power_settings_new,
                                                size: 11,
                                                color: bus.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                bus.isActive ? 'ACTIVE' : 'INACTIVE',
                                                style: TextStyle(
                                                  color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      bus.regNumber,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${bus.todayCollection.toStringAsFixed(1)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryGreen),
                                ),
                                const Text('Live Collection', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Livery / Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: catColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                bus.category,
                                style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.alt_route, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      bus.routeName,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.badge, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  bus.conductorName,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_ios, size: 11, color: AppTheme.primaryGreen),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 10),
          const AppCreatorFooter(),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}
