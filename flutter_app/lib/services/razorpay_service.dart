import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'api_service.dart';

class RazorpayService {
  late Razorpay _razorpay;
  BuildContext? _context;

  // Callbacks
  Function(bool success, String message)? onPaymentComplete;
  Function(String error)? onError;

  // Your Razorpay API keys
  static const String razorpayKeyId = 'rzp_live_Rfxhgy9ytOwBhY';

  // Subscription plans (prices in paise - INR cents)
  static const List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'monthly',
      'name': 'Monthly',
      'price': 9900, // ₹99 in paise
      'amount': 9900, // Amount in paise for calculations
      'displayPrice': '₹99',
      'period': '/month',
      'durationDays': 30,
    },
    {
      'id': 'quarterly',
      'name': '3 Months',
      'price': 24900, // ₹249 in paise
      'amount': 24900,
      'displayPrice': '₹249',
      'period': '/3 months',
      'durationDays': 90,
      'savings': 'Save ₹48',
    },
    {
      'id': 'annual',
      'name': 'Yearly',
      'price': 99900, // ₹999 in paise
      'amount': 99900,
      'displayPrice': '₹999',
      'period': '/year',
      'durationDays': 365,
      'savings': 'Save ₹789',
    },
  ];

  void initialize(BuildContext context) {
    _context = context;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Create recurring subscription (NEW - for auto-renewal with in-app payment)
  Future<void> createRecurringSubscription(
    Map<String, dynamic> plan, {
    Map<String, dynamic>? promoCode,
  }) async {
    try {
      final userId = StorageService.getUserId() ?? 'guest';
      final promoCodeStr = promoCode != null && promoCode['valid'] == true
          ? promoCode['code'] as String
          : null;

      // If 100% discount promo, activate directly
      if (promoCode != null && promoCode['discount_percent'] == 100) {
        await _activatePremiumDirectly(plan, promoCodeStr!);
        return;
      }

      // Create subscription via backend API
      final result = await ApiService.createRecurringSubscription(
        userId: userId,
        planType: plan['id'], // 'monthly', 'quarterly', or 'annual'
        promoCode: promoCodeStr,
      );

      final subscriptionId = result['subscriptionId'];
      final firstPaymentAmount = result['firstPaymentAmount'] as int;

      // Open Razorpay checkout IN-APP with subscription_id
      var options = {
        'key': razorpayKeyId,
        'subscription_id': subscriptionId, // This makes it a subscription payment
        'name': 'Teer Khela VIP',
        'description': '${plan['name']} Auto-Renewal Subscription',
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#667eea'},
        'notes': {
          'user_id': userId,
          'plan_type': plan['id'],
          if (promoCodeStr != null) 'promo_code': promoCodeStr,
        }
      };

      _razorpay.open(options);
    } catch (e) {
      // Convert technical errors to user-friendly messages
      String userMessage = _getUserFriendlyError(e.toString());
      onError?.call(userMessage);
    }
  }

  // Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String technicalError) {
    if (technicalError.contains('Network error') || technicalError.contains('SocketException')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    } else if (technicalError.contains('plan not available') || technicalError.contains('plan unavailable')) {
      return 'This subscription plan is temporarily unavailable. Please try again later or contact support.';
    } else if (technicalError.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (technicalError.contains('500')) {
      return 'Our servers are experiencing issues. Please try again in a few minutes.';
    } else if (technicalError.contains('404')) {
      return 'Service not found. Please update your app or contact support.';
    } else if (technicalError.contains('credentials') || technicalError.contains('authentication')) {
      return 'Payment system configuration error. Please contact support.';
    } else {
      return 'Unable to process subscription. Please try again or contact support.';
    }
  }

  // One-time checkout (LEGACY - for non-recurring payments)
  Future<void> openCheckout(
    Map<String, dynamic> plan, {
    Map<String, dynamic>? promoCode,
  }) async {
    try {
      final userId = StorageService.getUserId() ?? 'guest';

      // Calculate discounted price if promo code is applied
      int finalAmount = plan['price'];
      if (promoCode != null && promoCode['valid'] == true) {
        final discountPercent = promoCode['discount_percent'] as int;
        final discount = (plan['price'] * discountPercent) / 100;
        finalAmount = (plan['price'] - discount).toInt();

        // If 100% discount, activate directly without payment
        if (finalAmount == 0) {
          await _activatePremiumDirectly(plan, promoCode['code']);
          return;
        }
      }

      var options = {
        'key': razorpayKeyId,
        'amount': finalAmount, // Discounted amount in paise
        'name': 'Teer Khela VIP',
        'description': '${plan['name']} Subscription',
        'prefill': {
          'contact': '',
          'email': ''
        },
        'theme': {
          'color': '#667eea'
        },
        'notes': {
          'plan_id': plan['id'],
          'duration_days': plan['durationDays'].toString(),
          'user_id': userId,
          if (promoCode != null) 'promo_code': promoCode['code'],
        }
      };

      _razorpay.open(options);
    } catch (e) {
      onError?.call('Error: $e');
    }
  }

  Future<void> _activatePremiumDirectly(Map<String, dynamic> plan, String promoCode) async {
    try {
      final userId = StorageService.getUserId() ?? '';
      final apiUrl = 'https://teerkhela-production.up.railway.app/api/subscriptions/activate-promo';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'plan_id': plan['id'],
          'duration_days': plan['durationDays'],
          'promo_code': promoCode,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // Store premium status locally
        final durationDays = plan['durationDays'];
        final expiryDate = DateTime.now().add(Duration(days: durationDays));
        await StorageService.setPremiumStatus(true);
        await StorageService.setPremiumExpiry(expiryDate.toIso8601String());

        onPaymentComplete?.call(true, 'Premium activated successfully! Welcome to VIP membership.');
      } else {
        onPaymentComplete?.call(false, 'Activation failed: ${data['message']}');
      }
    } catch (e) {
      onPaymentComplete?.call(false, 'Error activating premium: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: ${response.paymentId}');

    try {
      final userId = StorageService.getUserId() ?? '';

      // Note: For subscriptions, the webhook will activate premium
      // We just need to wait and refresh user status
      await Future.delayed(const Duration(seconds: 2));

      // Refresh user status from backend
      // The webhook should have already activated premium
      await StorageService.setPremiumStatus(true);
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await StorageService.setPremiumExpiry(expiryDate.toIso8601String());

      onPaymentComplete?.call(
        true,
        'Subscription activated! Auto-renewal enabled. You are now a VIP member.',
      );
    } catch (e) {
      onPaymentComplete?.call(false, 'Error: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    onError?.call('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  List<Map<String, dynamic>> getPlans() {
    return subscriptionPlans;
  }

  void dispose() {
    _razorpay.clear();
  }
}
