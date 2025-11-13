import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPremium = userProvider.isPremium;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surface,
        elevation: 0,
        selectedLabelStyle: AppTheme.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: AppTheme.bodySmall.copyWith(
          fontSize: 10,
        ),
        onTap: onTap ?? (index) => _handleNavigation(context, index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.grid_3x3_rounded),
                if (!isPremium)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.premiumGold,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Common',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.stars_rounded),
                if (!isPremium)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.premiumGold,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Lucky VIP',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.psychology_rounded),
                if (!isPremium)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.premiumGold,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Dream',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calculate_rounded),
            label: 'Formula',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Don't navigate if already on current screen
    if (index == currentIndex) return;

    String route;
    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/common-numbers';
        break;
      case 2:
        route = '/lucky-numbers';
        break;
      case 3:
        route = '/dream';
        break;
      case 4:
        route = '/formula-calculator';
        break;
      default:
        return;
    }

    // Use pushReplacementNamed to avoid stacking
    Navigator.pushReplacementNamed(context, route);
  }
}
