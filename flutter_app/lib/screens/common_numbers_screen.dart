import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/results_provider.dart';

class CommonNumbersScreen extends StatefulWidget {
  const CommonNumbersScreen({super.key});

  @override
  State<CommonNumbersScreen> createState() => _CommonNumbersScreenState();
}

class _CommonNumbersScreenState extends State<CommonNumbersScreen> {
  String _selectedGame = 'shillong';
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;

  final Map<String, String> _games = {
    'shillong': 'Shillong Teer',
    'khanapara': 'Khanapara Teer',
    'juwai': 'Juwai Teer',
    'shillong-morning': 'Shillong Morning',
    'khanapara-morning': 'Khanapara Morning',
    'juwai-morning': 'Juwai Morning',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final resultsProvider = Provider.of<ResultsProvider>(context, listen: false);

      _data = await resultsProvider.getCommonNumbers(_selectedGame, userProvider.userId);

      setState(() {
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
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Common Numbers'),
      ),
      body: Column(
        children: [
          // Game Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: DropdownButtonFormField<String>(
              value: _selectedGame,
              decoration: const InputDecoration(
                labelText: 'Select Game',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
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
                _loadData();
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_error!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _data == null
                        ? const Center(child: Text('No data available'))
                        : _buildDataView(userProvider.isPremium),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView(bool isPremium) {
    final hotNumbers = _data!['hotNumbers'] as List<dynamic>? ?? [];
    final coldNumbers = _data!['coldNumbers'] as List<dynamic>? ?? [];
    final commonPairs = _data!['commonPairs'] as List<dynamic>? ?? [];
    final dayWiseAnalysis = _data!['dayWiseAnalysis'] as List<dynamic>?;

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
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPremium
                          ? 'Analysis based on last 30 days'
                          : 'Analysis based on last 7 days. Upgrade for 30 days!',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hot Numbers
          _buildNumberSection(
            'Hot Numbers',
            '🔥',
            'Most frequently appeared',
            hotNumbers.cast<Map<String, dynamic>>(),
            Colors.red,
          ),
          const SizedBox(height: 16),

          // Cold Numbers
          _buildNumberSection(
            'Cold Numbers',
            '❄️',
            'Rarely appeared',
            coldNumbers.cast<Map<String, dynamic>>(),
            Colors.blue,
          ),
          const SizedBox(height: 16),

          // Common Pairs
          if (commonPairs.isNotEmpty) ...[
            _buildPairsSection(commonPairs.cast<Map<String, dynamic>>()),
            const SizedBox(height: 16),
          ],

          // Day-wise Analysis (Premium Only)
          if (isPremium && dayWiseAnalysis != null && dayWiseAnalysis.isNotEmpty)
            _buildDayWiseSection(dayWiseAnalysis.cast<Map<String, dynamic>>())
          else if (!isPremium)
            _buildPremiumUpsell(),
        ],
      ),
    );
  }

  Widget _buildNumberSection(
    String title,
    String emoji,
    String subtitle,
    List<Map<String, dynamic>> numbers,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numbers.map((item) {
                final number = item['number'] as int;
                final count = item['count'] as int;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        number.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count times',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
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
    );
  }

  Widget _buildPairsSection(List<Map<String, dynamic>> pairs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Color(0xFF7c3aed)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Common Pairs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'FR-SR combinations',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pairs.map((item) {
              final pair = item['pair'] as String;
              final count = item['count'] as int;
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7c3aed).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up, color: Color(0xFF7c3aed)),
                ),
                title: Text(pair, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Chip(
                  label: Text('$count times'),
                  backgroundColor: Colors.grey.shade200,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayWiseSection(List<Map<String, dynamic>> dayWise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Day-wise Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dayWise.map((item) {
              final day = item['day'] as String;
              final count = item['count'] as int;
              final avgFr = item['avgFr'] as String;
              final avgSr = item['avgSr'] as String;

              return ListTile(
                title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Avg FR: $avgFr | Avg SR: $avgSr'),
                trailing: Text(
                  '$count results',
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumUpsell() {
    return Card(
      color: const Color(0xFF7c3aed).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.lock,
              size: 48,
              color: Color(0xFF7c3aed),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock Day-wise Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get detailed day-wise patterns and 30 days analysis',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/subscribe');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7c3aed),
              ),
              child: const Text(
                'Upgrade to Premium - ₹29/month',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
