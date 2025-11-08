import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/result.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, TeerResult> _results = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
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
      floatingActionButton: _buildFloatingMenu(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingMenu(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI Predictions Button
        FloatingActionButton.extended(
          heroTag: 'predictions',
          onPressed: () {
            Navigator.pushNamed(context, '/predictions');
          },
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.psychology_outlined, size: 20),
          label: Text(
            'AI Predictions',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: AppTheme.space8),

        // Formula Calculator Button
        FloatingActionButton.extended(
          heroTag: 'formula',
          onPressed: () {
            Navigator.pushNamed(context, '/formula-calculator');
          },
          backgroundColor: AppTheme.secondary,
          icon: const Icon(Icons.calculate_outlined, size: 20),
          label: Text(
            'Formula',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
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
            // Premium Banner for Free Users - Responsive
            if (!userProvider.isPremium)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                margin: EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: iconSize,
                    ),
                    SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unlock Premium',
                            style: AppTheme.heading3.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.045,
                            ),
                          ),
                          SizedBox(height: AppTheme.space4),
                          Text(
                            'AI Predictions • Dream AI • 30 Days History',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white70,
                              fontSize: size.width * 0.03,
                            ),
                          ),
                          SizedBox(height: AppTheme.space4),
                          Text(
                            '50% OFF - Just ₹49/month',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/subscribe');
                        },
                        icon: Icon(
                          Icons.arrow_forward,
                          color: AppTheme.premiumPurple,
                          size: iconSize * 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Results Grid - Responsive
            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.08),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.08),
                  child: Column(
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
                        onPressed: _loadResults,
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
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid: 2 columns for narrow, 3 for wide
                  final crossAxisCount = size.width > 600 ? 3 : 2;
                  final spacing = size.width * 0.04;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(spacing),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final game = _results.keys.elementAt(index);
                      final result = _results[game]!;
                      return _buildResultCard(result, size);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(TeerResult result, Size size) {
    final cardPadding = size.width * 0.035;
    final labelFontSize = size.width * 0.028;
    final numberFontSize = size.width * 0.06;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Game Name - Responsive
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: size.width * 0.045,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: AppTheme.space8),
                    Expanded(
                      child: Text(
                        result.displayName,
                        style: AppTheme.subtitle1.copyWith(
                          fontSize: size.width * 0.036,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // FR & SR in Row - Responsive
                Row(
                  children: [
                    // FR Box
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: size.width * 0.025,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.frColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'FR',
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: labelFontSize,
                                color: AppTheme.frColor.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppTheme.space4),
                            Text(
                              result.fr?.toString() ?? '--',
                              style: TextStyle(
                                fontSize: numberFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.frColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.space8),
                    // SR Box
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: size.width * 0.025,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.srColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SR',
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: labelFontSize,
                                color: AppTheme.srColor.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppTheme.space4),
                            Text(
                              result.sr?.toString() ?? '--',
                              style: TextStyle(
                                fontSize: numberFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.srColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // View History Button - Responsive
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: size.width * 0.08,
                    maxHeight: size.width * 0.1,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/game-history',
                        arguments: {'game': result.game, 'displayName': result.displayName},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: size.width * 0.035,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppTheme.space4),
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
