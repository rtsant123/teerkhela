import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simple authentication - you can enhance this with API call
      // For now, using hardcoded credentials (change these!)
      if (username == 'admin' && password == 'admin123') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_admin', true);
        await prefs.setString('admin_token', 'admin_session_${DateTime.now().millisecondsSinceEpoch}');

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        }
      } else {
        setState(() {
          _error = 'Invalid username or password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: size.width * 0.25,
                    height: size.width * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: size.width * 0.12,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: AppTheme.space32),

                  // Title
                  Text(
                    'Admin Login',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontSize: size.width * 0.08,
                    ),
                  ),
                  SizedBox(height: AppTheme.space8),
                  Text(
                    'Manage houses and results',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                    ),
                  ),
                  SizedBox(height: AppTheme.space32),

                  // Login Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(AppTheme.space24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        // Username
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                          enabled: !_isLoading,
                        ),
                        SizedBox(height: AppTheme.space16),

                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                          enabled: !_isLoading,
                          onSubmitted: (_) => _login(),
                        ),
                        SizedBox(height: AppTheme.space8),

                        // Error message
                        if (_error != null)
                          Container(
                            padding: EdgeInsets.all(AppTheme.space12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                SizedBox(width: AppTheme.space8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: AppTheme.space24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: EdgeInsets.symmetric(vertical: AppTheme.space16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: AppTheme.buttonText.copyWith(fontSize: size.width * 0.04),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.space32),

                  // Back to app
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
