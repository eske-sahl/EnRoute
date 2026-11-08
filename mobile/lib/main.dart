import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/fleet_state.dart';
import 'services/storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/passenger/passenger_portal.dart';
import 'features/conductor/conductor_portal.dart';
import 'features/owner/owner_portal.dart';

import 'features/splash/splash_screen.dart';
import 'services/app_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FleetState.instance.initialize();
  await AppSettingsService.instance.initialize();
  runApp(const EnRouteApp());
}

class EnRouteApp extends StatelessWidget {
  final bool showSplashFirst;
  const EnRouteApp({super.key, this.showSplashFirst = true});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'EnRoute',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppSettingsService.instance.themeMode,
          home: AppRootNavigationController(showSplashFirst: showSplashFirst),
        );
      },
    );
  }
}

// Backwards compatibility alias for tests
typedef SmartBusKeralaApp = EnRouteApp;

class AppRootNavigationController extends StatefulWidget {
  final bool showSplashFirst;
  const AppRootNavigationController({super.key, this.showSplashFirst = true});

  @override
  State<AppRootNavigationController> createState() => _AppRootNavigationControllerState();
}

class _AppRootNavigationControllerState extends State<AppRootNavigationController> {
  // Splash & Authentication State
  late bool _showingSplash;
  bool _isLoggedIn = false; // Starts at Login Page as requested
  String _userRole = 'PASSENGER'; // 'PASSENGER', 'CONDUCTOR', 'OWNER'
  String _userEmail = 'passenger@gmail.com';
  String _userName = 'Fathima';
  String _userId = 'SBK-KL-987263';
  bool _isBackendOnline = false;

  @override
  void initState() {
    super.initState();
    // Only show splash on initial launch for new user
    final hasSeen = StorageService.instance.hasSeenSplash();
    _showingSplash = widget.showSplashFirst && !hasSeen;

    // Restore persistent session if logged in
    final session = StorageService.instance.loadUserSession();
    if (session != null && session['role'] != null && session['role']!.isNotEmpty) {
      _isLoggedIn = true;
      _userRole = session['role']!;
      _userEmail = session['email'] ?? '';
      _userName = session['name'] ?? '';
      _userId = session['userId'] ?? '';
    }

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

    // Persist login session across app restarts
    StorageService.instance.saveUserSession({
      'role': role,
      'email': email,
      'name': name,
      'userId': userId,
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

    // Clear persistent session on explicit logout
    StorageService.instance.clearUserSession();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleWalletTopUp(String passengerId, double amount) {
    setState(() {
      FleetState.instance.topUpPassengerWallet(
        passengerId,
        amount,
        source: 'EnRoute UPI Gateway (enroute.kerala@upi)',
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('₹${amount.toInt()} added to EnRoute Wallet!'),
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
        // 0. Initial State: Show Splash Screen if first entry
        if (_showingSplash) {
          return SplashScreen(
            onFinish: () {
              StorageService.instance.setSeenSplash(true);
              setState(() {
                _showingSplash = false;
              });
            },
          );
        }

        // 1. User sees Login Page
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
          final owner = FleetState.instance.registeredOwners.firstWhere(
            (o) => o.id == _userId || o.email.toLowerCase() == _userEmail.toLowerCase(),
            orElse: () => FleetState.instance.registeredOwners.isNotEmpty
                ? FleetState.instance.registeredOwners.first
                : FleetState.instance.registerOwner(
                    name: _userName,
                    email: _userEmail,
                    phone: '9447012345',
                    password: 'password123',
                    companyName: 'St. George Motors Ernakulam',
                  ),
          );
          return OwnerPortal(
            owner: owner,
            onLogout: _handleLogout,
          );
        }
      },
    );
  }
}
