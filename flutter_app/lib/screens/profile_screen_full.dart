import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/referral_stats.dart';
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
  ReferralStats? _referralStats;
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoadingReferral = false;
  bool _isClaimingRewards = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadReferralData();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = StorageService.getNotificationsEnabled();
      _selectedLanguage = StorageService.getLanguage();
    });
  }

  Future<void> _loadReferralData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    if (userId == null) return;

    setState(() {
      _isLoadingReferral = true;
    });

    try {
      // Load referral stats and leaderboard in parallel
      final results = await Future.wait([
        ApiService.getReferralStats(userId),
        ApiService.getReferralLeaderboard(),
      ]);

      setState(() {
        _referralStats = ReferralStats.fromJson(results[0] as Map<String, dynamic>);
        _leaderboard = (results[1] as List)
            .map((json) => LeaderboardEntry.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoadingReferral = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReferral = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load referral data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyReferralCode() async {
    if (_referralStats == null) return;

    await Clipboard.setData(ClipboardData(text: _referralStats!.code));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral code copied to clipboard!'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareReferralCode() async {
    if (_referralStats == null) return;

    final code = _referralStats!.code;
    final message = 'Join Teer Khela using my code $code and get 5 days premium free! Download: https://play.google.com/store/apps/details?id=com.teerkhela.app';

    // Try to open WhatsApp first
    final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');

    try {
      final canLaunch = await canLaunchUrl(whatsappUrl);
      if (canLaunch) {
        await launchUrl(whatsappUrl);
      } else {
        // Fallback to share dialog
        await Share.share(message, subject: 'Join Teer Khela');
      }
    } catch (e) {
      // If WhatsApp fails, use share dialog
      await Share.share(message, subject: 'Join Teer Khela');
    }
  }

  Future<void> _claimRewards() async {
    if (_referralStats == null || _referralStats!.unclaimedRewards == 0) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    if (userId == null) return;

    setState(() {
      _isClaimingRewards = true;
    });

    try {
      final result = await ApiService.claimReferralRewards(userId);

      setState(() {
        _isClaimingRewards = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully claimed ${result['daysAdded']} days of premium!'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload referral data and user status
        _loadReferralData();
        await userProvider.loadUserStatus();
      }
    } catch (e) {
      setState(() {
        _isClaimingRewards = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim rewards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

              // Referral Program Card
              _buildReferralCard(size),

              SizedBox(height: AppTheme.space16),

              // Leaderboard Section
              if (_leaderboard.isNotEmpty) _buildLeaderboard(size),

              if (_leaderboard.isNotEmpty) SizedBox(height: AppTheme.space16),

              // Settings Section
              _buildSection(
                'Settings',
                [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: Text(
                          'Dark Mode',
                          style: AppTheme.subtitle1.copyWith(
                            fontSize: size.width * 0.038,
                          ),
                        ),
                        subtitle: Text(
                          'Switch between light and dark theme',
                          style: AppTheme.bodySmall.copyWith(
                            fontSize: size.width * 0.032,
                          ),
                        ),
                        value: themeProvider.isDarkMode,
                        activeColor: AppTheme.primary,
                        onChanged: (value) async {
                          await themeProvider.toggleTheme();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value ? 'Dark mode enabled' : 'Light mode enabled',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          size: size.width * 0.06,
                        ),
                      );
                    },
                  ),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
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
        color: isExpiringSoon ? AppTheme.warning.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isExpiringSoon ? Icons.warning_amber : Icons.check_circle,
                color: isExpiringSoon ? AppTheme.warning : AppTheme.success,
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
                    color: isExpiringSoon ? AppTheme.warning : AppTheme.success,
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

  Widget _buildReferralCard(Size size) {
    if (_isLoadingReferral) {
      return Container(
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: AppTheme.cardDecoration,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_referralStats == null) {
      return const SizedBox.shrink();
    }

    final hasRewards = _referralStats!.unclaimedRewards > 0;

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight, AppTheme.premiumPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referral Program',
                      style: AppTheme.heading3.copyWith(
                        fontSize: size.width * 0.045,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Share & earn premium days',
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.032,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space20),

          // Referral Code
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Referral Code',
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: size.width * 0.03,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: AppTheme.space8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _referralStats!.code,
                        style: AppTheme.heading1.copyWith(
                          fontSize: size.width * 0.055,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyReferralCode,
                      icon: const Icon(Icons.copy),
                      color: AppTheme.primary,
                      tooltip: 'Copy code',
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.space16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_referralStats!.totalReferrals}',
                        style: AppTheme.heading2.copyWith(
                          fontSize: size.width * 0.06,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Referrals',
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: size.width * 0.028,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.03),
                  decoration: BoxDecoration(
                    color: hasRewards
                        ? Colors.amber.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasRewards) const Text('🎁 ', style: TextStyle(fontSize: 20)),
                          Text(
                            '${_referralStats!.unclaimedRewards}',
                            style: AppTheme.heading2.copyWith(
                              fontSize: size.width * 0.06,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        hasRewards ? 'Days Unclaimed' : 'Rewards Claimed',
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: size.width * 0.028,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.space16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.premiumGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _shareReferralCode,
                    icon: const Icon(Icons.share, size: 20),
                    label: Text(
                      'Share Code',
                      style: AppTheme.buttonText.copyWith(
                        fontSize: size.width * 0.037,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.space12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasRewards && !_isClaimingRewards ? _claimRewards : null,
                  icon: _isClaimingRewards
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.redeem, size: 20),
                  label: Text(
                    'Claim Rewards',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: size.width * 0.037,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasRewards ? Colors.amber : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    elevation: hasRewards ? 4 : 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(Size size) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: AppTheme.premiumGold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Referral Leaderboard',
                  style: AppTheme.heading3.copyWith(
                    fontSize: size.width * 0.042,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(size.width * 0.04),
            itemCount: _leaderboard.length > 10 ? 10 : _leaderboard.length,
            separatorBuilder: (context, index) => SizedBox(height: AppTheme.space12),
            itemBuilder: (context, index) {
              final entry = _leaderboard[index];
              final isTopThree = entry.rank <= 3;

              return Container(
                padding: EdgeInsets.all(size.width * 0.03),
                decoration: BoxDecoration(
                  color: isTopThree
                      ? AppTheme.premiumGold.withOpacity(0.1)
                      : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: isTopThree
                      ? Border.all(color: AppTheme.premiumGold.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        entry.rankEmoji,
                        style: TextStyle(
                          fontSize: isTopThree ? 24 : size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.username,
                            style: AppTheme.subtitle1.copyWith(
                              fontSize: size.width * 0.038,
                              fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${entry.referrals} referrals',
                            style: AppTheme.bodySmall.copyWith(
                              fontSize: size.width * 0.032,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTopThree)
                      Icon(
                        Icons.star,
                        color: AppTheme.premiumGold,
                        size: size.width * 0.05,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
