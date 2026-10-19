import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';
import 'tabs/conductor_dashboard_tab.dart';
import 'tabs/conductor_journey_tab.dart';
import 'tabs/conductor_history_tab.dart';
import 'tabs/conductor_profile_tab.dart';

class ConductorPortal extends StatefulWidget {
  final ConductorModel conductor;
  final VoidCallback onLogout;

  const ConductorPortal({
    super.key,
    required this.conductor,
    required this.onLogout,
  });

  @override
  State<ConductorPortal> createState() => _ConductorPortalState();
}

class _ConductorPortalState extends State<ConductorPortal> {
  int _selectedTabIndex = 0;

  void _navigateToJourneyTab() {
    setState(() {
      _selectedTabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bus = FleetState.instance.getBusByReg(widget.conductor.assignedBusReg);
    final busName = bus?.busName ?? widget.conductor.assignedBusName;
    final busReg = bus?.regNumber ?? widget.conductor.assignedBusReg;
    final unreadReviews = FleetState.instance.getUnreadReviewsCountForConductor(busReg);

    final tabs = [
      // Tab 1: Dashboard
      ConductorDashboardTab(
        conductor: widget.conductor,
        onNavigateToJourney: _navigateToJourneyTab,
      ),

      // Tab 2: Bus Journey & Timeline Schedule Manager
      ConductorJourneyTab(
        conductor: widget.conductor,
      ),

      // Tab 3: Transaction & Ticket History
      ConductorHistoryTab(
        conductor: widget.conductor,
      ),

      // Tab 4: Profile & Settings (including Reviews)
      ConductorProfileTab(
        conductor: widget.conductor,
        onLogout: widget.onLogout,
      ),
    ];

    final titles = [
      'Conductor Terminal',
      'Bus Journey & Schedule',
      'Ticket Transactions',
      'Conductor Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[_selectedTabIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('$busName ($busReg) • ${widget.conductor.name}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          // Live GPS Broadcast Icon
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.greenAccent),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sensors, color: Colors.greenAccent, size: 12),
                SizedBox(width: 4),
                Text('GPS ON', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
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
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route, color: AppTheme.primaryGreen),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primaryGreen),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
