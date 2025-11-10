import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/predictions_provider.dart';
import '../models/prediction.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shimmer_widgets.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadPredictions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadPredictions();
  }

  void _checkAndLoadPredictions() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final predictionsProvider = Provider.of<PredictionsProvider>(context, listen: false);

    if (userProvider.isPremium && userProvider.userId != null && !predictionsProvider.isLoading) {
      _loadPredictions();
    }
  }

  Future<void> _loadPredictions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final predictionsProvider = Provider.of<PredictionsProvider>(context, listen: false);

    if (userProvider.isPremium && userProvider.userId != null) {
      await predictionsProvider.loadPredictions(userProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hot Numbers'),
        backgroundColor: AppTheme.primary,
        actions: [
          if (userProvider.isPremium)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPredictions,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? _buildPredictionsView(size)
          : _buildPremiumGate(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPremiumGate(Size size) {
    final iconSize = size.width * 0.2;
    final horizontalPadding = size.width * 0.05;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppTheme.space24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: const BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  size: iconSize * 0.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppTheme.space16),
              Text(
                'Hot Numbers',
                style: AppTheme.heading1.copyWith(
                  fontSize: size.width * 0.065,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.space8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Text(
                  'See hot numbers based on 30 days of real results data',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: size.width * 0.037,
                  ),
                ),
              ),
              SizedBox(height: AppTheme.space16),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.space24,
                      vertical: AppTheme.space16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Upgrade to Premium - ₹49/month',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: size.width * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionsView(Size size) {
    return Consumer<PredictionsProvider>(
      builder: (context, predictionsProvider, child) {
        if (predictionsProvider.isLoading) {
          return ListView.builder(
            padding: EdgeInsets.all(size.width * 0.04),
            itemCount: 4, // Show 4 shimmer cards
            itemBuilder: (context, index) {
              return ShimmerPredictionCard(size: size);
            },
          );
        }

        if (predictionsProvider.error != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: size.width * 0.16,
                    color: AppTheme.error,
                  ),
                  SizedBox(height: AppTheme.space16),
                  Text(
                    predictionsProvider.error!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium,
                  ),
                  SizedBox(height: AppTheme.space16),
                  ElevatedButton(
                    onPressed: _loadPredictions,
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

        if (!predictionsProvider.hasPredictions) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: size.width * 0.16,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: AppTheme.space16),
                  Text(
                    'Predictions not yet available',
                    style: AppTheme.heading3.copyWith(
                      fontSize: size.width * 0.045,
                    ),
                  ),
                  SizedBox(height: AppTheme.space8),
                  Text(
                    'AI predictions are generated daily at 6 AM',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTheme.space16),
                  ElevatedButton(
                    onPressed: _loadPredictions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                    child: const Text('Check Again'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadPredictions,
          color: AppTheme.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(size.width * 0.04),
            itemCount: predictionsProvider.predictions.length,
            itemBuilder: (context, index) {
              final game = predictionsProvider.predictions.keys.elementAt(index);
              final prediction = predictionsProvider.predictions[game]!;
              return _buildPredictionCard(prediction, size);
            },
          ),
        );
      },
    );
  }

  Widget _buildPredictionCard(Prediction prediction, Size size) {
    final cardPadding = size.width * 0.04;

    return Container(
      margin: EdgeInsets.only(bottom: size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.elevatedShadow,
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    prediction.displayName,
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                _buildConfidenceBadge(prediction.confidence, size),
              ],
            ),
            SizedBox(height: AppTheme.space16),

            // FR Predictions
            Text(
              'First Round (FR) Predictions',
              style: AppTheme.subtitle1.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.space12),
            _buildNumberGrid(prediction.fr, size),
            SizedBox(height: AppTheme.space20),

            // SR Predictions
            Text(
              'Second Round (SR) Predictions',
              style: AppTheme.subtitle1.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.space12),
            _buildNumberGrid(prediction.sr, size),
            SizedBox(height: AppTheme.space16),

            // Analysis
            Container(
              padding: EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: size.width * 0.04,
                        color: AppTheme.accent,
                      ),
                      SizedBox(width: AppTheme.space8),
                      Text(
                        'AI Analysis',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.space8),
                  Text(
                    prediction.analysis,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberGrid(List<int> numbers, Size size) {
    // Display 10 numbers in 2 rows of 5 using GridView
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: AppTheme.space8,
        mainAxisSpacing: AppTheme.space8,
        childAspectRatio: 1.0,
      ),
      itemCount: numbers.length,
      itemBuilder: (context, index) {
        return _buildNumberChip(numbers[index], size);
      },
    );
  }

  Widget _buildNumberChip(int number, Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.numberGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toString().padLeft(2, '0'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppTheme.numberSize(size.width),
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(int confidence, Size size) {
    Color color;
    if (confidence >= 90) {
      color = AppTheme.success;
    } else if (confidence >= 80) {
      color = AppTheme.info;
    } else if (confidence >= 70) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.width * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: size.width * 0.035, color: color),
          SizedBox(width: AppTheme.space4),
          Text(
            '$confidence%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.03,
            ),
          ),
        ],
      ),
    );
  }
}
