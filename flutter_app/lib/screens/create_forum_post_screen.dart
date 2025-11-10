import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class CreateForumPostScreen extends StatefulWidget {
  const CreateForumPostScreen({super.key});

  @override
  State<CreateForumPostScreen> createState() => _CreateForumPostScreenState();
}

class _CreateForumPostScreenState extends State<CreateForumPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  List<TeerGame> _games = [];
  String? _selectedGame;
  String _predictionType = 'FR';
  Set<int> _selectedNumbers = {};
  double _confidence = 75.0;
  bool _isLoading = false;
  bool _isLoadingGames = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final games = await ApiService.getGames();
      setState(() {
        _games = games;
        if (games.isNotEmpty) {
          _selectedGame = games[0].name;
        }
        _isLoadingGames = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGames = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load games: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  // Validate that description doesn't contain URLs
  bool _containsUrl(String text) {
    final urlPattern = RegExp(
      r'(https?:\/\/|www\.|http:\/\/|\.com|\.net|\.org|\.in|\.co|ftp:\/\/)',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one number'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    if (_selectedGame == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a game'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Check for URLs in description
    if (_containsUrl(_descriptionController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Links are not allowed in forum posts. Please remove any URLs.'),
          backgroundColor: AppTheme.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId ?? '';
      final username = userProvider.user?.email?.split('@')[0] ?? 'User${userId.substring(0, 4)}';

      await ApiService.createForumPost(
        userId: userId,
        username: username,
        game: _selectedGame!,
        predictionType: _predictionType,
        numbers: _selectedNumbers.toList()..sort(),
        confidence: _confidence.round(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to post. Please check your internet connection.'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitPost,
            ),
          ),
        );
      }
      print('Forum post error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleNumber(int number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        if (_selectedNumbers.length < 10) {
          _selectedNumbers.add(number);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 10 numbers allowed'),
              backgroundColor: AppTheme.warning,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingGames
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Selection
                    _buildSectionTitle('Select Game', size),
                    SizedBox(height: AppTheme.space12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGame,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: size.width * 0.04,
                          ),
                          items: _games.map((game) {
                            return DropdownMenuItem<String>(
                              value: game.name,
                              child: Text(game.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGame = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.space24),

                    // Prediction Type (FR/SR)
                    _buildSectionTitle('Prediction Type', size),
                    SizedBox(height: AppTheme.space12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPredictionTypeButton(
                            'FR',
                            'First Round',
                            AppTheme.frColor,
                            size,
                          ),
                        ),
                        SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: _buildPredictionTypeButton(
                            'SR',
                            'Second Round',
                            AppTheme.srColor,
                            size,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.space24),

                    // Number Selection
                    _buildSectionTitle(
                      'Select Numbers (up to 10)',
                      size,
                      subtitle: '${_selectedNumbers.length}/10 selected',
                    ),
                    SizedBox(height: AppTheme.space12),
                    _buildNumberPicker(size),
                    SizedBox(height: AppTheme.space24),

                    // Confidence Slider
                    _buildSectionTitle(
                      'Confidence Level',
                      size,
                      subtitle: '${_confidence.round()}%',
                    ),
                    SizedBox(height: AppTheme.space12),
                    Container(
                      padding: EdgeInsets.all(size.width * 0.04),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: _getConfidenceColor(_confidence.round()),
                              inactiveTrackColor: AppTheme.surfaceVariant,
                              thumbColor: _getConfidenceColor(_confidence.round()),
                              overlayColor: _getConfidenceColor(_confidence.round()).withOpacity(0.2),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _confidence,
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: '${_confidence.round()}%',
                              onChanged: (value) {
                                setState(() {
                                  _confidence = value;
                                });
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Low',
                                style: AppTheme.bodySmall.copyWith(
                                  fontSize: size.width * 0.03,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              Text(
                                'High',
                                style: AppTheme.bodySmall.copyWith(
                                  fontSize: size.width * 0.03,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.space24),

                    // Description
                    _buildSectionTitle('Description (Optional)', size),
                    SizedBox(height: AppTheme.space8),
                    Text(
                      'Share your insights (text only, no links or images)',
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: size.width * 0.03,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    SizedBox(height: AppTheme.space12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        maxLength: 200,
                        style: AppTheme.bodyMedium.copyWith(
                          fontSize: size.width * 0.035,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Example: These numbers are based on recent patterns...',
                          hintStyle: AppTheme.bodyMedium.copyWith(
                            fontSize: size.width * 0.033,
                            color: AppTheme.textTertiary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(size.width * 0.04),
                        ),
                        onChanged: (value) {
                          // Real-time URL checking
                          if (_containsUrl(value)) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Links are not allowed'),
                                backgroundColor: AppTheme.warning,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: AppTheme.space16),

                    // Community Guidelines
                    Container(
                      padding: EdgeInsets.all(size.width * 0.03),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.info.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: size.width * 0.04,
                            color: AppTheme.info,
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: Text(
                              'Community Guidelines: Share predictions with text only. Links, images, and spam are not allowed.',
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: size.width * 0.029,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.space24),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: size.width * 0.13,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.buttonShadow(AppTheme.primary),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Post to Community',
                                style: AppTheme.buttonText.copyWith(
                                  fontSize: size.width * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.04),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, Size size, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.heading3.copyWith(
            fontSize: size.width * 0.042,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: size.width * 0.035,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildPredictionTypeButton(
    String type,
    String label,
    Color color,
    Size size,
  ) {
    final isSelected = _predictionType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Clear selected numbers when switching between FR and SR
          if (_predictionType != type) {
            _selectedNumbers.clear();
          }
          _predictionType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.width * 0.04,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
          border: Border.all(
            color: isSelected ? color : AppTheme.surfaceVariant,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Column(
          children: [
            Text(
              type,
              style: AppTheme.heading2.copyWith(
                fontSize: size.width * 0.05,
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.space4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontSize: size.width * 0.03,
                color: isSelected ? color : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPicker(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: size.width * 0.015,
          mainAxisSpacing: size.width * 0.015,
          childAspectRatio: 1,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          final isSelected = _selectedNumbers.contains(index);
          return GestureDetector(
            onTap: () => _toggleNumber(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: size.width * 0.028,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) {
      return AppTheme.success;
    } else if (confidence >= 80) {
      return AppTheme.info;
    } else if (confidence >= 70) {
      return AppTheme.warning;
    } else {
      return AppTheme.textTertiary;
    }
  }
}
