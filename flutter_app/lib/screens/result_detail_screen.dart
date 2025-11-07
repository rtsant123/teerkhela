import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/results_provider.dart';
import '../models/result.dart';

class ResultDetailScreen extends StatefulWidget {
  final String game;

  const ResultDetailScreen({super.key, required this.game});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  List<TeerResult> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final resultsProvider = Provider.of<ResultsProvider>(context, listen: false);

      _history = await resultsProvider.getHistory(widget.game, userProvider.userId);

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
    final resultsProvider = Provider.of<ResultsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentResult = resultsProvider.getResultForGame(widget.game);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentResult?.displayName ?? widget.game),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today's Result Card
              if (currentResult != null) _buildTodayResultCard(currentResult),

              // Premium Upsell for Free Users
              if (!userProvider.isPremium)
                Card(
                  margin: const EdgeInsets.all(16),
                  color: const Color(0xFF7c3aed).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 48,
                          color: Color(0xFF7c3aed),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unlock 30 Days History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upgrade to Premium for full history and analysis',
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
                            'Upgrade Now - ₹49/month • 50% OFF',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // History Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Past Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      userProvider.isPremium ? 'Last 30 days' : 'Last 7 days',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // History Table
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadHistory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_history.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No history available'),
                  ),
                )
              else
                _buildHistoryTable(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayResultCard(TeerResult result) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7c3aed), Color(0xFFa78bfa)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Result",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResultBox('FR', result.fr),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResultBox('SR', result.sr),
                ),
              ],
            ),
            if (result.declaredTime != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Declared at ${result.declaredTime}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(String label, int? value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value?.toString().padLeft(2, '0') ?? '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFF7c3aed).withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('FR', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('SR', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _history.map((result) {
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('MMM dd').format(result.date))),
                DataCell(
                  Text(
                    result.fr?.toString().padLeft(2, '0') ?? '--',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Text(
                    result.sr?.toString().padLeft(2, '0') ?? '--',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
