import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../services/razorpay_service.dart';
import '../services/api_service.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final _promoController = TextEditingController();
  RazorpayService? _razorpayService;

  int _selectedPlan = 1;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _showPromo = false;
  String? _appliedPromo;
  double _discount = 0;

  final List<Map<String, dynamic>> _plans = [
    {'name': '30D', 'price': 99, 'days': 30},
    {'name': '90D', 'price': 249, 'days': 90},
    {'name': '365D', 'price': 999, 'days': 365},
  ];

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService!.initialize(context);

    _razorpayService!.onPaymentComplete = (success, message) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      if (success) {
        Provider.of<UserProvider>(context, listen: false).refreshUserStatus();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Premium activated!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorMessage = message);
      }
    };

    _razorpayService!.onError = (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = error;
      });
    };
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _handlePayNow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final plan = _plans[_selectedPlan];

    if (userProvider.isGuest || userProvider.userId == null) {
      final phone = await _showPhoneDialog();
      if (phone == null || phone.isEmpty) return;

      setState(() => _isProcessing = true);
      try {
        await userProvider.loginWithPhone(phone);
      } catch (e) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Login failed. Try again.';
        });
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final finalPrice = _discount > 0
        ? plan['price'] * (1 - _discount / 100)
        : plan['price'].toDouble();

    // If 100% discount, activate premium directly without payment
    if (_discount == 100 && _appliedPromo != null) {
      try {
        final response = await ApiService.activatePremiumWithPromo(
          userId: userProvider.userId!,
          planId: plan['name'],
          durationDays: plan['days'],
          promoCode: _appliedPromo!,
        );

        if (!mounted) return;
        setState(() => _isProcessing = false);

        await Provider.of<UserProvider>(context, listen: false).refreshUserStatus();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Premium activated for free!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Activation failed: ${e.toString()}';
        });
      }
      return;
    }

    // Regular payment with optional discount
    final paymentPlan = {
      'id': plan['name'],
      'name': plan['name'],
      'days': plan['days'],
      'durationDays': plan['days'],
      'price': (finalPrice * 100).toInt(),
      'displayPrice': '₹${finalPrice.toStringAsFixed(0)}',
    };

    // Create promo code data if applied
    Map<String, dynamic>? promoData;
    if (_appliedPromo != null && _discount > 0) {
      promoData = {
        'valid': true,
        'code': _appliedPromo,
        'discount_percent': _discount.toInt(),
      };
    }

    // Use openCheckout which handles promo codes properly
    await _razorpayService!.openCheckout(paymentPlan, promoCode: promoData);
    setState(() => _isProcessing = false);
  }

  Future<String?> _showPhoneDialog() async {
    final phoneController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Enter Phone Number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          autofocus: true,
          decoration: InputDecoration(
            prefix: Text('+91 '),
            hintText: '9876543210',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().length == 10) {
                Navigator.pop(context, phoneController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _applyPromo() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Call backend API to validate promo code
      final result = await ApiService.validatePromoCode(code);

      if (result['valid'] == true) {
        setState(() {
          _appliedPromo = code;
          _discount = result['discount_percent'].toDouble();
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['description'] ?? 'Promo code applied'}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = result['error'] ?? 'Invalid promo code';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to validate promo code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_selectedPlan];
    final finalPrice = _discount > 0
        ? plan['price'] * (1 - _discount / 100)
        : plan['price'].toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Get Premium', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features - ALL OF THEM
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.1), AppTheme.primaryDark.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('✨ Premium Features', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        SizedBox(height: 8),
                        _buildFeature(Icons.stars, 'AI Lucky Numbers'),
                        _buildFeature(Icons.psychology, 'Dream Number Analysis'),
                        _buildFeature(Icons.trending_up, 'Common Numbers'),
                        _buildFeature(Icons.whatshot, 'Hot & Cold Numbers'),
                        _buildFeature(Icons.calculate, 'Formula Calculator'),
                        _buildFeature(Icons.analytics, 'Advanced Predictions'),
                        _buildFeature(Icons.history, 'Full Game History'),
                        _buildFeature(Icons.assessment, 'Accuracy Stats'),
                        _buildFeature(Icons.lightbulb, 'Hit Numbers'),
                        _buildFeature(Icons.forum, 'Community Forum'),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Plans - HORIZONTAL
                  Text('Choose Plan:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    children: List.generate(3, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlan = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _selectedPlan == i ? AppTheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedPlan == i ? AppTheme.primary : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _plans[i]['name'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedPlan == i ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹${_plans[i]['price']}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedPlan == i ? Colors.white : AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ),

                  SizedBox(height: 14),

                  // Promo section
                  if (!_showPromo && _appliedPromo == null)
                    TextButton.icon(
                      onPressed: () => setState(() => _showPromo = true),
                      icon: Icon(Icons.local_offer, size: 16),
                      label: Text('Have a promo code?', style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: EdgeInsets.zero,
                      ),
                    ),

                  if (_showPromo && _appliedPromo == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Enter code',
                              hintStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: _applyPromo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text('Apply', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ],

                  if (_appliedPromo != null)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                          SizedBox(width: 6),
                          Expanded(child: Text('$_appliedPromo - $_discount% OFF', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 12))),
                          TextButton(
                            onPressed: () => setState(() {
                              _appliedPromo = null;
                              _discount = 0;
                              _promoController.clear();
                              _showPromo = false;
                            }),
                            child: Text('Remove', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),

                  if (_errorMessage != null) ...[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                          SizedBox(width: 6),
                          Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 12))),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      // BOTTOM BUTTON - ALWAYS VISIBLE
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_discount > 0) ...[
                    Text('₹${plan['price']}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 14)),
                    SizedBox(width: 6),
                  ],
                  Text('₹${finalPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  Text(' / ${plan['days']}d', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  child: _isProcessing
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('PAY NOW', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
