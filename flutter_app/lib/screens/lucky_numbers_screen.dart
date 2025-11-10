import 'package:flutter/material.dart';
import 'dart:math';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../models/game.dart';

class LuckyNumbersScreen extends StatefulWidget {
  const LuckyNumbersScreen({super.key});

  @override
  State<LuckyNumbersScreen> createState() => _LuckyNumbersScreenState();
}

class _LuckyNumbersScreenState extends State<LuckyNumbersScreen> {
  List<TeerGame> _games = [];
  String? _selectedGame;
  List<int> _luckyFR = [];
  List<int> _luckySR = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await ApiService.getGames();
      if (mounted) {
        setState(() {
          _games = games.where((g) => g.isActive).toList();
          if (_games.isNotEmpty) {
            _selectedGame = _games.first.name;
            _isLoading = false;
          }
        });
        if (_selectedGame != null) {
          _generateLuckyNumbers();
        }
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

  void _generateLuckyNumbers() {
    if (_selectedGame == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Generate 6 random FR and 6 random SR numbers (0-99)
      final random = Random();
      final luckyFR = <int>[];
      final luckySR = <int>[];

      // Generate unique random numbers
      final allNumbers = List.generate(100, (i) => i);
      allNumbers.shuffle(random);

      // Pick first 6 for FR
      luckyFR.addAll(allNumbers.sublist(0, 6));

      // Shuffle again and pick 6 for SR
      allNumbers.shuffle(random);
      luckySR.addAll(allNumbers.sublist(0, 6));

      setState(() {
        _luckyFR = luckyFR;
        _luckySR = luckySR;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate lucky numbers: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Numbers'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateLuckyNumbers,
            tooltip: 'Generate New',
          ),
        ],
      ),
      body: _buildBody(size),
    );
  }

  Widget _buildBody(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.space20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              SizedBox(height: AppTheme.space16),
              Text(
                _error!,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.space16),
              ElevatedButton(
                onPressed: _loadGames,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // House Selector
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.space16,
                vertical: AppTheme.space12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGame,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: AppTheme.subtitle1,
                  items: _games.map((game) {
                    return DropdownMenuItem(
                      value: game.name,
                      child: Text(game.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGame = value);
                      _generateLuckyNumbers();
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // Info Card
            Container(
              padding: EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary),
                  SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: Text(
                      'Randomly generated lucky numbers',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.space24),

            // FR Numbers
            Text(
              'First Round (FR)',
              style: AppTheme.heading2.copyWith(fontSize: 18),
            ),
            SizedBox(height: AppTheme.space12),
            Wrap(
              spacing: AppTheme.space12,
              runSpacing: AppTheme.space12,
              children: _luckyFR.map((num) => _buildNumberChip(num, true, size)).toList(),
            ),
            SizedBox(height: AppTheme.space24),

            // SR Numbers
            Text(
              'Second Round (SR)',
              style: AppTheme.heading2.copyWith(fontSize: 18),
            ),
            SizedBox(height: AppTheme.space12),
            Wrap(
              spacing: AppTheme.space12,
              runSpacing: AppTheme.space12,
              children: _luckySR.map((num) => _buildNumberChip(num, false, size)).toList(),
            ),
            SizedBox(height: AppTheme.space24),

            // Generate Button
            ElevatedButton.icon(
              onPressed: _generateLuckyNumbers,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Lucky Numbers'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(AppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberChip(int number, bool isFR, Size size) {
    return Container(
      width: (size.width - AppTheme.space16 * 2 - AppTheme.space12 * 2) / 3,
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.space16,
        horizontal: AppTheme.space12,
      ),
      decoration: BoxDecoration(
        gradient: isFR
            ? AppTheme.primaryGradient
            : const LinearGradient(
                colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Text(
        number.toString().padLeft(2, '0'),
        style: AppTheme.heading1.copyWith(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
