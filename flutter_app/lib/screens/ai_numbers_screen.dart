import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';

/// Unified AI Numbers Screen
/// Shows: AI Common Numbers, AI Lucky Numbers, or AI Hit Numbers
/// Each displays 10 numbers + date + confidence
class AINumbersScreen extends StatefulWidget {
  final String type; // 'common', 'lucky', or 'hit'

  const AINumbersScreen({super.key, required this.type});

  @override
  State<AINumbersScreen> createState() => _AINumbersScreenState();
}

class _AINumbersScreenState extends State<AINumbersScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;
  String _selectedGame = 'shillong';

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _fetchDataByType();
      if (mounted) {
        setState(() {
          _data = data;
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

  Future<Map<String, dynamic>> _fetchDataByType() async {
    switch (widget.type) {
      case 'common':
        return await ApiService.getAICommonNumbers(_selectedGame);
      case 'lucky':
        return await ApiService.getAILuckyNumbers(_selectedGame);
      case 'hit':
        return await ApiService.getAIHitNumbers(_selectedGame);
      default:
        throw Exception('Invalid type');
    }
  }

  String get _screenTitle {
    switch (widget.type) {
      case 'common':
        return 'AI Common Numbers';
      case 'lucky':
        return 'AI Lucky Numbers';
      case 'hit':
        return 'AI Hit Numbers';
      default:
        return 'AI Numbers';
    }
  }

  IconData get _screenIcon {
    switch (widget.type) {
      case 'common':
        return Icons.trending_up;
      case 'lucky':
        return Icons.star;
      case 'hit':
        return Icons.check_circle;
      default:
        return Icons.numbers;
    }
  }

  String get _description {
    switch (widget.type) {
      case 'common':
        return 'Most frequent numbers based on 30 days analysis';
      case 'lucky':
        return 'Lucky numbers based on astrology + historical data';
      case 'hit':
        return 'Numbers that actually appeared in past results';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNumbers,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? _buildNumbersView(size)
          : _buildPremiumGate(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPremiumGate(Size size) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.25,
              height: size.width * 0.25,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _screenIcon,
                size: size.width * 0.12,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.space20),
            Text(
              _screenTitle,
              style: AppTheme.heading1.copyWith(fontSize: size.width * 0.065),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.space12),
            Text(
              _description,
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(fontSize: size.width * 0.037),
            ),
            SizedBox(height: AppTheme.space32),
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
                  'Unlock for ₹49/month',
                  style: AppTheme.buttonText.copyWith(fontSize: size.width * 0.04),
                ),
              ),
            ),
            SizedBox(height: AppTheme.space16),
            Container(
              padding: EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Premium includes:', style: AppTheme.subtitle1),
                  SizedBox(height: AppTheme.space8),
                  _buildFeatureItem('✓ AI Dream Bot (7 languages)'),
                  _buildFeatureItem('✓ AI Common Numbers (10 daily)'),
                  _buildFeatureItem('✓ AI Lucky Numbers (10 daily)'),
                  _buildFeatureItem('✓ AI Hit Numbers (10 daily)'),
                  _buildFeatureItem('✓ AI Formula Calculator'),
                  _buildFeatureItem('✓ 30 Days Results History'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.space4),
      child: Text(text, style: AppTheme.bodyMedium),
    );
  }

  Widget _buildNumbersView(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            SizedBox(height: AppTheme.space16),
            Text(_error!, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: _loadNumbers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_data == null) {
      return Center(child: Text('No data available', style: AppTheme.bodyMedium));
    }

    return RefreshIndicator(
      onRefresh: _loadNumbers,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date & Confidence Card
            _buildInfoCard(size),
            SizedBox(height: AppTheme.space20),

            // FR Numbers
            _buildNumbersSection('FR Numbers', _data!['fr_numbers'] ?? [], size, AppTheme.frGradient),
            SizedBox(height: AppTheme.space20),

            // SR Numbers
            _buildNumbersSection('SR Numbers', _data!['sr_numbers'] ?? [], size, AppTheme.srGradient),
            SizedBox(height: AppTheme.space20),

            // Analysis
            if (_data!['analysis'] != null)
              _buildAnalysisCard(size),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Size size) {
    final date = _data!['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final confidence = _data!['confidence'] ?? 0;

    return Container(
      padding: EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: TextStyle(color: Colors.white70, fontSize: size.width * 0.032),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Confidence',
                style: TextStyle(color: Colors.white70, fontSize: size.width * 0.032),
              ),
              Text(
                '$confidence%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumbersSection(String title, List<dynamic> numbers, Size size, LinearGradient gradient) {
    if (numbers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Text('No numbers available', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppTheme.space8, bottom: AppTheme.space12),
          child: Text(title, style: AppTheme.heading2),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            final number = numbers[index];
            final displayNum = number is Map ? number['number'] : number;
            final count = number is Map ? number['count'] : null;

            return Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayNum.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (count != null)
                    Text(
                      '×$count',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: size.width * 0.025,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(Size size) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primary),
              SizedBox(width: AppTheme.space8),
              Text('Analysis', style: AppTheme.heading3),
            ],
          ),
          SizedBox(height: AppTheme.space12),
          Text(
            _data!['analysis'],
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
