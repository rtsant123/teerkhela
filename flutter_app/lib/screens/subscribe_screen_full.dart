import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/user_provider.dart';
import '../services/google_play_billing_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  GooglePlayBillingService? _billingService;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _initializeBilling();
  }

  @override
  void dispose() {
    _billingService?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeBilling() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _billingService = GooglePlayBillingService();

      // Set callbacks
      _billingService!.onPurchaseComplete = (success, message) {
        if (!mounted) return;

        if (success) {
          // Refresh user status
          Provider.of<UserProvider>(context, listen: false).refreshUserStatus();

          // Show success dialog
          _showSuccessDialog(message);
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      };

      _billingService!.onError = (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.error,
          ),
        );
      };

      // Wait for billing service to initialize
      await Future.delayed(const Duration(seconds: 2));

      if (!_billingService!.isAvailable()) {
        throw Exception('Google Play Store not available on this device');
      }

      final products = _billingService!.getProducts();

      if (products.isEmpty) {
        throw Exception('No subscription products found. Please create subscriptions in Play Console first.');
      }

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to VIP Premium!',
                style: AppTheme.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.buttonShadow(AppTheme.premiumPurple),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Start Using Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Future<void> _handleSubscribe(ProductDetails product) async {
    if (_billingService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Billing service not initialized')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing purchase...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Wait a moment for dialog to show
    await Future.delayed(const Duration(milliseconds: 300));

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    // Start purchase
    await _billingService!.purchaseSubscription(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Upgrade to VIP Premium'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore Purchases',
            onPressed: () async {
              if (_billingService != null) {
                await _billingService!.restorePurchases();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checking for previous purchases...')),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 5),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Premium Plans...',
            style: AppTheme.subtitle1.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Connecting to Google Play Store',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load Plans',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unable to fetch subscription packages.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeBilling,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: 16,
          ),
          child: Column(
            children: [
              _buildHeroSection(size),
              const SizedBox(height: 24),
              _buildBenefitsSection(size),
              const SizedBox(height: 32),
              _buildPlansSection(size),
              const SizedBox(height: 24),
              _buildTrustIndicators(size),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9333EA),
            Color(0xFFC026D3),
            Color(0xFFD946EF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.premiumPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Upgrade to VIP Premium',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Unlock AI-Powered Teer Predictions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(Size size) {
    final benefits = [
      {
        'icon': Icons.auto_awesome,
        'title': 'AI-Powered Predictions for all 6 games',
        'color': AppTheme.primary,
      },
      {
        'icon': Icons.nights_stay,
        'title': 'Dream Dictionary Bot (100+ symbols)',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.trending_up,
        'title': 'Today\'s Top 7 Common Numbers',
        'color': AppTheme.secondary,
      },
      {
        'icon': Icons.stars,
        'title': 'Lucky VIP Numbers',
        'color': AppTheme.premiumGold,
      },
      {
        'icon': Icons.calculate,
        'title': 'Formula Calculator & Hit Analysis',
        'color': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Priority Support',
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': Icons.block,
        'title': 'Ad-Free Experience',
        'color': AppTheme.error,
      },
      {
        'icon': Icons.insights,
        'title': 'Exclusive FOMO Insights',
        'color': const Color(0xFFF97316),
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Premium Benefits',
                style: AppTheme.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...benefits.map((benefit) => _buildBenefitItem(
                benefit['icon'] as IconData,
                benefit['title'] as String,
                benefit['color'] as Color,
                size,
              )),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, Color color, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppTheme.success,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Plan',
                style: AppTheme.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Billed through Google Play Store',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ..._products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return _buildPlanCard(product, index, size);
        }),
      ],
    );
  }

  Widget _buildPlanCard(ProductDetails product, int index, Size size) {
    final isPopular = index == 1; // Middle plan is popular

    // Get price
    final price = product.price;
    final priceNum = double.tryParse(product.rawPrice.toString()) ?? 0;

    // Determine savings
    int savePercentage = 0;
    if (product.id == GooglePlayBillingService.quarterlyProductId) {
      savePercentage = 12;
    } else if (product.id == GooglePlayBillingService.annualProductId) {
      savePercentage = 15;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isPopular ? AppTheme.premiumPurple : Colors.transparent,
          width: isPopular ? 2 : 0,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppTheme.premiumPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            gradient: isPopular
                ? LinearGradient(
                    colors: [
                      AppTheme.premiumPurple.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title.replaceAll(' (Teer Khela)', ''),
                          style: AppTheme.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isPopular || savePercentage > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isPopular
                            ? AppTheme.premiumGradient
                            : AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isPopular ? AppTheme.premiumPurple : AppTheme.premiumGold)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isPopular ? 'MOST POPULAR' : 'SAVE $savePercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isPopular
                      ? AppTheme.premiumGradient
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.buttonShadow(
                    isPopular ? AppTheme.premiumPurple : AppTheme.primary,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Subscribe Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildTrustIndicators(Size size) {
    final indicators = [
      {
        'icon': Icons.security,
        'text': '100% Secure Payment via Google',
      },
      {
        'icon': Icons.autorenew,
        'text': 'Auto-renewal (manage in Play Store)',
      },
      {
        'icon': Icons.flash_on,
        'text': 'Instant Activation',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: indicators.asMap().entries.map((entry) {
          final index = entry.key;
          final indicator = entry.value;
          final isLast = index == indicators.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    indicator['icon'] as IconData,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    indicator['text'] as String,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
