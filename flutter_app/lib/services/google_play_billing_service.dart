import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';

class GooglePlayBillingService {
  static const String baseUrl = 'https://teerkhela-production.up.railway.app/api/subscriptions';

  // Subscription Product IDs (must match Play Console)
  static const String monthlyProductId = 'premium_monthly';
  static const String quarterlyProductId = 'premium_quarterly';
  static const String annualProductId = 'premium_annual';

  static const List<String> _productIds = [
    monthlyProductId,
    quarterlyProductId,
    annualProductId,
  ];

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _loading = true;

  // Callbacks
  Function(bool success, String message)? onPurchaseComplete;
  Function(String error)? onError;

  GooglePlayBillingService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Check if in-app purchase is available
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      await _loadProducts();
    }

    _loading = false;
  }

  /// Load products from Google Play Store
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds.toSet());

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('❌ Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        debugPrint('❌ Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('✅ Loaded ${_products.length} products');

      // Sort products by price (lowest first)
      _products.sort((a, b) => double.parse(a.rawPrice.toString()).compareTo(double.parse(b.rawPrice.toString())));
    } catch (e) {
      debugPrint('❌ Exception loading products: $e');
    }
  }

  /// Get all available products
  List<ProductDetails> getProducts() {
    return _products;
  }

  /// Check if billing is available
  bool isAvailable() {
    return _isAvailable;
  }

  /// Check if still loading
  bool isLoading() {
    return _loading;
  }

  /// Purchase a subscription
  Future<void> purchaseSubscription(ProductDetails product) async {
    if (!_isAvailable) {
      onError?.call('Google Play Store not available');
      return;
    }

    try {
      debugPrint('🛒 Starting purchase for: ${product.id}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // For subscriptions, use buyNonConsumable
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('✅ Purchase flow initiated');
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      onError?.call('Failed to start purchase: $e');
    }
  }

  /// Handle purchase updates from Google Play
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('📦 Purchase update: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('⏳ Purchase pending...');
        _showPendingUI();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('❌ Purchase error: ${purchaseDetails.error}');
        _handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        debugPrint('✅ Purchase successful!');

        // Verify purchase with backend
        final bool valid = await _verifyPurchase(purchaseDetails);

        if (valid) {
          _deliverProduct(purchaseDetails);
        } else {
          _handleInvalidPurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('❌ Purchase canceled by user');
        onPurchaseComplete?.call(false, 'Purchase canceled');
      }

      // Complete the purchase (required by Google Play)
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      debugPrint('🔍 Verifying purchase with backend...');

      // Get purchase token
      String? purchaseToken;
      if (Platform.isAndroid) {
        final androidDetails = purchaseDetails as GooglePlayPurchaseDetails;
        purchaseToken = androidDetails.billingClientPurchase.purchaseToken;
      }

      if (purchaseToken == null) {
        debugPrint('❌ No purchase token found');
        return false;
      }

      // Get user ID
      final deviceId = StorageService.getDeviceId() ?? 'unknown';

      // Verify with backend
      final response = await http.post(
        Uri.parse('$baseUrl/verify-google-play'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'purchase_token': purchaseToken,
          'product_id': purchaseDetails.productID,
          'device_id': deviceId,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('📡 Verification response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Verification error: $e');
      return false;
    }
  }

  /// Deliver premium access to user
  void _deliverProduct(PurchaseDetails purchaseDetails) {
    debugPrint('🎉 Delivering premium access...');

    // Save premium status locally
    StorageService.setPremiumStatus(true);

    // Calculate expiry based on product
    Duration validity;
    switch (purchaseDetails.productID) {
      case monthlyProductId:
        validity = const Duration(days: 30);
        break;
      case quarterlyProductId:
        validity = const Duration(days: 90);
        break;
      case annualProductId:
        validity = const Duration(days: 365);
        break;
      default:
        validity = const Duration(days: 30);
    }

    final expiry = DateTime.now().add(validity);
    StorageService.setPremiumExpiry(expiry.toIso8601String());

    debugPrint('✅ Premium access granted until: $expiry');

    onPurchaseComplete?.call(true, 'Premium subscription activated!');
  }

  /// Handle invalid purchase
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    debugPrint('❌ Invalid purchase - verification failed');
    onPurchaseComplete?.call(false, 'Purchase verification failed. Please contact support.');
  }

  /// Handle purchase error
  void _handleError(IAPError error) {
    String message = 'Purchase failed';

    if (error.code == 'purchase_error') {
      message = 'Payment was not completed. Please try again.';
    } else if (error.code == 'payment_invalid') {
      message = 'Payment method is invalid. Please use a different payment method.';
    } else if (error.code == 'user_cancelled') {
      message = 'Purchase was canceled';
    }

    debugPrint('❌ Purchase error: ${error.code} - ${error.message}');
    onPurchaseComplete?.call(false, message);
  }

  /// Show pending UI
  void _showPendingUI() {
    debugPrint('⏳ Showing pending purchase UI...');
  }

  /// Stream done callback
  void _updateStreamOnDone() {
    debugPrint('📡 Purchase stream done');
    _subscription.cancel();
  }

  /// Stream error callback
  void _updateStreamOnError(dynamic error) {
    debugPrint('❌ Purchase stream error: $error');
  }

  /// Restore purchases (for users who already subscribed)
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      onError?.call('Google Play Store not available');
      return;
    }

    try {
      debugPrint('🔄 Restoring purchases...');
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restore initiated');
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      onError?.call('Failed to restore purchases: $e');
    }
  }

  /// Check active subscriptions
  Future<bool> hasActiveSubscription() async {
    try {
      // Check local storage first
      final isPremium = StorageService.getPremiumStatus();
      final expiryStr = StorageService.getPremiumExpiry();

      if (isPremium && expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (expiry.isAfter(DateTime.now())) {
          debugPrint('✅ Has valid premium subscription');
          return true;
        }
      }

      debugPrint('❌ No active subscription found');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking subscription: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}
