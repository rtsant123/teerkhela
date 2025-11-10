import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../models/game.dart';

class AdminAddResultScreen extends StatefulWidget {
  final String? selectedGame;

  const AdminAddResultScreen({super.key, this.selectedGame});

  @override
  State<AdminAddResultScreen> createState() => _AdminAddResultScreenState();
}

class _AdminAddResultScreenState extends State<AdminAddResultScreen> {
  final _frController = TextEditingController();
  final _srController = TextEditingController();

  List<TeerGame> _games = [];
  String? _selectedGame;
  bool _isLoading = false;
  bool _loadingGames = true;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.selectedGame;
    _loadGames();
  }

  @override
  void dispose() {
    _frController.dispose();
    _srController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    try {
      final games = await ApiService.getGames();
      if (mounted) {
        setState(() {
          _games = games.where((g) => g.isActive).toList();
          if (_selectedGame == null && _games.isNotEmpty) {
            _selectedGame = _games.first.name;
          }
          _loadingGames = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load houses';
          _loadingGames = false;
        });
      }
    }
  }

  Future<void> _submitResult() async {
    final fr = _frController.text.trim();
    final sr = _srController.text.trim();

    if (_selectedGame == null) {
      setState(() {
        _error = 'Please select a house';
      });
      return;
    }

    if (fr.isEmpty || sr.isEmpty) {
      setState(() {
        _error = 'Please enter both FR and SR results';
      });
      return;
    }

    final frNum = int.tryParse(fr);
    final srNum = int.tryParse(sr);

    if (frNum == null || srNum == null || frNum < 0 || frNum > 99 || srNum < 0 || srNum > 99) {
      setState(() {
        _error = 'Please enter valid numbers (0-99)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      // Call the admin API to add result
      await ApiService.adminAddResult(
        game: _selectedGame!,
        fr: frNum,
        sr: srNum,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Result added successfully!';
          _frController.clear();
          _srController.clear();
        });

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to add result: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Result'),
        backgroundColor: AppTheme.primary,
      ),
      body: _loadingGames
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Container(
                    padding: EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primary),
                        SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: Text(
                            'Enter today\'s results. AI will automatically analyze patterns.',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.space24),

                  // House Selector
                  Text('Select House', style: AppTheme.heading3),
                  SizedBox(height: AppTheme.space12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.space16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGame,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      style: AppTheme.subtitle1,
                      items: _games.map((game) {
                        return DropdownMenuItem<String>(
                          value: game.name,
                          child: Text(game.displayName),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGame = newValue;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: AppTheme.space24),

                  // Date (Today)
                  Text('Date', style: AppTheme.heading3),
                  SizedBox(height: AppTheme.space12),
                  Container(
                    padding: EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.primary),
                        SizedBox(width: AppTheme.space12),
                        Text(
                          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: AppTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.space24),

                  // FR and SR Input
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FR Result', style: AppTheme.heading3),
                            SizedBox(height: AppTheme.space12),
                            Container(
                              padding: EdgeInsets.all(AppTheme.space4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.frGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              child: TextField(
                                controller: _frController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '00',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                                ),
                                enabled: !_isLoading,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppTheme.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SR Result', style: AppTheme.heading3),
                            SizedBox(height: AppTheme.space12),
                            Container(
                              padding: EdgeInsets.all(AppTheme.space4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.srGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              child: TextField(
                                controller: _srController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '00',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                                ),
                                enabled: !_isLoading,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.space32),

                  // Error/Success Messages
                  if (_error != null)
                    Container(
                      padding: EdgeInsets.all(AppTheme.space12),
                      margin: EdgeInsets.only(bottom: AppTheme.space16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          SizedBox(width: AppTheme.space8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_successMessage != null)
                    Container(
                      padding: EdgeInsets.all(AppTheme.space12),
                      margin: EdgeInsets.only(bottom: AppTheme.space16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                          SizedBox(width: AppTheme.space8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: EdgeInsets.symmetric(vertical: AppTheme.space16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit Result',
                              style: AppTheme.buttonText.copyWith(fontSize: size.width * 0.04),
                            ),
                    ),
                  ),
                  SizedBox(height: AppTheme.space16),

                  // Info
                  Center(
                    child: Text(
                      'Results are automatically analyzed for AI predictions',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
