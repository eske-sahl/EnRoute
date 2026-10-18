import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';

class LoginScreen extends StatefulWidget {
  final Function(String role, String email, String name) onLoginSuccess;

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

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'PASSENGER') {
        _emailController.text = '9847000004';
        _nameController.text = 'Anjali Nair';
        _passwordController.text = 'password123';
      } else if (role == 'CONDUCTOR') {
        // Owner-provisioned credentials
        _emailController.text = 'suresh.conductor';
        _nameController.text = 'Suresh Kumar (Conductor)';
        _passwordController.text = 'password123';
      } else {
        _emailController.text = 'owner@stgeorge.com';
        _nameController.text = 'George Varghese (Owner)';
        _passwordController.text = 'password123';
      }
    });
  }

  void _handleAuth() {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Check if user is logging in with Owner-provisioned Conductor credentials
    final conductor = FleetState.instance.authenticateConductor(identifier, password);
    if (conductor != null) {
      widget.onLoginSuccess(
        'CONDUCTOR',
        conductor.email,
        conductor.name,
      );
      return;
    }

    // 2. Check if user is logging in as Bus Owner
    if (_selectedRole == 'OWNER' || identifier.toLowerCase().contains('owner')) {
      widget.onLoginSuccess(
        'OWNER',
        identifier,
        _nameController.text.isNotEmpty ? _nameController.text : 'George Varghese (Owner)',
      );
      return;
    }

    // 3. Otherwise (self-created account with phone number, passenger email, or personal password) -> Passenger Portal!
    widget.onLoginSuccess(
      'PASSENGER',
      identifier,
      _nameController.text.isNotEmpty ? _nameController.text : 'Passenger ($identifier)',
    );
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
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                              : (_selectedRole == 'OWNER' ? 'Owner Email / Username' : 'Mobile Number or Email'),
                          hintText: _selectedRole == 'CONDUCTOR'
                              ? 'e.g. suresh.conductor'
                              : (_selectedRole == 'OWNER' ? 'owner@stgeorge.com' : 'e.g. 9847000004'),
                          prefixIcon: Icon(
                            _selectedRole == 'CONDUCTOR'
                                ? Icons.badge_outlined
                                : (_selectedRole == 'OWNER' ? Icons.business_outlined : Icons.person_outline),
                            color: AppTheme.primaryGreen,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          helperText: _selectedRole == 'CONDUCTOR'
                              ? 'Conductor credentials are created by the Bus Owner'
                              : (_selectedRole == 'PASSENGER' ? 'Personal phone/account accesses Passenger Portal' : null),
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
                          _isSignUp ? 'Register & Continue' : 'Sign In as $_selectedRole',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Switch between Sign in and Sign up
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign In'
                              : 'New user? Create a free account',
                          style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
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
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: AppTheme.accentAmber, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Viva Demo Quick Fill:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _quickFillBtn('Passenger', 'PASSENGER'),
                          _quickFillBtn('Conductor', 'CONDUCTOR'),
                          _quickFillBtn('Owner', 'OWNER'),
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

  Widget _quickFillBtn(String label, String roleKey) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _selectRole(roleKey),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
    );
  }
}
