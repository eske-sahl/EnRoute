import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/wallet_tab.dart';
import 'tabs/profile_tab.dart';

class PassengerPortal extends StatefulWidget {
  final String passengerName;
  final String email;
  final double walletBalance;
  final bool isOnline;
  final Function(double) onTopUp;
  final VoidCallback onLogout;

  const PassengerPortal({
    super.key,
    required this.passengerName,
    required this.email,
    required this.walletBalance,
    required this.isOnline,
    required this.onTopUp,
    required this.onLogout,
  });

  @override
  State<PassengerPortal> createState() => _PassengerPortalState();
}

class _PassengerPortalState extends State<PassengerPortal> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      // Tab 1: Dashboard
      DashboardTab(
        passengerName: widget.passengerName,
        walletBalance: widget.walletBalance,
        onTopUp: widget.onTopUp,
      ),

      // Tab 2: Bus Search (with 2 inner tabs: Route Search & Bus by Reg No)
      const SearchTab(),

      // Tab 3: Wallet Details (All transactions, recharge, upi, cash, travel history)
      WalletTab(
        walletBalance: widget.walletBalance,
        onTopUp: widget.onTopUp,
      ),

      // Tab 4: Profile & Settings & Logout
      ProfileTab(
        passengerName: widget.passengerName,
        email: widget.email,
        onLogout: widget.onLogout,
      ),
    ];

    final tabTitles = [
      'Passenger Dashboard',
      'Bus & Route Search',
      'Wallet & Travel Ledger',
      'My Profile & Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tabTitles[_selectedTabIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isOnline ? AppTheme.accentAmber : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isOnline ? 'SmartBus Server Online' : 'Local Standalone Mode',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
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
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppTheme.primaryGreen),
            label: 'Bus Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppTheme.primaryGreen),
            label: 'Wallet Details',
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
