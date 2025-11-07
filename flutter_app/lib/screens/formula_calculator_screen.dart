import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

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
      appBar: AppBar(
        title: const Text('Formula Calculator'),
      ),
      body: userProvider.isPremium
          ? _buildCalculatorView()
          : _buildPremiumGate(),
    );
  }

  Widget _buildPremiumGate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calculate,
              size: 80,
              color: Color(0xFF7c3aed),
            ),
            const SizedBox(height: 24),
            const Text(
              'Premium Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Formula calculator is available for premium members only',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/subscribe');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7c3aed),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Upgrade to Premium - ₹49/month • 50% OFF',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter previous results to calculate predictions based on traditional Teer formulas',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Game Selector
          DropdownButtonFormField<String>(
            value: _selectedGame,
            decoration: const InputDecoration(
              labelText: 'Select Game',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sports_esports),
            ),
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
          const SizedBox(height: 16),

          // Formula Selector
          DropdownButtonFormField<String>(
            value: _selectedFormula,
            decoration: const InputDecoration(
              labelText: 'Select Formula',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.functions),
            ),
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
          const SizedBox(height: 24),

          // Previous Results Section
          Row(
            children: [
              const Text(
                'Previous Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addResultField,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Result Input Fields
          ..._resultControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Result ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_resultControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _removeResultField(index),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers['fr'],
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            decoration: const InputDecoration(
                              labelText: 'FR',
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: controllers['sr'],
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            decoration: const InputDecoration(
                              labelText: 'SR',
                              border: OutlineInputBorder(),
                              counterText: '',
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

          const SizedBox(height: 24),

          // Calculate Button
          ElevatedButton(
            onPressed: _isLoading ? null : _calculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7c3aed),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                : const Text(
                    'Calculate',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),

          // Results
          if (_calculationResult != null) ...[
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            _buildResults(_calculationResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(Map<String, dynamic> result) {
    final formulaType = result['formulaType'] as String;
    final calculation = result['calculation'] as String;
    final predictedNumbers = (result['predictedNumbers'] as List).cast<int>();
    final explanation = result['explanation'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF7c3aed), size: 28),
            const SizedBox(width: 12),
            const Text(
              'Calculation Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Formula Type
        Card(
          child: ListTile(
            leading: const Icon(Icons.functions, color: Color(0xFF7c3aed)),
            title: const Text('Formula Type'),
            subtitle: Text(_formulas[formulaType] ?? formulaType),
          ),
        ),

        // Calculation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Calculation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  calculation,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // Predicted Numbers
        Card(
          color: const Color(0xFF7c3aed).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.stars, color: Color(0xFF7c3aed)),
                    SizedBox(width: 8),
                    Text(
                      'Predicted Numbers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: predictedNumbers.map((num) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7c3aed),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7c3aed).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
        ),

        // Explanation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Explanation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  explanation,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
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
