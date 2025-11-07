import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = StorageService.getNotificationsEnabled();
      _selectedLanguage = StorageService.getLanguage();
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await StorageService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
      ),
    );
  }

  Future<void> _changeLanguage(String? language) async {
    if (language != null) {
      await StorageService.setLanguage(language);
      setState(() {
        _selectedLanguage = language;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language preference saved')),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Teer Khela'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Teer Khela - AI Predictions & Results'),
            SizedBox(height: 16),
            Text(
              'Get accurate Teer results and AI-powered predictions for all major Teer games.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: userProvider.isPremium
                      ? [const Color(0xFF7c3aed), const Color(0xFFa78bfa)]
                      : [Colors.grey.shade700, Colors.grey.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      userProvider.isPremium ? Icons.workspace_premium : Icons.person,
                      size: 40,
                      color: const Color(0xFF7c3aed),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userProvider.isPremium ? 'Premium Member' : 'Free User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Premium Status Card
            if (userProvider.isPremium)
              _buildPremiumStatusCard(user!)
            else
              _buildUpgradeCard(),

            const SizedBox(height: 16),

            // Settings Section
            _buildSection(
              'Settings',
              [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive daily predictions and alerts'),
                  value: _notificationsEnabled,
                  activeColor: const Color(0xFF7c3aed),
                  onChanged: _toggleNotifications,
                  secondary: const Icon(Icons.notifications),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(_getLanguageName(_selectedLanguage)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageSelector(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Account Section
            _buildSection(
              'Account',
              [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showAboutDialog,
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Open terms
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Test User Button (for testing without payment)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final provider = Provider.of<UserProvider>(context, listen: false);
                    try {
                      await provider.useTestUser();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Test account activated! All premium features unlocked for 30 days.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to activate test account: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.science),
                  label: const Text('Use Test Account (30 Days Premium)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard(user) {
    final expiryDate = user.expiryDate;
    final daysLeft = user.daysLeft;
    final isExpiringSoon = user.isExpiringSoon;

    return Card(
      margin: const EdgeInsets.all(16),
      color: isExpiringSoon ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isExpiringSoon ? Icons.warning_amber : Icons.check_circle,
                  color: isExpiringSoon ? Colors.orange : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Active',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expiryDate != null
                            ? 'Expires on ${DateFormat('MMM dd, yyyy').format(expiryDate)}'
                            : 'Active',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Days Remaining',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$daysLeft days',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isExpiringSoon ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to manage subscription screen
                  Navigator.pushNamed(context, '/manage-subscription');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7c3aed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Manage Subscription',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: const Color(0xFF7c3aed).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 48,
              color: Color(0xFF7c3aed),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upgrade to Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get AI predictions, dream bot, and more!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/subscribe');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7c3aed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Upgrade Now - ₹49/month • 50% OFF',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी (Hindi)'),
              value: 'hi',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('বাংলা (Bengali)'),
              value: 'bn',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    final languages = {
      'en': 'English',
      'hi': 'हिन्दी (Hindi)',
      'bn': 'বাংলা (Bengali)',
      'as': 'অসমীয়া (Assamese)',
    };
    return languages[code] ?? 'English';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/home'); // Go to home
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
