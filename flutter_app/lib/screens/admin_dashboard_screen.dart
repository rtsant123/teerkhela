import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../models/game.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<TeerGame> _games = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await ApiService.getGames();
      if (mounted) {
        setState(() {
          _games = games;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin');
    await prefs.remove('admin_token');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(size),
    );
  }

  Widget _buildBody(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            SizedBox(height: AppTheme.space16),
            Text(_error!, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: _loadGames,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGames,
      child: ListView(
        padding: EdgeInsets.all(AppTheme.space16),
        children: [
          // Quick Actions
          _buildQuickActions(size),
          SizedBox(height: AppTheme.space24),

          // Stats Cards
          _buildStatsCards(size),
          SizedBox(height: AppTheme.space24),

          // Houses List
          Text('Your Houses (${_games.length})', style: AppTheme.heading2),
          SizedBox(height: AppTheme.space16),

          if (_games.isEmpty)
            _buildEmptyState(size)
          else
            ..._games.map((game) => _buildGameCard(game, size)).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Size size) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: Colors.white, size: size.width * 0.06),
              SizedBox(width: AppTheme.space8),
              Text(
                'Quick Actions',
                style: AppTheme.heading3.copyWith(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space16),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle,
                  label: 'Add Results',
                  onTap: () => Navigator.pushNamed(context, '/admin-add-result'),
                ),
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.home_work,
                  label: 'Manage Houses',
                  onTap: () => Navigator.pushNamed(context, '/admin-manage-houses'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppTheme.space16),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              SizedBox(height: AppTheme.space8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(Size size) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Houses',
            value: _games.length.toString(),
            icon: Icons.home_work,
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.premiumPurple],
            ),
          ),
        ),
        SizedBox(width: AppTheme.space12),
        Expanded(
          child: _buildStatCard(
            title: 'Active Houses',
            value: _games.where((g) => g.isActive).length.toString(),
            icon: Icons.check_circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: AppTheme.space8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(TeerGame game, Size size) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppTheme.space16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: game.isActive ? AppTheme.primaryGradient : const LinearGradient(
              colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(Icons.home_work, color: Colors.white),
        ),
        title: Text(
          game.displayName,
          style: AppTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.space4),
            Text(game.region ?? 'No region', style: AppTheme.bodySmall),
            SizedBox(height: AppTheme.space4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: game.isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                game.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: game.isActive ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppTheme.primary),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/admin-add-result',
              arguments: game.name,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: size.width * 0.15, color: AppTheme.textTertiary),
          SizedBox(height: AppTheme.space16),
          Text(
            'No houses yet',
            style: AppTheme.heading3.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.space8),
          Text(
            'Create your first house to get started',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.space24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/admin-manage-houses'),
            icon: const Icon(Icons.add),
            label: const Text('Create House'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.space24,
                vertical: AppTheme.space12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
