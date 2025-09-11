import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutManager {
  static const String _layoutsKey = 'saved_layouts';
  static const String _currentLayoutKey = 'current_layout_id';
  
  late SharedPreferences _prefs;
  Map<String, LayoutConfig> _layouts = {};
  String? _currentLayoutId;
  
  // Singleton pattern
  static final LayoutManager _instance = LayoutManager._internal();
  factory LayoutManager() => _instance;
  LayoutManager._internal();
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadLayouts();
    _currentLayoutId = _prefs.getString(_currentLayoutKey);
  }
  
  Future<void> _loadLayouts() async {
    try {
      final layoutsJson = _prefs.getString(_layoutsKey);
      if (layoutsJson != null) {
        final Map<String, dynamic> layoutsData = json.decode(layoutsJson);
        _layouts = layoutsData.map(
          (key, value) => MapEntry(key, LayoutConfig.fromJson(value)),
        );
      }
    } catch (e) {
      debugPrint('Error loading layouts: $e');
      _layouts = {};
    }
  }
  
  Future<void> _saveLayouts() async {
    try {
      final layoutsData = _layouts.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await _prefs.setString(_layoutsKey, json.encode(layoutsData));
    } catch (e) {
      debugPrint('Error saving layouts: $e');
    }
  }
  
  Future<String> saveCurrentLayout(String name, Map<String, dynamic> uiState) async {
    final layoutId = DateTime.now().millisecondsSinceEpoch.toString();
    final layout = LayoutConfig(
      id: layoutId,
      name: name,
      uiState: uiState,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _layouts[layoutId] = layout;
    await _saveLayouts();
    
    debugPrint('Layout saved: $name (ID: $layoutId)');
    return layoutId;
  }
  
  Future<void> updateLayout(String layoutId, Map<String, dynamic> uiState) async {
    if (_layouts.containsKey(layoutId)) {
      _layouts[layoutId] = _layouts[layoutId]!.copyWith(
        uiState: uiState,
        updatedAt: DateTime.now(),
      );
      await _saveLayouts();
      debugPrint('Layout updated: $layoutId');
    }
  }
  
  Future<void> deleteLayout(String layoutId) async {
    _layouts.remove(layoutId);
    await _saveLayouts();
    
    if (_currentLayoutId == layoutId) {
      _currentLayoutId = null;
      await _prefs.remove(_currentLayoutKey);
    }
    
    debugPrint('Layout deleted: $layoutId');
  }
  
  Future<void> setCurrentLayout(String layoutId) async {
    if (_layouts.containsKey(layoutId)) {
      _currentLayoutId = layoutId;
      await _prefs.setString(_currentLayoutKey, layoutId);
      debugPrint('Current layout set to: $layoutId');
    }
  }
  
  LayoutConfig? getLayout(String layoutId) {
    return _layouts[layoutId];
  }
  
  LayoutConfig? getCurrentLayout() {
    if (_currentLayoutId != null) {
      return _layouts[_currentLayoutId];
    }
    return null;
  }
  
  List<LayoutConfig> getAllLayouts() {
    return _layouts.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  String? get currentLayoutId => _currentLayoutId;
  
  bool hasLayouts() => _layouts.isNotEmpty;
  
  Future<void> renameLayout(String layoutId, String newName) async {
    if (_layouts.containsKey(layoutId)) {
      _layouts[layoutId] = _layouts[layoutId]!.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await _saveLayouts();
      debugPrint('Layout renamed: $layoutId -> $newName');
    }
  }
  
  Future<String> duplicateLayout(String layoutId, String newName) async {
    final originalLayout = _layouts[layoutId];
    if (originalLayout != null) {
      return await saveCurrentLayout(newName, originalLayout.uiState);
    }
    throw Exception('Layout not found: $layoutId');
  }
}

class LayoutConfig {
  final String id;
  final String name;
  final Map<String, dynamic> uiState;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  LayoutConfig({
    required this.id,
    required this.name,
    required this.uiState,
    required this.createdAt,
    required this.updatedAt,
  });
  
  LayoutConfig copyWith({
    String? name,
    Map<String, dynamic>? uiState,
    DateTime? updatedAt,
  }) {
    return LayoutConfig(
      id: id,
      name: name ?? this.name,
      uiState: uiState ?? this.uiState,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uiState': uiState,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    return LayoutConfig(
      id: json['id'],
      name: json['name'],
      uiState: Map<String, dynamic>.from(json['uiState']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}