import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'tabs/owner_dashboard_tab.dart';
import 'tabs/owner_bus_list_tab.dart';
import 'tabs/owner_conductor_tab.dart';
import 'tabs/owner_profile_tab.dart';

class OwnerPortal extends StatefulWidget {
  final VoidCallback onLogout;

  const OwnerPortal({
    super.key,
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
        onLogout: widget.onLogout,
      ),
    ];

    final titles = [
      'Owner Fleet Dashboard',
      'My Bus Fleet & Routes',
      'Conductor Directory',
      'Owner Profile & Permits',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[_selectedTabIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const Text('St. George Motors • Ernakulam', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
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
