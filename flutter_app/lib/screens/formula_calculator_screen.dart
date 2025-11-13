import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import 'package:shimmer/shimmer.dart';

class FormulaCalculatorScreen extends StatefulWidget {
  const FormulaCalculatorScreen({super.key});

  @override
  State<FormulaCalculatorScreen> createState() => _FormulaCalculatorScreenState();
}

class _FormulaCalculatorScreenState extends State<FormulaCalculatorScreen> {
  String _selectedGame = 'shillong';
  String _selectedFormula = 'house';
  final List<Map<String, TextEditingController>> _resultControllers = [];
  bool _isLoading = false;
  Map<String, dynamic>? _calculationResult;

  final Map<String, String> _games = {
    'shillong': 'Shillong Teer',
    'khanapara': 'Khanapara Teer',
    'juwai': 'Juwai Teer',
  };

  final Map<String, String> _formulas = {
    'house': 'House Formula',
    'ending': 'Ending Formula',
    'sum': 'Sum Formula',
  };

  @override
  void initState() {
    super.initState();
    _addResultField();
  }

  void _addResultField() {
    setState(() {
      _resultControllers.add({
        'fr': TextEditingController(),
        'sr': TextEditingController(),
      });
    });
  }

  void _removeResultField(int index) {
    if (_resultControllers.length > 1) {
      setState(() {
        _resultControllers[index]['fr']!.dispose();
        _resultControllers[index]['sr']!.dispose();
        _resultControllers.removeAt(index);
      });
    }
  }

  Future<void> _calculate() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Validate inputs
    final previousResults = <Map<String, int>>[];
    for (final controllers in _resultControllers) {
      final frText = controllers['fr']!.text.trim();
      final srText = controllers['sr']!.text.trim();

      if (frText.isEmpty || srText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      final fr = int.tryParse(frText);
      final sr = int.tryParse(srText);

      if (fr == null || sr == null || fr < 0 || fr > 99 || sr < 0 || sr > 99) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid numbers (0-99)')),
        );
        return;
      }

      previousResults.add({'fr': fr, 'sr': sr});
    }

    setState(() {
      _isLoading = true;
      _calculationResult = null;
    });

    try {
      final result = await ApiService.calculateFormula(
        userProvider.userId!,
        _selectedGame,
        _selectedFormula,
        previousResults,
      );

      setState(() {
        _calculationResult = result;
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Formula Calculator'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? _buildCalculatorView()
          : _buildPremiumGate(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildPremiumGate() {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.2;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calculate,
                size: iconSize * 0.5,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.space24),
            Text(
              'Premium Feature',
              style: AppTheme.heading1.copyWith(
                fontSize: size.width * 0.065,
              ),
            ),
            SizedBox(height: AppTheme.space12),
            Text(
              'Formula calculator is available for premium members only',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
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
                  'Upgrade to Premium',
                  style: AppTheme.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorView() {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          Container(
            padding: EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info, size: size.width * 0.05),
                SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Text(
                    'Enter previous results to calculate predictions based on traditional Teer formulas',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.space20),

          // Game Selector
          DropdownButtonFormField<String>(
            value: _selectedGame,
            decoration: InputDecoration(
              labelText: 'Select Game',
              labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.sports_esports, color: AppTheme.primary),
              filled: true,
              fillColor: AppTheme.surface,
            ),
            style: AppTheme.bodyMedium,
            items: _games.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGame = value!;
              });
            },
          ),
          SizedBox(height: AppTheme.space16),

          // Formula Selector
          DropdownButtonFormField<String>(
            value: _selectedFormula,
            decoration: InputDecoration(
              labelText: 'Select Formula',
              labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.functions, color: AppTheme.primary),
              filled: true,
              fillColor: AppTheme.surface,
            ),
            style: AppTheme.bodyMedium,
            items: _formulas.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFormula = value!;
              });
            },
          ),
          SizedBox(height: AppTheme.space24),

          // Previous Results Section
          Row(
            children: [
              Text(
                'Previous Results',
                style: AppTheme.heading3.copyWith(
                  fontSize: size.width * 0.048,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: TextButton.icon(
                  onPressed: _addResultField,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: Text(
                    'Add',
                    style: AppTheme.buttonText.copyWith(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.space16),

          // Result Input Fields
          ..._resultControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: AppTheme.space12),
              decoration: AppTheme.cardDecoration,
              child: Padding(
                padding: EdgeInsets.all(AppTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.space12,
                            vertical: AppTheme.space4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Text(
                            'Result ${index + 1}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_resultControllers.length > 1)
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: AppTheme.error, size: 24),
                            onPressed: () => _removeResultField(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    SizedBox(height: AppTheme.space16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers['fr'],
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.045,
                            ),
                            decoration: InputDecoration(
                              labelText: 'FR (First Round)',
                              labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(color: AppTheme.primary, width: 2),
                              ),
                              counterText: '',
                              filled: true,
                              fillColor: AppTheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.space16),
                        Expanded(
                          child: TextField(
                            controller: controllers['sr'],
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.045,
                            ),
                            decoration: InputDecoration(
                              labelText: 'SR (Second Round)',
                              labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(color: AppTheme.primary, width: 2),
                              ),
                              counterText: '',
                              filled: true,
                              fillColor: AppTheme.surfaceVariant.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          SizedBox(height: AppTheme.space24),

          // Calculate Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: _isLoading ? null : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: _isLoading ? null : AppTheme.buttonShadow(AppTheme.primary),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? AppTheme.textSecondary.withOpacity(0.5) : Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: AppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: AppTheme.space12),
                        Text(
                          'Calculating...',
                          style: AppTheme.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: size.width * 0.042,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Calculate Predictions',
                      style: AppTheme.buttonText.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.042,
                      ),
                    ),
            ),
          ),

          // Results
          if (_calculationResult != null) ...[
            SizedBox(height: AppTheme.space32),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            SizedBox(height: AppTheme.space24),
            _buildResults(_calculationResult!, size),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(Map<String, dynamic> result, Size size) {
    final formulaType = result['formulaType'] as String;
    final calculation = result['calculation'] as String;
    final predictedNumbers = (result['predictedNumbers'] as List).cast<int>();
    final explanation = result['explanation'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.space8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: size.width * 0.06),
            ),
            SizedBox(width: AppTheme.space12),
            Text(
              'Calculation Results',
              style: AppTheme.heading2.copyWith(
                fontSize: size.width * 0.055,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.space20),

        // Predicted Numbers - MAIN DISPLAY
        Container(
          padding: EdgeInsets.all(AppTheme.space20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withOpacity(0.1),
                AppTheme.primaryLight.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.stars, color: AppTheme.primary, size: size.width * 0.06),
                  SizedBox(width: AppTheme.space8),
                  Text(
                    'Predicted Numbers',
                    style: AppTheme.heading3.copyWith(
                      fontSize: size.width * 0.048,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.space20),
              // Display numbers in 2 rows of 5
              _buildPredictedNumbersGrid(predictedNumbers, size),
            ],
          ),
        ),
        SizedBox(height: AppTheme.space16),

        // Formula Type
        Container(
          decoration: AppTheme.cardDecoration,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.space16,
              vertical: AppTheme.space8,
            ),
            leading: Container(
              padding: EdgeInsets.all(AppTheme.space8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(Icons.functions, color: AppTheme.primary, size: 24),
            ),
            title: Text(
              'Formula Type',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            subtitle: Text(
              _formulas[formulaType] ?? formulaType,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.042,
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.space12),

        // Calculation
        Container(
          decoration: AppTheme.cardDecoration,
          padding: EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(Icons.calculate, color: AppTheme.accent, size: 20),
                  ),
                  SizedBox(width: AppTheme.space8),
                  Text(
                    'Calculation Steps',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.04,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.space12),
              Container(
                padding: EdgeInsets.all(AppTheme.space12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  calculation,
                  style: AppTheme.bodyMedium.copyWith(
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.space12),

        // Explanation
        Container(
          decoration: AppTheme.cardDecoration,
          padding: EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(Icons.lightbulb_outline, color: AppTheme.warning, size: 20),
                  ),
                  SizedBox(width: AppTheme.space8),
                  Text(
                    'How it Works',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.04,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.space12),
              Text(
                explanation,
                style: AppTheme.bodyMedium.copyWith(
                  height: 1.6,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPredictedNumbersGrid(List<int> numbers, Size size) {
    // Display up to 10 numbers in 2 rows of 5
    return Column(
      children: [
        // First row - up to 5 numbers
        if (numbers.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: numbers.take(5).map((num) => _buildPredictedNumberChip(num, size)).toList(),
          ),
        if (numbers.length > 5) ...[
          SizedBox(height: AppTheme.space16),
          // Second row - remaining numbers (up to 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: numbers.skip(5).take(5).map((num) => _buildPredictedNumberChip(num, size)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPredictedNumberChip(int number, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.055,
        vertical: size.width * 0.04,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.buttonShadow(AppTheme.primary),
      ),
      child: Text(
        number.toString().padLeft(2, '0'),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.06,
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controllers in _resultControllers) {
      controllers['fr']!.dispose();
      controllers['sr']!.dispose();
    }
    super.dispose();
  }
}
