import 'package:flutter/material.dart';
import 'package:mobile_ui_playground_flutter/llm_api_service.dart'; // Import your LLM service

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

  double _nameFontSize = 24.0;
  FontWeight _nameFontWeight = FontWeight.bold;
  Color _nameTextColor = Colors.black87;

  double _titleFontSize = 16.0;
  Color _titleTextColor = Colors.grey[700]!;
  bool _isTitleVisible = true;

  double _bioFontSize = 14.0;
  Color _bioTextColor = Colors.black54;

  // --- Store Initial State for Reset ---
  late Map<String, dynamic> _initialState;

  // Controller for the text input field
  final TextEditingController _commandController = TextEditingController();
  final LLMApiService _llmService = LLMApiService(); // Instantiate your LLM service

  bool _isLoading = false; // To show loading indicator during API call

  @override
  void initState() {
    super.initState();
    _saveInitialState(); // Save initial state on widget initialization
  }

  void _saveInitialState() {
    _initialState = {
      'profileCardBackgroundColor': _profileCardBackgroundColor,
      'profileCardBorderRadius': _profileCardBorderRadius,
      'profileImageBorderRadius': _profileImageBorderRadius,
      'profileImageSize': _profileImageSize,
      'nameFontSize': _nameFontSize,
      'nameFontWeight': _nameFontWeight,
      'nameTextColor': _nameTextColor,
      'titleFontSize': _titleFontSize,
      'titleTextColor': _titleTextColor,
      'isTitleVisible': _isTitleVisible,
      'bioFontSize': _bioFontSize,
      'bioTextColor': _bioTextColor,
    };
  }

  void _resetUI() {
    setState(() {
      _profileCardBackgroundColor = _initialState['profileCardBackgroundColor'];
      _profileCardBorderRadius = _initialState['profileCardBorderRadius'];
      _profileImageBorderRadius = _initialState['profileImageBorderRadius'];
      _profileImageSize = _initialState['profileImageSize'];
      _nameFontSize = _initialState['nameFontSize'];
      _nameFontWeight = _initialState['nameFontWeight'];
      _nameTextColor = _initialState['nameTextColor'];
      _titleFontSize = _initialState['titleFontSize'];
      _titleTextColor = _initialState['titleTextColor'];
      _isTitleVisible = _initialState['isTitleVisible'];
      _bioFontSize = _initialState['bioFontSize'];
      _bioTextColor = _initialState['bioTextColor'];
    });
    _commandController.clear();
    _showMessage('UI has been reset.', success: true);
  }

  // --- LLM-Powered Command Handling ---
  Future<void> _handleCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) {
      _showMessage('Please enter a command.', success: false);
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
          _applyInstruction(instruction);
          _showMessage('Command applied!', success: true);
        } else {
          _showMessage('LLM did not understand the command or returned invalid output. Please rephrase.', success: false);
        }
      });
    } catch (e) {
      _showMessage('Error processing command: $e', success: false);
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
    final String? operation = instruction['operation']; // For operations like "add"

    if (component == null || property == null || value == null) {
      print('Invalid instruction format: $instruction');
      _showMessage('Invalid instruction from LLM.', success: false);
      return;
    }

    // Apply changes based on the component and property
    switch (component) {
      case 'profileImage':
        if (property == 'borderRadius' && value is double) {
          _profileImageBorderRadius = value;
        } else if (property == 'size' && value is double) {
          _profileImageSize = value;
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
          _nameFontSize = (operation == 'add') ? (_nameFontSize + value) : value;
        } else if (property == 'fontWeight' && value is String) {
          if (value.toLowerCase() == 'bold') _nameFontWeight = FontWeight.bold;
          if (value.toLowerCase() == 'normal') _nameFontWeight = FontWeight.normal;
        } else if (property == 'textColor' && value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) {
            _nameTextColor = newColor;
          }
        }
        break;
      case 'titleText':
        if (property == 'fontSize' && value is double) {
          _titleFontSize = (operation == 'add') ? (_titleFontSize + value) : value;
        } else if (property == 'textColor' && value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) {
            _titleTextColor = newColor;
          }
        } else if (property == 'isVisible' && value is bool) {
          _isTitleVisible = value;
        }
        break;
      case 'bioText':
        if (property == 'fontSize' && value is double) {
          _bioFontSize = (operation == 'add') ? (_bioFontSize + value) : value;
        } else if (property == 'textColor' && value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) {
            _bioTextColor = newColor;
          }
        }
        break;
      default:
        print('Unknown component: $component');
        _showMessage('LLM requested change for unknown component: $component', success: false);
    }
  }


  void _showMessage(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Playground'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    'Jane Doe',
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
                      'Lead Product Designer',
                      style: TextStyle(
                        fontSize: _titleFontSize,
                        color: _titleTextColor,
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    'Innovating user experiences with a keen eye for detail and a passion for human-centered design.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _bioFontSize,
                      color: _bioTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(), // Pushes input bar to the bottom

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