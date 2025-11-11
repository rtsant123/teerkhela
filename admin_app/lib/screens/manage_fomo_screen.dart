import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageFomoScreen extends StatefulWidget {
  const ManageFomoScreen({super.key});

  @override
  State<ManageFomoScreen> createState() => _ManageFomoScreenState();
}

class _ManageFomoScreenState extends State<ManageFomoScreen> {
  List<dynamic> _fomoItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFomoItems();
  }

  Future<void> _loadFomoItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/fomo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fomoItems = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load FOMO items';
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

  void _showAddFomoDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'accuracy';
    bool isActive = true;

    final types = {
      'accuracy': 'Accuracy Stat',
      'winner': 'Winner Count',
      'users': 'Active Users',
      'testimonial': 'User Testimonial',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add FOMO Content'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Content Type',
                    border: OutlineInputBorder(),
                  ),
                  items: types.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., 95% Accurate Predictions',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'e.g., Our AI predictions helped 500+ users win this week!',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() => isActive = value ?? true);
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
                _addFomoItem(
                  selectedType,
                  titleController.text,
                  messageController.text,
                  isActive,
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFomoItem(String type, String title, String message, bool isActive) async {
    if (title.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill all fields', false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/fomo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': type,
          'title': title,
          'message': message,
          'isActive': isActive,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('FOMO content added successfully!', true);
        _loadFomoItems();
      } else {
        final data = json.decode(response.body);
        _showSnackBar('Failed: ${data['message'] ?? 'Unknown error'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  void _showEditFomoDialog(Map<String, dynamic> item) {
    final titleController = TextEditingController(text: item['title']);
    final messageController = TextEditingController(text: item['message']);
    String selectedType = item['type'] ?? 'accuracy';
    bool isActive = item['is_active'] ?? true;

    final types = {
      'accuracy': 'Accuracy Stat',
      'winner': 'Winner Count',
      'users': 'Active Users',
      'testimonial': 'User Testimonial',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit FOMO Content'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Content Type',
                    border: OutlineInputBorder(),
                  ),
                  items: types.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() => isActive = value ?? true);
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
                _editFomoItem(
                  item['id'],
                  selectedType,
                  titleController.text,
                  messageController.text,
                  isActive,
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editFomoItem(int id, String type, String title, String message, bool isActive) async {
    if (title.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill all fields', false);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/fomo/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': type,
          'title': title,
          'message': message,
          'isActive': isActive,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('FOMO content updated successfully!', true);
        _loadFomoItems();
      } else {
        final data = json.decode(response.body);
        _showSnackBar('Failed: ${data['message'] ?? 'Unknown error'}', false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete FOMO Content'),
        content: Text('Are you sure you want to delete "${item['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFomoItem(item['id']);
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

  Future<void> _deleteFomoItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://teerkhela-production.up.railway.app/api/admin/fomo/$id'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('FOMO content deleted successfully!', true);
        _loadFomoItems();
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'accuracy':
        return Icons.trending_up;
      case 'winner':
        return Icons.emoji_events;
      case 'users':
        return Icons.people;
      case 'testimonial':
        return Icons.format_quote;
      default:
        return Icons.campaign;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'accuracy':
        return Colors.green;
      case 'winner':
        return Colors.amber;
      case 'users':
        return Colors.blue;
      case 'testimonial':
        return Colors.purple;
      default:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FOMO Manager', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00BCD4),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFomoItems,
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
                        onPressed: _loadFomoItems,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _fomoItems.isEmpty
                  ? const Center(
                      child: Text('No FOMO content yet.\nTap + to add one.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _fomoItems.length,
                      itemBuilder: (context, index) {
                        final item = _fomoItems[index];
                        final type = item['type'] ?? 'accuracy';
                        final isActive = item['is_active'] ?? true;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getColorForType(type),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getIconForType(type),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  item['title'] ?? 'Untitled',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      item['message'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getColorForType(type),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green[100] : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE' : 'INACTIVE',
                                    style: TextStyle(
                                      color: isActive ? Colors.green[700] : Colors.red[700],
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
                                        onPressed: () => _showEditFomoDialog(item),
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
                                        onPressed: () => _showDeleteDialog(item),
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
        onPressed: _showAddFomoDialog,
        backgroundColor: const Color(0xFF00BCD4),
        label: const Text('Add FOMO'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
