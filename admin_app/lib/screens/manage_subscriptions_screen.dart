import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageSubscriptionsScreen extends StatefulWidget {
  const ManageSubscriptionsScreen({super.key});

  @override
  State<ManageSubscriptionsScreen> createState() => _ManageSubscriptionsScreenState();
}

class _ManageSubscriptionsScreenState extends State<ManageSubscriptionsScreen> {
  List<dynamic> _packages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/subscription-packages'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _packages = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load packages';
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

  void _showAddPackageDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final daysController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPopular = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Subscription Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                    hintText: 'e.g., Monthly Premium',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (₹)',
                    hintText: 'e.g., 49',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (days)',
                    hintText: 'e.g., 30',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Full access to all features',
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Mark as Popular'),
                  value: isPopular,
                  onChanged: (value) {
                    setState(() => isPopular = value ?? false);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
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
              onPressed: () {
                Navigator.pop(context);
                _addPackage(
                  nameController.text,
                  priceController.text,
                  daysController.text,
                  descriptionController.text,
                  isPopular,
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPackage(String name, String price, String days, String description, bool isPopular) async {
    if (name.isEmpty || price.isEmpty || days.isEmpty) {
      _showSnackBar('Please fill all required fields', false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/subscription-packages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'price': int.parse(price),
          'days': int.parse(days),
          'description': description,
          'isPopular': isPopular,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Package added successfully!', true);
        _loadPackages();
      } else {
        final data = json.decode(response.body);
        _showSnackBar('Failed: ${data['message'] ?? 'Unknown error'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  void _showEditPackageDialog(Map<String, dynamic> package) {
    final nameController = TextEditingController(text: package['name']);
    final priceController = TextEditingController(text: package['price'].toString());
    final daysController = TextEditingController(text: package['days'].toString());
    final descriptionController = TextEditingController(text: package['description'] ?? '');
    bool isPopular = package['is_popular'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (₹)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (days)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Mark as Popular'),
                  value: isPopular,
                  onChanged: (value) {
                    setState(() => isPopular = value ?? false);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
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
              onPressed: () {
                Navigator.pop(context);
                _editPackage(
                  package['id'],
                  nameController.text,
                  priceController.text,
                  daysController.text,
                  descriptionController.text,
                  isPopular,
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editPackage(int id, String name, String price, String days, String description, bool isPopular) async {
    if (name.isEmpty || price.isEmpty || days.isEmpty) {
      _showSnackBar('Please fill all required fields', false);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/subscription-packages/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'price': int.parse(price),
          'days': int.parse(days),
          'description': description,
          'isPopular': isPopular,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Package updated successfully!', true);
        _loadPackages();
      } else {
        final data = json.decode(response.body);
        _showSnackBar('Failed: ${data['message'] ?? 'Unknown error'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  void _showDeleteDialog(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "${package['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePackage(package['id']);
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

  Future<void> _deletePackage(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/subscription-packages/$id'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Package deleted successfully!', true);
        _loadPackages();
      } else {
        final data = json.decode(response.body);
        _showSnackBar('Failed: ${data['message'] ?? 'Unknown error'}', false);
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
        title: const Text('Manage Subscriptions', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9C27B0),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackages,
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
                        onPressed: _loadPackages,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _packages.isEmpty
                  ? const Center(
                      child: Text('No subscription packages yet.\nTap + to add one.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _packages.length,
                      itemBuilder: (context, index) {
                        final package = _packages[index];
                        final isPopular = package['is_popular'] ?? false;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.card_membership, color: Colors.white),
                                    ),
                                    if (isPopular)
                                      const Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  package['name'] ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('₹${package['price']} for ${package['days']} days'),
                                    if (package['description'] != null && package['description'].toString().isNotEmpty)
                                      Text(
                                        package['description'],
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPopular ? Colors.amber[100] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isPopular ? 'POPULAR' : 'ACTIVE',
                                    style: TextStyle(
                                      color: isPopular ? Colors.amber[900] : Colors.grey[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showEditPackageDialog(package),
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
                                        onPressed: () => _showDeleteDialog(package),
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
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPackageDialog,
        backgroundColor: const Color(0xFF9C27B0),
        label: const Text('Add Package'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
