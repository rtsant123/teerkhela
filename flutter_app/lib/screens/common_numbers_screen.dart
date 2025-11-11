import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class CommonNumbersScreen extends StatefulWidget {
  const CommonNumbersScreen({super.key});

  @override
  State<CommonNumbersScreen> createState() => _CommonNumbersScreenState();
}

class _CommonNumbersScreenState extends State<CommonNumbersScreen> {
  String _selectedGame = 'shillong';
  List<int> _commonNumbers = [];
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
      _loadData();
    });
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
      // Get today's common numbers (7 numbers)
      final commonNumbersData = await ApiService.getCommonNumbers(_selectedGame, userProvider.userId);
      if (mounted) {
        setState(() {
          _commonNumbers = (commonNumbersData['numbers'] as List<dynamic>?)
              ?.map((n) => n as int)
              .take(7)
              .toList() ?? [];
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
        title: const Text('Common Numbers Today'),
        backgroundColor: AppTheme.primary,
        actions: [
          if (userProvider.isPremium)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? _buildContent(size)
          : _buildPremiumLock(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildContent(Size size) {
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
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game Selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGame,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                items: _games.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGame = value);
                    _loadData();
                  }
                },
              ),
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Info Card
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.premiumPurple.withOpacity(0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 24),
                SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Top 7 Common Numbers',
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Based on AI analysis and historical patterns',
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Common Numbers Grid
          if (_commonNumbers.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  children: [
                    Icon(
                      Icons.grid_3x3_rounded,
                      size: size.width * 0.2,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: AppTheme.space16),
                    Text(
                      'No common numbers available yet.\nCheck back later!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: size.width * 0.03,
              runSpacing: size.width * 0.03,
              alignment: WrapAlignment.center,
              children: List.generate(7, (index) {
                if (index < _commonNumbers.length) {
                  return _buildNumberCard(_commonNumbers[index], index, size);
                } else {
                  return _buildEmptyCard(size);
                }
              }),
            ),

          SizedBox(height: size.height * 0.04),

          // Legend
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber.shade700),
                    SizedBox(width: AppTheme.space8),
                    Text(
                      'How to use:',
                      style: TextStyle(
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.space8),
                Text(
                  '• These 7 numbers have the highest probability for today',
                  style: TextStyle(fontSize: size.width * 0.032, color: AppTheme.textSecondary),
                ),
                Text(
                  '• Updated daily based on AI predictions',
                  style: TextStyle(fontSize: size.width * 0.032, color: AppTheme.textSecondary),
                ),
                Text(
                  '• Use these numbers for better winning chances',
                  style: TextStyle(fontSize: size.width * 0.032, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(int number, int rank, Size size) {
    final isTopThree = rank < 3;
    final gradient = isTopThree
        ? LinearGradient(
            colors: [AppTheme.primary, AppTheme.premiumPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.grey.shade600, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      width: (size.width - size.width * 0.08 - size.width * 0.06) / 3,
      height: size.width * 0.25,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isTopThree ? AppTheme.primary : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Rank Badge
          if (isTopThree)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${rank + 1}',
                  style: TextStyle(
                    fontSize: size.width * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Number
          Center(
            child: Text(
              number.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: size.width * 0.12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(Size size) {
    return Container(
      width: (size.width - size.width * 0.08 - size.width * 0.06) / 3,
      height: size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          '--',
          style: TextStyle(
            fontSize: size.width * 0.12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLock(Size size) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: size.width * 0.25,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                'Premium Feature',
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Upgrade to Premium to access today\'s top 7 common numbers with highest winning probability',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.04),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/subscribe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
