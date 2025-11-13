import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/result.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/accuracy_banner_widget.dart';

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
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(userProvider),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadResults,
        color: AppTheme.primary,
        child: _buildBody(size, userProvider),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar(UserProvider userProvider) {
    return AppBar(
      title: const Text(
        'Teer Khela',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // VIP/Premium Badge Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: userProvider.isPremium
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'VIP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : TextButton.icon(
                  onPressed: () => _showSubscriptionModal(context),
                  icon: const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  label: const Text(
                    'Get VIP',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBody(Size size, UserProvider userProvider) {
    final horizontalPadding = size.width * 0.04;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Accuracy/FOMO Banner
          const AccuracyBannerWidget(),

          const SizedBox(height: 20),

          // Quick Access Buttons
          _buildQuickAccessButtons(size, horizontalPadding),

          const SizedBox(height: 24),

          // Today's Results Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                Text(
                  'Today\'s Results',
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
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

          const SizedBox(height: 16),

          // Results List
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ShimmerResultCard(size: size),
                  ),
                ),
              ),
            )
          else if (_error != null)
            _buildErrorState(size, horizontalPadding)
          else if (_results.isEmpty)
            _buildEmptyState(size, horizontalPadding)
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: _results.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildResultCard(entry.value, size),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButtons(Size size, double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  'Predictions',
                  Icons.psychology,
                  const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.premiumPurple],
                  ),
                  () => Navigator.pushNamed(context, '/predictions'),
                  size,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickButton(
                  'Dream Bot',
                  Icons.lightbulb,
                  const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFF5576c)],
                  ),
                  () => Navigator.pushNamed(context, '/dream-bot'),
                  size,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  'Formula',
                  Icons.calculate,
                  const LinearGradient(
                    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  ),
                  () => Navigator.pushNamed(context, '/formula-calculator'),
                  size,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickButton(
                  'Hit Analysis',
                  Icons.show_chart,
                  const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  () => Navigator.pushNamed(context, '/hit-numbers'),
                  size,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    String label,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
    Size size,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.02,
              horizontal: 12,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: size.width * 0.08,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(TeerResult result, Size size) {
    final bool isComplete = result.fr != null && result.sr != null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final displayDate = result.date != null
        ? dateFormat.format(result.date!)
        : DateFormat('MMM dd, yyyy').format(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.displayName,
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: size.height * 0.004),
                          Text(
                            displayDate,
                            style: TextStyle(
                              fontSize: size.width * 0.032,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                        vertical: size.height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isComplete ? 'DECLARED' : 'PENDING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.029,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),

                // FR & SR Numbers
                Row(
                  children: [
                    // FR
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'FR',
                              style: TextStyle(
                                fontSize: size.width * 0.032,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: size.height * 0.008),
                            Text(
                              result.fr?.toString().padLeft(2, '0') ?? '--',
                              style: TextStyle(
                                fontSize: size.width * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    // SR
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SR',
                              style: TextStyle(
                                fontSize: size.width * 0.032,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(height: size.height * 0.008),
                            Text(
                              result.sr?.toString().padLeft(2, '0') ?? '--',
                              style: TextStyle(
                                fontSize: size.width * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),

                // View History Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: size.width * 0.04,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: size.width * 0.015),
                      Text(
                        'View Full History',
                        style: TextStyle(
                          fontSize: size.width * 0.034,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(width: size.width * 0.01),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: size.width * 0.03,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Size size, double horizontalPadding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: size.width * 0.12,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size, double horizontalPadding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: size.width * 0.12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Yet',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Results will appear here once they are declared',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionModal(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubscriptionModal(size: size),
    );
  }
}

// Subscription Modal Widget
class _SubscriptionModal extends StatefulWidget {
  final Size size;

  const _SubscriptionModal({required this.size});

  @override
  State<_SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<_SubscriptionModal> {
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await ApiService.getSubscriptionPackages();
      setState(() {
        _packages = packages;
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
    return Container(
      height: widget.size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        fontSize: widget.size.width * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock premium features and predictions',
                  style: TextStyle(
                    fontSize: widget.size.width * 0.035,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Failed to load plans: $_error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _packages.length,
                        itemBuilder: (context, index) {
                          final package = _packages[index];
                          final isPopular = package['is_popular'] ?? false;
                          return _buildPlanCard(package, isPopular);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> package, bool isPopular) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isPopular
            ? const LinearGradient(
                colors: [AppTheme.primary, AppTheme.premiumPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPopular ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? Colors.transparent : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? AppTheme.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name and duration
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package['name'],
                            style: TextStyle(
                              fontSize: widget.size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: isPopular ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${package['days']} days',
                            style: TextStyle(
                              fontSize: widget.size.width * 0.035,
                              color: isPopular
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${package['price']}',
                          style: TextStyle(
                            fontSize: widget.size.width * 0.065,
                            fontWeight: FontWeight.bold,
                            color: isPopular ? Colors.white : AppTheme.primary,
                          ),
                        ),
                        Text(
                          'only',
                          style: TextStyle(
                            fontSize: widget.size.width * 0.03,
                            color: isPopular
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  package['description'],
                  style: TextStyle(
                    fontSize: widget.size.width * 0.035,
                    color: isPopular
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubscribe(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? Colors.white : AppTheme.primary,
                      foregroundColor: isPopular ? AppTheme.primary : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Subscribe Now',
                      style: TextStyle(
                        fontSize: widget.size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Popular badge
          if (isPopular)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: widget.size.width * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleSubscribe(Map<String, dynamic> package) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/subscribe',
      arguments: {'planId': package['id'].toString()},
    );
  }
}
