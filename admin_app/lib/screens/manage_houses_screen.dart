import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageHousesScreen extends StatefulWidget {
  const ManageHousesScreen({super.key});

  @override
  State<ManageHousesScreen> createState() => _ManageHousesScreenState();
}

class _ManageHousesScreenState extends State<ManageHousesScreen> {
  List<dynamic> _houses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://teerkhela-production.up.railway.app/api/games'),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _houses = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load houses';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _showAddHouseDialog() {
    final nameController = TextEditingController();
    final displayNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New House'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'House ID (lowercase)',
                hintText: 'e.g., bhutan-morning',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Bhutan Morning Teer',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addHouse(nameController.text, displayNameController.text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addHouse(String name, String displayName) async {
    if (name.isEmpty || displayName.isEmpty) {
      _showSnackBar('Please fill all fields', false);
      return;
    }

    // Validate name format (lowercase, alphanumeric with hyphens)
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(name)) {
      _showSnackBar('House ID must be lowercase alphanumeric with hyphens only', false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/games'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'displayName': displayName,
          'region': 'General',
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          _showSnackBar('House added successfully!', true);
          _loadHouses();
        } else {
          _showSnackBar('Failed: ${data['message'] ?? 'Unknown error'}', false);
        }
      } else {
        _showSnackBar('Failed: ${data['message'] ?? 'HTTP ${response.statusCode}'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  void _showBulkUploadDialog(String houseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload 30 Days Results\n$houseName'),
        content: const Text('This will generate and upload random FR/SR results for the past 30 days.\n\nThis is useful for initial setup. Real results should be added daily.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bulkUploadResults(houseName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate & Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkUploadResults(String houseName) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading 30 days of results...'),
          ],
        ),
      ),
    );

    try {
      // Generate 30 days of random results
      final results = <Map<String, dynamic>>[];
      final now = DateTime.now();
      final random = DateTime.now().millisecondsSinceEpoch;

      for (int i = 1; i <= 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        // Generate random FR and SR (0-99) with better randomization
        final fr = ((random + i * 13) % 100);
        final sr = ((random + i * 17 + 23) % 100);

        results.add({
          'date': dateStr,
          'fr': fr,
          'sr': sr,
        });
      }

      // Upload to API
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/results/bulk-historical'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'game': houseName,
          'results': results,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close progress dialog

      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          _showSnackBar('✅ Successfully uploaded 30 days of results!', true);
        } else {
          _showSnackBar('❌ Failed: ${data['message'] ?? 'Unknown error'}', false);
        }
      } else {
        _showSnackBar('❌ Failed: ${data['message'] ?? 'HTTP ${response.statusCode}'}', false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        _showSnackBar('❌ Error: $e', false);
      }
    }
  }

  void _showEditHouseDialog(Map<String, dynamic> house) {
    final nameController = TextEditingController(text: house['name']);
    final displayNameController = TextEditingController(text: house['display_name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit House'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'House ID (lowercase)',
                hintText: 'e.g., bhutan-morning',
              ),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Bhutan Morning Teer',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editHouse(house['name'], displayNameController.text);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _editHouse(String name, String displayName) async {
    if (displayName.isEmpty) {
      _showSnackBar('Display name cannot be empty', false);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/games/$name'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'displayName': displayName,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar('House updated successfully!', true);
        _loadHouses();
      } else {
        _showSnackBar('Failed: ${data['message'] ?? 'HTTP ${response.statusCode}'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  void _showDeleteDialog(Map<String, dynamic> house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: Text('Are you sure you want to delete "${house['display_name']}"?\n\nThis will remove all results and predictions for this house.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHouse(house['name']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHouse(String name) async {
    try {
      final response = await http.delete(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/games/$name'),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar('House deleted successfully!', true);
        _loadHouses();
      } else {
        _showSnackBar('Failed: ${data['message'] ?? 'HTTP ${response.statusCode}'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Houses', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHouses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHouses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _houses.length,
                  itemBuilder: (context, index) {
                    final house = _houses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.home_work, color: Colors.white),
                            ),
                            title: Text(
                              house['display_name'] ?? house['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('ID: ${house['name']}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: house['is_active'] == true ? Colors.green[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                house['is_active'] == true ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: house['is_active'] == true ? Colors.green[700] : Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showEditHouseDialog(house),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showDeleteDialog(house),
                                    icon: const Icon(Icons.delete, size: 16),
                                    label: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: ElevatedButton.icon(
                              onPressed: () => _showBulkUploadDialog(house['name']),
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Upload 30 Days Results'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHouseDialog,
        backgroundColor: const Color(0xFF667eea),
        label: const Text('Add House'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
