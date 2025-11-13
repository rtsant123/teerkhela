import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RazorpayService {
  static const String baseUrl = 'https://teerkhela-production.up.railway.app/api/razorpay';

  late Razorpay _razorpay;
  Function(Map<String, dynamic>)? onSuccess;
  Function(String)? onError;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    if (onSuccess != null) {
      onSuccess!({
        'payment_id': response.paymentId,
        'order_id': response.orderId,
        'signature': response.signature,
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error: ${response.code} - ${response.message}');
    if (onError != null) {
      onError!('${response.message} (Code: ${response.code})');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet: ${response.walletName}');
    if (onError != null) {
      onError!('External wallet payment not supported');
    }
  }

  /// Create Razorpay order on backend
  Future<Map<String, dynamic>?> createOrder({
    required double amount,
    required int userId,
    required int packageId,
    required String packageName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'user_id': userId,
          'package_id': packageId,
          'package_name': packageName,
        }),
      );

      debugPrint('Create Order Response: ${response.statusCode}');
      debugPrint('Create Order Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        debugPrint('❌ Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      return null;
    }
  }

  /// Open Razorpay checkout
  void openCheckout({
    required String orderId,
    required double amount,
    required String keyId,
    required String name,
    required String email,
    required String phone,
    required String description,
  }) {
    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Teer Khela',
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': phone,
        'email': email,
        'name': name,
      },
      'readonly': {
        'contact': false,
        'email': false,
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {
        'color': '#667eea',
        'hide_topbar': false
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Error opening Razorpay: $e');
      if (onError != null) {
        onError!('Failed to open payment gateway');
      }
    }
  }

  /// Verify payment signature on backend
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'user_id': userId,
          'user_name': userName,
          'user_email': userEmail,
        }),
      );

      debugPrint('Verify Payment Response: ${response.statusCode}');
      debugPrint('Verify Payment Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        debugPrint('❌ Payment verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error verifying payment: $e');
      return false;
    }
  }

  /// Complete payment flow
  Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required int userId,
    required int packageId,
    required String packageName,
    required String userName,
    required String userEmail,
    required String userPhone,
    required Function(bool, String) onComplete,
  }) async {
    debugPrint('🚀 RazorpayService.initiatePayment() called');
    debugPrint('   Amount: ₹$amount');
    debugPrint('   UserId: $userId');
    debugPrint('   PackageId: $packageId');
    debugPrint('   PackageName: $packageName');
    debugPrint('   UserName: $userName');
    debugPrint('   UserEmail: $userEmail');
    debugPrint('   UserPhone: $userPhone');

    try {
      // Show loading
      debugPrint('📊 Showing loading dialog...');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Create order
      debugPrint('📞 Creating Razorpay order...');
      final orderData = await createOrder(
        amount: amount,
        userId: userId,
        packageId: packageId,
        packageName: packageName,
      );

      debugPrint('📦 Order response: $orderData');

      // Close loading
      if (context.mounted) {
        debugPrint('✅ Closing loading dialog');
        Navigator.pop(context);
      }

      if (orderData == null) {
        debugPrint('❌ Failed to create order - orderData is null');
        onComplete(false, 'Failed to create payment order');
        return;
      }

      debugPrint('✅ Order created successfully: ${orderData['order_id']}');

      // Set callbacks
      onSuccess = (response) async {
        // Show loading
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // Verify payment
        final verified = await verifyPayment(
          orderId: response['order_id'],
          paymentId: response['payment_id'],
          signature: response['signature'],
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        );

        // Close loading
        if (context.mounted) {
          Navigator.pop(context);
        }

        if (verified) {
          onComplete(true, 'Payment successful!');
        } else {
          onComplete(false, 'Payment verification failed');
        }
      };

      onError = (error) {
        onComplete(false, error);
      };

      // Open checkout
      debugPrint('🏪 Opening Razorpay checkout...');
      debugPrint('   Order ID: ${orderData['order_id']}');
      debugPrint('   Key ID: ${orderData['key_id']}');
      debugPrint('   Amount: ₹$amount');

      openCheckout(
        orderId: orderData['order_id'],
        amount: amount,
        keyId: orderData['key_id'],
        name: userName,
        email: userEmail,
        phone: userPhone,
        description: packageName,
      );

      debugPrint('✅ Checkout opened successfully');
    } catch (e) {
      debugPrint('❌ Error initiating payment: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading if open
      }
      onComplete(false, 'Failed to initiate payment: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
