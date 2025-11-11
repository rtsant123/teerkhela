import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teer Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Today's Date
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Admin Menu Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context,
                        icon: Icons.add_circle,
                        title: 'Add Result',
                        subtitle: 'Today\'s Result',
                        color: const Color(0xFF4CAF50),
                        onTap: () => Navigator.pushNamed(context, '/add-result'),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.history,
                        title: 'Past Results',
                        subtitle: 'Bulk Add',
                        color: const Color(0xFFFF9800),
                        onTap: () => Navigator.pushNamed(context, '/past-results'),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.home_work,
                        title: 'Manage Houses',
                        subtitle: 'Add/Edit Houses',
                        color: const Color(0xFF2196F3),
                        onTap: () => Navigator.pushNamed(context, '/manage-houses'),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.card_membership,
                        title: 'Subscriptions',
                        subtitle: 'Manage Plans',
                        color: const Color(0xFF9C27B0),
                        onTap: () => Navigator.pushNamed(context, '/manage-subscriptions'),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.campaign,
                        title: 'FOMO Manager',
                        subtitle: 'Social Proof',
                        color: const Color(0xFF00BCD4),
                        onTap: () => Navigator.pushNamed(context, '/manage-fomo'),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.notifications_active,
                        title: 'Send Bonus',
                        subtitle: 'Notify Users',
                        color: const Color(0xFFE91E63),
                        onTap: () => Navigator.pushNamed(context, '/send-bonus'),
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

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
