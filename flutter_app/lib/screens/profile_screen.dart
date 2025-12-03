import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            vertical: AppTheme.space20,
          ),
          child: Column(
            children: [
              // User Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.06),
                decoration: BoxDecoration(
                  gradient: userProvider.isPremium
                      ? AppTheme.premiumGradient
                      : LinearGradient(
                          colors: [Colors.grey.shade700, Colors.grey.shade500],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.elevatedShadow,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: size.width * 0.15,
                      backgroundColor: Colors.white,
                      child: Icon(
                        userProvider.isPremium ? Icons.workspace_premium : Icons.person,
                        size: size.width * 0.15,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: AppTheme.space20),
                    Text(
                      user?.email ?? 'Guest User',
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.space12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: AppTheme.space10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userProvider.isPremium ? 'PREMIUM MEMBER' : 'FREE USER',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.space24),

              // Premium Status or Upgrade
              if (userProvider.isPremium)
                _buildPremiumStatus(user!, size, context)
              else
                _buildUpgradeCard(size, context),

              SizedBox(height: AppTheme.space32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, userProvider),
                  icon: const Icon(Icons.logout, size: 24),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(color: AppTheme.error, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 6),
    );
  }

  Widget _buildPremiumStatus(user, Size size, BuildContext context) {
    final expiryDate = user.expiryDate;
    final daysLeft = user.daysLeft;
    final isExpiringSoon = user.isExpiringSoon;

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpiringSoon ? AppTheme.warning.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpiringSoon ? Icons.warning_amber : Icons.check_circle,
                  color: isExpiringSoon ? AppTheme.warning : AppTheme.success,
                  size: 32,
                ),
              ),
              SizedBox(width: AppTheme.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Active',
                      style: TextStyle(
                        fontSize: size.width * 0.048,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      expiryDate != null
                          ? 'Expires ${DateFormat('MMM dd, yyyy').format(expiryDate)}'
                          : 'Active',
                      style: TextStyle(
                        fontSize: size.width * 0.034,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space20),
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isExpiringSoon ? AppTheme.warning : AppTheme.success).withOpacity(0.1),
                  (isExpiringSoon ? AppTheme.warning : AppTheme.success).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Days Remaining',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: isExpiringSoon ? AppTheme.warning : AppTheme.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$daysLeft days',
                    style: TextStyle(
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.space16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/manage-subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(Size size, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: size.width * 0.2,
            height: size.width * 0.2,
            decoration: const BoxDecoration(
              gradient: AppTheme.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              size: size.width * 0.12,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.space20),
          Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: size.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.space12),
          Text(
            'Get AI predictions, dream bot, common numbers, lucky VIP numbers & more!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.038,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.space24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.premiumGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/subscribe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: TextStyle(fontSize: size.width * 0.048),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: size.width * 0.038),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: size.width * 0.04)),
          ),
          TextButton(
            onPressed: () async {
              await userProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
