import 'package:flutter/material.dart';
import 'package:mobile_ui_playground_flutter/llm_api_service.dart'; // Import your LLM service
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // For json.encode and json.decode

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

class _MyHomePageState extends State<MyHomePage> {
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

  // New component states
  Color _colorBoxBackgroundColor = Colors.purple[200]!;
  double _colorBoxSize = 50.0; // Default size for the new box

  // Button states
  String _buttonTextContent = 'Apply Changes';
  Color _buttonBackgroundColor = Colors.blue;
  Color _buttonTextColor = Colors.white;
  double _buttonBorderRadius = 4.0;

  // Switch states
  bool _switchValue = true; // Initial state for the switch
  Color _switchActiveColor = Colors.green;
  Color _switchInactiveThumbColor = Colors.grey;

  // New: Main Column Layout state
  MainAxisAlignment _mainColumnAlignment = MainAxisAlignment.start;

  // --- Store Initial State for Reset ---
  late Map<String, dynamic> _initialState;

  // For Saving/Loading Presets
  late SharedPreferences _prefs;
  Map<String, Map<String, dynamic>> _savedPresets = {}; // Stores presetName -> {ui_state_map}

  // Controller for the text input field
  final TextEditingController _commandController = TextEditingController();
  final LLMApiService _llmService = LLMApiService(); // Instantiate your LLM service

  bool _isLoading = false; // To show loading indicator during API call
  OverlayEntry? _overlayEntry; // For custom message overlay

  @override
  void initState() {
    super.initState();
    _saveInitialState(); // Save initial state on widget initialization
    _initSharedPreferences(); // Initialize shared preferences
  }

  @override
  void dispose() {
    _commandController.dispose();
    _overlayEntry?.remove(); // Clean up overlay if it's still visible
    super.dispose();
  }

  // Initialize SharedPreferences and load existing presets
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAllPresets();
  }

  void _saveInitialState() {
    _initialState = {
      'profileCardBackgroundColor': _profileCardBackgroundColor.value, // Store color as int
      'profileCardBorderRadius': _profileCardBorderRadius,
      'profileImageBorderRadius': _profileImageBorderRadius,
      'profileImageSize': _profileImageSize,
      'nameTextContent': _nameTextContent,
      'nameFontSize': _nameFontSize,
      'nameFontWeight': _nameFontWeight.index, // Store FontWeight as its index
      'nameTextColor': _nameTextColor.value,
      'nameTextAlign': _nameTextAlign.index, // Store TextAlign as its index
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
      'mainColumnAlignment': _mainColumnAlignment.index, // Save MainAxisAlignment as its index
    };
  }

  // Get current UI state as a map for saving
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
    };
  }

  // Apply a loaded UI state from a map
  void _applyUIState(Map<String, dynamic> state) {
    setState(() {
      _profileCardBackgroundColor = Color(state['profileCardBackgroundColor']);
      _profileCardBorderRadius = state['profileCardBorderRadius'];
      _profileImageBorderRadius = state['profileImageBorderRadius'];
      _profileImageSize = state['profileImageSize'];
      _nameTextContent = state['nameTextContent'];
      _nameFontSize = state['nameFontSize'];
      _nameFontWeight = FontWeight.values[state['nameFontWeight']];
      _nameTextColor = Color(state['nameTextColor']);
      _nameTextAlign = TextAlign.values[state['nameTextAlign']];
      _titleTextContent = state['titleTextContent'];
      _titleFontSize = state['titleFontSize'];
      _titleTextColor = Color(state['titleTextColor']);
      _isTitleVisible = state['isTitleVisible'];
      _titleTextAlign = TextAlign.values[state['titleTextAlign']];
      _bioTextContent = state['bioTextContent'];
      _bioFontSize = state['bioFontSize'];
      _bioTextColor = Color(state['bioTextColor']);
      _bioTextAlign = TextAlign.values[state['bioTextAlign']];
      _colorBoxBackgroundColor = Color(state['colorBoxBackgroundColor']);
      _colorBoxSize = state['colorBoxSize'];
      _buttonTextContent = state['buttonTextContent'];
      _buttonBackgroundColor = Color(state['buttonBackgroundColor']);
      _buttonTextColor = Color(state['buttonTextColor']);
      _buttonBorderRadius = state['buttonBorderRadius'];
      _switchValue = state['switchValue'];
      _switchActiveColor = Color(state['switchActiveColor']);
      _switchInactiveThumbColor = Color(state['switchInactiveThumbColor']);
      _mainColumnAlignment = MainAxisAlignment.values[state['mainColumnAlignment']];
    });
  }

  // Save a preset to SharedPreferences
  Future<void> _savePreset(String presetName) async {
    final uiState = _getCurrentUIState();
    await _prefs.setString('preset_$presetName', json.encode(uiState));
    _loadAllPresets(); // Reload all presets to update the list
    _showCustomMessage('Layout "$presetName" saved!', success: true);
  }

  // Load a preset from SharedPreferences
  Future<void> _loadPreset(String presetName) async {
    final String? presetJson = _prefs.getString('preset_$presetName');
    if (presetJson != null) {
      final Map<String, dynamic> uiState = json.decode(presetJson);
      _applyUIState(uiState);
      _showCustomMessage('Layout "$presetName" loaded!', success: true);
    } else {
      _showCustomMessage('Preset "$presetName" not found.', success: false);
    }
  }

  // Load all presets from SharedPreferences
  void _loadAllPresets() {
    setState(() {
      _savedPresets.clear();
      for (String key in _prefs.getKeys()) {
        if (key.startsWith('preset_')) {
          final presetName = key.substring(7); // Remove 'preset_' prefix
          final String? presetJson = _prefs.getString(key);
          if (presetJson != null) {
            _savedPresets[presetName] = json.decode(presetJson);
          }
        }
      }
    });
  }

  void _resetUI() {
    _applyUIState(_initialState); // Use the new apply method for reset
    _commandController.clear();
    _showCustomMessage('UI has been reset.', success: true);
  }

  // Helper to parse TextAlign from string
  TextAlign _parseTextAlign(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'left': return TextAlign.left;
      case 'center': return TextAlign.center;
      case 'right': return TextAlign.right;
      case 'justify': return TextAlign.justify;
      case 'start': return TextAlign.start;
      case 'end': return TextAlign.end;
      default: return TextAlign.center; // Default if unknown
    }
  }

  // Helper to parse MainAxisAlignment from string
  MainAxisAlignment _parseMainAxisAlignment(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'start': return MainAxisAlignment.start;
      case 'center': return MainAxisAlignment.center;
      case 'end': return MainAxisAlignment.end;
      case 'spacebetween': return MainAxisAlignment.spaceBetween;
      case 'spacearound': return MainAxisAlignment.spaceAround;
      case 'spaceevenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start; // Default if unknown
    }
  }

  // --- LLM-Powered Command Handling ---
  Future<void> _handleCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) {
      _showCustomMessage('Please enter a command.', success: false);
      return;
    }

    // Handle 'reset ui' command locally for immediate feedback
    if (command.toLowerCase() == 'reset ui') {
      _resetUI();
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final Map<String, dynamic>? instruction =
      await _llmService.generateStructuredOutput(command);

      setState(() { // Update UI based on LLM's instruction
        if (instruction != null && instruction.isNotEmpty) {
          // Check for commandType for preset management
          if (instruction.containsKey('commandType')) {
            final String commandType = instruction['commandType'];
            final String? presetName = instruction['presetName'];

            if (presetName == null || presetName.isEmpty) {
              _showCustomMessage('Preset name is required for this command.', success: false);
            } else if (commandType == 'savePreset') {
              _savePreset(presetName);
            } else if (commandType == 'loadPreset') {
              _loadPreset(presetName);
            } else {
              _showCustomMessage('Unknown command type: $commandType', success: false);
            }
          } else {
            // It's a UI modification instruction
            _applyInstruction(instruction);
            _showCustomMessage('Command applied!', success: true);
          }
        } else {
          _showCustomMessage('LLM did not understand the command or returned invalid output. Please rephrase.', success: false);
        }
      });
    } catch (e) {
      _showCustomMessage('Error processing command: $e', success: false);
      print('Command processing error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      _commandController.clear();
    }
  }

  void _applyInstruction(Map<String, dynamic> instruction) {
    final String? component = instruction['component'];
    final String? property = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation']; // For operations like "add" or "subtract"

    if (component == null || property == null || value == null) {
      print('Invalid instruction format: $instruction');
      _showCustomMessage('Invalid instruction from LLM.', success: false);
      return;
    }

    // Apply changes based on the component and property
    setState(() { // Ensure all state changes are wrapped in setState
      switch (component) {
        case 'profileImage':
          if (property == 'borderRadius' && value is double) {
            _profileImageBorderRadius = value;
          } else if (property == 'size' && value is double) {
            if (operation == 'add') {
              _profileImageSize += value;
            } else if (operation == 'subtract') {
              _profileImageSize -= value;
            } else {
              _profileImageSize = value;
            }
          }
          break;
        case 'profileCard':
          if (property == 'backgroundColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _profileCardBackgroundColor = newColor;
            }
          } else if (property == 'borderRadius' && value is double) {
            _profileCardBorderRadius = value;
          }
          break;
        case 'nameText':
          if (property == 'fontSize' && value is double) {
            if (operation == 'add') {
              _nameFontSize += value;
            } else if (operation == 'subtract') {
              _nameFontSize -= value;
            } else {
              _nameFontSize = value;
            }
          } else if (property == 'fontWeight' && value is String) {
            if (value.toLowerCase() == 'bold') _nameFontWeight = FontWeight.bold;
            if (value.toLowerCase() == 'normal') _nameFontWeight = FontWeight.normal;
          } else if (property == 'textColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _nameTextColor = newColor;
            }
          } else if (property == 'content' && value is String) {
            _nameTextContent = value;
          } else if (property == 'textAlign' && value is String) {
            _nameTextAlign = _parseTextAlign(value);
          }
          break;
        case 'titleText':
          if (property == 'fontSize' && value is double) {
            if (operation == 'add') {
              _titleFontSize += value;
            } else if (operation == 'subtract') {
              _titleFontSize -= value;
            } else {
              _titleFontSize = value;
            }
          } else if (property == 'textColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _titleTextColor = newColor;
            }
          } else if (property == 'isVisible' && value is bool) {
            _isTitleVisible = value;
          } else if (property == 'content' && value is String) {
            _titleTextContent = value;
          } else if (property == 'textAlign' && value is String) {
            _titleTextAlign = _parseTextAlign(value);
          }
          break;
        case 'bioText':
          if (property == 'fontSize' && value is double) {
            if (operation == 'add') {
              _bioFontSize += value;
            } else if (operation == 'subtract') {
              _bioFontSize -= value;
            } else {
              _bioFontSize = value;
            }
          } else if (property == 'textColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _bioTextColor = newColor;
            }
          } else if (property == 'content' && value is String) {
            _bioTextContent = value;
          } else if (property == 'textAlign' && value is String) {
            _bioTextAlign = _parseTextAlign(value);
          }
          break;
        case 'colorBox':
          if (property == 'backgroundColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _colorBoxBackgroundColor = newColor;
            }
          } else if (property == 'size' && value is double) {
            if (operation == 'add') {
              _colorBoxSize += value;
            } else if (operation == 'subtract') {
              _colorBoxSize -= value;
            } else {
              _colorBoxSize = value;
            }
          }
          break;
        case 'button':
          if (property == 'content' && value is String) {
            _buttonTextContent = value;
          } else if (property == 'backgroundColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _buttonBackgroundColor = newColor;
            }
          } else if (property == 'textColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _buttonTextColor = newColor;
            }
          } else if (property == 'borderRadius' && value is double) {
            _buttonBorderRadius = value;
          }
          break;
        case 'toggleSwitch':
          if (property == 'activeColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _switchActiveColor = newColor;
            }
          } else if (property == 'inactiveThumbColor' && value is String) {
            final Color? newColor = parseHexColor(value);
            if (newColor != null) {
              _switchInactiveThumbColor = newColor;
            }
          } else if (property == 'value' && value is bool) {
            _switchValue = value;
          }
          break;
        case 'mainColumn': // New: handle mainColumn alignment
          if (property == 'mainAxisAlignment' && value is String) {
            _mainColumnAlignment = _parseMainAxisAlignment(value);
          }
          break;
        default:
          print('Unknown component: $component');
          _showCustomMessage('LLM requested change for unknown component: $component', success: false);
      }
    });
  }

  // Custom message display using OverlayEntry
  void _showCustomMessage(String message, {bool success = true}) {
    // Remove any existing overlay first
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // Below status bar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: success ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Automatically remove after a duration
    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  // Dialog to save a new preset
  void _showSavePresetDialog() {
    final TextEditingController presetNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Current Layout'),
        content: TextField(
          controller: presetNameController,
          decoration: const InputDecoration(hintText: 'Enter preset name'),
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
                _showCustomMessage('Preset name cannot be empty.', success: false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Dialog to load an existing preset
  void _showLoadPresetDialog() {
    if (_savedPresets.isEmpty) {
      _showCustomMessage('No saved layouts found.', success: false);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Saved Layout'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedPresets.length,
            itemBuilder: (context, index) {
              final presetName = _savedPresets.keys.elementAt(index);
              return ListTile(
                title: Text(presetName),
                onTap: () {
                  _loadPreset(presetName);
                  Navigator.pop(context);
                },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Playground'),
        centerTitle: true,
        actions: [
          // Save Preset Button
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Layout',
            onPressed: _showSavePresetDialog,
          ),
          // Load Preset Button
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Layout',
            onPressed: _showLoadPresetDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: _mainColumnAlignment, // Apply mainAxisAlignment
          children: [
            // Profile Card
            Container(
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
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content tightly
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_profileImageBorderRadius),
                    child: Image.network(
                      'https://via.placeholder.com/150', // Placeholder image
                      width: _profileImageSize,
                      height: _profileImageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nameTextContent, // Use state for content
                    textAlign: _nameTextAlign, // Apply text alignment
                    style: TextStyle(
                      fontSize: _nameFontSize,
                      fontWeight: _nameFontWeight,
                      color: _nameTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Conditionally render the title
                  if (_isTitleVisible)
                    Text(
                      _titleTextContent, // Use state for content
                      textAlign: _titleTextAlign, // Apply text alignment
                      style: TextStyle(
                        fontSize: _titleFontSize,
                        color: _titleTextColor,
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    _bioTextContent, // Use state for content
                    textAlign: _bioTextAlign, // Apply text alignment
                    style: TextStyle(
                      fontSize: _bioFontSize,
                      color: _bioTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // New: Color Box
            Container(
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
            ),

            // New: Dynamic Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  // This button just triggers the command input, or could have its own action
                  _showCustomMessage('Button Pressed! (No action yet)', success: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonBackgroundColor,
                  foregroundColor: _buttonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonBorderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(_buttonTextContent),
              ),
            ),

            // New: Dynamic Switch
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Toggle Feature:'),
                  Switch(
                    value: _switchValue,
                    onChanged: (bool newValue) {
                      // Allow manual toggle, but LLM can also change it
                      setState(() {
                        _switchValue = newValue;
                      });
                      _showCustomMessage('Switch toggled to: $newValue', success: true);
                    },
                    activeColor: _switchActiveColor,
                    inactiveThumbColor: _switchInactiveThumbColor,
                  ),
                ],
              ),
            ),

            // Spacer will now only take up remaining space after other elements are aligned by mainColumnAlignment
            const Spacer(),

            // Command Input
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commandController,
                      decoration: InputDecoration(
                        hintText: 'Enter UI command (e.g., "make picture square")',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onSubmitted: (_) => _handleCommand(), // Trigger on "Enter" key
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isLoading
                      ? const CircularProgressIndicator() // Show loading spinner
                      : ElevatedButton(
                    onPressed: _handleCommand,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
