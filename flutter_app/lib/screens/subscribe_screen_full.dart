import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../services/google_play_billing_service.dart';
import '../services/razorpay_service.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../config/app_config.dart';
import '../utils/app_theme.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  PaymentMethod _paymentMethod = AppConfig.paymentMethod;
  GooglePlayBillingService? _billingService;
  RazorpayService? _razorpayService;

  int _selectedPlanIndex = 2; // Yearly pre-selected
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  // Google Play products
  List<ProductDetails> _googlePlayProducts = [];

  // Razorpay plans
  List<Map<String, dynamic>> _razorpayPlans = [];

  // Promo code state
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isValidatingPromo = false;
  Map<String, dynamic>? _appliedPromoCode;
  String? _promoError;

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
  }

  Future<void> _initializePaymentService() async {
    setState(() => _isLoading = true);

    debugPrint('🏪 Initializing ${AppConfig.buildVariant} payment service');

    if (AppConfig.paymentMethod == PaymentMethod.googlePlay) {
      // Play Store Build - Google Play Billing ONLY
      _billingService = GooglePlayBillingService();

      _billingService!.onPurchaseComplete = (success, message) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
        if (success) {
          Provider.of<UserProvider>(context, listen: false).refreshUserStatus();
          _showSuccessDialog(message);
        } else {
          setState(() => _errorMessage = message);
        }
      };

      _billingService!.onError = (error) {
        if (!mounted) return;
        setState(() {
          _isPurchasing = false;
          _errorMessage = error;
        });
      };

      // Wait for products to load
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _googlePlayProducts = _billingService!.getProducts();
        _isLoading = false;
      });

      debugPrint('✅ Google Play Billing initialized with ${_googlePlayProducts.length} products');
    } else {
      // Direct APK Build - Razorpay ONLY
      _razorpayService = RazorpayService();
      _razorpayService!.initialize(context);

      _razorpayService!.onPaymentComplete = (success, message) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
        if (success) {
          Provider.of<UserProvider>(context, listen: false).refreshUserStatus();
          _showSuccessDialog(message);
        } else {
          setState(() => _errorMessage = message);
        }
      };

      _razorpayService!.onError = (error) {
        if (!mounted) return;
        setState(() {
          _isPurchasing = false;
          _errorMessage = error;
        });
      };

      setState(() {
        _razorpayPlans = _razorpayService!.getPlans();
        _isLoading = false;
      });

      debugPrint('✅ Razorpay initialized with ${_razorpayPlans.length} plans');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 32),
            const SizedBox(width: 12),
            const Text('Success!'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close subscription screen
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingPromo = true;
      _promoError = null;
    });

    try {
      final result = await ApiService.validatePromoCode(code);

      if (result['valid'] == true) {
        setState(() {
          _appliedPromoCode = result;
          _promoError = null;
          _isValidatingPromo = false;
        });
      } else {
        setState(() {
          _appliedPromoCode = null;
          _promoError = result['error'] ?? 'Invalid promo code';
          _isValidatingPromo = false;
        });
      }
    } catch (e) {
      setState(() {
        _appliedPromoCode = null;
        _promoError = 'Failed to validate promo code';
        _isValidatingPromo = false;
      });
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _promoError = null;
      _promoCodeController.clear();
    });
  }

  double _calculateDiscountedPrice(double originalPrice) {
    if (_appliedPromoCode == null) return originalPrice;

    final discountPercent = _appliedPromoCode!['discount_percent'] as int;
    final discount = originalPrice * (discountPercent / 100);
    return originalPrice - discount;
  }

  void _handlePurchase() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    if (_paymentMethod == PaymentMethod.googlePlay) {
      // Google Play purchase
      if (_googlePlayProducts.isEmpty) {
        setState(() {
          _isPurchasing = false;
          _errorMessage = 'No products available';
        });
        return;
      }
      final product = _googlePlayProducts[_selectedPlanIndex];
      await _billingService!.purchaseSubscription(product);
    } else if (_paymentMethod == PaymentMethod.razorpay) {
      // Razorpay purchase
      if (_razorpayPlans.isEmpty) {
        setState(() {
          _isPurchasing = false;
          _errorMessage = 'No plans available';
        });
        return;
      }
      final plan = _razorpayPlans[_selectedPlanIndex];

      // Create recurring subscription (auto-renewal enabled)
      await _razorpayService!.createRecurringSubscription(
        plan,
        promoCode: _appliedPromoCode,
      );

      setState(() => _isPurchasing = false); // Razorpay handles its own flow
    }
  }

  @override
  void dispose() {
    _billingService?.dispose();
    _razorpayService?.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                    SizedBox(height: 16),
                    Text('Loading subscription plans...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // Header with close button
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 48), // Balance the close button
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Premium Icon
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.workspace_premium,
                              size: screenWidth * 0.15,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.025),

                          // Title
                          Text(
                            'Upgrade to VIP Premium',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.065,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // Subtitle
                          Text(
                            'Unlock all premium features',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Features
                          _buildFeatures(screenWidth),

                          SizedBox(height: screenHeight * 0.03),

                          // Plans
                          _buildPlans(screenWidth, screenHeight),

                          SizedBox(height: screenHeight * 0.025),

                          // Promo code section (only for Razorpay)
                          if (_paymentMethod == PaymentMethod.razorpay)
                            _buildPromoCodeSection(screenWidth, screenHeight),

                          if (_errorMessage != null) ...[
                            SizedBox(height: screenHeight * 0.02),
                            _buildErrorBanner(screenWidth),
                          ],

                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                  ),

                  // Subscribe button
                  _buildSubscribeButton(screenWidth, screenHeight),
                ],
              ),
      ),
    );
  }

  Widget _buildFeatures(double screenWidth) {
    final features = [
      {'icon': Icons.stars, 'text': 'VIP Lucky Numbers'},
      {'icon': Icons.analytics, 'text': 'AI Hit Numbers Analysis'},
      {'icon': Icons.nightlight_round, 'text': 'AI Dream Teer Number'},
      {'icon': Icons.grid_on, 'text': 'VIP Common Numbers'},
      {'icon': Icons.calculate, 'text': 'VIP Formula Calculator'},
      {'icon': Icons.verified, 'text': 'AI Accuracy Tracking'},
    ];

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primary, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.025),
              Text(
                'What You Get',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          ...features.map((feature) => Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
            child: Row(
              children: [
                Icon(
                  feature['icon'] as IconData,
                  color: AppTheme.primary,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    feature['text'] as String,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPlans(double screenWidth, double screenHeight) {
    final plans = _paymentMethod == PaymentMethod.googlePlay
        ? _googlePlayProducts.map((product) {
            String planName = 'Premium';
            String period = '/month';
            String? savings;

            if (product.id == GooglePlayBillingService.monthlyProductId) {
              planName = 'Monthly';
              period = '/month';
            } else if (product.id == GooglePlayBillingService.quarterlyProductId) {
              planName = '3 Months';
              period = '/3 months';
              savings = 'SAVE 10%';
            } else if (product.id == GooglePlayBillingService.annualProductId) {
              planName = 'Yearly';
              period = '/year';
              savings = 'BEST VALUE';
            }

            return {
              'name': planName,
              'price': product.price,
              'period': period,
              'savings': savings,
            };
          }).toList()
        : _razorpayPlans.map((plan) => {
              'name': plan['name'],
              'price': plan['displayPrice'],
              'period': plan['period'],
              'savings': plan['savings'],
            }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        ...List.generate(plans.length, (index) {
          final plan = plans[index];
          final isSelected = _selectedPlanIndex == index;
          final isPopular = index == 2; // Yearly

          return GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: screenHeight * 0.012),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  width: isSelected ? 0 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Radio indicator
                  Container(
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: screenWidth * 0.03,
                              height: screenWidth * 0.03,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: screenWidth * 0.03),

                  // Plan details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan['name'] as String,
                              style: TextStyle(
                                fontSize: screenWidth * 0.043,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (plan['savings'] != null) ...[
                              SizedBox(width: screenWidth * 0.02),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenWidth * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withOpacity(0.25) : Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  plan['savings'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white,
                                    fontSize: screenWidth * 0.028,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        Text(
                          plan['period'] as String,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    plan['price'] as String,
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPromoCodeSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have a promo code?',
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),

        // Promo code input with apply button
        if (_appliedPromoCode == null) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.025),
              ElevatedButton(
                onPressed: _isValidatingPromo ? null : _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.0165,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isValidatingPromo
                    ? SizedBox(
                        height: screenHeight * 0.02,
                        width: screenHeight * 0.02,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],

        // Applied promo code display
        if (_appliedPromoCode != null) ...[
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Colors.green.shade700, size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.025),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_appliedPromoCode!['code']} Applied',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_appliedPromoCode!['discount_percent']}% discount',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: screenWidth * 0.033,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _removePromoCode,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Price breakdown
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Original Price',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      _razorpayPlans.isNotEmpty ? _razorpayPlans[_selectedPlanIndex]['displayPrice'] : '₹0',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: Colors.grey.shade700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.008),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '-${_appliedPromoCode!['discount_percent']}%',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Divider(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Final Price',
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _razorpayPlans.isNotEmpty
                          ? '₹${(_calculateDiscountedPrice(_razorpayPlans[_selectedPlanIndex]['amount'] / 100)).toStringAsFixed(0)}'
                          : '₹0',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Promo error message
        if (_promoError != null) ...[
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    _promoError!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: screenWidth * 0.033,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorBanner(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(double screenWidth, double screenHeight) {
    String buttonText = 'Subscribe Now';
    if (_paymentMethod == PaymentMethod.googlePlay && _googlePlayProducts.isNotEmpty) {
      buttonText = 'Subscribe - ${_googlePlayProducts[_selectedPlanIndex].price}';
    } else if (_paymentMethod == PaymentMethod.razorpay && _razorpayPlans.isNotEmpty) {
      if (_appliedPromoCode != null) {
        final discountedPrice = _calculateDiscountedPrice(_razorpayPlans[_selectedPlanIndex]['amount'] / 100);
        if (discountedPrice == 0) {
          buttonText = 'Activate Premium - FREE';
        } else {
          buttonText = 'Subscribe - ₹${discountedPrice.toStringAsFixed(0)}';
        }
      } else {
        buttonText = 'Subscribe - ${_razorpayPlans[_selectedPlanIndex]['displayPrice']}';
      }
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.065,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                shadowColor: AppTheme.primary.withOpacity(0.5),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isPurchasing
                  ? SizedBox(
                      height: screenHeight * 0.025,
                      width: screenHeight * 0.025,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Cancel anytime • Secure payment',
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
