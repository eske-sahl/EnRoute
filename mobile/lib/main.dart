import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/fleet_state.dart';
import 'features/auth/login_screen.dart';
import 'features/passenger/passenger_portal.dart';
import 'features/conductor/conductor_portal.dart';
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
  String _userId = 'SBK-KL-987263';
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

  void _handleLogin(String role, String email, String name, String userId) {
    setState(() {
      _userRole = role;
      _userEmail = email;
      _userName = name;
      _userId = userId;
      _isLoggedIn = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as $_userRole: $name ($userId)'),
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

  void _handleWalletTopUp(String passengerId, double amount) {
    setState(() {
      FleetState.instance.topUpPassengerWallet(passengerId, amount);
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
    return ListenableBuilder(
      listenable: FleetState.instance,
      builder: (context, _) {
        // 1. Initial State: User sees Login Page
        if (!_isLoggedIn) {
          return LoginScreen(onLoginSuccess: _handleLogin);
        }

        // 2. Logged In State: Route based on role
        if (_userRole == 'PASSENGER') {
          final passenger = FleetState.instance.registeredPassengers.firstWhere(
            (p) => p.id == _userId || p.email.toLowerCase() == _userEmail.toLowerCase(),
            orElse: () => FleetState.instance.registeredPassengers.first,
          );
          return PassengerPortal(
            passenger: passenger,
            isOnline: _isBackendOnline,
            onTopUp: (amt) => _handleWalletTopUp(passenger.id, amt),
            onLogout: _handleLogout,
          );
        } else if (_userRole == 'CONDUCTOR') {
          final conductor = FleetState.instance.conductors.firstWhere(
            (c) =>
                c.email.toLowerCase() == _userEmail.toLowerCase() ||
                c.userId.toLowerCase() == _userEmail.toLowerCase() ||
                c.name.toLowerCase() == _userName.toLowerCase(),
            orElse: () => FleetState.instance.conductors.first,
          );
          return ConductorPortal(
            conductor: conductor,
            onLogout: _handleLogout,
          );
        } else {
          return OwnerPortal(
            onLogout: _handleLogout,
          );
        }
      },
    );
  }
}
