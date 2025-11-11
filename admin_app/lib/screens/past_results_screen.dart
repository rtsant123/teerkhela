import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PastResultsScreen extends StatefulWidget {
  const PastResultsScreen({super.key});

  @override
  State<PastResultsScreen> createState() => _PastResultsScreenState();
}

class _PastResultsScreenState extends State<PastResultsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedHouse = 'shillong';
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  final _frController = TextEditingController();
  final _srController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  final List<Map<String, String>> _houses = [
    {'id': 'shillong', 'name': 'Shillong Teer'},
    {'id': 'khanapara', 'name': 'Khanapara Teer'},
    {'id': 'juwai', 'name': 'Juwai Teer'},
    {'id': 'bhutan', 'name': 'Bhutan Teer'},
    {'id': 'shillong-morning', 'name': 'Shillong Morning'},
    {'id': 'juwai-morning', 'name': 'Juwai Morning'},
    {'id': 'khanapara-morning', 'name': 'Khanapara Morning'},
    {'id': 'shillong-night', 'name': 'Shillong Night'},
    {'id': 'night', 'name': 'Night Teer'},
    {'id': 'first', 'name': 'First Teer'},
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitResult() async {
    if (!_formKey.currentState!.validate()) return;

    final fr = int.tryParse(_frController.text.trim());
    final sr = int.tryParse(_srController.text.trim());

    if (fr == null || sr == null || fr < 0 || fr > 99 || sr < 0 || sr > 99) {
      _showMessage('Numbers must be 0-99', false);
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final dateStr = _selectedDate.toIso8601String().split('T')[0];
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/results/manual-entry'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'game': _selectedHouse,
          'date': dateStr,
          'fr': fr,
          'sr': sr,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        _showMessage('✅ Result added for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}!', true);
        _frController.clear();
        _srController.clear();
      } else {
        _showMessage('❌ Failed: ${data['message']}', false);
      }
    } catch (e) {
      _showMessage('❌ Error: Check internet', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, bool success) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  void dispose() {
    _frController.dispose();
    _srController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Past Results', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add historical results one by one',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date Selector
              const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                          const SizedBox(width: 12),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // House Selector
              const Text('Select House', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: _selectedHouse,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 30),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  items: _houses.map((house) => DropdownMenuItem<String>(
                    value: house['id'],
                    child: Text(house['name']!),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedHouse = value);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Number Inputs
              const Text('Enter Results (00-99)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _frController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'FR',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 28),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 24),
                        ),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _srController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'SR',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 28),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 24),
                        ),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Message
              if (_message != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _isSuccess ? Colors.green : Colors.red, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(_isSuccess ? Icons.check_circle : Icons.error, color: _isSuccess ? Colors.green[700] : Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_message!, style: TextStyle(color: _isSuccess ? Colors.green[700] : Colors.red[700], fontSize: 14, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                      : const Text('ADD PAST RESULT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
