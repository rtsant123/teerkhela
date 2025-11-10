import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../models/game.dart';

class AdminManageHousesScreen extends StatefulWidget {
  const AdminManageHousesScreen({super.key});

  @override
  State<AdminManageHousesScreen> createState() => _AdminManageHousesScreenState();
}

class _AdminManageHousesScreenState extends State<AdminManageHousesScreen> {
  List<TeerGame> _games = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await ApiService.getGames();
      if (mounted) {
        setState(() {
          _games = games;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final displayNameController = TextEditingController();
    final regionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New House'),
        content: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 16),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(
                  labelText: 'Region',
                  hintText: 'e.g., Bhutan',
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
            onPressed: () async {
              final name = nameController.text.trim();
              final displayName = displayNameController.text.trim();
              final region = regionController.text.trim();

              if (name.isEmpty || displayName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in House ID and Display Name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                Navigator.pop(context);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Creating house...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                await ApiService.adminCreateHouse(
                  name: name,
                  displayName: displayName,
                  region: region.isEmpty ? null : region,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('House "$displayName" created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadGames();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create house: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(TeerGame game) async {
    final nameController = TextEditingController(text: game.name);
    final displayNameController = TextEditingController(text: game.displayName);
    final regionController = TextEditingController(text: game.region ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit House'),
        content: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 16),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(
                  labelText: 'Region',
                  hintText: 'e.g., Bhutan',
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
            onPressed: () async {
              final name = nameController.text.trim();
              final displayName = displayNameController.text.trim();
              final region = regionController.text.trim();

              if (name.isEmpty || displayName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in House ID and Display Name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating house...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                await ApiService.adminUpdateHouse(
                  id: game.id,
                  name: name,
                  displayName: displayName,
                  region: region.isEmpty ? null : region,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('House "$displayName" updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadGames();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update house: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Houses'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create House'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            SizedBox(height: AppTheme.space16),
            Text(_error!, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: _loadGames,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: AppTheme.textTertiary),
            SizedBox(height: AppTheme.space16),
            Text(
              'No houses yet',
              style: AppTheme.heading2.copyWith(color: AppTheme.textSecondary),
            ),
            SizedBox(height: AppTheme.space8),
            Text(
              'Tap the button below to create your first house',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGames,
      child: ListView.builder(
        padding: EdgeInsets.all(AppTheme.space16),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return Card(
            margin: EdgeInsets.only(bottom: AppTheme.space12),
            child: ListTile(
              contentPadding: EdgeInsets.all(AppTheme.space16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: game.isActive ? AppTheme.primaryGradient : const LinearGradient(
                    colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(Icons.home_work, color: Colors.white),
              ),
              title: Text(
                game.displayName,
                style: AppTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppTheme.space4),
                  Text('ID: ${game.name}', style: AppTheme.bodySmall),
                  if (game.region != null)
                    Text('Region: ${game.region}', style: AppTheme.bodySmall),
                  SizedBox(height: AppTheme.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: game.isActive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: game.isActive ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(Icons.power_settings_new, size: 20),
                        SizedBox(width: 8),
                        Text('Toggle Active'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditDialog(game);
                  } else if (value == 'toggle') {
                    try {
                      await ApiService.adminToggleHouse(game.id, !game.isActive);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('House "${game.displayName}" is now ${!game.isActive ? "active" : "inactive"}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadGames();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to toggle house: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
