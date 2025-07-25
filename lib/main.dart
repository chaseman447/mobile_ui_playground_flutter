import 'package:flutter/material.dart';
import 'package:mobile_ui_playground_flutter/llm_api_service.dart'; // Import your LLM service
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // For json.encode and json.decode
import 'dart:async'; // For Timer for image carousel
import 'package:flutter/foundation.dart'; // For debugPrint

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Playground',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // --- State Variables for UI Elements ---
  Color _profileCardBackgroundColor = Colors.grey[200]!;
  double _profileCardBorderRadius = 8.0;

  double _profileImageBorderRadius = 50.0; // Initial round image
  double _profileImageSize = 100.0;

  String _nameTextContent = 'Jane Doe'; // Text content state
  double _nameFontSize = 24.0;
  FontWeight _nameFontWeight = FontWeight.bold;
  Color _nameTextColor = Colors.black87;
  TextAlign _nameTextAlign = TextAlign.center; // Text alignment state

  String _titleTextContent = 'Lead Product Designer'; // Text content state
  double _titleFontSize = 16.0;
  Color _titleTextColor = Colors.grey[700]!;
  bool _isTitleVisible = true;
  TextAlign _titleTextAlign = TextAlign.center; // Text alignment state

  String _bioTextContent = 'Innovating user experiences with a keen eye for detail and a passion for human-centered design.'; // Text content state
  double _bioFontSize = 14.0;
  Color _bioTextColor = Colors.black54;
  TextAlign _bioTextAlign = TextAlign.center; // Text alignment state

  // Component states
  Color _colorBoxBackgroundColor = Colors.purple[200]!;
  double _colorBoxSize = 50.0;

  String _buttonTextContent = 'Apply Changes';
  Color _buttonBackgroundColor = Colors.blue;
  Color _buttonTextColor = Colors.white;
  double _buttonBorderRadius = 4.0;

  bool _switchValue = true;
  Color _switchActiveColor = Colors.green;
  Color _switchInactiveThumbColor = Colors.grey;

  MainAxisAlignment _mainColumnAlignment = MainAxisAlignment.start;

  double _sliderValue = 0.5;
  double _sliderMin = 0.0;
  double _sliderMax = 1.0;
  Color _sliderActiveColor = Colors.blue;
  Color _sliderInactiveColor = Colors.grey;

  double _progressValue = 0.3;
  Color _progressColor = Colors.blue;
  Color _progressBackgroundColor = Colors.grey[300]!;

  final List<String> _imageUrls = [
    'https://picsum.photos/150/150?random=1',
    'https://picsum.photos/150/150?random=2',
    'https://picsum.photos/150/150?random=3',
  ];
  int _currentImageIndex = 0;
  bool _imageAutoPlay = false;
  Timer? _imageAutoPlayTimer;

  // New animation states
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // New: List to hold dynamically added widgets
  // Each map will contain 'widgetType' and 'properties'
  List<Map<String, dynamic>> _dynamicWidgets = [];

  // Enhanced state management
  late Map<String, dynamic> _initialState;
  late SharedPreferences _prefs;
  Map<String, Map<String, dynamic>> _savedPresets = {};

  final TextEditingController _commandController = TextEditingController();
  final LLMApiService _llmService = LLMApiService();

  bool _isLoading = false;
  String _lastCommand = '';
  List<String> _commandHistory = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    debugPrint('MyHomePage initState: Initializing enhanced UI');

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    _saveInitialState();
    _initSharedPreferences();
    _startImageAutoPlayTimer();
  }

  @override
  void dispose() {
    debugPrint('MyHomePage dispose: Cleaning up resources');
    _commandController.dispose();
    _imageAutoPlayTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadAllPresets();
      _loadCommandHistory();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
      _showMessage('Error loading saved data', isError: true);
    }
  }

  void _saveInitialState() {
    _initialState = _getCurrentUIState();
    debugPrint('Initial UI state saved with ${_initialState.length} properties');
  }

  Map<String, dynamic> _getCurrentUIState() {
    return {
      'profileCardBackgroundColor': _profileCardBackgroundColor.value,
      'profileCardBorderRadius': _profileCardBorderRadius,
      'profileImageBorderRadius': _profileImageBorderRadius,
      'profileImageSize': _profileImageSize,
      'nameTextContent': _nameTextContent,
      'nameFontSize': _nameFontSize,
      'nameFontWeight': _nameFontWeight.index,
      'nameTextColor': _nameTextColor.value,
      'nameTextAlign': _nameTextAlign.index,
      'titleTextContent': _titleTextContent,
      'titleFontSize': _titleFontSize,
      'titleTextColor': _titleTextColor.value,
      'isTitleVisible': _isTitleVisible,
      'titleTextAlign': _titleTextAlign.index,
      'bioTextContent': _bioTextContent,
      'bioFontSize': _bioFontSize,
      'bioTextColor': _bioTextColor.value,
      'bioTextAlign': _bioTextAlign.index,
      'colorBoxBackgroundColor': _colorBoxBackgroundColor.value,
      'colorBoxSize': _colorBoxSize,
      'buttonTextContent': _buttonTextContent,
      'buttonBackgroundColor': _buttonBackgroundColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonBorderRadius': _buttonBorderRadius,
      'switchValue': _switchValue,
      'switchActiveColor': _switchActiveColor.value,
      'switchInactiveThumbColor': _switchInactiveThumbColor.value,
      'mainColumnAlignment': _mainColumnAlignment.index,
      'sliderValue': _sliderValue,
      'sliderMin': _sliderMin,
      'sliderMax': _sliderMax,
      'sliderActiveColor': _sliderActiveColor.value,
      'sliderInactiveColor': _sliderInactiveColor.value,
      'progressValue': _progressValue,
      'progressColor': _progressColor.value,
      'progressBackgroundColor': _progressBackgroundColor.value,
      'currentImageIndex': _currentImageIndex,
      'imageAutoPlay': _imageAutoPlay,
      // New: Save dynamic widgets state
      'dynamicWidgets': _dynamicWidgets,
    };
  }

  void _applyUIState(Map<String, dynamic> state) {
    if (!mounted) return;

    setState(() {
      try {
        _profileCardBackgroundColor = Color(state['profileCardBackgroundColor'] ?? Colors.grey[200]!.value);
        _profileCardBorderRadius = (state['profileCardBorderRadius'] ?? 8.0).toDouble();
        _profileImageBorderRadius = (state['profileImageBorderRadius'] ?? 50.0).toDouble();
        _profileImageSize = (state['profileImageSize'] ?? 100.0).toDouble();
        _nameTextContent = state['nameTextContent'] ?? 'Jane Doe';
        _nameFontSize = (state['nameFontSize'] ?? 24.0).toDouble();
        _nameFontWeight = FontWeight.values[state['nameFontWeight'] ?? FontWeight.bold.index];
        _nameTextColor = Color(state['nameTextColor'] ?? Colors.black87.value);
        _nameTextAlign = TextAlign.values[state['nameTextAlign'] ?? TextAlign.center.index];
        _titleTextContent = state['titleTextContent'] ?? 'Lead Product Designer';
        _titleFontSize = (state['titleFontSize'] ?? 16.0).toDouble();
        _titleTextColor = Color(state['titleTextColor'] ?? Colors.grey[700]!.value);
        _isTitleVisible = state['isTitleVisible'] ?? true;
        _titleTextAlign = TextAlign.values[state['titleTextAlign'] ?? TextAlign.center.index];
        _bioTextContent = state['bioTextContent'] ?? 'Default bio text';
        _bioFontSize = (state['bioFontSize'] ?? 14.0).toDouble();
        _bioTextColor = Color(state['bioTextColor'] ?? Colors.black54.value);
        _bioTextAlign = TextAlign.values[state['bioTextAlign'] ?? TextAlign.center.index];
        _colorBoxBackgroundColor = Color(state['colorBoxBackgroundColor'] ?? Colors.purple[200]!.value);
        _colorBoxSize = (state['colorBoxSize'] ?? 50.0).toDouble();
        _buttonTextContent = state['buttonTextContent'] ?? 'Apply Changes';
        _buttonBackgroundColor = Color(state['buttonBackgroundColor'] ?? Colors.blue.value);
        _buttonTextColor = Color(state['buttonTextColor'] ?? Colors.white.value);
        _buttonBorderRadius = (state['buttonBorderRadius'] ?? 4.0).toDouble();
        _switchValue = state['switchValue'] ?? true;
        _switchActiveColor = Color(state['switchActiveColor'] ?? Colors.green.value);
        _switchInactiveThumbColor = Color(state['switchInactiveThumbColor'] ?? Colors.grey.value);
        _mainColumnAlignment = MainAxisAlignment.values[state['mainColumnAlignment'] ?? MainAxisAlignment.start.index];
        _sliderValue = (state['sliderValue'] ?? 0.5).toDouble();
        _sliderMin = (state['sliderMin'] ?? 0.0).toDouble();
        _sliderMax = (state['sliderMax'] ?? 1.0).toDouble();
        _sliderActiveColor = Color(state['sliderActiveColor'] ?? Colors.blue.value);
        _sliderInactiveColor = Color(state['sliderInactiveColor'] ?? Colors.grey.value);
        _progressValue = (state['progressValue'] ?? 0.3).toDouble();
        _progressColor = Color(state['progressColor'] ?? Colors.blue.value);
        _progressBackgroundColor = Color(state['progressBackgroundColor'] ?? Colors.grey[300]!.value);
        _currentImageIndex = state['currentImageIndex'] ?? 0;
        _imageAutoPlay = state['imageAutoPlay'] ?? false;
        // New: Load dynamic widgets state
        _dynamicWidgets = (state['dynamicWidgets'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ??
            [];
      } catch (e) {
        debugPrint('Error applying UI state: $e');
        _showMessage('Error applying UI state', isError: true);
      }
    });

    _startImageAutoPlayTimer();
  }

  void _saveCommandHistory() async {
    try {
      await _prefs.setStringList('command_history', _commandHistory);
    } catch (e) {
      debugPrint('Error saving command history: $e');
    }
  }

  void _loadCommandHistory() {
    try {
      _commandHistory = _prefs.getStringList('command_history') ?? [];
    } catch (e) {
      debugPrint('Error loading command history: $e');
    }
  }

  Future<void> _savePreset(String presetName) async {
    if (presetName.trim().isEmpty) {
      _showMessage('Preset name cannot be empty', isError: true);
      return;
    }

    try {
      final uiState = _getCurrentUIState();
      await _prefs.setString('preset_$presetName', json.encode(uiState));
      _loadAllPresets();
      _showMessage('Layout "$presetName" saved successfully!');
    } catch (e) {
      debugPrint('Error saving preset: $e');
      _showMessage('Error saving preset', isError: true);
    }
  }

  Future<void> _loadPreset(String presetName) async {
    try {
      final String? presetJson = _prefs.getString('preset_$presetName');
      if (presetJson != null) {
        final Map<String, dynamic> uiState = json.decode(presetJson);
        _applyUIState(uiState);
        _showMessage('Layout "$presetName" loaded successfully!');
      } else {
        _showMessage('Preset "$presetName" not found', isError: true);
      }
    } catch (e) {
      debugPrint('Error loading preset: $e');
      _showMessage('Error loading preset', isError: true);
    }
  }

  void _loadAllPresets() {
    if (!mounted) return;

    setState(() {
      _savedPresets.clear();
      try {
        for (String key in _prefs.getKeys()) {
          if (key.startsWith('preset_')) {
            final presetName = key.substring(7);
            final String? presetJson = _prefs.getString(key);
            if (presetJson != null) {
              _savedPresets[presetName] = json.decode(presetJson);
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading presets: $e');
      }
    });
  }

  void _resetUI() {
    _applyUIState(_initialState);
    _commandController.clear();
    _showMessage('UI has been reset to initial state');
  }

  TextAlign _parseTextAlign(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'left': return TextAlign.left;
      case 'center': return TextAlign.center;
      case 'right': return TextAlign.right;
      case 'justify': return TextAlign.justify;
      case 'start': return TextAlign.start;
      case 'end': return TextAlign.end;
      default: return TextAlign.center;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'start': return MainAxisAlignment.start;
      case 'center': return MainAxisAlignment.center;
      case 'end': return MainAxisAlignment.end;
      case 'spacebetween': return MainAxisAlignment.spaceBetween;
      case 'spacearound': return MainAxisAlignment.spaceAround;
      case 'spaceevenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  void _startImageAutoPlayTimer() {
    _imageAutoPlayTimer?.cancel();
    if (_imageAutoPlay && _imageUrls.isNotEmpty) {
      _imageAutoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
          });
        }
      });
    }
  }

  Future<void> _handleCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) {
      _showMessage('Please enter a command', isError: true);
      return;
    }

    // Add to history
    if (!_commandHistory.contains(command)) {
      _commandHistory.insert(0, command);
      if (_commandHistory.length > 50) {
        _commandHistory = _commandHistory.take(50).toList();
      }
      _saveCommandHistory();
    }

    _lastCommand = command;
    _historyIndex = -1;

    if (command.toLowerCase() == 'reset ui') {
      _resetUI();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic>? instruction = await _llmService.generateStructuredOutput(command);

      if (instruction != null && instruction.isNotEmpty) {
        if (instruction.containsKey('commandType')) {
          // New: Handle addWidget command type
          if (instruction['commandType'] == 'addWidget') {
            _handleAddWidgetCommand(instruction);
          } else {
            await _handlePresetCommand(instruction);
          }
        } else {
          // Attempt to apply instruction to static components first
          bool handled = _applyInstructionToStaticComponent(instruction);
          if (!handled) {
            // If not a static component, try to apply to dynamic widgets
            _handleDynamicWidgetModification(instruction);
          }
          _showMessage('Command applied successfully!');
        }
      } else {
        _showMessage('Could not understand the command. Please try rephrasing.', isError: true);
      }
    } catch (e) {
      debugPrint('Command processing error: $e');
      _showMessage('Error processing command: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
      _commandController.clear();
    }
  }

  Future<void> _handlePresetCommand(Map<String, dynamic> instruction) async {
    final String commandType = instruction['commandType'];
    final String? presetName = instruction['presetName'];

    if (presetName == null || presetName.isEmpty) {
      _showMessage('Preset name is required', isError: true);
      return;
    }

    switch (commandType) {
      case 'savePreset':
        await _savePreset(presetName);
        break;
      case 'loadPreset':
        await _loadPreset(presetName);
        break;
      default:
        _showMessage('Unknown command type: $commandType', isError: true);
    }
  }

  // New: Handle addWidget command
  void _handleAddWidgetCommand(Map<String, dynamic> instruction) {
    final String? widgetType = instruction['widgetType'];
    final Map<String, dynamic>? properties = instruction['properties'];

    if (widgetType == null || properties == null) {
      _showMessage('Invalid addWidget command format.', isError: true);
      return;
    }

    setState(() {
      _dynamicWidgets.add({
        'widgetType': widgetType,
        'properties': properties,
        'id': DateTime.now().microsecondsSinceEpoch, // Unique ID for the widget
      });
      _showMessage('Added new $widgetType widget!');
      debugPrint('Dynamic widgets: $_dynamicWidgets');
    });
  }

  // New: Method to handle modification of dynamic widgets
  void _handleDynamicWidgetModification(Map<String, dynamic> instruction) {
    final String? component = instruction['component']; // This will be the widgetType for dynamic widgets
    final String? property = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (component == null || property == null || value == null) {
      _showMessage('Invalid instruction format for dynamic widget modification.', isError: true);
      return;
    }

    // Find the dynamic widget based on its type and optional targetIndex
    int? targetIndexInList;
    if (instruction.containsKey('targetIndex') && instruction['targetIndex'] is num) {
      // LLM provides 1-based index, convert to 0-based
      int requestedIndex = instruction['targetIndex'].toInt() - 1;
      int count = 0;
      for (int i = 0; i < _dynamicWidgets.length; i++) {
        if (_dynamicWidgets[i]['widgetType'] == component) {
          if (count == requestedIndex) {
            targetIndexInList = i;
            break;
          }
          count++;
        }
      }
    } else {
      // Default to the first instance if no specific index is given
      for (int i = 0; i < _dynamicWidgets.length; i++) {
        if (_dynamicWidgets[i]['widgetType'] == component) {
          targetIndexInList = i;
          break;
        }
      }
    }


    if (targetIndexInList != null) {
      setState(() {
        Map<String, dynamic> targetProperties = _dynamicWidgets[targetIndexInList!]['properties'];
        try {
          switch (component) {
            case 'button':
              if (property == 'content' && value is String) {
                targetProperties['content'] = value;
              } else if (property == 'backgroundColor' && value is String) {
                targetProperties['backgroundColor'] = value;
              } else if (property == 'textColor' && value is String) {
                targetProperties['textColor'] = value;
              } else if (property == 'borderRadius' && value is num) {
                targetProperties['borderRadius'] = value.toDouble();
              }
              break;
            case 'colorBox':
              if (property == 'backgroundColor' && value is String) {
                targetProperties['backgroundColor'] = value;
              } else if (property == 'size' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['size'] = (targetProperties['size'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['size'] = ((targetProperties['size'] ?? 0.0).toDouble() - newValue).clamp(20.0, 150.0);
                } else {
                  targetProperties['size'] = newValue.clamp(20.0, 150.0);
                }
              }
              break;
            case 'text':
              if (property == 'content' && value is String) {
                targetProperties['content'] = value;
              } else if (property == 'fontSize' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['fontSize'] = (targetProperties['fontSize'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['fontSize'] = ((targetProperties['fontSize'] ?? 0.0).toDouble() - newValue).clamp(8.0, 48.0);
                } else {
                  targetProperties['fontSize'] = newValue.clamp(8.0, 48.0);
                }
              } else if (property == 'textColor' && value is String) {
                targetProperties['textColor'] = value;
              } else if (property == 'textAlign' && value is String) {
                targetProperties['textAlign'] = value; // Store string, parse in _buildDynamicWidget
              } else if (property == 'fontWeight' && value is String) {
                targetProperties['fontWeight'] = value;
              }
              break;
            case 'toggleSwitch':
              if (property == 'value' && value is bool) {
                targetProperties['value'] = value;
              } else if (property == 'activeColor' && value is String) {
                targetProperties['activeColor'] = value;
              } else if (property == 'inactiveThumbColor' && value is String) {
                targetProperties['inactiveThumbColor'] = value;
              }
              break;
            case 'slider':
              if (property == 'value' && value is num) {
                double currentMin = (targetProperties['min'] ?? 0.0).toDouble();
                double currentMax = (targetProperties['max'] ?? 1.0).toDouble();
                targetProperties['value'] = value.toDouble().clamp(currentMin, currentMax);
              } else if (property == 'min' && value is num) {
                targetProperties['min'] = value.toDouble();
                targetProperties['value'] = (targetProperties['value'] ?? 0.0).toDouble().clamp(targetProperties['min'], targetProperties['max']);
              } else if (property == 'max' && value is num) {
                targetProperties['max'] = value.toDouble();
                targetProperties['value'] = (targetProperties['value'] ?? 0.0).toDouble().clamp(targetProperties['min'], targetProperties['max']);
              } else if (property == 'activeColor' && value is String) {
                targetProperties['activeColor'] = value;
              } else if (property == 'inactiveColor' && value is String) {
                targetProperties['inactiveColor'] = value;
              }
              break;
            case 'progressIndicator':
              if (property == 'value' && value is num) {
                targetProperties['value'] = value.toDouble().clamp(0.0, 1.0);
              } else if (property == 'color' && value is String) {
                targetProperties['color'] = value;
              } else if (property == 'backgroundColor' && value is String) {
                targetProperties['backgroundColor'] = value;
              }
              break;
            case 'textField':
              if (property == 'initialText' && value is String) {
                targetProperties['initialText'] = value;
              } else if (property == 'hintText' && value is String) {
                targetProperties['hintText'] = value;
              } else if (property == 'textColor' && value is String) {
                targetProperties['textColor'] = value;
              } else if (property == 'fontSize' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['fontSize'] = (targetProperties['fontSize'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['fontSize'] = ((targetProperties['fontSize'] ?? 0.0).toDouble() - newValue).clamp(8.0, 32.0);
                } else {
                  targetProperties['fontSize'] = newValue.clamp(8.0, 32.0);
                }
              } else if (property == 'borderColor' && value is String) {
                targetProperties['borderColor'] = value;
              } else if (property == 'borderRadius' && value is num) {
                targetProperties['borderRadius'] = value.toDouble();
              } else if (property == 'focusedBorderColor' && value is String) {
                targetProperties['focusedBorderColor'] = value;
              }
              break;
            default:
              _showMessage('Cannot modify dynamic widget of type: $component', isError: true);
              break;
          }
          // Force a rebuild of the specific dynamic widget by creating a new map
          _dynamicWidgets[targetIndexInList!] = Map.from(_dynamicWidgets[targetIndexInList!]);
          debugPrint('Modified dynamic widget: $_dynamicWidgets');
        } catch (e) {
          debugPrint('Error modifying dynamic widget properties: $e');
          _showMessage('Error modifying dynamic widget properties.', isError: true);
        }
      });
    } else {
      _showMessage('No dynamic widget of type "$component" at the specified index found to modify.', isError: true);
    }
  }


  // Original _applyInstruction renamed and modified to handle static components only
  bool _applyInstructionToStaticComponent(Map<String, dynamic> instruction) {
    final String? component = instruction['component'];
    final String? property = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (component == null || property == null || value == null) {
      return false; // Not a valid instruction for static component
    }

    // Use a flag to indicate if a static component was handled
    bool handled = true;

    setState(() { // Ensure all state changes are wrapped in setState
      try {
        switch (component) {
          case 'profileImage':
            _handleProfileImageInstruction(property, value, operation);
            break;
          case 'profileCard':
            _handleProfileCardInstruction(property, value, operation);
            break;
          case 'nameText':
            _handleNameTextInstruction(property, value, operation);
            break;
          case 'titleText':
            _handleTitleTextInstruction(property, value, operation);
            break;
          case 'bioText':
            _handleBioTextInstruction(property, value, operation);
            break;
          case 'colorBox':
            _handleColorBoxInstruction(property, value, operation);
            break;
          case 'button':
            _handleButtonInstruction(property, value, operation);
            break;
          case 'toggleSwitch':
            _handleSwitchInstruction(property, value, operation);
            break;
          case 'mainColumn':
            _handleMainColumnInstruction(property, value, operation);
            break;
          case 'slider':
            _handleSliderInstruction(property, value, operation);
            break;
          case 'progressIndicator':
            _handleProgressInstruction(property, value, operation);
            break;
          case 'imageGallery':
            _handleImageGalleryInstruction(property, value, operation);
            break;
          default:
            handled = false; // Not a static component
        }
      } catch (e) {
        debugPrint('Error applying instruction to static component: $e');
        _showMessage('Error applying instruction to static component.', isError: true);
        handled = false;
      }
    });
    return handled;
  }


  void _handleProfileImageInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'borderRadius':
        if (value is num) _profileImageBorderRadius = value.toDouble();
        break;
      case 'size':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _profileImageSize += newValue;
          } else if (operation == 'subtract') {
            _profileImageSize = (_profileImageSize - newValue).clamp(20.0, 200.0);
          } else {
            _profileImageSize = newValue.clamp(20.0, 200.0);
          }
        }
        break;
    }
  }

  void _handleProfileCardInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'backgroundColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _profileCardBackgroundColor = newColor;
        }
        break;
      case 'borderRadius':
        if (value is num) _profileCardBorderRadius = value.toDouble().clamp(0.0, 50.0);
        break;
    }
  }

  void _handleNameTextInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'fontSize':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _nameFontSize += newValue;
          } else if (operation == 'subtract') {
            _nameFontSize = (_nameFontSize - newValue).clamp(8.0, 48.0);
          } else {
            _nameFontSize = newValue.clamp(8.0, 48.0);
          }
        }
        break;
      case 'fontWeight':
        if (value is String) {
          _nameFontWeight = value.toLowerCase() == 'bold' ? FontWeight.bold : FontWeight.normal;
        }
        break;
      case 'textColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _nameTextColor = newColor;
        }
        break;
      case 'content':
        if (value is String) _nameTextContent = value;
        break;
      case 'textAlign':
        if (value is String) _nameTextAlign = _parseTextAlign(value);
        break;
    }
  }

  void _handleTitleTextInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'fontSize':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _titleFontSize += newValue;
          } else if (operation == 'subtract') {
            _titleFontSize = (_titleFontSize - newValue).clamp(8.0, 32.0);
          } else {
            _titleFontSize = newValue.clamp(8.0, 32.0);
          }
        }
        break;
      case 'textColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _titleTextColor = newColor;
        }
        break;
      case 'isVisible':
        if (value is bool) _isTitleVisible = value;
        break;
      case 'content':
        if (value is String) _titleTextContent = value;
        break;
      case 'textAlign':
        if (value is String) _titleTextAlign = _parseTextAlign(value);
        break;
    }
  }

  void _handleBioTextInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'fontSize':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _bioFontSize += newValue;
          } else if (operation == 'subtract') {
            _bioFontSize = (_bioFontSize - newValue).clamp(8.0, 24.0);
          } else {
            _bioFontSize = newValue.clamp(8.0, 24.0);
          }
        }
        break;
      case 'textColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _bioTextColor = newColor;
        }
        break;
      case 'content':
        if (value is String) _bioTextContent = value;
        break;
      case 'textAlign':
        if (value is String) _bioTextAlign = _parseTextAlign(value);
        break;
    }
  }

  void _handleColorBoxInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'backgroundColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _colorBoxBackgroundColor = newColor;
        }
        break;
      case 'size':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _colorBoxSize += newValue;
          } else if (operation == 'subtract') {
            _colorBoxSize = (_colorBoxSize - newValue).clamp(20.0, 150.0);
          } else {
            _colorBoxSize = newValue.clamp(20.0, 150.0);
          }
        }
        break;
    }
  }

  void _handleButtonInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'content':
        if (value is String) _buttonTextContent = value;
        break;
      case 'backgroundColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _buttonBackgroundColor = newColor;
        }
        break;
      case 'textColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _buttonTextColor = newColor;
        }
        break;
      case 'borderRadius':
        if (value is num) _buttonBorderRadius = value.toDouble().clamp(0.0, 30.0);
        break;
    }
  }

  void _handleSwitchInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'activeColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _switchActiveColor = newColor;
        }
        break;
      case 'inactiveThumbColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _switchInactiveThumbColor = newColor;
        }
        break;
      case 'value':
        if (value is bool) _switchValue = value;
        break;
    }
  }

  void _handleMainColumnInstruction(String property, dynamic value, String? operation) {
    if (property == 'mainAxisAlignment' && value is String) {
      _mainColumnAlignment = _parseMainAxisAlignment(value);
    }
  }

  void _handleSliderInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'value':
        if (value is num) _sliderValue = value.toDouble().clamp(_sliderMin, _sliderMax);
        break;
      case 'min':
        if (value is num) {
          _sliderMin = value.toDouble();
          _sliderValue = _sliderValue.clamp(_sliderMin, _sliderMax);
        }
        break;
      case 'max':
        if (value is num) {
          _sliderMax = value.toDouble();
          _sliderValue = _sliderValue.clamp(_sliderMin, _sliderMax);
        }
        break;
      case 'activeColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _sliderActiveColor = newColor;
        }
        break;
      case 'inactiveColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _sliderInactiveColor = newColor;
        }
        break;
    }
  }

  void _handleProgressInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'value':
        if (value is num) _progressValue = value.toDouble().clamp(0.0, 1.0);
        break;
      case 'color':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _progressColor = newColor;
        }
        break;
      case 'backgroundColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _progressBackgroundColor = newColor;
        }
        break;
    }
  }

  void _handleImageGalleryInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'currentImageIndex':
        if (value is int) {
          _currentImageIndex = value.clamp(0, _imageUrls.length - 1);
        }
        break;
      case 'autoPlay':
        if (value is bool) {
          _imageAutoPlay = value;
          _startImageAutoPlayTimer();
        }
        break;
      case 'nextImage':
        _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
        break;
      case 'prevImage':
        _currentImageIndex = (_currentImageIndex - 1 + _imageUrls.length) % _imageUrls.length;
        break;
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSavePresetDialog() {
    final TextEditingController presetNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Current Layout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: presetNameController,
              decoration: const InputDecoration(
                hintText: 'Enter preset name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'This will save the current UI configuration',
              style: Theme.of(context).textTheme.bodySmall,
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
              final String presetName = presetNameController.text.trim();
              if (presetName.isNotEmpty) {
                _savePreset(presetName);
                Navigator.pop(context);
              } else {
                _showMessage('Preset name cannot be empty', isError: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLoadPresetDialog() {
    _loadAllPresets();
    if (_savedPresets.isEmpty) {
      _showMessage('No saved layouts found', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Saved Layout'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedPresets.length,
            itemBuilder: (context, index) {
              final presetName = _savedPresets.keys.elementAt(index);
              return Card(
                child: ListTile(
                  title: Text(presetName),
                  leading: const Icon(Icons.palette),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePreset(presetName),
                  ),
                  onTap: () {
                    _loadPreset(presetName);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePreset(String presetName) async {
    try {
      await _prefs.remove('preset_$presetName');
      _loadAllPresets();
      _showMessage('Preset "$presetName" deleted');
    } catch (e) {
      debugPrint('Error deleting preset: $e');
      _showMessage('Error deleting preset', isError: true);
    }
  }

  void _showCommandHistory() {
    if (_commandHistory.isEmpty) {
      _showMessage('No command history available', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Command History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _commandHistory.length,
            itemBuilder: (context, index) {
              final command = _commandHistory[index];
              return ListTile(
                title: Text(command),
                leading: const Icon(Icons.history),
                onTap: () {
                  _commandController.text = command;
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _commandHistory.clear();
              _saveCommandHistory();
              Navigator.pop(context);
              _showMessage('Command history cleared');
            },
            child: const Text('Clear History'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // New: Helper function to build dynamic widgets based on their type and properties
  Widget _buildDynamicWidget(Map<String, dynamic> widgetData) {
    final String widgetType = widgetData['widgetType'];
    final Map<String, dynamic> properties = Map<String, dynamic>.from(widgetData['properties']);
    final Key uniqueKey = ValueKey('dynamic_widget_${widgetData['id']}'); // Use a unique key

    try {
      switch (widgetType) {
        case 'button':
          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                _showMessage('Dynamic Button Pressed: ${properties['content'] ?? 'No Text'}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: parseHexColor(properties['backgroundColor'] ?? '0xFF2196F3'),
                foregroundColor: parseHexColor(properties['textColor'] ?? '0xFFFFFFFF'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 4.0).toDouble()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(properties['content'] ?? 'Dynamic Button'),
            ),
          );
        case 'colorBox':
          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: (properties['size'] ?? 50.0).toDouble(),
              height: (properties['size'] ?? 50.0).toDouble(),
              decoration: BoxDecoration(
                color: parseHexColor(properties['backgroundColor'] ?? '0xFF9C27B0'),
                borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        case 'text':
          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              properties['content'] ?? 'Dynamic Text',
              textAlign: _parseTextAlign(properties['textAlign'] ?? 'center'),
              style: TextStyle(
                fontSize: (properties['fontSize'] ?? 16.0).toDouble(),
                color: parseHexColor(properties['textColor'] ?? '0xFF000000'),
                fontWeight: properties['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        case 'toggleSwitch':
          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dynamic Toggle:'),
                Switch(
                  value: properties['value'] ?? false,
                  onChanged: (bool newValue) {
                    // Update the state of this specific dynamic switch
                    setState(() {
                      final int index = _dynamicWidgets.indexWhere((w) => w['id'] == widgetData['id']);
                      if (index != -1) {
                        _dynamicWidgets[index]['properties']['value'] = newValue;
                      }
                    });
                    _showMessage('Dynamic Switch toggled to: $newValue');
                  },
                  activeColor: parseHexColor(properties['activeColor'] ?? '0xFF4CAF50'),
                  inactiveThumbColor: parseHexColor(properties['inactiveThumbColor'] ?? '0xFF9E9E9E'),
                ),
              ],
            ),
          );
        case 'slider':
        // For dynamic sliders, we'll need a way to update their individual values.
        // For simplicity, this example will just display it.
        // A more robust solution would involve managing state for each dynamic slider.
          double dynSliderValue = (properties['value'] ?? 0.5).toDouble().clamp(
            (properties['min'] ?? 0.0).toDouble(),
            (properties['max'] ?? 1.0).toDouble(),
          );
          double dynSliderMin = (properties['min'] ?? 0.0).toDouble();
          double dynSliderMax = (properties['max'] ?? 1.0).toDouble();

          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                Text('Dynamic Slider Value: ${dynSliderValue.toStringAsFixed(2)}'),
                Slider(
                  value: dynSliderValue,
                  min: dynSliderMin,
                  max: dynSliderMax,
                  activeColor: parseHexColor(properties['activeColor'] ?? '0xFF2196F3'),
                  inactiveColor: parseHexColor(properties['inactiveColor'] ?? '0xFF9E9E9E'),
                  onChanged: (double newValue) {
                    // Update the state of this specific dynamic slider
                    setState(() {
                      final int index = _dynamicWidgets.indexWhere((w) => w['id'] == widgetData['id']);
                      if (index != -1) {
                        _dynamicWidgets[index]['properties']['value'] = newValue;
                      }
                    });
                  },
                ),
              ],
            ),
          );
        case 'progressIndicator':
          double dynProgressValue = (properties['value'] ?? 0.5).toDouble().clamp(0.0, 1.0);
          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                Text('Dynamic Progress: ${(dynProgressValue * 100).toStringAsFixed(0)}%'),
                LinearProgressIndicator(
                  value: dynProgressValue,
                  color: parseHexColor(properties['color'] ?? '0xFF2196F3'),
                  backgroundColor: parseHexColor(properties['backgroundColor'] ?? '0xFFE0E0E0'),
                ),
              ],
            ),
          );
        case 'textField': // New: Handle dynamic TextField
          TextEditingController dynamicTextController = TextEditingController(text: properties['initialText'] ?? '');
          // This controller needs to be managed carefully for dynamic widgets.
          // For simplicity, it's created here. A more complex app might manage a map of controllers.

          return Padding(
            key: uniqueKey,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              controller: dynamicTextController,
              decoration: InputDecoration(
                hintText: properties['hintText'] ?? 'Dynamic Text Field',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                  borderSide: BorderSide(color: parseHexColor(properties['borderColor'] ?? '0xFF9E9E9E') ?? Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                  borderSide: BorderSide(color: parseHexColor(properties['borderColor'] ?? '0xFF9E9E9E') ?? Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                  borderSide: BorderSide(color: parseHexColor(properties['focusedBorderColor'] ?? '0xFF2196F3') ?? Colors.blue, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: TextStyle(
                fontSize: (properties['fontSize'] ?? 16.0).toDouble(),
                color: parseHexColor(properties['textColor'] ?? '0xFF000000'),
              ),
              onChanged: (text) {
                // Update the 'initialText' property in the dynamicWidgets list
                // so that the state is preserved across app restarts/preset loads.
                setState(() {
                  final int index = _dynamicWidgets.indexWhere((w) => w['id'] == widgetData['id']);
                  if (index != -1) {
                    _dynamicWidgets[index]['properties']['initialText'] = text;
                  }
                });
              },
            ),
          );
        default:
          return SizedBox(
            key: uniqueKey,
            child: Text('Unknown dynamic widget type: $widgetType'),
          );
      }
    } catch (e) {
      debugPrint('Error building dynamic widget $widgetType: $e');
      return SizedBox(
        key: uniqueKey,
        child: Text('Error rendering dynamic widget: $widgetType'),
      );
    }
  }

  Widget _buildProfileCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _profileCardBackgroundColor,
              borderRadius: BorderRadius.circular(_profileCardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'profile_image',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_profileImageBorderRadius),
                    child: Image.network(
                      'https://picsum.photos/150?random=4',
                      width: _profileImageSize,
                      height: _profileImageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: _profileImageSize,
                          height: _profileImageSize,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 50),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _nameFontSize,
                    fontWeight: _nameFontWeight,
                    color: _nameTextColor,
                  ),
                  child: Text(
                    _nameTextContent,
                    textAlign: _nameTextAlign,
                  ),
                ),
                const SizedBox(height: 5),
                if (_isTitleVisible)
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: _titleFontSize,
                      color: _titleTextColor,
                    ),
                    child: Text(
                      _titleTextContent,
                      textAlign: _titleTextAlign,
                    ),
                  ),
                const SizedBox(height: 15),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _bioFontSize,
                    color: _bioTextColor,
                  ),
                  child: Text(
                    _bioTextContent,
                    textAlign: _bioTextAlign,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _colorBoxSize,
      height: _colorBoxSize,
      decoration: BoxDecoration(
        color: _colorBoxBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildDynamicButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: () {
            _showMessage('Button pressed! Current state: ${_getCurrentUIState().keys.length} properties');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonBackgroundColor,
            foregroundColor: _buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 3,
          ),
          child: Text(_buttonTextContent),
        ),
      ),
    );
  }

  Widget _buildDynamicSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feature Toggle',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Switch(
                value: _switchValue,
                onChanged: (bool newValue) {
                  setState(() {
                    _switchValue = newValue;
                  });
                  _showMessage('Switch toggled to: $newValue');
                },
                activeColor: _switchActiveColor,
                inactiveThumbColor: _switchInactiveThumbColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Slider Value: ${_sliderValue.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: _sliderValue,
                min: _sliderMin,
                max: _sliderMax,
                activeColor: _sliderActiveColor,
                inactiveColor: _sliderInactiveColor,
                divisions: 20,
                label: _sliderValue.toStringAsFixed(2),
                onChanged: (double newValue) {
                  setState(() {
                    _sliderValue = newValue;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_sliderMin.toStringAsFixed(1)}'),
                  Text('${_sliderMax.toStringAsFixed(1)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Progress: ${(_progressValue * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  color: _progressColor,
                  backgroundColor: _progressBackgroundColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: _progressValue,
                  color: _progressColor,
                  backgroundColor: _progressBackgroundColor,
                  strokeWidth: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Image Gallery',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              if (_imageUrls.isNotEmpty)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ClipRRect(
                    key: ValueKey(_currentImageIndex),
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrls[_currentImageIndex],
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 40),
                              Text('Image Error', textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('No Images Loaded', textAlign: TextAlign.center),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        _currentImageIndex = (_currentImageIndex - 1 + _imageUrls.length) % _imageUrls.length;
                      });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${_currentImageIndex + 1} of ${_imageUrls.length}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(_imageAutoPlay ? Icons.pause_circle : Icons.play_circle),
                    onPressed: () {
                      setState(() {
                        _imageAutoPlay = !_imageAutoPlay;
                        _startImageAutoPlayTimer();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Image indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_imageUrls.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _currentImageIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commandController,
                  decoration: InputDecoration(
                    hintText: 'Enter UI command (e.g., "make picture square")',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: _showCommandHistory,
                      tooltip: 'Command History',
                    ),
                  ),
                  onSubmitted: (_) => _handleCommand(),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
                  : ElevatedButton.icon(
                onPressed: _handleCommand,
                icon: const Icon(Icons.send),
                label: const Text('Apply'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          if (_lastCommand.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Last command: "$_lastCommand"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MyHomePage widget tree.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Playground'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Layout',
            onPressed: _showSavePresetDialog,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Load Layout',
            onPressed: _showLoadPresetDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset UI',
            onPressed: _resetUI,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'history':
                  _showCommandHistory();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Command History'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: _mainColumnAlignment,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProfileCard(),
                    _buildColorBox(),
                    _buildDynamicButton(),
                    _buildDynamicSwitch(),
                    _buildDynamicSlider(),
                    _buildProgressIndicator(),
                    _buildImageGallery(),
                    // New: Render dynamically added widgets
                    ..._dynamicWidgets.map((widgetData) => _buildDynamicWidget(widgetData)).toList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildCommandInput(),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Flutter UI Playground'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('An interactive Flutter app that responds to natural language commands.'),
            SizedBox(height: 12),
            Text('Features:'),
            Text('• Dynamic UI modification via LLM'),
            Text('• Save/Load layout presets'),
            Text('• Command history'),
            Text('• Animated transitions'),
            Text('• Enhanced error handling'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
