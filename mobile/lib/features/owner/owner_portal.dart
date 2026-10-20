import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';
import 'tabs/owner_dashboard_tab.dart';
import 'tabs/owner_bus_list_tab.dart';
import 'tabs/owner_conductor_tab.dart';
import 'tabs/owner_profile_tab.dart';

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

  void _navigateToConductorTab() {
    setState(() {
      _selectedTabIndex = 2; // Jump to Conductor tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      // Tab 1: Owner Dashboard
      OwnerDashboardTab(
        onNavigateToConductorTab: _navigateToConductorTab,
      ),

      // Tab 2: My Buses (Fleet management & + Register Bus)
      OwnerBusListTab(
        onNavigateToConductorTab: _navigateToConductorTab,
      ),

      // Tab 3: Conductor List (Add Conductor credentials)
      const OwnerConductorTab(),

      // Tab 4: Owner Profile & Settings
      OwnerProfileTab(
        owner: widget.owner,
        onLogout: widget.onLogout,
      ),
    ];

    final titles = [
      'Owner Fleet Dashboard',
      'My Bus Fleet & Routes',
      'Conductor Directory',
      'Owner Profile & Permits',
    ];

    final unreadReviews = FleetState.instance.getUnreadReviewsCountForOwner();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[_selectedTabIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('${widget.owner.companyName} • ${widget.owner.name}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          // Reviews Quick Notification Icon
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.star_rate),
                tooltip: 'Passenger Reviews',
                onPressed: () {
                  setState(() {
                    _selectedTabIndex = 3; // Navigate to Profile / Reviews
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
      body: tabs[_selectedTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
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
