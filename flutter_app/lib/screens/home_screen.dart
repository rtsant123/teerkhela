import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/result.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/accuracy_banner_widget.dart';
import '../models/accuracy_stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, TeerResult> _results = {};
  bool _isLoading = true;
  String? _error;
  AccuracyStats? _hitStats;

  @override
  void initState() {
    super.initState();
    _loadResults();
    _loadHitStats();
  }

  Future<void> _loadHitStats() async {
    try {
      final stats = await ApiService.getAccuracyStats(days: 1);
      if (mounted) {
        setState(() {
          _hitStats = stats;
        });
      }
    } catch (e) {
      // Silently fail - hit stats are optional
      print('Could not load hit stats: $e');
    }
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ApiService.getResults();
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Get emoji/icon for each game
  String _getGameIcon(String game) {
    final icons = {
      'shillong': '🎯',
      'khanapara': '🎲',
      'juwai': '🎪',
      'shillong-morning': '🌅',
      'juwai-morning': '🌄',
      'khanapara-morning': '☀️',
    };
    return icons[game] ?? '🎮';
  }

  // Get gradient for each game
  LinearGradient _getGameGradient(String game) {
    final gradients = {
      'shillong': const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'khanapara': const LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFF5576c)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'juwai': const LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'shillong-morning': const LinearGradient(
        colors: [Color(0xFFfa709a), Color(0xFFfee140)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'juwai-morning': const LinearGradient(
        colors: [Color(0xFF30cfd0), Color(0xFF330867)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'khanapara-morning': const LinearGradient(
        colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
    return gradients[game] ?? AppTheme.primaryGradient;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teer Khela'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResults,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildFloatingMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Results History Button
        AnimatedScaleButton(
          onPressed: () {
            Navigator.pushNamed(context, '/hit-numbers');
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/hit-numbers');
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.show_chart, size: 24, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Hit Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Formula Calculator Button with enhanced visibility
        AnimatedScaleButton(
          onPressed: () {
            Navigator.pushNamed(context, '/formula-calculator');
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998e).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/formula-calculator');
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calculate_outlined, size: 24, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Formula',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(Size size) {
    final userProvider = Provider.of<UserProvider>(context);
    final iconSize = size.width * 0.1;
    final horizontalPadding = size.width * 0.04;

    return RefreshIndicator(
      onRefresh: _loadResults,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Premium Banner for Free Users - Simplified
            if (!userProvider.isPremium)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/subscribe'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get predictions, analysis & more',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹49',
                          style: TextStyle(
                            color: const Color(0xFF667eea),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

            // Section Header - Cleaner
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 12),
              child: Row(
                children: [
                  Text(
                    'Today\'s Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Results List - Single Column for Better Visibility
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ShimmerResultCard(size: size),
                    ),
                  ),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.08),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppTheme.space24),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(AppTheme.opacityMedium),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: size.width * 0.12,
                          color: AppTheme.error,
                        ),
                      ),
                      SizedBox(height: AppTheme.space16),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.space8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppTheme.space24),
                      ElevatedButton(
                        onPressed: _loadResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: _results.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildResultCard(entry.value, size),
                    );
                  }).toList(),
                ),
              ),

            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(TeerResult result, Size size) {
    final bool isComplete = result.fr != null && result.sr != null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final displayDate = result.date != null ? dateFormat.format(result.date!) : DateFormat('MMM dd, yyyy').format(DateTime.now());

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/game-history',
          arguments: {'game': result.game, 'displayName': result.displayName},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.015),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.displayName,
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Text(
                        displayDate,
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.025, vertical: size.height * 0.005),
                  decoration: BoxDecoration(
                    color: isComplete ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isComplete ? 'DECLARED' : 'PENDING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.029,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),

            // FR & SR Numbers
            Row(
              children: [
                // FR
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'FR',
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          result.fr?.toString().padLeft(2, '0') ?? '--',
                          style: TextStyle(
                            fontSize: size.width * 0.085,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                // SR
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SR',
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          result.sr?.toString().padLeft(2, '0') ?? '--',
                          style: TextStyle(
                            fontSize: size.width * 0.085,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.015),

            // View History Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: size.width * 0.04, color: Colors.grey.shade700),
                  SizedBox(width: size.width * 0.015),
                  Text(
                    'View Full History',
                    style: TextStyle(
                      fontSize: size.width * 0.034,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: size.width * 0.01),
                  Icon(Icons.arrow_forward_ios, size: size.width * 0.03, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simplified helper methods
  Widget _buildOldResultCard(TeerResult result, Size size) {
    final bool isComplete = result.fr != null && result.sr != null;
    final String statusText = isComplete ? 'DECLARED' : 'PENDING';
    final Color statusColor = isComplete ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final gameIcon = _getGameIcon(result.game);
    final gameGradient = _getGameGradient(result.game);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.space20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/game-history',
              arguments: {'game': result.game, 'displayName': result.displayName},
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.space20),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Game Name + Status Badge
                Row(
                  children: [
                    // Game Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: gameGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: gameGradient.colors.first.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          gameIcon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Game Name & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.displayName,
                            style: AppTheme.heading3,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                result.declaredTime ?? 'Not declared yet',
                                style: TextStyle(
                                  fontSize: size.width * 0.032,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(AppTheme.space20),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Results: FR & SR - Big and Clear
                Container(
                  padding: EdgeInsets.all(AppTheme.space20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // FR
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'FIRST ROUND',
                              style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.frGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                boxShadow: AppTheme.buttonShadow(AppTheme.frColor),
                              ),
                              child: Text(
                                result.fr?.toString().padLeft(2, '0') ?? '--',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppTheme.numberSize(size.width),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(AppTheme.opacityMedium),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // SR
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'SECOND ROUND',
                              style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.srGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                boxShadow: AppTheme.buttonShadow(AppTheme.srColor),
                              ),
                              child: Text(
                                result.sr?.toString().padLeft(2, '0') ?? '--',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppTheme.numberSize(size.width),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(AppTheme.opacityMedium),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // View History Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: gameGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gameGradient.colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/game-history',
                          arguments: {'game': result.game, 'displayName': result.displayName},
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'View Full History',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
