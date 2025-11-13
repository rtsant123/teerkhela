import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/accuracy_stats.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class HitNumbersScreen extends StatefulWidget {
  const HitNumbersScreen({super.key});

  @override
  State<HitNumbersScreen> createState() => _HitNumbersScreenState();
}

class _HitNumbersScreenState extends State<HitNumbersScreen> {
  bool _isLoading = true;
  AccuracyStats? _accuracyStats;
  String? _error;
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _loadHitData();
  }

  Future<void> _loadHitData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await ApiService.getAccuracyStats(days: _selectedDays);
      setState(() {
        _accuracyStats = stats;
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hit Numbers'),
        backgroundColor: AppTheme.primary,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (days) {
              setState(() {
                _selectedDays = days;
              });
              _loadHitData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('Today')),
              const PopupMenuItem(value: 7, child: Text('Last 7 Days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 Days')),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? _buildHitNumbersView(size)
          : _buildPremiumLock(size),
    );
  }

  Widget _buildPremiumLock(Size size) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.2,
              height: size.width * 0.2,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes,
                size: size.width * 0.1,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.space24),
            Text(
              'Hit Numbers Tracker',
              style: AppTheme.heading1.copyWith(
                fontSize: size.width * 0.065,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.space12),
            Text(
              'See which predictions matched actual results',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.037,
              ),
            ),
            SizedBox(height: AppTheme.space32),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
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
                  children: [
                    const Icon(Icons.workspace_premium, size: 20),
                    SizedBox(width: AppTheme.space8),
                    Text(
                      'Unlock Hit Tracker',
                      style: AppTheme.buttonText.copyWith(
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHitNumbersView(Size size) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: size.width * 0.15,
              color: AppTheme.error,
            ),
            SizedBox(height: AppTheme.space16),
            Text(
              'Failed to load data',
              style: AppTheme.heading2,
            ),
            SizedBox(height: AppTheme.space8),
            Text(
              _error!,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: _loadHitData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_accuracyStats == null) {
      return Center(
        child: Text(
          'No data available',
          style: AppTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHitData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Stats Card
            _buildOverallStatsCard(size),
            SizedBox(height: AppTheme.space16),

            // Section Header
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primary,
                  size: size.width * 0.055,
                ),
                SizedBox(width: AppTheme.space8),
                Text(
                  'Recent Predictions',
                  style: AppTheme.heading2.copyWith(
                    fontSize: size.width * 0.05,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.space12),

            // Recent Predictions List
            if (_accuracyStats!.lastPredictions.isEmpty)
              _buildEmptyState(size)
            else
              ..._accuracyStats!.lastPredictions
                  .map((prediction) => _buildPredictionCard(prediction, size))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(Size size) {
    final stats = _accuracyStats!;
    final hitCount = stats.successfulPredictions;
    final totalCount = stats.totalPredictions;
    final accuracy = stats.overallAccuracy;

    return Container(
      padding: EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.buttonShadow(AppTheme.primary),
      ),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              const Icon(
                Icons.track_changes,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: AppTheme.space8),
              Text(
                'Last $_selectedDays ${_selectedDays == 1 ? 'Day' : 'Days'} Performance',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space20),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Accuracy
              _buildStatItem(
                '${accuracy.toStringAsFixed(1)}%',
                'Accuracy',
                Icons.auto_graph,
                size,
              ),
              // Hit Count
              _buildStatItem(
                '$hitCount',
                'Hits',
                Icons.check_circle,
                size,
              ),
              // Total
              _buildStatItem(
                '$totalCount',
                'Total',
                Icons.all_inclusive,
                size,
              ),
            ],
          ),
          SizedBox(height: AppTheme.space16),

          // FR/SR Breakdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'FR Accuracy',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: AppTheme.space4),
                      Text(
                        '${stats.frAccuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SR Accuracy',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: AppTheme.space4),
                      Text(
                        '${stats.srAccuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Size size) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: size.width * 0.08,
        ),
        SizedBox(height: AppTheme.space8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionCard(PredictionResult prediction, Size size) {
    final hasFrResult = prediction.actualFr != null;
    final hasSrResult = prediction.actualSr != null;
    final frHit = hasFrResult && prediction.predictedFr.contains(prediction.actualFr);
    final srHit = hasSrResult && prediction.predictedSr.contains(prediction.actualSr);
    final isHit = frHit || srHit;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.space12),
      padding: EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isHit
              ? AppTheme.success
              : AppTheme.textSecondary.withOpacity(0.2),
          width: isHit ? 2 : 1,
        ),
        boxShadow: isHit
            ? [
                BoxShadow(
                  color: AppTheme.success.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
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
                      prediction.displayName,
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.space4),
                    Text(
                      prediction.formattedDate,
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.032,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isHit)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: AppTheme.space4),
                      const Text(
                        'HIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTheme.space16),

          // FR Numbers
          _buildNumberSection(
            'FR',
            prediction.predictedFr,
            prediction.actualFr,
            frHit,
            size,
          ),
          SizedBox(height: AppTheme.space12),

          // SR Numbers
          _buildNumberSection(
            'SR',
            prediction.predictedSr,
            prediction.actualSr,
            srHit,
            size,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSection(
    String label,
    List<int> predictedNumbers,
    int? actualNumber,
    bool isHit,
    Size size,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label Predicted:',
              style: AppTheme.subtitle1.copyWith(
                fontSize: size.width * 0.035,
                color: AppTheme.textSecondary,
              ),
            ),
            if (actualNumber != null) ...[
              SizedBox(width: AppTheme.space8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.space8,
                  vertical: AppTheme.space4,
                ),
                decoration: BoxDecoration(
                  color: isHit
                      ? AppTheme.success.withOpacity(0.2)
                      : AppTheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: isHit ? AppTheme.success : AppTheme.error,
                  ),
                ),
                child: Text(
                  'Result: ${actualNumber.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isHit ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.03,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: AppTheme.space8),
        Wrap(
          spacing: AppTheme.space8,
          runSpacing: AppTheme.space8,
          children: predictedNumbers.map((num) {
            final isMatch = actualNumber != null && num == actualNumber;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.width * 0.015,
              ),
              decoration: BoxDecoration(
                color: isMatch
                    ? AppTheme.success
                    : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: isMatch
                      ? AppTheme.success
                      : AppTheme.primary.withOpacity(0.3),
                  width: isMatch ? 2 : 1,
                ),
                boxShadow: isMatch
                    ? [
                        BoxShadow(
                          color: AppTheme.success.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                num.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isMatch ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isMatch ? FontWeight.bold : FontWeight.w600,
                  fontSize: size.width * 0.035,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Size size) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space32),
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: size.width * 0.15,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.space16),
          Text(
            'No predictions yet',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.space8),
          Text(
            'Check back after predictions are made',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
