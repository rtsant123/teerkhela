import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/admin_home_screen.dart';
import 'screens/past_results_screen.dart';
import 'screens/manage_houses_screen.dart';
import 'screens/send_bonus_screen.dart';
import 'screens/manage_subscriptions_screen.dart';
import 'screens/manage_fomo_screen.dart';
import 'screens/manage_payment_methods_screen.dart';
import 'screens/payment_approvals_screen.dart';

void main() {
  runApp(const TeerAdminApp());
}

class TeerAdminApp extends StatelessWidget {
  const TeerAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teer Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF667eea),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AdminHomeScreen(),
        '/add-result': (context) => const AddResultScreen(),
        '/past-results': (context) => const PastResultsScreen(),
        '/manage-houses': (context) => const ManageHousesScreen(),
        '/manage-subscriptions': (context) => const ManageSubscriptionsScreen(),
        '/manage-fomo': (context) => const ManageFomoScreen(),
        '/send-bonus': (context) => const SendBonusScreen(),
        '/manage-payment-methods': (context) => const ManagePaymentMethodsScreen(),
        '/payment-approvals': (context) => const PaymentApprovalsScreen(),
      },
    );
  }
}

class AddResultScreen extends StatefulWidget {
  const AddResultScreen({super.key});

  @override
  State<AddResultScreen> createState() => _AddResultScreenState();
}

class _AddResultScreenState extends State<AddResultScreen> {
  final _frController = TextEditingController();
  final _srController = TextEditingController();
  String _selectedHouse = 'shillong';
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

  Future<void> _submitResult() async {
    final fr = _frController.text.trim();
    final sr = _srController.text.trim();

    if (fr.isEmpty || sr.isEmpty) {
      _showMessage('Please enter both FR and SR', false);
      return;
    }

    final frNum = int.tryParse(fr);
    final srNum = int.tryParse(sr);

    if (frNum == null || srNum == null || frNum < 0 || frNum > 99 || srNum < 0 || srNum > 99) {
      _showMessage('Numbers must be 0-99', false);
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final date = DateTime.now().toIso8601String().split('T')[0];
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/results/manual-entry'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'game': _selectedHouse,
          'date': date,
          'fr': frNum,
          'sr': srNum,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        _showMessage('✅ Result added!', true);
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
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Teer Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Color(0xFF667eea).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text('Today: $dateStr', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Select House', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
              ),
              child: DropdownButton<String>(
                value: _selectedHouse,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, size: 30),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                items: _houses.map((house) => DropdownMenuItem<String>(value: house['id'], child: Text(house['name']!))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedHouse = value);
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text('Enter Results (00-99)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]), borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: _frController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: const InputDecoration(hintText: 'FR', hintStyle: TextStyle(color: Colors.white54, fontSize: 32), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 30)),
                      enabled: !_isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]), borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: _srController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: const InputDecoration(hintText: 'SR', hintStyle: TextStyle(color: Colors.white54, fontSize: 32), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 30)),
                      enabled: !_isLoading,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: _isSuccess ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: _isSuccess ? Colors.green : Colors.red, width: 2)),
                child: Row(
                  children: [
                    Icon(_isSuccess ? Icons.check_circle : Icons.error, color: _isSuccess ? Colors.green[700] : Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_message!, style: TextStyle(color: _isSuccess ? Colors.green[700] : Colors.red[700], fontSize: 14, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitResult,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text('SUBMIT RESULT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(child: Text('Results update instantly in user app', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _frController.dispose();
    _srController.dispose();
    super.dispose();
  }
}
