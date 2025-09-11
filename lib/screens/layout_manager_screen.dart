import 'package:flutter/material.dart';
import '../services/layout_manager.dart';
import '../services/navigation_service.dart';

class LayoutManagerScreen extends StatefulWidget {
  const LayoutManagerScreen({super.key});

  @override
  State<LayoutManagerScreen> createState() => _LayoutManagerScreenState();
}

class _LayoutManagerScreenState extends State<LayoutManagerScreen> {
  final LayoutManager _layoutManager = LayoutManager();
  final NavigationService _navigationService = NavigationService();
  List<LayoutConfig> _layouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLayouts();
  }

  Future<void> _loadLayouts() async {
    setState(() {
      _isLoading = true;
    });
    
    await _layoutManager.initialize();
    setState(() {
      _layouts = _layoutManager.getAllLayouts();
      _isLoading = false;
    });
  }

  Future<void> _deleteLayout(LayoutConfig layout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Layout'),
          content: Text('Are you sure you want to delete "${layout.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _layoutManager.deleteLayout(layout.id);
      await _loadLayouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${layout.name}" deleted')),
        );
      }
    }
  }

  Future<void> _renameLayout(LayoutConfig layout) async {
    final TextEditingController controller = TextEditingController(text: layout.name);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Layout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Layout Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty && name != layout.name) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newName != null) {
      await _layoutManager.renameLayout(layout.id, newName);
      await _loadLayouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Layout renamed to "$newName"')),
        );
      }
    }
  }

  Future<void> _duplicateLayout(LayoutConfig layout) async {
    final TextEditingController controller = TextEditingController(text: '${layout.name} (Copy)');
    
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Duplicate Layout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'New Layout Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('Duplicate'),
            ),
          ],
        );
      },
    );

    if (newName != null) {
      await _layoutManager.duplicateLayout(layout.id, newName);
      await _loadLayouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Layout duplicated as "$newName"')),
        );
      }
    }
  }

  Future<void> _loadLayout(LayoutConfig layout) async {
    await _navigationService.navigateToLayout(layout.id);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _layouts.isEmpty
              ? _buildEmptyState()
              : _buildLayoutList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/home');
        },
        tooltip: 'Create New Layout',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Layouts Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first layout by designing\na UI and saving it from the home screen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Layout'),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _layouts.length,
      itemBuilder: (context, index) {
        final layout = _layouts[index];
        final isCurrentLayout = _layoutManager.currentLayoutId == layout.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isCurrentLayout ? 4 : 1,
          color: isCurrentLayout ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isCurrentLayout 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[300],
              child: Icon(
                isCurrentLayout ? Icons.check : Icons.dashboard,
                color: isCurrentLayout ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              layout.name,
              style: TextStyle(
                fontWeight: isCurrentLayout ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Created: ${_formatDate(layout.createdAt)}'),
                Text('Updated: ${_formatDate(layout.updatedAt)}'),
                if (isCurrentLayout)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Current Layout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'load':
                    await _loadLayout(layout);
                    break;
                  case 'rename':
                    await _renameLayout(layout);
                    break;
                  case 'duplicate':
                    await _duplicateLayout(layout);
                    break;
                  case 'delete':
                    await _deleteLayout(layout);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'load',
                  child: ListTile(
                    leading: Icon(Icons.play_arrow),
                    title: Text('Load Layout'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'rename',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Duplicate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            onTap: () => _loadLayout(layout),
          ),
        );
      },
    );
  }
}