import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'features/auth/login_screen.dart';
import 'features/passenger/passenger_portal.dart';
import 'features/conductor/conductor_terminal_screen.dart';
import 'features/owner/owner_portal.dart';

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
      home: const AppRootNavigationController(),
    );
  }
}

class AppRootNavigationController extends StatefulWidget {
  const AppRootNavigationController({super.key});

  @override
  State<AppRootNavigationController> createState() => _AppRootNavigationControllerState();
}

class _AppRootNavigationControllerState extends State<AppRootNavigationController> {
  // Authentication State
  bool _isLoggedIn = false; // Starts at Login Page as requested
  String _userRole = 'PASSENGER'; // 'PASSENGER', 'CONDUCTOR', 'OWNER'
  String _userEmail = 'passenger@gmail.com';
  String _userName = 'Anjali Nair';

  // State for passenger demo wallet
  double _walletBalance = 250.0;
  bool _isBackendOnline = false;

  @override
  void initState() {
    super.initState();
    _pingBackend();
  }

  Future<void> _pingBackend() async {
    final health = await ApiService.asyncCheckHealth();
    if (health != null && mounted) {
      setState(() {
        _isBackendOnline = true;
      });
    }
  }

  void _handleLogin(String role, String email, String name) {
    setState(() {
      _userRole = role;
      _userEmail = email;
      _userName = name;
      _isLoggedIn = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as $_userRole: $name'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleWalletTopUp(double amount) {
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

  @override
  Widget build(BuildContext context) {
    // 1. Initial State: User sees Login Page
    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _handleLogin);
    }

    // 2. Logged In State: Route based on role
    if (_userRole == 'PASSENGER') {
      return PassengerPortal(
        passengerName: _userName,
        email: _userEmail,
        walletBalance: _walletBalance,
        isOnline: _isBackendOnline,
        onTopUp: _handleWalletTopUp,
        onLogout: _handleLogout,
      );
    } else if (_userRole == 'CONDUCTOR') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Conductor Portal'),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
          ],
        ),
        body: ConductorTerminalScreen(
          onEndTrip: _handleLogout,
          onTicketIssued: (fare) {},
        ),
      );
    } else {
      return OwnerPortal(
        onLogout: _handleLogout,
      );
    }
  }
}
