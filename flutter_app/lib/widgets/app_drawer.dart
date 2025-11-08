import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return Drawer(
      child: Container(
        color: AppTheme.background,
        child: Column(
          children: [
            // Drawer Header with Gradient
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppTheme.space16,
                bottom: AppTheme.space24,
                left: AppTheme.space20,
                right: AppTheme.space20,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Logo/Icon
                  Container(
                    width: size.width * 0.15,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Icon(
                      Icons.sports_cricket,
                      size: size.width * 0.08,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: AppTheme.space16),

                  // App Name
                  Text(
                    'Teer Khela',
                    style: AppTheme.heading2.copyWith(
                      color: Colors.white,
                      fontSize: size.width * 0.055,
                    ),
                  ),
                  SizedBox(height: AppTheme.space4),

                  // User Status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.space12,
                      vertical: AppTheme.space4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userProvider.isPremium
                              ? Icons.workspace_premium
                              : Icons.person,
                          color: Colors.white,
                          size: size.width * 0.04,
                        ),
                        SizedBox(width: AppTheme.space4),
                        Text(
                          userProvider.isPremium ? 'VIP Member' : 'Free User',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: size.width * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: AppTheme.space8),
                children: [
                  // Home / Results
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
                    title: 'Home',
                    subtitle: 'Live Results',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    size: size,
                  ),

                  const Divider(height: 1),

                  // VIP / Premium
                  _buildMenuItem(
                    context,
                    icon: Icons.workspace_premium,
                    title: 'VIP Premium',
                    subtitle: userProvider.isPremium ? 'Active' : 'Upgrade Now',
                    isPremium: true,
                    onTap: () {
                      Navigator.pop(context);
                      if (userProvider.isPremium) {
                        Navigator.pushNamed(context, '/profile');
                      } else {
                        Navigator.pushNamed(context, '/subscribe');
                      }
                    },
                    size: size,
                  ),

                  const Divider(height: 1),

                  // Hit Number (AI Predictions)
                  _buildMenuItem(
                    context,
                    icon: Icons.psychology,
                    title: 'Hit Number',
                    subtitle: 'AI Predictions',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/predictions');
                    },
                    size: size,
                  ),

                  // Dream Number
                  _buildMenuItem(
                    context,
                    icon: Icons.nightlight_round,
                    title: 'Dream Number',
                    subtitle: 'Dream Interpretation',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/dream');
                    },
                    size: size,
                  ),

                  // Common Number
                  _buildMenuItem(
                    context,
                    icon: Icons.numbers,
                    title: 'Common Number',
                    subtitle: 'Hot & Cold Numbers',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/common-numbers');
                    },
                    size: size,
                  ),

                  // Formula Calculator
                  _buildMenuItem(
                    context,
                    icon: Icons.calculate,
                    title: 'Formula Calculator',
                    subtitle: 'House, Ending, Sum',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/formula-calculator');
                    },
                    size: size,
                  ),

                  const Divider(height: 1),

                  // Profile
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'Account Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                    size: size,
                  ),
                ],
              ),
            ),

            // Footer - App Version
            Container(
              padding: EdgeInsets.all(AppTheme.space16),
              child: Column(
                children: [
                  if (!userProvider.isPremium)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: AppTheme.space12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.premiumGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/subscribe');
                        },
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: size.width * 0.045,
                            ),
                            SizedBox(width: AppTheme.space8),
                            Text(
                              'Upgrade to VIP - ₹49/mo',
                              style: AppTheme.buttonText.copyWith(
                                fontSize: size.width * 0.037,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Text(
                    'Version 1.0.0',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Size size,
    bool isPremium = false,
    bool isPremiumFeature = false,
  }) {
    return ListTile(
      leading: Container(
        width: size.width * 0.11,
        height: size.width * 0.11,
        decoration: BoxDecoration(
          gradient: isPremium
              ? AppTheme.premiumGradient
              : LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.1),
                    AppTheme.primaryLight.withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(
          icon,
          color: isPremium ? Colors.white : AppTheme.primary,
          size: size.width * 0.055,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: AppTheme.subtitle1.copyWith(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isPremiumFeature) ...[
            SizedBox(width: AppTheme.space4),
            Icon(
              Icons.lock,
              size: size.width * 0.035,
              color: AppTheme.premiumGold,
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          fontSize: size.width * 0.032,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: size.width * 0.035,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space4,
      ),
    );
  }
}
