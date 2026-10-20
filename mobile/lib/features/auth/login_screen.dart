import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';

class LoginScreen extends StatefulWidget {
  final Function(String role, String email, String name, String userId) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'PASSENGER'; // 'PASSENGER', 'CONDUCTOR', 'OWNER'
  bool _isSignUp = false;

  final _emailController = TextEditingController(text: 'passenger@gmail.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Anjali Nair');
  final _phoneController = TextEditingController(text: '9847000004');
  final _companyController = TextEditingController(text: 'St. George Motors Ernakulam');

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'PASSENGER') {
        _emailController.text = 'passenger@gmail.com';
        _nameController.text = 'Anjali Nair';
        _phoneController.text = '9847000004';
        _passwordController.text = 'password123';
      } else if (role == 'CONDUCTOR') {
        // Owner-provisioned credentials
        _emailController.text = 'suresh.conductor';
        _nameController.text = 'Suresh Kumar (Conductor)';
        _passwordController.text = 'password123';
        _isSignUp = false;
      } else {
        _emailController.text = 'owner@stgeorge.com';
        _nameController.text = 'George Varghese';
        _companyController.text = 'St. George Motors Ernakulam';
        _phoneController.text = '9447012345';
        _passwordController.text = 'password123';
      }
    });
  }

  void _fillAccount(String email, String pass, String name, String phone, String role, [String company = 'St. George Motors Ernakulam']) {
    setState(() {
      _selectedRole = role;
      _emailController.text = email;
      _passwordController.text = pass;
      _nameController.text = name;
      _phoneController.text = phone;
      _companyController.text = company;
      _isSignUp = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleAuth() {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showError('Please enter both your login identifier and password.');
      return;
    }

    // 1. Sign-Up Mode for Passengers and Bus Owners
    if (_isSignUp) {
      if (_selectedRole == 'CONDUCTOR') {
        _showError('Conductor accounts are created by Bus Owners in the Owner Portal.');
        return;
      }

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      if (name.isEmpty) {
        _showError('Please enter your full name to register.');
        return;
      }
      if (phone.isEmpty || phone.length < 10) {
        _showError('Please enter a valid 10-digit mobile number.');
        return;
      }

      // Owner Sign-Up
      if (_selectedRole == 'OWNER') {
        final company = _companyController.text.trim();
        if (company.isEmpty) {
          _showError('Please enter your bus firm or company name.');
          return;
        }

        final existingOwner = FleetState.instance.findOwnerByIdOrPhone(phone) ??
            FleetState.instance.findOwnerByIdOrPhone(identifier);
        if (existingOwner != null) {
          _showError('An owner account with this phone or email already exists. Please sign in instead.');
          return;
        }

        final newOwner = FleetState.instance.registerOwner(
          name: name,
          email: identifier.contains('@') ? identifier : '$phone@smartbus.kerala.gov.in',
          phone: phone,
          password: password,
          companyName: company,
        );

        widget.onLoginSuccess('OWNER', newOwner.email, '${newOwner.name} (${newOwner.companyName})', newOwner.id);
        return;
      }

      // Passenger Sign-Up
      final existing = FleetState.instance.findPassengerByIdOrPhone(phone) ??
          FleetState.instance.findPassengerByIdOrPhone(identifier);
      if (existing != null) {
        _showError('An account with this phone or email already exists. Please sign in instead.');
        return;
      }

      final newPassenger = FleetState.instance.registerPassenger(
        name: name,
        phone: phone,
        email: identifier.contains('@') ? identifier : '$phone@smartbus.kerala.gov.in',
        password: password,
      );

      widget.onLoginSuccess('PASSENGER', newPassenger.email, newPassenger.name, newPassenger.id);
      return;
    }

    // 2. Sign-In Mode: Conductor Login
    if (_selectedRole == 'CONDUCTOR') {
      final conductor = FleetState.instance.authenticateConductor(identifier, password);
      if (conductor != null) {
        widget.onLoginSuccess('CONDUCTOR', conductor.email, conductor.name, conductor.id);
      } else {
        _showError('Incorrect Conductor ID or password. Use owner-provisioned credentials.');
      }
      return;
    }

    // 3. Sign-In Mode: Bus Owner Login
    if (_selectedRole == 'OWNER') {
      final owner = FleetState.instance.authenticateOwner(identifier, password);
      if (owner != null) {
        widget.onLoginSuccess('OWNER', owner.email, '${owner.name} (${owner.companyName})', owner.id);
      } else {
        _showError('Incorrect Owner email/phone or password. Please verify credentials or create an owner account.');
      }
      return;
    }

    // 4. Sign-In Mode: Passenger Login
    final passenger = FleetState.instance.authenticatePassenger(identifier, password);
    if (passenger != null) {
      widget.onLoginSuccess('PASSENGER', passenger.email, passenger.name, passenger.id);
    } else {
      _showError('Incorrect email/phone or password. Please verify credentials or create an account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003824), Color(0xFF005A3A), Color(0xFFF6F8FA)],
            stops: [0.0, 0.35, 0.35],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // Top Branding Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_bus, color: AppTheme.darkSlate, size: 32),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SmartBus Kerala',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Public Transit Management System',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Role Selector Switcher
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _roleTabItem('Passenger', 'PASSENGER', Icons.person),
                      _roleTabItem('Conductor', 'CONDUCTOR', Icons.qr_code_scanner),
                      _roleTabItem('Bus Owner', 'OWNER', Icons.business),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isSignUp ? 'Create Account' : 'Welcome Back',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _selectedRole,
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSignUp
                            ? 'Register to start using SmartBus Kerala'
                            : 'Sign in to access your ${_selectedRole.toLowerCase()} terminal',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      if (_isSignUp) ...[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: _selectedRole == 'OWNER' ? 'Owner Full Name' : 'Full Name',
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedRole == 'OWNER') ...[
                          TextField(
                            controller: _companyController,
                            decoration: InputDecoration(
                              labelText: 'Operating Firm / Bus Company Name',
                              hintText: 'e.g. St. George Motors, Kondody Transports',
                              prefixIcon: const Icon(Icons.business_outlined, color: AppTheme.primaryGreen),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: '10-Digit Mobile Number',
                            prefixIcon: const Icon(Icons.phone_android, color: AppTheme.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextField(
                        controller: _emailController,
                        keyboardType: _selectedRole == 'PASSENGER' ? TextInputType.text : TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: _selectedRole == 'CONDUCTOR'
                              ? 'Owner-Assigned Conductor User ID'
                              : (_selectedRole == 'OWNER' ? 'Owner Email Address' : 'Mobile Number or Email'),
                          hintText: _selectedRole == 'CONDUCTOR'
                              ? 'e.g. suresh.conductor'
                              : (_selectedRole == 'OWNER' ? 'e.g. owner@stgeorge.com' : 'e.g. 9847000004'),
                          prefixIcon: Icon(
                            _selectedRole == 'CONDUCTOR'
                                ? Icons.badge_outlined
                                : (_selectedRole == 'OWNER' ? Icons.business_outlined : Icons.person_outline),
                            color: AppTheme.primaryGreen,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          helperText: _selectedRole == 'CONDUCTOR'
                              ? 'Conductor credentials are created by the Bus Owner'
                              : (_selectedRole == 'PASSENGER' ? 'Personal phone/account accesses Passenger Portal' : 'Official owner credentials'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isSignUp ? 'Register as $_selectedRole' : 'Sign In as $_selectedRole',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Switch between Sign in and Sign up
                      if (_selectedRole != 'CONDUCTOR')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'New $_selectedRole? Create an account',
                            style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Conductor accounts are provisioned by Bus Owners in the Owner Portal.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Viva Demo Quick-Fill Bar
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: AppTheme.accentAmber, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Account Switcher (Pre-Configured Credentials):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          _accountFillBtn('Anjali Nair (Passenger)', () => _fillAccount('passenger@gmail.com', 'password123', 'Anjali Nair', '9847000004', 'PASSENGER')),
                          _accountFillBtn('Rahul Menon (Student Pass)', () => _fillAccount('rahul@gmail.com', 'password123', 'Rahul Menon', '9847000005', 'PASSENGER')),
                          _accountFillBtn('Suresh (Conductor)', () => _fillAccount('suresh.conductor', 'password123', 'Suresh Kumar', '9847011001', 'CONDUCTOR')),
                          _accountFillBtn('George (Owner)', () => _fillAccount('owner@stgeorge.com', 'password123', 'George Varghese', '9447012345', 'OWNER')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTabItem(String title, String roleKey, IconData icon) {
    final isSelected = _selectedRole == roleKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectRole(roleKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade600),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountFillBtn(String label, VoidCallback onTap) {
    return ActionChip(
      avatar: const Icon(Icons.person_pin, size: 14, color: AppTheme.primaryGreen),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      onPressed: onTap,
    );
  }
}
