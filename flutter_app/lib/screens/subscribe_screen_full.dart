import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  late Razorpay _razorpay;
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Razorpay Production Keys
  static const String razorpayKeyId = 'rzp_test_RcNQd80r82gwlm'; // TODO: Replace with live key
  static const String planId = 'plan_PUmwDBdxGxFw5h'; // Monthly subscription plan
  static const bool testMode = false; // Production mode - real Razorpay payments

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Pre-fill email if saved
    final savedEmail = StorageService.getEmail();
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _emailController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: const Text(
          'Your premium subscription is now active. Enjoy all features!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Refresh user status
              Provider.of<UserProvider>(context, listen: false).refreshUserStatus();

              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              Navigator.pushReplacementNamed(context, '/predictions'); // Go to predictions
            },
            child: const Text('Start Using'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _openCheckout,
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  Future<void> _openCheckout() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId!;

      // Save email
      await StorageService.setEmail(email);
      userProvider.updateEmail(email);

      // TEST MODE: Show error - payment must be configured
      if (testMode) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Text('Payment Not Available'),
              ],
            ),
            content: const Text(
              'Payment integration is not configured.\n\nPlease contact support to activate premium.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // PRODUCTION MODE: Real payment flow
      final subscriptionData = await ApiService.createSubscription(
        userId,
        email,
        planId,
      );

      // Open Razorpay checkout
      var options = {
        'key': razorpayKeyId,
        'subscription_id': subscriptionData['subscriptionId'],
        'name': 'Teer Khela Premium',
        'description': 'Monthly Subscription - AI Predictions',
        'prefill': {
          'email': email,
          'contact': '',
        },
        'theme': {
          'color': '#7c3aed',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to process subscription. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Subscription error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: AppTheme.primary,
      ),
      drawer: const AppDrawer(),
      body: _buildContent(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildContent(Size size) {
    final horizontalPadding = size.width * 0.05;
    final iconSize = size.width * 0.2;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppTheme.space16,
        ),
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(size.width * 0.08),
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: iconSize,
                    color: Colors.white,
                  ),
                  SizedBox(height: AppTheme.space16),
                  Text(
                    'Premium Membership',
                    style: AppTheme.heading1.copyWith(
                      fontSize: size.width * 0.065,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.space12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Text(
                      '50% OFF - LIMITED TIME!',
                      style: AppTheme.buttonText.copyWith(
                        fontSize: size.width * 0.033,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: size.width * 0.055,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '49',
                        style: TextStyle(
                          fontSize: size.width * 0.08,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: AppTheme.space8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹99',
                            style: TextStyle(
                              fontSize: size.width * 0.042,
                              color: Colors.white70,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            'per month',
                            style: TextStyle(
                              fontSize: size.width * 0.037,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.space8),
                  Text(
                    'Auto-renews monthly. Cancel anytime.',
                    style: AppTheme.bodySmall.copyWith(
                      fontSize: size.width * 0.03,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Features Section - Simplified to 3 Key Benefits
            Container(
              padding: EdgeInsets.all(AppTheme.space20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppTheme.premiumPurple,
                        size: size.width * 0.065,
                      ),
                      SizedBox(width: AppTheme.space12),
                      Text(
                        'What You Get',
                        style: AppTheme.heading3.copyWith(
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.space20),
                  _buildFeatureItem(
                    Icons.auto_graph,
                    'AI Predictions (10 Numbers)',
                    'Daily AI predictions for FR & SR in all 6 Teer games',
                    size,
                  ),
                  SizedBox(height: AppTheme.space16),
                  _buildFeatureItem(
                    Icons.nights_stay,
                    'Dream Interpreter Bot',
                    '100+ symbols in Hindi, Bengali, English & more',
                    size,
                  ),
                  SizedBox(height: AppTheme.space16),
                  _buildFeatureItem(
                    Icons.bar_chart,
                    'Complete Analytics',
                    '30-day history • Common numbers • Formula calculator',
                    size,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Email Input
            Container(
              padding: EdgeInsets.all(AppTheme.space16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Your Email',
                    style: AppTheme.subtitle1.copyWith(
                      fontSize: size.width * 0.042,
                    ),
                  ),
                  SizedBox(height: AppTheme.space12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: size.width * 0.038,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: AppTheme.bodyMedium.copyWith(
                        fontSize: size.width * 0.037,
                      ),
                      hintText: 'Enter your email',
                      hintStyle: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.035,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
                      prefixIcon: Icon(
                        Icons.email,
                        size: size.width * 0.055,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTheme.space16,
                        vertical: AppTheme.space12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Subscribe Button
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
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
                onPressed: _isLoading ? null : _openCheckout,
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
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: size.width * 0.05,
                          ),
                          SizedBox(width: AppTheme.space8),
                          Text(
                            'Subscribe Now - ₹49/month',
                            style: AppTheme.buttonText.copyWith(
                              fontSize: size.width * 0.042,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: AppTheme.space16),

            // Terms
            Container(
              padding: EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                'By subscribing, you agree to auto-renewal. You can cancel anytime from your profile. Powered by Razorpay secure payments.',
                style: AppTheme.bodySmall.copyWith(
                  fontSize: size.width * 0.03,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Size size,
  ) {
    final iconContainerSize = size.width * 0.11;
    final iconSize = iconContainerSize * 0.5;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                description,
                style: AppTheme.bodySmall.copyWith(
                  fontSize: size.width * 0.032,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: size.width * 0.05,
        ),
      ],
    );
  }
}
