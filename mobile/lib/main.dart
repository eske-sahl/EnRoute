import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'features/auth/login_screen.dart';
import 'features/passenger/passenger_home_screen.dart';
import 'features/conductor/conductor_terminal_screen.dart';
import 'features/owner/owner_fleet_screen.dart';

void main() {
  runApp(const SmartBusKeralaApp());
}

class SmartBusKeralaApp extends StatelessWidget {
  const SmartBusKeralaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBus Kerala',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const MainAppController(),
    );
  }
}

class MainAppController extends StatefulWidget {
  const MainAppController({super.key});

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  bool _isAuthenticated = true; // Start logged-in for immediate testing
  String _activeRole = 'PASSENGER'; // 'PASSENGER', 'CONDUCTOR', 'OWNER'
  String _activeUserName = 'Anjali Nair';
  double _walletBalance = 250.0;
  bool _isBackendOnline = false;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final health = await ApiService.asyncCheckHealth();
    if (health != null && mounted) {
      setState(() {
        _isBackendOnline = true;
      });
    }
  }

  void _handleLogin(String role, String email, String name) {
    setState(() {
      _activeRole = role;
      _activeUserName = name;
      _isAuthenticated = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  void _handleTopUp(double amount) {
    setState(() {
      _walletBalance += amount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('₹${amount.toInt()} added to SmartBus Wallet!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTicketIssued(double fare) {
    if (_walletBalance >= fare) {
      setState(() {
        _walletBalance -= fare;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not authenticated, show Login & Role Selection
    if (!_isAuthenticated) {
      return LoginScreen(onLoginSuccess: _handleLogin);
    }

    // Role-Based Views
    Widget currentScreen;
    if (_activeRole == 'PASSENGER') {
      currentScreen = PassengerHomeScreen(
        passengerName: _activeUserName,
        walletBalance: _walletBalance,
        isOnline: _isBackendOnline,
        onTopUp: _handleTopUp,
        onLogout: _handleLogout,
      );
    } else if (_activeRole == 'CONDUCTOR') {
      currentScreen = ConductorTerminalScreen(
        onEndTrip: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip ended. Daily collection reconciled.')),
          );
        },
        onTicketIssued: _handleTicketIssued,
      );
    } else {
      currentScreen = const OwnerFleetScreen();
    }

    // Quick Role Switcher Bar at the bottom
    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navRoleItem('Passenger', 'PASSENGER', Icons.person_outline, Icons.person),
                _navRoleItem('Conductor', 'CONDUCTOR', Icons.qr_code_scanner_outlined, Icons.qr_code_scanner),
                _navRoleItem('Bus Owner', 'OWNER', Icons.directions_bus_outlined, Icons.directions_bus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navRoleItem(String title, String roleKey, IconData icon, IconData activeIcon) {
    final isSelected = _activeRole == roleKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeRole = roleKey;
          if (roleKey == 'PASSENGER') _activeUserName = 'Anjali Nair';
          if (roleKey == 'CONDUCTOR') _activeUserName = 'Suresh Kumar';
          if (roleKey == 'OWNER') _activeUserName = 'George Varghese';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
