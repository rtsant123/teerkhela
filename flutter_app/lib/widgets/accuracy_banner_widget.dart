import 'package:flutter/material.dart';
import '../models/accuracy_stats.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class AccuracyBannerWidget extends StatefulWidget {
  const AccuracyBannerWidget({super.key});

  @override
  State<AccuracyBannerWidget> createState() => _AccuracyBannerWidgetState();
}

class _AccuracyBannerWidgetState extends State<AccuracyBannerWidget> {
  AccuracyStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ApiService.getAccuracyStats(days: 30);
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDetailedStats(BuildContext context, Size size) {
    if (_stats == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: size.height * 0.7,
            ),
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Accuracy Stats',
                      style: AppTheme.heading2,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.space16),

                // Overall Accuracy
                Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _stats!.accuracyColor,
                        _stats!.accuracyColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: AppTheme.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Accuracy',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${_stats!.overallAccuracy.toStringAsFixed(0)}%',
                            style: AppTheme.heading1.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.space16),

                // FR/SR Accuracy
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'FR Accuracy',
                        '${_stats!.frAccuracy.toStringAsFixed(0)}%',
                        AppTheme.frColor,
                        size,
                      ),
                    ),
                    SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: _buildStatCard(
                        'SR Accuracy',
                        '${_stats!.srAccuracy.toStringAsFixed(0)}%',
                        AppTheme.srColor,
                        size,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.space16),

                // Last 10 Predictions
                Text(
                  'Last 10 Predictions',
                  style: AppTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.space12),

                Flexible(
                  child: _stats!.lastPredictions.isEmpty
                      ? Center(
                          child: Text(
                            'No predictions yet',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _stats!.lastPredictions.length > 10
                              ? 10
                              : _stats!.lastPredictions.length,
                          itemBuilder: (context, index) {
                            final prediction = _stats!.lastPredictions[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: AppTheme.space8),
                              padding: EdgeInsets.all(size.width * 0.03),
                              decoration: BoxDecoration(
                                color: prediction.isHit
                                    ? AppTheme.success.withOpacity(0.05)
                                    : AppTheme.error.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall,
                                ),
                                border: Border.all(
                                  color: prediction.isHit
                                      ? AppTheme.success.withOpacity(0.2)
                                      : AppTheme.error.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    prediction.isHit
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: prediction.isHit
                                        ? AppTheme.success
                                        : AppTheme.error,
                                    size: 20,
                                  ),
                                  SizedBox(width: AppTheme.space8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prediction.displayName,
                                          style: AppTheme.bodySmall.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          prediction.formattedDate,
                                          style: AppTheme.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: AppTheme.space16),

                // Best Performing Game
                if (_stats!.bestPerformingGame != null) ...[
                  Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: AppTheme.space8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best Performing',
                                style: AppTheme.caption,
                              ),
                              Text(
                                _getDisplayName(_stats!.bestPerformingGame!),
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.space16),
                ],

                // View Full Stats Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/accuracy-stats');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.space12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'View Full Stats',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppTheme.space8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.space4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.04;

    if (_isLoading || _stats == null) {
      return const SizedBox.shrink();
    }

    final accuracy = _stats!.overallAccuracy;
    final color = _stats!.accuracyColor;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: horizontalPadding / 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.buttonShadow(color),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailedStats(context, size),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Row(
              children: [
                // Target Icon
                Container(
                  padding: EdgeInsets.all(size.width * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '🎯',
                    style: TextStyle(fontSize: size.width * 0.08),
                  ),
                ),
                SizedBox(width: AppTheme.space12),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Accuracy: ${accuracy.toStringAsFixed(0)}%',
                        style: AppTheme.subtitle1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      SizedBox(height: AppTheme.space4),
                      // Progress Bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: accuracy / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.space4),
                      Text(
                        'Tap to view detailed stats',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white70,
                          fontSize: size.width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: size.width * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
