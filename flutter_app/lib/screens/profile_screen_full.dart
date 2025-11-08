import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

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
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About Teer Khela',
          style: AppTheme.heading3.copyWith(
            fontSize: size.width * 0.045,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.037,
              ),
            ),
            SizedBox(height: AppTheme.space8),
            Text(
              'Teer Khela - AI Predictions & Results',
              style: AppTheme.subtitle1.copyWith(
                fontSize: size.width * 0.038,
              ),
            ),
            SizedBox(height: AppTheme.space16),
            Text(
              'Get accurate Teer results and AI-powered predictions for all major Teer games.',
              style: AppTheme.bodySmall.copyWith(
                fontSize: size.width * 0.032,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: size.width * 0.038),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primary,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: AppTheme.space12,
          ),
          child: Column(
            children: [
              // User Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  gradient: userProvider.isPremium
                      ? AppTheme.premiumGradient
                      : LinearGradient(
                          colors: [Colors.grey.shade700, Colors.grey.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: size.width * 0.12,
                      backgroundColor: Colors.white,
                      child: Icon(
                        userProvider.isPremium ? Icons.workspace_premium : Icons.person,
                        size: size.width * 0.12,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: AppTheme.space16),
                    Text(
                      user?.email ?? 'Guest User',
                      style: AppTheme.heading2.copyWith(
                        fontSize: size.width * 0.045,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppTheme.space8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: AppTheme.space8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Text(
                        userProvider.isPremium ? 'Premium Member' : 'Free User',
                        style: AppTheme.subtitle1.copyWith(
                          fontSize: size.width * 0.038,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Premium Status Card
              if (userProvider.isPremium)
                _buildPremiumStatusCard(user!, size)
              else
                _buildUpgradeCard(size),

              SizedBox(height: AppTheme.space16),

              // Settings Section
              _buildSection(
                'Settings',
                [
                  SwitchListTile(
                    title: Text(
                      'Push Notifications',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.038,
                      ),
                    ),
                    subtitle: Text(
                      'Receive daily predictions and alerts',
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.032,
                      ),
                    ),
                    value: _notificationsEnabled,
                    activeColor: AppTheme.primary,
                    onChanged: _toggleNotifications,
                    secondary: Icon(
                      Icons.notifications,
                      size: size.width * 0.06,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      size: size.width * 0.06,
                    ),
                    title: Text(
                      'Language',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.038,
                      ),
                    ),
                    subtitle: Text(
                      _getLanguageName(_selectedLanguage),
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.032,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: size.width * 0.04,
                    ),
                    onTap: () => _showLanguageSelector(),
                  ),
                ],
                size,
              ),

              SizedBox(height: AppTheme.space16),

              // Account Section
              _buildSection(
                'Account',
                [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      size: size.width * 0.06,
                    ),
                    title: Text(
                      'About',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.038,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: size.width * 0.04,
                    ),
                    onTap: _showAboutDialog,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      size: size.width * 0.06,
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.038,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: size.width * 0.04,
                    ),
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      size: size.width * 0.06,
                    ),
                    title: Text(
                      'Terms of Service',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.038,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: size.width * 0.04,
                    ),
                    onTap: () {
                      // TODO: Open terms
                    },
                  ),
                ],
                size,
              ),

              SizedBox(height: AppTheme.space16),

              // Test User Button (for testing without payment)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final provider = Provider.of<UserProvider>(context, listen: false);
                    try {
                      await provider.useTestUser();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test account activated! All premium features unlocked for 30 days.'),
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
                  icon: Icon(
                    Icons.science,
                    size: size.width * 0.05,
                  ),
                  label: Text(
                    'Use Test Account (30 Days Premium)',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: size.width * 0.038,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.space12,
                      horizontal: AppTheme.space16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.space16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.space12,
                      horizontal: AppTheme.space16,
                    ),
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: size.width * 0.04,
                      color: AppTheme.error,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.space32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildPremiumStatusCard(user, Size size) {
    final expiryDate = user.expiryDate;
    final daysLeft = user.daysLeft;
    final isExpiringSoon = user.isExpiringSoon;

    return Container(
      margin: EdgeInsets.only(top: AppTheme.space16),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: isExpiringSoon ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isExpiringSoon ? Icons.warning_amber : Icons.check_circle,
                color: isExpiringSoon ? Colors.orange : Colors.green,
                size: size.width * 0.08,
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Active',
                      style: AppTheme.heading3.copyWith(
                        fontSize: size.width * 0.045,
                      ),
                    ),
                    SizedBox(height: AppTheme.space4),
                    Text(
                      expiryDate != null
                          ? 'Expires on ${DateFormat('MMM dd, yyyy').format(expiryDate)}'
                          : 'Active',
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.032,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space16),
          Container(
            padding: EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Days Remaining',
                  style: AppTheme.subtitle1.copyWith(
                    fontSize: size.width * 0.038,
                  ),
                ),
                Text(
                  '$daysLeft days',
                  style: AppTheme.heading3.copyWith(
                    fontSize: size.width * 0.045,
                    color: isExpiringSoon ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.space16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to manage subscription screen
                Navigator.pushNamed(context, '/manage-subscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.space12,
                  horizontal: AppTheme.space16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Manage Subscription',
                style: AppTheme.buttonText.copyWith(
                  fontSize: size.width * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(Size size) {
    final iconSize = size.width * 0.15;

    return Container(
      margin: EdgeInsets.only(top: AppTheme.space16),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: const BoxDecoration(
              gradient: AppTheme.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              size: iconSize * 0.6,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.space16),
          Text(
            'Upgrade to Premium',
            style: AppTheme.heading2.copyWith(
              fontSize: size.width * 0.05,
            ),
          ),
          SizedBox(height: AppTheme.space8),
          Text(
            'Get AI predictions, dream bot, and more!',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: size.width * 0.037,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.space16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.premiumGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/subscribe');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.space12,
                  horizontal: AppTheme.space16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Upgrade Now - ₹49/month • 50% OFF',
                style: AppTheme.buttonText.copyWith(
                  fontSize: size.width * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.02,
            vertical: AppTheme.space8,
          ),
          child: Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              fontSize: size.width * 0.032,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: AppTheme.cardDecoration,
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageSelector() {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: AppTheme.heading3.copyWith(
            fontSize: size.width * 0.045,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(
                'English',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
              ),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(
                'हिन्दी (Hindi)',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
              ),
              value: 'hi',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(
                'বাংলা (Bengali)',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
              ),
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
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: AppTheme.heading3.copyWith(
            fontSize: size.width * 0.045,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.bodyMedium.copyWith(
            fontSize: size.width * 0.037,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: size.width * 0.038),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/home'); // Go to home
            },
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: size.width * 0.038,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
