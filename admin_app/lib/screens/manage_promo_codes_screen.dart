import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PromoCode {
  final int id;
  final String code;
  final int discountPercent;
  final int? maxUses;
  final int currentUses;
  final String? validUntil;
  final bool isActive;
  final String? description;

  PromoCode({
    required this.id,
    required this.code,
    required this.discountPercent,
    this.maxUses,
    required this.currentUses,
    this.validUntil,
    required this.isActive,
    this.description,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'],
      code: json['code'] ?? '',
      discountPercent: json['discount_percent'] ?? 0,
      maxUses: json['max_uses'],
      currentUses: json['current_uses'] ?? 0,
      validUntil: json['valid_until'],
      isActive: json['is_active'] ?? true,
      description: json['description'],
    );
  }
}

class ManagePromoCodesScreen extends StatefulWidget {
  const ManagePromoCodesScreen({super.key});

  @override
  State<ManagePromoCodesScreen> createState() => _ManagePromoCodesScreenState();
}

class _ManagePromoCodesScreenState extends State<ManagePromoCodesScreen> {
  List<PromoCode> _promoCodes = [];
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  // Form controllers for creating new promo code
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _fetchPromoCodes();
  }

  Future<void> _fetchPromoCodes() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://teerkhela-production.up.railway.app/api/promo-codes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _promoCodes = data.map((item) => PromoCode.fromJson(item)).toList();
        });
      } else {
        _showMessage('Failed to load promo codes', false);
      }
    } catch (e) {
      _showMessage('Error: Check internet connection', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPromoCode() async {
    if (_codeController.text.trim().isEmpty || _discountController.text.trim().isEmpty) {
      _showMessage('Code and discount are required', false);
      return;
    }

    final discount = int.tryParse(_discountController.text.trim());
    if (discount == null || discount < 0 || discount > 100) {
      _showMessage('Discount must be 0-100', false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> body = {
        'code': _codeController.text.trim().toUpperCase(),
        'discount_percent': discount,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      };

      if (_maxUsesController.text.trim().isNotEmpty) {
        body['max_uses'] = int.tryParse(_maxUsesController.text.trim());
      }

      if (_selectedExpiryDate != null) {
        body['valid_until'] = _selectedExpiryDate!.toIso8601String();
      }

      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/promo-codes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        _showMessage('✅ Promo code created successfully!', true);
        _clearForm();
        _fetchPromoCodes();
        if (mounted) Navigator.pop(context);
      } else {
        _showMessage('❌ ${data['error'] ?? 'Failed to create promo code'}', false);
      }
    } catch (e) {
      _showMessage('❌ Error: Check internet', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePromoCode(int id, bool currentStatus) async {
    try {
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/promo-codes/$id/toggle'),
      );

      if (response.statusCode == 200) {
        _showMessage('✅ Promo code ${currentStatus ? 'deactivated' : 'activated'}', true);
        _fetchPromoCodes();
      } else {
        _showMessage('❌ Failed to toggle promo code', false);
      }
    } catch (e) {
      _showMessage('❌ Error: Check internet', false);
    }
  }

  Future<void> _deletePromoCode(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://teerkhela-production.up.railway.app/api/promo-codes/$id'),
      );

      if (response.statusCode == 200) {
        _showMessage('✅ Promo code deleted', true);
        _fetchPromoCodes();
      } else {
        _showMessage('❌ Failed to delete promo code', false);
      }
    } catch (e) {
      _showMessage('❌ Error: Check internet', false);
    }
  }

  void _clearForm() {
    _codeController.clear();
    _discountController.clear();
    _maxUsesController.clear();
    _descriptionController.clear();
    _selectedExpiryDate = null;
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

  void _showCreateDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Promo Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Code *',
                    hintText: 'SUMMER50',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Discount % *',
                    hintText: '0-100',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxUsesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Max Uses (optional)',
                    hintText: 'Leave empty for unlimited',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Summer sale discount',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => _selectedExpiryDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedExpiryDate == null
                              ? 'No expiry date'
                              : 'Expires: ${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createPromoCode(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
              ),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _maxUsesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Codes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchPromoCodes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Message Banner
          if (_message != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _isSuccess ? Colors.green[50] : Colors.red[50],
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle : Icons.error,
                    color: _isSuccess ? Colors.green[700] : Colors.red[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Promo Codes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _promoCodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No promo codes yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to create your first promo code',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _promoCodes.length,
                        itemBuilder: (context, index) {
                          final promo = _promoCodes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF667eea),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              promo.code,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              border: Border.all(color: Colors.green),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${promo.discountPercent}% OFF',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: promo.isActive,
                                        onChanged: (value) => _togglePromoCode(promo.id, promo.isActive),
                                        activeColor: const Color(0xFF667eea),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (promo.description != null && promo.description!.isNotEmpty)
                                    Text(
                                      promo.description!,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Uses: ${promo.currentUses}${promo.maxUses != null ? ' / ${promo.maxUses}' : ' (unlimited)'}',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                      ),
                                      const SizedBox(width: 16),
                                      if (promo.validUntil != null) ...[
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Expires: ${DateTime.parse(promo.validUntil!).day}/${DateTime.parse(promo.validUntil!).month}/${DateTime.parse(promo.validUntil!).year}',
                                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                        ),
                                      ] else
                                        Text(
                                          'No expiry',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: promo.isActive ? Colors.green[100] : Colors.red[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          promo.isActive ? 'ACTIVE' : 'INACTIVE',
                                          style: TextStyle(
                                            color: promo.isActive ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Promo Code'),
                                              content: Text('Are you sure you want to delete "${promo.code}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deletePromoCode(promo.id);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Code', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
