import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/dream_interpretation.dart';
import '../utils/app_theme.dart';
import '../utils/screenshot_protection.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class DreamScreen extends StatefulWidget {
  const DreamScreen({super.key});

  @override
  State<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends State<DreamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dreamController = TextEditingController();
  String _selectedGame = 'shillong';
  bool _isLoading = false;
  String _loadingMessage = '';
  int _loadingStep = 0;
  DreamInterpretation? _result;
  String _searchQuery = '';

  final Map<String, String> _games = {
    'shillong': 'Shillong Teer',
    'khanapara': 'Khanapara Teer',
    'juwai': 'Juwai Teer',
    'shillong-morning': 'Shillong Morning',
    'khanapara-morning': 'Khanapara Morning',
    'juwai-morning': 'Juwai Morning',
  };

  // Dream symbols database with numbers
  final List<Map<String, dynamic>> _symbols = [
    {'symbol': 'Snake', 'hindi': 'साँप', 'numbers': [05, 15, 50, 51]},
    {'symbol': 'Tiger', 'hindi': 'बाघ', 'numbers': [08, 18, 80, 88]},
    {'symbol': 'Elephant', 'hindi': 'हाथी', 'numbers': [01, 10, 11, 91]},
    {'symbol': 'Fish', 'hindi': 'मछली', 'numbers': [09, 19, 90, 99]},
    {'symbol': 'Dog', 'hindi': 'कुत्ता', 'numbers': [02, 12, 20, 22]},
    {'symbol': 'Cat', 'hindi': 'बिल्ली', 'numbers': [03, 13, 30, 33]},
    {'symbol': 'Bird', 'hindi': 'पक्षी', 'numbers': [04, 14, 40, 44]},
    {'symbol': 'Horse', 'hindi': 'घोड़ा', 'numbers': [07, 17, 70, 77]},
    {'symbol': 'Cow', 'hindi': 'गाय', 'numbers': [06, 16, 60, 66]},
    {'symbol': 'Rat', 'hindi': 'चूहा', 'numbers': [21, 31, 41, 51]},
    {'symbol': 'Water', 'hindi': 'पानी', 'numbers': [00, 10, 20, 30]},
    {'symbol': 'Fire', 'hindi': 'आग', 'numbers': [23, 32, 45, 54]},
    {'symbol': 'Moon', 'hindi': 'चाँद', 'numbers': [24, 42, 46, 64]},
    {'symbol': 'Sun', 'hindi': 'सूरज', 'numbers': [01, 11, 21, 31]},
    {'symbol': 'Tree', 'hindi': 'पेड़', 'numbers': [25, 52, 55, 85]},
    {'symbol': 'Mountain', 'hindi': 'पहाड़', 'numbers': [26, 62, 72, 82]},
    {'symbol': 'River', 'hindi': 'नदी', 'numbers': [27, 72, 37, 73]},
    {'symbol': 'House', 'hindi': 'घर', 'numbers': [28, 82, 48, 84]},
    {'symbol': 'Temple', 'hindi': 'मंदिर', 'numbers': [29, 92, 39, 93]},
    {'symbol': 'God/Goddess', 'hindi': 'भगवान', 'numbers': [01, 11, 21, 91]},
    {'symbol': 'Money', 'hindi': 'पैसा', 'numbers': [34, 43, 53, 63]},
    {'symbol': 'Gold', 'hindi': 'सोना', 'numbers': [35, 53, 75, 95]},
    {'symbol': 'Silver', 'hindi': 'चाँदी', 'numbers': [36, 63, 76, 96]},
    {'symbol': 'King', 'hindi': 'राजा', 'numbers': [37, 73, 77, 97]},
    {'symbol': 'Queen', 'hindi': 'रानी', 'numbers': [38, 83, 78, 98]},
    {'symbol': 'Baby', 'hindi': 'बच्चा', 'numbers': [39, 93, 29, 92]},
    {'symbol': 'Marriage', 'hindi': 'शादी', 'numbers': [45, 54, 65, 56]},
    {'symbol': 'Death', 'hindi': 'मृत्यु', 'numbers': [41, 14, 47, 74]},
    {'symbol': 'Blood', 'hindi': 'खून', 'numbers': [42, 24, 52, 25]},
    {'symbol': 'Rain', 'hindi': 'बारिश', 'numbers': [43, 34, 63, 36]},
    {'symbol': 'Flower', 'hindi': 'फूल', 'numbers': [44, 54, 64, 74]},
    {'symbol': 'Fruit', 'hindi': 'फल', 'numbers': [46, 64, 56, 65]},
    {'symbol': 'Vegetable', 'hindi': 'सब्जी', 'numbers': [47, 74, 57, 75]},
    {'symbol': 'Rice', 'hindi': 'चावल', 'numbers': [48, 84, 58, 85]},
    {'symbol': 'Bread', 'hindi': 'रोटी', 'numbers': [49, 94, 59, 95]},
    {'symbol': 'Milk', 'hindi': 'दूध', 'numbers': [55, 65, 75, 85]},
    {'symbol': 'Meat', 'hindi': 'मांस', 'numbers': [56, 65, 86, 68]},
    {'symbol': 'Egg', 'hindi': 'अंडा', 'numbers': [57, 75, 87, 78]},
    {'symbol': 'Car', 'hindi': 'गाड़ी', 'numbers': [58, 85, 68, 86]},
    {'symbol': 'Train', 'hindi': 'ट्रेन', 'numbers': [59, 95, 69, 96]},
    {'symbol': 'Plane', 'hindi': 'हवाई जहाज', 'numbers': [66, 76, 86, 96]},
    {'symbol': 'Boat', 'hindi': 'नाव', 'numbers': [67, 76, 97, 79]},
    {'symbol': 'Road', 'hindi': 'सड़क', 'numbers': [68, 86, 98, 89]},
    {'symbol': 'Bridge', 'hindi': 'पुल', 'numbers': [69, 96, 99, 90]},
    {'symbol': 'School', 'hindi': 'स्कूल', 'numbers': [71, 17, 81, 18]},
    {'symbol': 'Hospital', 'hindi': 'अस्पताल', 'numbers': [72, 27, 82, 28]},
    {'symbol': 'Police', 'hindi': 'पुलिस', 'numbers': [73, 37, 83, 38]},
    {'symbol': 'Army', 'hindi': 'सेना', 'numbers': [74, 47, 84, 48]},
    {'symbol': 'Doctor', 'hindi': 'डॉक्टर', 'numbers': [75, 57, 85, 58]},
    {'symbol': 'Teacher', 'hindi': 'शिक्षक', 'numbers': [76, 67, 86, 68]},
    {'symbol': 'Father', 'hindi': 'पिता', 'numbers': [01, 10, 91, 19]},
    {'symbol': 'Mother', 'hindi': 'माता', 'numbers': [02, 20, 92, 29]},
    {'symbol': 'Brother', 'hindi': 'भाई', 'numbers': [03, 30, 93, 39]},
    {'symbol': 'Sister', 'hindi': 'बहन', 'numbers': [04, 40, 94, 49]},
    {'symbol': 'Friend', 'hindi': 'दोस्त', 'numbers': [05, 50, 95, 59]},
    {'symbol': 'Enemy', 'hindi': 'दुश्मन', 'numbers': [06, 60, 96, 69]},
    {'symbol': 'Knife', 'hindi': 'चाकू', 'numbers': [79, 97, 89, 98]},
    {'symbol': 'Gun', 'hindi': 'बंदूक', 'numbers': [88, 98, 78, 87]},
    {'symbol': 'Key', 'hindi': 'चाबी', 'numbers': [81, 18, 91, 19]},
    {'symbol': 'Lock', 'hindi': 'ताला', 'numbers': [82, 28, 92, 29]},
    {'symbol': 'Mirror', 'hindi': 'आईना', 'numbers': [83, 38, 93, 39]},
    {'symbol': 'Clock', 'hindi': 'घड़ी', 'numbers': [84, 48, 94, 49]},
    {'symbol': 'Phone', 'hindi': 'फोन', 'numbers': [85, 58, 95, 59]},
    {'symbol': 'Letter', 'hindi': 'पत्र', 'numbers': [86, 68, 96, 69]},
    {'symbol': 'Book', 'hindi': 'किताब', 'numbers': [87, 78, 97, 79]},
    {'symbol': 'Pen', 'hindi': 'कलम', 'numbers': [00, 01, 10, 11]},
    {'symbol': 'Chair', 'hindi': 'कुर्सी', 'numbers': [02, 12, 22, 32]},
    {'symbol': 'Table', 'hindi': 'मेज', 'numbers': [03, 13, 23, 33]},
    {'symbol': 'Bed', 'hindi': 'बिस्तर', 'numbers': [04, 14, 24, 34]},
    {'symbol': 'Dream', 'hindi': 'सपना', 'numbers': [07, 17, 27, 37]},
    {'symbol': 'Love', 'hindi': 'प्यार', 'numbers': [08, 18, 28, 38]},
    {'symbol': 'Anger', 'hindi': 'गुस्सा', 'numbers': [09, 19, 29, 39]},
    {'symbol': 'Fear', 'hindi': 'डर', 'numbers': [13, 31, 33, 53]},
    {'symbol': 'Happy', 'hindi': 'खुश', 'numbers': [14, 41, 44, 54]},
    {'symbol': 'Sad', 'hindi': 'दुखी', 'numbers': [15, 51, 55, 65]},
    {'symbol': 'Crying', 'hindi': 'रोना', 'numbers': [16, 61, 66, 76]},
    {'symbol': 'Laughing', 'hindi': 'हँसना', 'numbers': [17, 71, 77, 87]},
    {'symbol': 'Running', 'hindi': 'दौड़ना', 'numbers': [18, 81, 88, 98]},
    {'symbol': 'Flying', 'hindi': 'उड़ना', 'numbers': [19, 91, 99, 09]},
    {'symbol': 'Swimming', 'hindi': 'तैरना', 'numbers': [20, 02, 22, 42]},
    {'symbol': 'Eating', 'hindi': 'खाना', 'numbers': [26, 62, 66, 86]},
    {'symbol': 'Drinking', 'hindi': 'पीना', 'numbers': [27, 72, 77, 97]},
    {'symbol': 'Sleeping', 'hindi': 'सोना', 'numbers': [28, 82, 88, 08]},
    {'symbol': 'Dancing', 'hindi': 'नाचना', 'numbers': [29, 92, 99, 09]},
    {'symbol': 'Singing', 'hindi': 'गाना', 'numbers': [33, 43, 53, 63]},
    {'symbol': 'Fighting', 'hindi': 'लड़ना', 'numbers': [34, 43, 44, 54]},
    {'symbol': 'Winning', 'hindi': 'जीतना', 'numbers': [35, 53, 55, 75]},
    {'symbol': 'Losing', 'hindi': 'हारना', 'numbers': [36, 63, 66, 96]},
    {'symbol': 'White', 'hindi': 'सफेद', 'numbers': [11, 21, 31, 41]},
    {'symbol': 'Black', 'hindi': 'काला', 'numbers': [12, 21, 32, 42]},
    {'symbol': 'Red', 'hindi': 'लाल', 'numbers': [23, 32, 43, 34]},
    {'symbol': 'Blue', 'hindi': 'नीला', 'numbers': [24, 42, 44, 64]},
    {'symbol': 'Green', 'hindi': 'हरा', 'numbers': [25, 52, 45, 54]},
    {'symbol': 'Yellow', 'hindi': 'पीला', 'numbers': [26, 62, 46, 64]},
    {'symbol': 'Orange', 'hindi': 'नारंगी', 'numbers': [27, 72, 47, 74]},
    {'symbol': 'Pink', 'hindi': 'गुलाबी', 'numbers': [28, 82, 48, 84]},
    {'symbol': 'Purple', 'hindi': 'बैंगनी', 'numbers': [29, 92, 49, 94]},
    {'symbol': 'Sky', 'hindi': 'आकाश', 'numbers': [00, 10, 50, 60]},
    {'symbol': 'Star', 'hindi': 'तारा', 'numbers': [07, 70, 17, 71]},
    {'symbol': 'Cloud', 'hindi': 'बादल', 'numbers': [08, 80, 18, 81]},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    ScreenshotProtection.enableProtection(); // Block screenshots for premium content
  }

  @override
  void dispose() {
    ScreenshotProtection.disableProtection(); // Re-enable screenshots when leaving
    _tabController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSymbols {
    if (_searchQuery.isEmpty) return _symbols;
    return _symbols.where((s) {
      final symbol = s['symbol'].toString().toLowerCase();
      final hindi = s['hindi'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return symbol.contains(query) || hindi.contains(query);
    }).toList();
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
      _loadingStep = 0;
    });

    try {
      setState(() {
        _loadingMessage = 'Analyzing dream symbols...';
        _loadingStep = 1;
      });
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _loadingMessage = 'Matching patterns with 100+ dream symbols...';
        _loadingStep = 2;
      });
      await Future.delayed(const Duration(milliseconds: 700));

      setState(() {
        _loadingMessage = 'AI generating predictions...';
        _loadingStep = 3;
      });

      final result = await ApiService.interpretDream(
        userProvider.userId!,
        _dreamController.text,
        'auto',  // Auto-detect language
        _selectedGame,
      );

      setState(() {
        _loadingMessage = 'Preparing results...';
        _loadingStep = 4;
      });
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _result = result;
        _isLoading = false;
        _loadingStep = 0;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadingStep = 0;
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
        bottom: userProvider.isPremium ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Symbols'),
            Tab(icon: Icon(Icons.edit_note), text: 'Write Dream'),
          ],
        ) : null,
      ),
      drawer: const AppDrawer(),
      body: userProvider.isPremium
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildSymbolsTab(size),
                _buildWriteDreamTab(size),
              ],
            )
          : _buildPremiumLock(size),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildSymbolsTab(Size size) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search symbols...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // Symbols List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            itemCount: _filteredSymbols.length,
            itemBuilder: (context, index) {
              final symbol = _filteredSymbols[index];
              return Container(
                margin: EdgeInsets.only(bottom: size.width * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        symbol['symbol'].toString()[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    symbol['symbol'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.04,
                    ),
                  ),
                  subtitle: Text(
                    symbol['hindi'],
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: size.width * 0.035,
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: (symbol['numbers'] as List<int>).map((n) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          n.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.03,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWriteDreamTab(Size size) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
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

          // Game Selector
          DropdownButtonFormField<String>(
            value: _selectedGame,
            decoration: InputDecoration(
              labelText: 'Target Game',
              labelStyle: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.037,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppTheme.space16,
                vertical: AppTheme.space16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedGame = value);
            },
          ),
          SizedBox(height: AppTheme.space16),

          // Dream Input
          TextField(
            controller: _dreamController,
            maxLines: 6,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: size.width * 0.037,
            ),
            decoration: InputDecoration(
              labelText: 'Describe your dream',
              hintText: 'Enter your dream in any language...\n\nExample:\nमैंने सपने में साँप देखा\nI saw a snake in my dream',
              hintStyle: AppTheme.bodySmall.copyWith(
                fontSize: size.width * 0.032,
              ),
              contentPadding: EdgeInsets.all(AppTheme.space16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: AppTheme.space20),

          // Submit Button
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
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
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

          // Loading Animation
          if (_isLoading) _buildLoadingAnimation(size),

          // Results
          if (_result != null) _buildResults(_result!, size),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation(Size size) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            width: size.width * 0.2,
            height: size.width * 0.2,
            decoration: BoxDecoration(
              gradient: AppTheme.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: size.width * 0.1,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.space24),
          Text(
            _loadingMessage,
            style: AppTheme.subtitle1.copyWith(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.space16),
          const CircularProgressIndicator(),
          SizedBox(height: AppTheme.space16),
          Text('Step $_loadingStep of 4'),
          SizedBox(height: AppTheme.space8),
          LinearProgressIndicator(value: _loadingStep / 4),
        ],
      ),
    );
  }

  Widget _buildResults(DreamInterpretation result, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(thickness: 2, color: AppTheme.textSecondary.withOpacity(0.2)),
        SizedBox(height: AppTheme.space16),

        // Header
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.accent, size: 24),
            SizedBox(width: AppTheme.space12),
            Text('Interpretation Results', style: AppTheme.heading2),
          ],
        ),
        SizedBox(height: AppTheme.space16),

        // Symbols Found
        if (result.symbols.isNotEmpty) ...[
          Container(
            decoration: AppTheme.cardDecoration,
            padding: EdgeInsets.all(AppTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppTheme.warning, size: 20),
                    SizedBox(width: AppTheme.space8),
                    Text('Symbols Found', style: AppTheme.subtitle1),
                  ],
                ),
                SizedBox(height: AppTheme.space12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.symbols.map((symbol) {
                    return Chip(
                      label: Text(symbol),
                      backgroundColor: AppTheme.warning.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.space16),
        ],

        // Predicted Numbers
        Container(
          decoration: AppTheme.cardDecoration,
          padding: EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.stars, color: AppTheme.accent, size: 20),
                  SizedBox(width: AppTheme.space8),
                  Text('Predicted Numbers', style: AppTheme.subtitle1),
                ],
              ),
              SizedBox(height: AppTheme.space12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.numbers.map((num) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.numberGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      num.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.space16),

        // Recommendation
        Container(
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppTheme.success),
          ),
          padding: EdgeInsets.all(AppTheme.space16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 20),
              SizedBox(width: AppTheme.space12),
              Expanded(
                child: Text(
                  'Recommended for ${result.recommendation} Teer',
                  style: AppTheme.subtitle1.copyWith(color: AppTheme.success),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumLock(Size size) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.2,
              height: size.width * 0.2,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: size.width * 0.1,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.space24),
            Text('Dream AI Bot', style: AppTheme.heading1, textAlign: TextAlign.center),
            SizedBox(height: AppTheme.space12),
            Text(
              'AI-powered dream interpretation with Teer number predictions',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium,
            ),
            SizedBox(height: AppTheme.space24),
            _buildFeatureItem(Icons.list_alt, '100+ Dream Symbols', 'Comprehensive symbol database', size),
            SizedBox(height: AppTheme.space12),
            _buildFeatureItem(Icons.auto_awesome, 'AI-Powered Analysis', 'Advanced AI interprets dreams', size),
            SizedBox(height: AppTheme.space12),
            _buildFeatureItem(Icons.numbers, 'Number Predictions', 'Get FR & SR suggestions', size),
            SizedBox(height: AppTheme.space32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/subscribe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: AppTheme.space16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium, size: 20, color: Colors.white),
                    SizedBox(width: AppTheme.space8),
                    const Text(
                      'Unlock Dream AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle, Size size) {
    return Container(
      padding: EdgeInsets.all(AppTheme.space12),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.subtitle1),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
