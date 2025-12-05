import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = false;
  final String _baseUrl = 'https://teerkhela-production.up.railway.app/api/admin';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data['data']['users'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _grantPremium(String userId) async {
    final daysController = TextEditingController(text: '30');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grant Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many days of premium access?'),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Grant'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final days = int.tryParse(daysController.text) ?? 30;
        final response = await http.post(
          Uri.parse('$_baseUrl/user/$userId/grant-premium'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'days': days}),
        );

        if (response.statusCode == 200) {
          _loadUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Premium granted for $days days')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _extendPremium(String userId) async {
    final daysController = TextEditingController(text: '30');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Extend premium by how many days?'),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Extend'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final days = int.tryParse(daysController.text) ?? 30;
        final response = await http.post(
          Uri.parse('$_baseUrl/user/$userId/extend-premium'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'days': days}),
        );

        if (response.statusCode == 200) {
          _loadUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Premium extended by $days days')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _revokePremium(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Premium'),
        content: const Text('Are you sure you want to revoke premium access for this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/user/$userId/revoke-premium'),
        );

        if (response.statusCode == 200) {
          _loadUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Premium revoked')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('$_baseUrl/user/$userId'));
        if (response.statusCode == 200) {
          _loadUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User deleted')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                itemCount: _users.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final isPremium = user['is_premium'] == true;
                  final expiryDate = user['expiry_date'];
                  final phoneNumber = user['phone_number'] ?? user['id'];
                  final createdAt = user['created_at'];

                  // Calculate days left if premium
                  int? daysLeft;
                  if (isPremium && expiryDate != null) {
                    try {
                      final expiry = DateTime.parse(expiryDate);
                      daysLeft = expiry.difference(DateTime.now()).inDays;
                    } catch (e) {
                      daysLeft = null;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Status icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isPremium ? Colors.green.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isPremium ? Icons.workspace_premium : Icons.person_outline,
                                  color: isPremium ? Colors.green.shade700 : Colors.grey.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isPremium ? Colors.green : Colors.grey,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isPremium ? 'PREMIUM' : 'FREE',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        if (isPremium && daysLeft != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '$daysLeft days left',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: daysLeft < 7 ? Colors.orange : Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),

                          // Action buttons
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Grant/Extend Premium
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => isPremium
                                    ? _extendPremium(user['id'].toString())
                                    : _grantPremium(user['id'].toString()),
                                  icon: Icon(
                                    isPremium ? Icons.add_circle : Icons.workspace_premium,
                                    size: 16,
                                  ),
                                  label: Text(
                                    isPremium ? 'Extend' : 'Grant',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPremium ? Colors.blue : Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),

                              if (isPremium) ...[
                                const SizedBox(width: 8),
                                // Revoke Premium
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _revokePremium(user['id'].toString()),
                                    icon: const Icon(Icons.remove_circle, size: 16),
                                    label: const Text(
                                      'Revoke',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(width: 8),
                              // Delete User
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _deleteUser(user['id'].toString()),
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Additional details
                          if (isPremium && expiryDate != null) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  'Expires: ${expiryDate.toString().substring(0, 10)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (createdAt != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person_add, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  'Joined: ${createdAt.toString().substring(0, 10)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
