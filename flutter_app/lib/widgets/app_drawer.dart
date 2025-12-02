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
      width: size.width * 0.8, // Responsive drawer width
      child: Container(
        color: AppTheme.background,
        child: Column(
          children: [
            // Drawer Header with Gradient
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + size.height * 0.02,
                bottom: size.height * 0.025,
                left: size.width * 0.05,
                right: size.width * 0.05,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar and Name
                  if (userProvider.user != null && !userProvider.user!.isGuest)
                    Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.user!.name ?? 'User',
                            style: AppTheme.heading2.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.05,
                            ),
                          ),
                          if (userProvider.user!.phoneNumber != null)
                            Text(
                              userProvider.user!.phoneNumber!,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: size.width * 0.035,
                              ),
                            ),
                          SizedBox(height: size.height * 0.015),
                        ],
                      ),
                    ),

                  // App Logo/Icon - Teer (Archery Target)
                  Container(
                    width: size.width * 0.15,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Icon(
                      Icons.gps_fixed, // Target icon for Teer (archery)
                      size: size.width * 0.08,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),

                  // App Name
                  Text(
                    'Teer Khela',
                    style: AppTheme.heading2.copyWith(
                      color: Colors.white,
                      fontSize: size.width * 0.055,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),

                  // User Status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.006,
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
                        SizedBox(width: size.width * 0.015),
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
                padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
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

                  // Common Numbers
                  _buildMenuItem(
                    context,
                    icon: Icons.numbers,
                    title: 'Common Numbers',
                    subtitle: 'Most Frequent',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/common-numbers');
                    },
                    size: size,
                  ),

                  // Hot & Cold Numbers
                  _buildMenuItem(
                    context,
                    icon: Icons.whatshot,
                    title: 'Hot & Cold Numbers',
                    subtitle: 'Trending Analysis',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/hot-cold-numbers');
                    },
                    size: size,
                  ),

                  // Lucky Numbers
                  _buildMenuItem(
                    context,
                    icon: Icons.star,
                    title: 'Lucky Numbers',
                    subtitle: 'Randomly Generated',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/lucky-numbers');
                    },
                    size: size,
                  ),

                  // Hit Numbers
                  _buildMenuItem(
                    context,
                    icon: Icons.check_circle,
                    title: 'Hit Numbers',
                    subtitle: 'Past Winners',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/hit-numbers');
                    },
                    size: size,
                  ),

                  // AI Dream Number
                  _buildMenuItem(
                    context,
                    icon: Icons.nightlight_round,
                    title: 'AI Dream Number',
                    subtitle: 'Dream to Numbers',
                    isPremiumFeature: !userProvider.isPremium,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/dream');
                    },
                    size: size,
                  ),

                  // Formula Calculator
                  _buildMenuItem(
                    context,
                    icon: Icons.calculate,
                    title: 'Formula Calculator',
                    subtitle: 'Calculate Numbers',
                    isPremiumFeature: !userProvider.isPremium,
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

                  const Divider(height: 1),

                  // Contact Us
                  _buildMenuItem(
                    context,
                    icon: Icons.support_agent,
                    title: 'Contact Us',
                    subtitle: 'Get Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/contact-us');
                    },
                    size: size,
                  ),

                  // Privacy Policy
                  _buildMenuItem(
                    context,
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    subtitle: 'Your Data Privacy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/privacy-policy');
                    },
                    size: size,
                  ),

                  // Terms & Conditions
                  _buildMenuItem(
                    context,
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    subtitle: 'Usage Terms',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/terms-conditions');
                    },
                    size: size,
                  ),
                ],
              ),
            ),

            // Footer - App Version
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                children: [
                  if (!userProvider.isPremium)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: size.height * 0.015),
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
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
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
                              size: size.width * 0.05,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Flexible(
                              child: Text(
                                'Upgrade to VIP',
                                style: AppTheme.buttonText.copyWith(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Text(
                    'Version 1.0.7',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: size.width * 0.032,
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
    bool isAdmin = false,
  }) {
    return ListTile(
      dense: true,
      leading: Container(
        width: size.width * 0.12,
        height: size.width * 0.12,
        decoration: BoxDecoration(
          gradient: isPremium
              ? AppTheme.premiumGradient
              : isAdmin
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.15),
                        AppTheme.primaryLight.withOpacity(0.15),
                      ],
                    ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: (isPremium || isAdmin) ? Colors.white : AppTheme.primary,
          size: size.width * 0.06,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTheme.subtitle1.copyWith(
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isPremiumFeature) ...[
            SizedBox(width: size.width * 0.01),
            Icon(
              Icons.lock,
              size: size.width * 0.038,
              color: AppTheme.premiumGold,
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          fontSize: size.width * 0.034,
          color: AppTheme.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: size.width * 0.038,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.width * 0.01,
      ),
    );
  }
}
