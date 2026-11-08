import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';
import 'tabs/owner_dashboard_tab.dart';
import 'tabs/owner_financials_tab.dart';
import 'tabs/owner_bus_list_tab.dart';
import 'tabs/owner_conductor_tab.dart';
import 'tabs/owner_profile_tab.dart';
import 'bus_detail_page.dart';

class OwnerPortal extends StatefulWidget {
  final OwnerModel owner;
  final VoidCallback onLogout;

  const OwnerPortal({
    super.key,
    required this.owner,
    required this.onLogout,
  });

  @override
  State<OwnerPortal> createState() => _OwnerPortalState();
}

class _OwnerPortalState extends State<OwnerPortal> {
  int _selectedTabIndex = 0;
  BusModel? _selectedBus;

  void _navigateToConductorTab() {
    setState(() {
      _selectedBus = null;
      _selectedTabIndex = 3; // Jump to Conductor tab
    });
  }

  void _navigateToFinancialsTab() {
    setState(() {
      _selectedBus = null;
      _selectedTabIndex = 1; // Jump to Profit & Financials tab
    });
  }

  void _onManageBus(BusModel bus) {
    setState(() {
      _selectedBus = bus;
    });
  }

  void _showAdminPortalModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        final pendingBuses = FleetState.instance.buses.where((b) => b.isWaitingForVerification).toList();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin & MVD Verification Portal',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    const Text('Official State Transport Oversight', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Web Links Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2633) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.blue.shade800 : Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.language, color: Colors.blue.shade700, size: 16),
                          const SizedBox(width: 6),
                          Text('WEB ADMIN PORTAL URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue.shade700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        'http://localhost:5001/data',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.blue.shade300 : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Open this URL in any web browser to view the visual interactive backend data dashboard, verify buses, manage passengers, and explore live API endpoints.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pending Verification Requests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PENDING REGISTRATION REQUESTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: pendingBuses.isNotEmpty ? Colors.amber.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pendingBuses.length} Pending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: pendingBuses.isNotEmpty ? Colors.amber.shade900 : Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (pendingBuses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14241B) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.green.shade800 : Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All fleet buses have been verified and approved by MVD Admin.',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.green.shade300 : Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...pendingBuses.map((bus) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2B2416) : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.amber.shade700 : Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(bus.regNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber.shade800)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Owner: ${bus.ownerName} (${bus.ownerPhone})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Chassis: ${bus.chassisNumber} • Permit: ${bus.permitNumber}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Awaiting official MVD / Admin review & permit verification',
                              style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      // Tab 1: Owner Dashboard
      OwnerDashboardTab(
        owner: widget.owner,
        onNavigateToConductorTab: _navigateToConductorTab,
        onNavigateToFinancialsTab: _navigateToFinancialsTab,
        onManageBus: _onManageBus,
      ),

      // Tab 2: Profit & Financial Analytics (Daily, Weekly, Monthly, Yearly)
      OwnerFinancialsTab(
        owner: widget.owner,
      ),

      // Tab 3: My Buses (Fleet management & + Register Bus)
      OwnerBusListTab(
        owner: widget.owner,
        onNavigateToConductorTab: _navigateToConductorTab,
        onManageBus: _onManageBus,
      ),

      // Tab 4: Conductor List (Add & Edit Conductor credentials)
      OwnerConductorTab(
        owner: widget.owner,
      ),

      // Tab 5: Owner Profile & Settings
      OwnerProfileTab(
        owner: widget.owner,
        onLogout: widget.onLogout,
      ),
    ];

    final titles = [
      'Owner Fleet Dashboard',
      'Profit & Financial Analytics',
      'My Bus Fleet & Routes',
      'Conductor Directory',
      'Owner Profile & Permits',
    ];

    final unreadReviews = FleetState.instance.getUnreadReviewsCountForOwner(widget.owner.id);

    return Scaffold(
      appBar: _selectedBus != null
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titles[_selectedTabIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text('${widget.owner.companyName} • ${widget.owner.name}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
              actions: [
                // Admin Verification & Data Portal Button
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin Portal & MVD Verification',
                  onPressed: () => _showAdminPortalModal(context),
                ),
                // Reviews Quick Notification Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.star_rate),
                      tooltip: 'Passenger Reviews',
                      onPressed: () {
                        setState(() {
                          _selectedBus = null;
                          _selectedTabIndex = 4; // Navigate to Profile / Reviews
                        });
                      },
                    ),
                    if (unreadReviews > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('$unreadReviews', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: widget.onLogout,
                ),
              ],
            ),
      body: _selectedBus != null
          ? BusDetailPage(
              bus: _selectedBus!,
              onNavigateToConductors: () {
                setState(() {
                  _selectedBus = null;
                  _selectedTabIndex = 3;
                });
              },
              onBack: () => setState(() => _selectedBus = null),
            )
          : tabs[_selectedTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedBus = null;
            _selectedTabIndex = index;
          });
        },
        indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryGreen),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: AppTheme.primaryGreen),
            label: 'Profit & P/L',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
            label: 'My Buses',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge, color: AppTheme.primaryGreen),
            label: 'Conductors',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business, color: AppTheme.primaryGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
