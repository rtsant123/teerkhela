import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class CommonNumbersScreen extends StatefulWidget {
  const CommonNumbersScreen({super.key});

  @override
  State<CommonNumbersScreen> createState() => _CommonNumbersScreenState();
}

class _CommonNumbersScreenState extends State<CommonNumbersScreen> {
  String _selectedGame = 'shillong';
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;

  final Map<String, String> _games = {
    'shillong': 'Shillong Teer',
    'khanapara': 'Khanapara Teer',
    'juwai': 'Juwai Teer',
    'shillong-morning': 'Shillong Morning',
    'khanapara-morning': 'Khanapara Morning',
    'juwai-morning': 'Juwai Morning',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if premium
    if (!userProvider.isPremium) {
      return; // Will show premium lock UI
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _data = await ApiService.getCommonNumbers(_selectedGame, userProvider.userId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Common Numbers'),
        backgroundColor: AppTheme.primary,
        actions: [
          if (userProvider.isPremium)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
        ],
      ),
      body: userProvider.isPremium ? _buildPremiumContent() : _buildPremiumLock(),
    );
  }

  Widget _buildPremiumLock() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.numbers,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Common Numbers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'Discover hot and cold numbers based on historical data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Features
            _buildFeatureItem(Icons.trending_up, 'Hot Numbers', 'Most frequently appearing'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.trending_down, 'Cold Numbers', 'Rarely appearing'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.analytics, 'Statistical Analysis', 'Data-driven insights'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.history, 'Historical Trends', 'Past 30 days analysis'),
            const SizedBox(height: 40),

            // Upgrade Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.premiumGold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/subscribe');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.workspace_premium, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            const Text(
              'Just ₹29/month • 50% OFF',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final hotNumbers = _data?['hotNumbers'] as List<dynamic>? ?? [];
    final coldNumbers = _data?['coldNumbers'] as List<dynamic>? ?? [];
    final commonPairs = _data?['commonPairs'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: DropdownButtonFormField<String>(
              value: _selectedGame,
              decoration: InputDecoration(
                labelText: 'Select Game',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
              items: _games.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGame = value!;
                });
                _loadData();
              },
            ),
          ),
          const SizedBox(height: 16),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppTheme.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Analysis based on last 30 days of data',
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Hot Numbers
          _buildNumberSection(
            'Hot Numbers',
            '🔥',
            'Most frequently appeared',
            hotNumbers.isNotEmpty ? hotNumbers.cast<Map<String, dynamic>>() : [],
            AppTheme.error,
          ),
          const SizedBox(height: 20),

          // Cold Numbers
          _buildNumberSection(
            'Cold Numbers',
            '❄️',
            'Rarely appeared',
            coldNumbers.isNotEmpty ? coldNumbers.cast<Map<String, dynamic>>() : [],
            AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSection(
    String title,
    String emoji,
    String subtitle,
    List<Map<String, dynamic>> numbers,
    Color color,
  ) {
    if (numbers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 12),
              const Text(
                'No data available yet',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: numbers.map((item) {
              final number = item['number'] as int;
              final count = item['count'] as int;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      number.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count times',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
