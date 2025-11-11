import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendBonusScreen extends StatefulWidget {
  const SendBonusScreen({super.key});

  @override
  State<SendBonusScreen> createState() => _SendBonusScreenState();
}

class _SendBonusScreenState extends State<SendBonusScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill all fields', false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/notification/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'message': message,
          'type': 'bonus',
        }),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        _showSnackBar('✅ Notification sent to all users!', true);
        _titleController.clear();
        _messageController.clear();
      } else {
        _showSnackBar('❌ Failed: ${data['message']}', false);
      }
    } catch (e) {
      _showSnackBar('❌ Error: $e', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Bonus Notification', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFF06292)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notify All Users',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Send bonus alerts to all app users',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title Input
            const Text('Notification Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Bonus Numbers Available!',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.title),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // Message Input
            const Text('Notification Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'e.g., Check today\'s hot numbers for big wins!',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.message),
              ),
              maxLines: 4,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // Quick Templates
            const Text('Quick Templates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTemplateChip('Bonus Alert', 'Special bonus numbers available now!'),
                _buildTemplateChip('Hot Numbers', 'Today\'s hot numbers are ready!'),
                _buildTemplateChip('Big Win', 'Check the winning numbers now!'),
              ],
            ),
            const SizedBox(height: 32),

            // Send Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendNotification,
                icon: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: const Text('SEND TO ALL USERS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String title, String message) {
    return ActionChip(
      label: Text(title),
      onPressed: () {
        setState(() {
          _titleController.text = title;
          _messageController.text = message;
        });
      },
      backgroundColor: Colors.blue[50],
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }
}
