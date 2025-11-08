import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/dream_interpretation.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class DreamScreen extends StatefulWidget {
  const DreamScreen({super.key});

  @override
  State<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends State<DreamScreen> {
  final _dreamController = TextEditingController();
  String _selectedLanguage = 'auto';
  String _selectedGame = 'shillong';
  bool _isLoading = false;
  DreamInterpretation? _result;

  final Map<String, String> _languages = {
    'auto': 'Auto Detect',
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
    'bn': 'বাংলা (Bengali)',
    'as': 'অসমীয়া (Assamese)',
    'ne': 'नेपाली (Nepali)',
  };

  final Map<String, String> _games = {
    'shillong': 'Shillong Teer',
    'khanapara': 'Khanapara Teer',
    'juwai': 'Juwai Teer',
    'shillong-morning': 'Shillong Morning',
    'khanapara-morning': 'Khanapara Morning',
    'juwai-morning': 'Juwai Morning',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures UI rebuilds when premium status changes
  }

  Future<void> _interpretDream() async {
    if (_dreamController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your dream')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await ApiService.interpretDream(
        userProvider.userId!,
        _dreamController.text,
        _selectedLanguage,
        _selectedGame,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Dream AI Bot'),
        backgroundColor: AppTheme.primary,
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? _buildDreamBotView(size)
          : _buildPremiumLock(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildPremiumLock(Size size) {
    final iconSize = size.width * 0.2;
    final horizontalPadding = size.width * 0.05;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppTheme.space24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),

              // Premium Icon - Responsive
              Container(
                width: iconSize,
                height: iconSize,
                decoration: const BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  size: iconSize * 0.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppTheme.space24),

              // Title - Responsive
              Text(
                'Dream AI Bot',
                style: AppTheme.heading1.copyWith(
                  fontSize: size.width * 0.065,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.space12),

              // Description - Responsive
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Text(
                  'AI-powered dream interpretation with Teer number predictions',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: size.width * 0.037,
                  ),
                ),
              ),
              SizedBox(height: AppTheme.space24),

              // Features - Compact and Responsive
              _buildFeatureItem(
                Icons.translate,
                'Multi-Language Support',
                'Works in English, Hindi, Bengali, Assamese & more',
                size,
              ),
              SizedBox(height: AppTheme.space12),
              _buildFeatureItem(
                Icons.lightbulb_outline,
                '100+ Dream Symbols',
                'Comprehensive dream symbol database',
                size,
              ),
              SizedBox(height: AppTheme.space12),
              _buildFeatureItem(
                Icons.auto_awesome,
                'AI-Powered Analysis',
                'Advanced AI interprets your dreams',
                size,
              ),
              SizedBox(height: AppTheme.space12),
              _buildFeatureItem(
                Icons.numbers,
                'Teer Number Predictions',
                'Get FR & SR number suggestions',
                size,
              ),
              SizedBox(height: AppTheme.space32),

              // Upgrade Button - Responsive
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/subscribe');
                  },
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium, size: 20),
                      SizedBox(width: AppTheme.space8),
                      Text(
                        'Unlock Dream AI',
                        style: AppTheme.buttonText.copyWith(
                          fontSize: size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppTheme.space12),

              // Price - Responsive
              Text(
                'Just ₹49/month • 50% OFF',
                style: AppTheme.bodySmall.copyWith(
                  fontSize: size.width * 0.033,
                ),
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
    Size size,
  ) {
    final iconContainerSize = size.width * 0.11;
    final iconSize = iconContainerSize * 0.5;

    return Container(
      padding: EdgeInsets.all(AppTheme.space12),
      decoration: AppTheme.cardDecoration,
      child: Row(
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
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: size.width * 0.032,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamBotView(Size size) {
    final horizontalPadding = size.width * 0.04;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card - Responsive
            Container(
              padding: EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primary,
                    size: size.width * 0.045,
                  ),
                  SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: Text(
                      'Describe your dream in any language. Our AI will interpret it and suggest Teer numbers.',
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.033,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.space16),

            // Language Selector - Responsive
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Language',
                labelStyle: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space12,
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
                  Icons.language,
                  color: AppTheme.primary,
                  size: size.width * 0.05,
                ),
              ),
              items: _languages.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: size.width * 0.037,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            SizedBox(height: AppTheme.space16),

            // Game Selector - Responsive
            DropdownButtonFormField<String>(
              value: _selectedGame,
              decoration: InputDecoration(
                labelText: 'Target Game',
                labelStyle: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space12,
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
                  Icons.sports_cricket,
                  color: AppTheme.primary,
                  size: size.width * 0.05,
                ),
              ),
              items: _games.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: size.width * 0.037,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGame = value!;
                });
              },
            ),
            SizedBox(height: AppTheme.space16),

            // Dream Input - Responsive
            TextField(
              controller: _dreamController,
              maxLines: 6,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.037,
              ),
              decoration: InputDecoration(
                labelText: 'Describe your dream',
                labelStyle: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.037,
                ),
                hintText: 'Enter your dream in any language...\n\nExample:\nमैंने सपने में साँप देखा\nI saw a snake in my dream\nআমি স্বপ্নে সাপ দেখেছি',
                hintStyle: AppTheme.bodySmall.copyWith(
                  fontSize: size.width * 0.032,
                ),
                contentPadding: EdgeInsets.all(AppTheme.space12),
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
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: AppTheme.space20),

            // Submit Button - Responsive
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.buttonShadow(AppTheme.primary),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _interpretDream,
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
                    ? SizedBox(
                        height: size.width * 0.05,
                        width: size.width * 0.05,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: size.width * 0.045),
                          SizedBox(width: AppTheme.space8),
                          Text(
                            'Interpret Dream',
                            style: AppTheme.buttonText.copyWith(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Results
            if (_result != null) _buildResults(_result!, size),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(DreamInterpretation result, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(thickness: 2, color: AppTheme.textSecondary.withOpacity(0.2)),
        SizedBox(height: AppTheme.space16),

        // Header - Responsive
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppTheme.accent,
              size: size.width * 0.06,
            ),
            SizedBox(width: AppTheme.space12),
            Text(
              'Interpretation Results',
              style: AppTheme.heading2.copyWith(
                fontSize: size.width * 0.05,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.space16),

        // Language Detected - Responsive
        Container(
          decoration: AppTheme.cardDecoration,
          child: ListTile(
            leading: Icon(
              Icons.language,
              color: AppTheme.accent,
              size: size.width * 0.055,
            ),
            title: Text(
              'Language Detected',
              style: AppTheme.subtitle1.copyWith(
                fontSize: size.width * 0.038,
              ),
            ),
            subtitle: Text(
              result.languageName,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.035,
              ),
            ),
          ),
        ),

        // Symbols Found - Responsive
        if (result.symbols.isNotEmpty) ...[
          SizedBox(height: AppTheme.space16),
          Container(
            decoration: AppTheme.cardDecoration,
            padding: EdgeInsets.all(AppTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: AppTheme.warning,
                      size: size.width * 0.05,
                    ),
                    SizedBox(width: AppTheme.space8),
                    Text(
                      'Symbols Found',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.space12),
                Wrap(
                  spacing: AppTheme.space8,
                  runSpacing: AppTheme.space8,
                  children: result.symbols.map((symbol) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                        vertical: size.width * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.warning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: size.width * 0.025,
                            color: AppTheme.warning,
                          ),
                          SizedBox(width: AppTheme.space4),
                          Text(
                            symbol,
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: size.width * 0.033,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],

        // Predicted Numbers - Responsive
        SizedBox(height: AppTheme.space16),
        Container(
          decoration: AppTheme.cardDecoration,
          padding: EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: AppTheme.accent,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: AppTheme.space8),
                  Expanded(
                    child: Text(
                      'Predicted Numbers',
                      style: AppTheme.subtitle1.copyWith(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildConfidenceBadge(result.confidence, size),
                ],
              ),
              SizedBox(height: AppTheme.space12),
              Wrap(
                spacing: size.width * 0.03,
                runSpacing: size.width * 0.03,
                children: result.numbers.map((num) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.width * 0.025,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.premiumGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.buttonShadow(AppTheme.accent),
                    ),
                    child: Text(
                      num.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.05,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Analysis - Responsive
        SizedBox(height: AppTheme.space16),
        Container(
          decoration: AppTheme.cardDecoration,
          padding: EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.warning,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: AppTheme.space8),
                  Text(
                    'AI Analysis',
                    style: AppTheme.subtitle1.copyWith(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.space12),
              Text(
                result.analysis,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.035,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        // Recommendation - Responsive
        SizedBox(height: AppTheme.space16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppTheme.success),
          ),
          padding: EdgeInsets.all(AppTheme.space16),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: size.width * 0.05,
              ),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: Text(
                  'Recommended for ${result.recommendation} Teer',
                  style: AppTheme.subtitle1.copyWith(
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBadge(int confidence, Size size) {
    Color color;
    if (confidence >= 90) {
      color = AppTheme.success;
    } else if (confidence >= 80) {
      color = AppTheme.info;
    } else if (confidence >= 70) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.width * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: size.width * 0.035, color: color),
          SizedBox(width: AppTheme.space4),
          Text(
            '$confidence%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }
}
