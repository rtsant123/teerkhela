import 'package:flutter/material.dart';
import '../models/accuracy_stats.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class AccuracyStatsScreen extends StatefulWidget {
  const AccuracyStatsScreen({super.key});

  @override
  State<AccuracyStatsScreen> createState() => _AccuracyStatsScreenState();
}

class _AccuracyStatsScreenState extends State<AccuracyStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AccuracyStats? _overallStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await ApiService.getAccuracyStats(days: 30);
      setState(() {
        _overallStats = stats;
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Accuracy Stats'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Overall'),
            Tab(text: 'By Game'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : _error != null
              ? _buildError(size)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverallTab(size),
                    _buildByGameTab(size),
                  ],
                ),
    );
  }

  Widget _buildError(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
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
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.space24,
                  vertical: AppTheme.space12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallTab(Size size) {
    if (_overallStats == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Accuracy Circle
            _buildAccuracyCircle(size),
            SizedBox(height: AppTheme.space24),

            // FR/SR Split
            _buildFrSrSplit(size),
            SizedBox(height: AppTheme.space24),

            // Stats Summary
            _buildStatsSummary(size),
            SizedBox(height: AppTheme.space24),

            // Last 10 Predictions
            _buildLastPredictions(size),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyCircle(Size size) {
    if (_overallStats == null) return const SizedBox.shrink();

    final accuracy = _overallStats!.overallAccuracy;
    final color = _overallStats!.accuracyColor;

    return Container(
      padding: EdgeInsets.all(size.width * 0.06),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: size.width * 0.45,
            height: size.width * 0.45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.45,
                  height: size.width * 0.45,
                  child: CircularProgressIndicator(
                    value: accuracy / 100,
                    strokeWidth: size.width * 0.025,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.space16),
          Text(
            _overallStats!.bestPerformingGame != null
                ? 'Best: ${_getDisplayName(_overallStats!.bestPerformingGame!)}'
                : 'Keep predicting!',
            style: AppTheme.subtitle1.copyWith(
              color: AppTheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFrSrSplit(Size size) {
    if (_overallStats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: AppTheme.frColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.frColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.looks_one_rounded,
                  size: size.width * 0.08,
                  color: AppTheme.frColor,
                ),
                SizedBox(height: AppTheme.space8),
                Text(
                  '${_overallStats!.frAccuracy.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.frColor,
                  ),
                ),
                Text(
                  'FR Accuracy',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.frColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppTheme.space16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: AppTheme.srColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.srColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.looks_two_rounded,
                  size: size.width * 0.08,
                  color: AppTheme.srColor,
                ),
                SizedBox(height: AppTheme.space8),
                Text(
                  '${_overallStats!.srAccuracy.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.srColor,
                  ),
                ),
                Text(
                  'SR Accuracy',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.srColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(Size size) {
    if (_overallStats == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary (Last 30 Days)',
            style: AppTheme.heading3,
          ),
          SizedBox(height: AppTheme.space16),
          _buildStatRow(
            icon: Icons.analytics_outlined,
            label: 'Total Predictions',
            value: '${_overallStats!.totalPredictions}',
            color: AppTheme.primary,
          ),
          SizedBox(height: AppTheme.space12),
          _buildStatRow(
            icon: Icons.check_circle_outline,
            label: 'Successful Hits',
            value: '${_overallStats!.successfulPredictions}',
            color: AppTheme.success,
          ),
          SizedBox(height: AppTheme.space12),
          _buildStatRow(
            icon: Icons.trending_up,
            label: 'Success Rate',
            value: '${_overallStats!.overallAccuracy.toStringAsFixed(1)}%',
            color: _overallStats!.accuracyColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: AppTheme.space12),
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTheme.subtitle1.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLastPredictions(Size size) {
    if (_overallStats == null || _overallStats!.lastPredictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Predictions',
          style: AppTheme.heading3,
        ),
        SizedBox(height: AppTheme.space12),
        ...(_overallStats!.lastPredictions.take(10).map(
          (prediction) => _buildPredictionCard(prediction, size),
        )),
      ],
    );
  }

  Widget _buildPredictionCard(PredictionResult prediction, Size size) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.space12),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: prediction.isHit
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.error.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.displayName,
                      style: AppTheme.subtitle1,
                    ),
                    SizedBox(height: AppTheme.space4),
                    Text(
                      prediction.formattedDate,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: prediction.isHit
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  prediction.isHit ? Icons.check : Icons.close,
                  color: prediction.isHit ? AppTheme.success : AppTheme.error,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predicted',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    SizedBox(height: AppTheme.space4),
                    Row(
                      children: [
                        _buildNumberChip(
                          'FR',
                          prediction.predictedFr.join(', '),
                          AppTheme.frColor,
                        ),
                        SizedBox(width: AppTheme.space8),
                        _buildNumberChip(
                          'SR',
                          prediction.predictedSr.join(', '),
                          AppTheme.srColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (prediction.actualFr != null && prediction.actualSr != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actual',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      SizedBox(height: AppTheme.space4),
                      Row(
                        children: [
                          _buildNumberChip(
                            'FR',
                            '${prediction.actualFr}',
                            AppTheme.frColor,
                          ),
                          SizedBox(width: AppTheme.space8),
                          _buildNumberChip(
                            'SR',
                            '${prediction.actualSr}',
                            AppTheme.srColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        '$label: $value',
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildByGameTab(Size size) {
    if (_overallStats == null || _overallStats!.gameStats == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.08),
          child: Text(
            'No game-specific stats available',
            style: AppTheme.bodyMedium,
          ),
        ),
      );
    }

    final gameStats = _overallStats!.gameStats!.values.toList();

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(size.width * 0.04),
        itemCount: gameStats.length,
        itemBuilder: (context, index) {
          final stats = gameStats[index];
          return _buildGameCard(stats, size);
        },
      ),
    );
  }

  Widget _buildGameCard(GameAccuracy stats, Size size) {
    final color = _getAccuracyColor(stats.accuracy);

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.space16),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stats.displayName,
                  style: AppTheme.heading3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  '${stats.accuracy.toStringAsFixed(0)}%',
                  style: AppTheme.subtitle1.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space16),
          Row(
            children: [
              Expanded(
                child: _buildGameStatBox(
                  'FR',
                  '${stats.frAccuracy.toStringAsFixed(0)}%',
                  AppTheme.frColor,
                ),
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildGameStatBox(
                  'SR',
                  '${stats.srAccuracy.toStringAsFixed(0)}%',
                  AppTheme.srColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${stats.totalPredictions}',
                    style: AppTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    '${stats.successfulPredictions}',
                    style: AppTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
                    ),
                  ),
                  Text(
                    'Hits',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppTheme.space4),
          Text(
            value,
            style: AppTheme.subtitle1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 70) {
      return AppTheme.success;
    } else if (accuracy >= 60) {
      return AppTheme.info;
    } else {
      return AppTheme.warning;
    }
  }

  String _getDisplayName(String game) {
    final names = {
      'shillong': 'Shillong Teer',
      'khanapara': 'Khanapara Teer',
      'juwai': 'Juwai Teer',
      'shillong-morning': 'Shillong Morning',
      'juwai-morning': 'Juwai Morning',
      'khanapara-morning': 'Khanapara Morning',
    };
    return names[game] ?? game;
  }
}
