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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadData();
  }

  void _checkAndLoadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isPremium && _data == null && !_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isPremium) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _data = await ApiService.getCommonNumbers(_selectedGame, userProvider.userId);
      if (mounted) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

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
      body: userProvider.isPremium
          ? _buildPremiumContent(size)
          : _buildPremiumLock(size),
    );
  }

  Widget _buildPremiumLock(Size size) {
    final iconSize = size.width * 0.22;
    final horizontalPadding = size.width * 0.05;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppTheme.space16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.05),

            // Premium Icon - Responsive
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.numbers,
                size: iconSize * 0.5,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Title - Responsive
            Text(
              'Common Numbers',
              style: AppTheme.heading1.copyWith(
                fontSize: size.width * 0.065,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.space8),

            // Description - Responsive
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Text(
                'Discover hot and cold numbers based on historical data',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Features - Compact and Responsive
            _buildFeatureItem(
              Icons.trending_up,
              'Hot Numbers',
              'Most frequently appearing',
              size,
            ),
            SizedBox(height: AppTheme.space12),
            _buildFeatureItem(
              Icons.trending_down,
              'Cold Numbers',
              'Rarely appearing',
              size,
            ),
            SizedBox(height: AppTheme.space12),
            _buildFeatureItem(
              Icons.analytics,
              'Statistical Analysis',
              'Data-driven insights',
              size,
            ),
            SizedBox(height: AppTheme.space12),
            _buildFeatureItem(
              Icons.history,
              'Historical Trends',
              'Past 30 days analysis',
              size,
            ),
            SizedBox(height: AppTheme.space32),

            // Upgrade Button - Responsive
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 400,
                minHeight: 48,
                maxHeight: 56,
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.space16,
                    vertical: AppTheme.space12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium, size: 20),
                    SizedBox(width: AppTheme.space8),
                    Text(
                      'Upgrade to Premium',
                      style: AppTheme.buttonText.copyWith(
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.space12),

            // Price - Responsive
            Text(
              'Just ₹49/month • 50% OFF',
              style: AppTheme.bodySmall.copyWith(
                fontSize: size.width * 0.033,
              ),
            ),
            SizedBox(height: size.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
    Size size,
  ) {
    final iconContainerSize = size.width * 0.11;
    final iconSize = iconContainerSize * 0.5;

    return Container(
      padding: EdgeInsets.all(AppTheme.space12),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: iconSize,
            ),
          ),
          SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.subtitle1.copyWith(
                    fontSize: size.width * 0.038,
                  ),
                ),
                SizedBox(height: AppTheme.space4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: size.width * 0.032,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContent(Size size) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: size.width * 0.12,
                color: AppTheme.error,
              ),
              SizedBox(height: AppTheme.space16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium,
              ),
              SizedBox(height: AppTheme.space16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.space24,
                    vertical: AppTheme.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final hotNumbers = _data?['hotNumbers'] as List<dynamic>? ?? [];
    final coldNumbers = _data?['coldNumbers'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Selector - Compact
          Container(
            padding: EdgeInsets.all(AppTheme.space12),
            decoration: AppTheme.cardDecoration,
            child: DropdownButtonFormField<String>(
              value: _selectedGame,
              decoration: InputDecoration(
                labelText: 'Select Game',
                labelStyle: AppTheme.bodyMedium,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
              items: _games.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: AppTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGame = value;
                  });
                  _loadData();
                }
              },
            ),
          ),
          SizedBox(height: AppTheme.space12),

          // Info Card - Compact
          Container(
            padding: EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 18,
                ),
                SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Text(
                    'Analysis based on last 30 days of data',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.space16),

          // Hot Numbers
          _buildNumberSection(
            'Hot Numbers',
            '🔥',
            'Most frequently appeared',
            hotNumbers.isNotEmpty
                ? hotNumbers.cast<Map<String, dynamic>>()
                : [],
            AppTheme.error,
            size,
          ),
          SizedBox(height: AppTheme.space16),

          // Cold Numbers
          _buildNumberSection(
            'Cold Numbers',
            '❄️',
            'Rarely appeared',
            coldNumbers.isNotEmpty
                ? coldNumbers.cast<Map<String, dynamic>>()
                : [],
            AppTheme.primary,
            size,
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
    Size size,
  ) {
    if (numbers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppTheme.space20),
        decoration: AppTheme.cardDecoration,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox,
                size: size.width * 0.12,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: AppTheme.space8),
              Text(
                'No data available yet',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppTheme.space12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: size.width * 0.065),
              ),
              SizedBox(width: AppTheme.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.heading3.copyWith(
                        fontSize: size.width * 0.042,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate optimal number chip size based on screen width
              final availableWidth = constraints.maxWidth;
              final spacing = AppTheme.space8;
              final chipsPerRow = (availableWidth / 70).floor().clamp(3, 6);
              final chipWidth = (availableWidth - (spacing * (chipsPerRow - 1))) / chipsPerRow;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: numbers.map((item) {
                  final number = item['number'] as int;
                  final count = item['count'] as int;
                  return Container(
                    width: chipWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.space8,
                      vertical: AppTheme.space8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      border: Border.all(color: color, width: 1.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          number.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(height: AppTheme.space4),
                        Text(
                          '$count×',
                          style: TextStyle(
                            fontSize: size.width * 0.027,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
