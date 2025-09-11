import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layout_manager.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final LayoutManager _layoutManager = LayoutManager();
  
  // Singleton pattern
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  BuildContext? get context => navigatorKey.currentContext;
  
  // Navigate to a specific layout by ID
  Future<void> navigateToLayout(String layoutId) async {
    try {
      final layout = _layoutManager.getLayout(layoutId);
      if (layout != null) {
        await _layoutManager.setCurrentLayout(layoutId);
        _showMessage('Switched to layout: ${layout.name}');
        
        // Navigate to home to show the layout
        if (context != null) {
          Navigator.of(context!).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } else {
        _showMessage('Layout not found');
      }
    } catch (e) {
      debugPrint('Error navigating to layout: $e');
      _showMessage('Error loading layout');
    }
  }
  
  // Navigate to a layout by name using existing preset system
  Future<void> navigateToLayoutByName(String layoutName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? presetJson = prefs.getString('preset_$layoutName');
      
      if (presetJson != null) {
        // Navigate to home and trigger layout load
        if (context != null) {
          Navigator.of(context!).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
            arguments: {'loadPreset': layoutName},
          );
        }
        _showMessage('Switched to layout: $layoutName');
      } else {
        _showMessage('Layout "$layoutName" not found');
      }
    } catch (e) {
      debugPrint('Error navigating to layout by name: $e');
      _showMessage('Layout "$layoutName" not found');
    }
  }
  
  // Navigate to layout manager screen
  void navigateToLayoutManager() {
    if (context != null) {
      Navigator.of(context!).pushNamed('/layout-manager');
    }
  }
  
  // Navigate to a specific screen by name
  void navigateToScreen(String screenName) {
    if (context != null) {
      switch (screenName.toLowerCase()) {
        case 'home':
        case '/home':
          Navigator.of(context!).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
          break;
        case 'settings':
        case '/settings':
          Navigator.of(context!).pushNamedAndRemoveUntil(
            '/settings',
            (route) => false,
          );
          break;
        case 'about':
        case '/about':
          Navigator.of(context!).pushNamedAndRemoveUntil(
            '/about',
            (route) => false,
          );
          break;
        case 'layouts':
        case 'layout-manager':
          navigateToLayoutManager();
          break;
        default:
          debugPrint('Unknown screen: $screenName');
      }
    }
  }
  
  // Navigate back
  void goBack() {
    if (context != null && Navigator.of(context!).canPop()) {
      Navigator.of(context!).pop();
    }
  }
  
  // Show layout selection dialog
  Future<void> showLayoutSelectionDialog() async {
    if (context == null) return;
    
    final layouts = _layoutManager.getAllLayouts();
    if (layouts.isEmpty) {
      _showMessage('No saved layouts found');
      return;
    }
    
    final selectedLayout = await showDialog<LayoutConfig>(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Layout'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: layouts.length,
              itemBuilder: (context, index) {
                final layout = layouts[index];
                final isCurrentLayout = _layoutManager.currentLayoutId == layout.id;
                
                return ListTile(
                  title: Text(layout.name),
                  subtitle: Text(
                    'Updated: ${_formatDate(layout.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  leading: Icon(
                    isCurrentLayout ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isCurrentLayout ? Theme.of(context).primaryColor : null,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(layout);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    
    if (selectedLayout != null) {
      await navigateToLayout(selectedLayout.id);
    }
  }
  
  // Show save layout dialog
  Future<void> showSaveLayoutDialog(Map<String, dynamic> currentUIState) async {
    if (context == null) return;
    
    final TextEditingController nameController = TextEditingController();
    
    final layoutName = await showDialog<String>(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Layout'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Layout Name',
              hintText: 'Enter a name for this layout',
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
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    if (layoutName != null && layoutName.isNotEmpty) {
      final layoutId = await _layoutManager.saveCurrentLayout(layoutName, currentUIState);
      _showMessage('Layout "$layoutName" saved successfully');
    }
  }
  
  void _showMessage(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Handle navigation commands from AI
  Future<void> handleNavigationCommand(Map<String, dynamic> command) async {
    final String action = command['action'] ?? '';
    
    switch (action.toLowerCase()) {
      case 'navigate_to_screen':
        final String screenName = command['screen'] ?? '';
        navigateToScreen(screenName);
        break;
        
      case 'navigate_to_layout':
        final String layoutId = command['layoutId'] ?? '';
        if (layoutId.isNotEmpty) {
          await navigateToLayout(layoutId);
        }
        break;
        
      case 'show_layout_selection':
        await showLayoutSelectionDialog();
        break;
        
      case 'save_current_layout':
        final Map<String, dynamic> uiState = command['uiState'] ?? {};
        await showSaveLayoutDialog(uiState);
        break;
        
      case 'go_back':
        goBack();
        break;
        
      default:
        debugPrint('Unknown navigation command: $action');
    }
  }
}