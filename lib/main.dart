import 'package:flutter/material.dart';
import 'package:mobile_ui_playground_flutter/llm_api_service.dart'; // Import your LLM service
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // For json.encode and json.decode
import 'dart:async'; // For Timer for image carousel
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:speech_to_text/speech_to_text.dart'; // Import speech_to_text

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
  bool _isProfileCardVisible = true;
  Alignment _profileCardAlignment = Alignment.center;
  double _profileCardPadding = 0.0; // New: Padding for profile card

  double _profileImageBorderRadius = 50.0;
  double _profileImageSize = 100.0;

  String _nameTextContent = 'Jane Doe';
  double _nameFontSize = 24.0;
  FontWeight _nameFontWeight = FontWeight.bold;
  Color _nameTextColor = Colors.black87;
  TextAlign _nameTextAlign = TextAlign.center;
  bool _isNameTextVisible = true;
  Alignment _nameTextAlignment = Alignment.center;
  double _nameTextPadding = 0.0; // New: Padding for name text

  String _titleTextContent = 'Lead Product Designer';
  double _titleFontSize = 16.0;
  Color _titleTextColor = Colors.grey[700]!;
  bool _isTitleVisible = true;
  TextAlign _titleTextAlign = TextAlign.center;
  Alignment _titleTextAlignment = Alignment.center;
  double _titleTextPadding = 0.0; // New: Padding for title text

  String _bioTextContent = 'Innovating user experiences with a keen eye for detail and a passion for human-centered design.';
  double _bioFontSize = 14.0;
  Color _bioTextColor = Colors.black54;
  TextAlign _bioTextAlign = TextAlign.center;
  bool _isBioTextVisible = true;
  Alignment _bioTextAlignment = Alignment.center;
  double _bioTextPadding = 0.0; // New: Padding for bio text

  // Component states
  Color _colorBoxBackgroundColor = Colors.purple[200]!;
  double _colorBoxSize = 50.0;
  bool _isColorBoxVisible = true;
  Alignment _colorBoxAlignment = Alignment.center;
  double _colorBoxPadding = 0.0; // New: Padding for color box

  String _buttonTextContent = 'Apply Changes';
  Color _buttonBackgroundColor = Colors.blue;
  Color _buttonTextColor = Colors.white;
  double _buttonBorderRadius = 4.0;
  bool _isMainActionButtonVisible = true;
  Alignment _mainActionButtonAlignment = Alignment.center;
  double _mainActionButtonPadding = 0.0; // New: Padding for button

  bool _switchValue = true;
  Color _switchActiveColor = Colors.green;
  Color _switchInactiveThumbColor = Colors.grey;
  bool _isToggleSwitchVisible = true;
  Alignment _toggleSwitchAlignment = Alignment.center;
  double _toggleSwitchPadding = 0.0; // New: Padding for switch

  MainAxisAlignment _mainColumnAlignment = MainAxisAlignment.start;
  CrossAxisAlignment _mainColumnCrossAlignment = CrossAxisAlignment.center;
  double _mainColumnPadding = 16.0;
  Color _mainColumnBackgroundColor = Colors.transparent;

  double _sliderValue = 0.5;
  double _sliderMin = 0.0;
  double _sliderMax = 1.0;
  Color _sliderActiveColor = Colors.blue;
  Color _sliderInactiveColor = Colors.grey;
  bool _isSliderVisible = true;
  Alignment _sliderAlignment = Alignment.center;
  double _sliderPadding = 0.0; // New: Padding for slider

  double _progressValue = 0.3;
  Color _progressColor = Colors.blue;
  Color _progressBackgroundColor = Colors.grey[300]!;
  bool _isProgressIndicatorVisible = true;
  Alignment _progressIndicatorAlignment = Alignment.center;
  double _progressIndicatorPadding = 0.0; // New: Padding for progress indicator

  final List<String> _imageUrls = [
    'https://picsum.photos/150/150?random=1',
    'https://picsum.photos/150/150?random=2',
    'https://picsum.photos/150/150?random=3',
  ];
  int _currentImageIndex = 0;
  bool _imageAutoPlay = false;
  Timer? _imageAutoPlayTimer;
  bool _isImageGalleryVisible = true;
  Alignment _imageGalleryAlignment = Alignment.center;
  double _imageGalleryPadding = 0.0; // New: Padding for image gallery

  // New: Static TextField variables
  String _staticTextFieldContent = 'Hello, Flutter!';
  final TextEditingController _staticTextFieldController = TextEditingController();
  bool _isStaticTextFieldVisible = true;
  Alignment _staticTextFieldAlignment = Alignment.center;
  double _staticTextFieldPadding = 0.0;

  // New animation states
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // New: List to hold dynamically added widgets
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

  // Speech-to-text variables
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWordsSpoken = ''; // Stores the last recognized words from speech
  String _currentLocaleId = '';
  bool _isListening = false; // Track listening state

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

    _staticTextFieldController.text = _staticTextFieldContent; // Initialize static text field controller

    _saveInitialState();
    _initSharedPreferences();
    _startImageAutoPlayTimer();
    _initSpeech(); // Initialize speech recognition
  }

  @override
  void dispose() {
    debugPrint('MyHomePage dispose: Cleaning up resources');
    _commandController.dispose();
    _staticTextFieldController.dispose(); // Dispose static text field controller
    _imageAutoPlayTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _speechToText.stop(); // Stop listening when disposing
    super.dispose();
  }

  /// This initializes the speech recognition capability.
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: (val) => debugPrint('Speech Error: $val'),
    );
    if (_speechEnabled) {
      final systemLocales = await _speechToText.locales();
      _currentLocaleId = systemLocales.first.localeId;
      debugPrint('Speech initialized. Locale: $_currentLocaleId');
    } else {
      debugPrint('Speech recognition not available');
      _showMessage('Speech recognition not available.', isError: true);
    }
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (!_speechEnabled) {
      _showMessage('Speech recognition not enabled.', isError: true);
      return;
    }
    _lastWordsSpoken = ''; // Clear previous words
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 10), // Listen for up to 10 seconds
      pauseFor: const Duration(seconds: 3), // Pause if no speech for 3 seconds
      localeId: _currentLocaleId,
      cancelOnError: true,
      partialResults: true,
      onDevice: true,
    );
    setState(() {
      _isListening = true;
      _showMessage('Listening for vocal command...');
    });
  }

  /// Manually stop the active speech recognition session
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      if (_lastWordsSpoken.isNotEmpty) {
        // If words were recognized, process them as a command
        _commandController.text = _lastWordsSpoken;
        _handleCommand();
      } else {
        _showMessage('No vocal command detected.', isError: true);
      }
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns a SpeechRecognitionResult with words recognized.
  void _onSpeechResult(result) {
    setState(() {
      _lastWordsSpoken = result.recognizedWords;
      if (result.finalResult) {
        _isListening = false; // Stop listening automatically on final result
        _commandController.text = _lastWordsSpoken; // Populate text field
        _handleCommand(); // Process the command
      }
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the status of the speech recognition changes.
  void _onSpeechStatus(String status) {
    debugPrint('Speech Status: $status');
    setState(() {
      _isListening = _speechToText.isListening;
    });
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
      'isProfileCardVisible': _isProfileCardVisible,
      'profileCardAlignment': _profileCardAlignment.toString().split('.').last,
      'profileCardPadding': _profileCardPadding, // Save padding
      'profileImageBorderRadius': _profileImageBorderRadius,
      'profileImageSize': _profileImageSize,
      'nameTextContent': _nameTextContent,
      'nameFontSize': _nameFontSize,
      'nameFontWeight': _nameFontWeight.index,
      'nameTextColor': _nameTextColor.value,
      'nameTextAlign': _nameTextAlign.index,
      'isNameTextVisible': _isNameTextVisible,
      'nameTextAlignment': _nameTextAlignment.toString().split('.').last,
      'nameTextPadding': _nameTextPadding, // Save padding
      'titleTextContent': _titleTextContent,
      'titleFontSize': _titleFontSize,
      'titleTextColor': _titleTextColor.value,
      'isTitleVisible': _isTitleVisible,
      'titleTextAlign': _titleTextAlign.index,
      'titleTextAlignment': _titleTextAlignment.toString().split('.').last,
      'titleTextPadding': _titleTextPadding, // Save padding
      'bioTextContent': _bioTextContent,
      'bioFontSize': _bioFontSize,
      'bioTextColor': _bioTextColor.value,
      'bioTextAlign': _bioTextAlign.index,
      'isBioTextVisible': _isBioTextVisible,
      'bioTextAlignment': _bioTextAlignment.toString().split('.').last,
      'bioTextPadding': _bioTextPadding, // Save padding
      'colorBoxBackgroundColor': _colorBoxBackgroundColor.value,
      'colorBoxSize': _colorBoxSize,
      'isColorBoxVisible': _isColorBoxVisible,
      'colorBoxAlignment': _colorBoxAlignment.toString().split('.').last,
      'colorBoxPadding': _colorBoxPadding, // Save padding
      'buttonTextContent': _buttonTextContent,
      'buttonBackgroundColor': _buttonBackgroundColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonBorderRadius': _buttonBorderRadius,
      'isMainActionButtonVisible': _isMainActionButtonVisible,
      'mainActionButtonAlignment': _mainActionButtonAlignment.toString().split('.').last,
      'mainActionButtonPadding': _mainActionButtonPadding, // Save padding
      'switchValue': _switchValue,
      'switchActiveColor': _switchActiveColor.value,
      'switchInactiveThumbColor': _switchInactiveThumbColor.value,
      'isToggleSwitchVisible': _isToggleSwitchVisible,
      'toggleSwitchAlignment': _toggleSwitchAlignment.toString().split('.').last,
      'toggleSwitchPadding': _toggleSwitchPadding, // Save padding
      'mainColumnAlignment': _mainColumnAlignment.index,
      'mainColumnCrossAlignment': _mainColumnCrossAlignment.index,
      'mainColumnPadding': _mainColumnPadding,
      'mainColumnBackgroundColor': _mainColumnBackgroundColor.value,
      'sliderValue': _sliderValue,
      'sliderMin': _sliderMin,
      'sliderMax': _sliderMax,
      'sliderActiveColor': _sliderActiveColor.value,
      'sliderInactiveColor': _sliderInactiveColor.value,
      'isSliderVisible': _isSliderVisible,
      'sliderAlignment': _sliderAlignment.toString().split('.').last,
      'sliderPadding': _sliderPadding, // Save padding
      'progressValue': _progressValue,
      'progressColor': _progressColor.value,
      'progressBackgroundColor': _progressBackgroundColor.value,
      'isProgressIndicatorVisible': _isProgressIndicatorVisible,
      'progressIndicatorAlignment': _progressIndicatorAlignment.toString().split('.').last,
      'progressIndicatorPadding': _progressIndicatorPadding, // Save padding
      'currentImageIndex': _currentImageIndex,
      'imageAutoPlay': _imageAutoPlay,
      'isImageGalleryVisible': _isImageGalleryVisible,
      'imageGalleryAlignment': _imageGalleryAlignment.toString().split('.').last,
      'imageGalleryPadding': _imageGalleryPadding, // Save padding
      'staticTextFieldContent': _staticTextFieldContent, // Save static text field content
      'isStaticTextFieldVisible': _isStaticTextFieldVisible,
      'staticTextFieldAlignment': _staticTextFieldAlignment.toString().split('.').last,
      'staticTextFieldPadding': _staticTextFieldPadding,
      'dynamicWidgets': _dynamicWidgets,
    };
  }

  void _applyUIState(Map<String, dynamic> state) {
    if (!mounted) return;

    setState(() {
      try {
        _profileCardBackgroundColor = Color(state['profileCardBackgroundColor'] ?? Colors.grey[200]!.value);
        _profileCardBorderRadius = (state['profileCardBorderRadius'] ?? 8.0).toDouble();
        _isProfileCardVisible = state['isProfileCardVisible'] ?? true;
        _profileCardAlignment = _parseAlignment(state['profileCardAlignment'] ?? 'center');
        _profileCardPadding = (state['profileCardPadding'] ?? 0.0).toDouble(); // Apply padding

        _profileImageBorderRadius = (state['profileImageBorderRadius'] ?? 50.0).toDouble();
        _profileImageSize = (state['profileImageSize'] ?? 100.0).toDouble();

        _nameTextContent = state['nameTextContent'] ?? 'Jane Doe';
        _nameFontSize = (state['nameFontSize'] ?? 24.0).toDouble();
        _nameFontWeight = FontWeight.values[state['nameFontWeight'] ?? FontWeight.bold.index];
        _nameTextColor = Color(state['nameTextColor'] ?? Colors.black87.value);
        _nameTextAlign = TextAlign.values[state['nameTextAlign'] ?? TextAlign.center.index];
        _isNameTextVisible = state['isNameTextVisible'] ?? true;
        _nameTextAlignment = _parseAlignment(state['nameTextAlignment'] ?? 'center');
        _nameTextPadding = (state['nameTextPadding'] ?? 0.0).toDouble(); // Apply padding

        _titleTextContent = state['titleTextContent'] ?? 'Lead Product Designer';
        _titleFontSize = (state['titleFontSize'] ?? 16.0).toDouble();
        _titleTextColor = Color(state['titleTextColor'] ?? Colors.grey[700]!.value);
        _isTitleVisible = state['isTitleVisible'] ?? true;
        _titleTextAlign = TextAlign.values[state['titleTextAlign'] ?? TextAlign.center.index];
        _titleTextAlignment = _parseAlignment(state['titleTextAlignment'] ?? 'center');
        _titleTextPadding = (state['titleTextPadding'] ?? 0.0).toDouble(); // Apply padding

        _bioTextContent = state['bioTextContent'] ?? 'Default bio text';
        _bioFontSize = (state['bioFontSize'] ?? 14.0).toDouble();
        _bioTextColor = Color(state['bioTextColor'] ?? Colors.black54.value);
        _bioTextAlign = TextAlign.values[state['bioTextAlign'] ?? TextAlign.center.index];
        _isBioTextVisible = state['isBioTextVisible'] ?? true;
        _bioTextAlignment = _parseAlignment(state['bioTextAlignment'] ?? 'center');
        _bioTextPadding = (state['bioTextPadding'] ?? 0.0).toDouble(); // Apply padding

        _colorBoxBackgroundColor = Color(state['colorBoxBackgroundColor'] ?? Colors.purple[200]!.value);
        _colorBoxSize = (state['colorBoxSize'] ?? 50.0).toDouble();
        _isColorBoxVisible = state['isColorBoxVisible'] ?? true;
        _colorBoxAlignment = _parseAlignment(state['colorBoxAlignment'] ?? 'center');
        _colorBoxPadding = (state['colorBoxPadding'] ?? 0.0).toDouble(); // Apply padding

        _buttonTextContent = state['buttonTextContent'] ?? 'Apply Changes';
        _buttonBackgroundColor = Color(state['buttonBackgroundColor'] ?? Colors.blue.value);
        _buttonTextColor = Color(state['buttonTextColor'] ?? Colors.white.value);
        _buttonBorderRadius = (state['buttonBorderRadius'] ?? 4.0).toDouble();
        _isMainActionButtonVisible = true;
        _mainActionButtonAlignment = _parseAlignment(state['mainActionButtonAlignment'] ?? 'center');
        _mainActionButtonPadding = (state['mainActionButtonPadding'] ?? 0.0).toDouble(); // Apply padding

        _switchValue = state['switchValue'] ?? true;
        _switchActiveColor = Color(state['switchActiveColor'] ?? Colors.green.value);
        _switchInactiveThumbColor = Color(state['switchInactiveThumbColor'] ?? Colors.grey.value);
        _isToggleSwitchVisible = true;
        _toggleSwitchAlignment = _parseAlignment(state['toggleSwitchAlignment'] ?? 'center');
        _toggleSwitchPadding = (state['toggleSwitchPadding'] ?? 0.0).toDouble(); // Apply padding

        _mainColumnAlignment = MainAxisAlignment.values[state['mainColumnAlignment'] ?? MainAxisAlignment.start.index];
        _mainColumnCrossAlignment = CrossAxisAlignment.values[state['mainColumnCrossAlignment'] ?? CrossAxisAlignment.center.index];
        _mainColumnPadding = (state['mainColumnPadding'] ?? 16.0).toDouble();
        _mainColumnBackgroundColor = Color(state['mainColumnBackgroundColor'] ?? Colors.transparent.value);

        _sliderValue = (state['sliderValue'] ?? 0.5).toDouble();
        _sliderMin = (state['sliderMin'] ?? 0.0).toDouble();
        _sliderMax = (state['sliderMax'] ?? 1.0).toDouble();
        _sliderActiveColor = Color(state['sliderActiveColor'] ?? Colors.blue.value);
        _sliderInactiveColor = Color(state['sliderInactiveColor'] ?? Colors.grey.value);
        _isSliderVisible = true;
        _sliderAlignment = _parseAlignment(state['sliderAlignment'] ?? 'center');
        _sliderPadding = (state['sliderPadding'] ?? 0.0).toDouble(); // Apply padding

        _progressValue = (state['progressValue'] ?? 0.3).toDouble();
        _progressColor = Color(state['progressColor'] ?? Colors.blue.value);
        _progressBackgroundColor = Color(state['progressBackgroundColor'] ?? Colors.grey[300]!.value);
        _isProgressIndicatorVisible = true;
        _progressIndicatorAlignment = _parseAlignment(state['progressIndicatorAlignment'] ?? 'center');
        _progressIndicatorPadding = (state['progressIndicatorPadding'] ?? 0.0).toDouble(); // Apply padding

        _currentImageIndex = state['currentImageIndex'] ?? 0;
        _imageAutoPlay = state['imageAutoPlay'] ?? false;
        _isImageGalleryVisible = true;
        _imageGalleryAlignment = _parseAlignment(state['imageGalleryAlignment'] ?? 'center');
        _imageGalleryPadding = (state['imageGalleryPadding'] ?? 0.0).toDouble(); // Apply padding

        _staticTextFieldContent = state['staticTextFieldContent'] ?? 'Hello, Flutter!';
        _staticTextFieldController.text = _staticTextFieldContent; // Update controller text
        _isStaticTextFieldVisible = state['isStaticTextFieldVisible'] ?? true;
        _staticTextFieldAlignment = _parseAlignment(state['staticTextFieldAlignment'] ?? 'center');
        _staticTextFieldPadding = (state['staticTextFieldPadding'] ?? 0.0).toDouble();

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

  CrossAxisAlignment _parseCrossAxisAlignment(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'start': return CrossAxisAlignment.start;
      case 'center': return CrossAxisAlignment.center;
      case 'end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return CrossAxisAlignment.center;
    }
  }

  Alignment _parseAlignment(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'topleft': return Alignment.topLeft;
      case 'topcenter': return Alignment.topCenter;
      case 'topright': return Alignment.topRight;
      case 'centerleft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerright': return Alignment.centerRight;
      case 'bottomleft': return Alignment.bottomLeft;
      case 'bottomcenter': return Alignment.bottomCenter;
      case 'bottomright': return Alignment.bottomRight;
      default: return Alignment.center;
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
    } else if (command.toLowerCase() == 'make screen blank') {
      _makeScreenBlank();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic>? instruction = await _llmService.generateStructuredOutput(command);

      if (instruction != null && instruction.isNotEmpty) {
        if (instruction.containsKey('commandType')) {
          if (instruction['commandType'] == 'addWidget') {
            _handleAddWidgetCommand(instruction);
          } else {
            await _handlePresetCommand(instruction);
          }
        } else {
          bool handled = _applyInstructionToStaticComponent(instruction);
          if (!handled) {
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
        'id': DateTime.now().microsecondsSinceEpoch,
      });
      _showMessage('Added new $widgetType widget!');
      debugPrint('Dynamic widgets: $_dynamicWidgets');
    });
  }

  void _handleDynamicWidgetModification(Map<String, dynamic> instruction) {
    final String? component = instruction['component'];
    final String? property = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (component == null || property == null || value == null) {
      _showMessage('Invalid instruction format for dynamic widget modification.', isError: true);
      return;
    }

    int? targetIndexInList;
    if (instruction.containsKey('targetIndex') && instruction['targetIndex'] is num) {
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
            case 'dynamicButton':
              if (property == 'content' && value is String) {
                targetProperties['content'] = value;
              } else if (property == 'backgroundColor' && value is String) {
                targetProperties['backgroundColor'] = value;
              } else if (property == 'textColor' && value is String) {
                targetProperties['textColor'] = value;
              } else if (property == 'borderRadius' && value is num) {
                targetProperties['borderRadius'] = value.toDouble();
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic button
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
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
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic color box
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
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
                targetProperties['textAlign'] = value;
              } else if (property == 'fontWeight' && value is String) {
                targetProperties['fontWeight'] = value;
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic text
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              }
              break;
            case 'toggleSwitch':
              if (property == 'value' && value is bool) {
                targetProperties['value'] = value;
              } else if (property == 'activeColor' && value is String) {
                targetProperties['activeColor'] = value;
              } else if (property == 'inactiveThumbColor' && value is String) {
                targetProperties['inactiveThumbColor'] = value;
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic switch
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
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
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic slider
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              }
              break;
            case 'progressIndicator':
              if (property == 'value' && value is num) {
                targetProperties['value'] = value.toDouble().clamp(0.0, 1.0);
              } else if (property == 'color' && value is String) {
                targetProperties['color'] = value;
              } else if (property == 'backgroundColor' && value is String) {
                targetProperties['backgroundColor'] = value;
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic progress indicator
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
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
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) { // New: Padding for dynamic text field
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              }
              break;
            default:
              _showMessage('Cannot modify dynamic widget of type: $component', isError: true);
              break;
          }
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

  bool _applyInstructionToStaticComponent(Map<String, dynamic> instruction) {
    final String? component = instruction['component'];
    final String? property = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (component == null || property == null || value == null) {
      return false;
    }

    bool handled = true;

    setState(() {
      try {
        switch (component) {
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
          case 'mainActionButton':
            _handleButtonInstruction(property, value, operation);
            break;
          case 'toggleSwitch':
            _handleSwitchInstruction(property, value, operation);
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
          case 'mainColumn':
            _handleMainColumnInstruction(property, value, operation);
            break;
          case 'staticTextField': // New: Handle static text field instructions
            _handleStaticTextFieldInstruction(property, value, operation);
            break;
          default:
            handled = false;
        }
      } catch (e) {
        debugPrint('Error applying instruction to static component: $e');
        _showMessage('Error applying instruction to static component.', isError: true);
        handled = false;
      }
    });
    return handled;
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
      case 'isVisible':
        if (value is bool) _isProfileCardVisible = value;
        break;
      case 'alignment':
        if (value is String) _profileCardAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _profileCardPadding += newValue;
          } else if (operation == 'subtract') {
            _profileCardPadding = (_profileCardPadding - newValue).clamp(0.0, 50.0);
          } else {
            _profileCardPadding = newValue.clamp(0.0, 50.0);
          }
        }
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
      case 'isVisible':
        if (value is bool) _isNameTextVisible = value;
        break;
      case 'alignment':
        if (value is String) _nameTextAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _nameTextPadding += newValue;
          } else if (operation == 'subtract') {
            _nameTextPadding = (_nameTextPadding - newValue).clamp(0.0, 50.0);
          } else {
            _nameTextPadding = newValue.clamp(0.0, 50.0);
          }
        }
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
      case 'alignment':
        if (value is String) _titleTextAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _titleTextPadding += newValue;
          } else if (operation == 'subtract') {
            _titleTextPadding = (_titleTextPadding - newValue).clamp(0.0, 50.0);
          } else {
            _titleTextPadding = newValue.clamp(0.0, 50.0);
          }
        }
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
      case 'isVisible':
        if (value is bool) _isBioTextVisible = value;
        break;
      case 'alignment':
        if (value is String) _bioTextAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _bioTextPadding += newValue;
          } else if (operation == 'subtract') {
            _bioTextPadding = (_bioTextPadding - newValue).clamp(0.0, 50.0);
          } else {
            _bioTextPadding = newValue.clamp(0.0, 50.0);
          }
        }
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
      case 'isVisible':
        if (value is bool) _isColorBoxVisible = value;
        break;
      case 'alignment':
        if (value is String) _colorBoxAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _colorBoxPadding += newValue;
          } else if (operation == 'subtract') {
            _colorBoxPadding = (_colorBoxPadding - newValue).clamp(0.0, 50.0);
          } else {
            _colorBoxPadding = newValue.clamp(0.0, 50.0);
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
      case 'isVisible':
        if (value is bool) _isMainActionButtonVisible = value;
        break;
      case 'alignment':
        if (value is String) _mainActionButtonAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _mainActionButtonPadding += newValue;
          } else if (operation == 'subtract') {
            _mainActionButtonPadding = (_mainActionButtonPadding - newValue).clamp(0.0, 50.0);
          } else {
            _mainActionButtonPadding = newValue.clamp(0.0, 50.0);
          }
        }
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
      case 'isVisible':
        if (value is bool) _isToggleSwitchVisible = value;
        break;
      case 'alignment':
        if (value is String) _toggleSwitchAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _toggleSwitchPadding += newValue;
          } else if (operation == 'subtract') {
            _toggleSwitchPadding = (_toggleSwitchPadding - newValue).clamp(0.0, 50.0);
          } else {
            _toggleSwitchPadding = newValue.clamp(0.0, 50.0);
          }
        }
        break;
    }
  }

  void _handleMainColumnInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'mainAxisAlignment':
        if (value is String) {
          _mainColumnAlignment = _parseMainAxisAlignment(value);
        }
        break;
      case 'crossAxisAlignment':
        if (value is String) {
          _mainColumnCrossAlignment = _parseCrossAxisAlignment(value);
        }
        break;
      case 'padding':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _mainColumnPadding += newValue;
          } else if (operation == 'subtract') {
            _mainColumnPadding = (_mainColumnPadding - newValue).clamp(0.0, 50.0);
          } else {
            _mainColumnPadding = newValue.clamp(0.0, 50.0);
          }
        }
        break;
      case 'backgroundColor':
        if (value is String) {
          final Color? newColor = parseHexColor(value);
          if (newColor != null) _mainColumnBackgroundColor = newColor;
        }
        break;
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
      case 'isVisible':
        if (value is bool) _isSliderVisible = value;
        break;
      case 'alignment':
        if (value is String) _sliderAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _sliderPadding += newValue;
          } else if (operation == 'subtract') {
            _sliderPadding = (_sliderPadding - newValue).clamp(0.0, 50.0);
          } else {
            _sliderPadding = newValue.clamp(0.0, 50.0);
          }
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
      case 'isVisible':
        if (value is bool) _isProgressIndicatorVisible = value;
        break;
      case 'alignment':
        if (value is String) _progressIndicatorAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _progressIndicatorPadding += newValue;
          } else if (operation == 'subtract') {
            _progressIndicatorPadding = (_progressIndicatorPadding - newValue).clamp(0.0, 50.0);
          } else {
            _progressIndicatorPadding = newValue.clamp(0.0, 50.0);
          }
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
      case 'isVisible':
        if (value is bool) _isImageGalleryVisible = value;
        break;
      case 'alignment':
        if (value is String) _imageGalleryAlignment = _parseAlignment(value);
        break;
      case 'padding': // New: Handle padding
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _imageGalleryPadding += newValue;
          } else if (operation == 'subtract') {
            _imageGalleryPadding = (_imageGalleryPadding - newValue).clamp(0.0, 50.0);
          } else {
            _imageGalleryPadding = newValue.clamp(0.0, 50.0);
          }
        }
        break;
    }
  }

  void _handleStaticTextFieldInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'content':
        if (value is String) {
          _staticTextFieldContent = value;
          _staticTextFieldController.text = value; // Update controller
        }
        break;
      case 'isVisible':
        if (value is bool) _isStaticTextFieldVisible = value;
        break;
      case 'alignment':
        if (value is String) _staticTextFieldAlignment = _parseAlignment(value);
        break;
      case 'padding':
        if (value is num) {
          final newValue = value.toDouble();
          if (operation == 'add') {
            _staticTextFieldPadding += newValue;
          } else if (operation == 'subtract') {
            _staticTextFieldPadding = (_staticTextFieldPadding - newValue).clamp(0.0, 50.0);
          } else {
            _staticTextFieldPadding = newValue.clamp(0.0, 50.0);
          }
        }
        break;
    }
  }

  void _makeScreenBlank() {
    setState(() {
      _isProfileCardVisible = false;
      _isNameTextVisible = false;
      _isTitleVisible = false;
      _isBioTextVisible = false;
      _isColorBoxVisible = false;
      _isMainActionButtonVisible = false;
      _isToggleSwitchVisible = false;
      _isSliderVisible = false;
      _isProgressIndicatorVisible = false;
      _isImageGalleryVisible = false;
      _isStaticTextFieldVisible = false; // Hide static text field
      _dynamicWidgets.clear();
    });
    _showMessage('Screen is now blank.');
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

  Widget _buildDynamicWidget(Map<String, dynamic> widgetData) {
    final String widgetType = widgetData['widgetType'];
    final Map<String, dynamic> properties = Map<String, dynamic>.from(widgetData['properties']);
    final Key uniqueKey = ValueKey('dynamic_widget_${widgetData['id']}');

    try {
      Alignment dynamicAlignment = _parseAlignment(properties['alignment'] ?? 'center');
      double dynamicPadding = (properties['padding'] ?? 0.0).toDouble(); // Get padding for dynamic widgets

      Widget childWidget;
      switch (widgetType) {
        case 'dynamicButton':
          childWidget = ElevatedButton(
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
          );
          break;
        case 'colorBox':
          childWidget = Container(
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
          );
          break;
        case 'text':
          childWidget = Text(
            properties['content'] ?? 'Dynamic Text',
            textAlign: _parseTextAlign(properties['textAlign'] ?? 'center'),
            style: TextStyle(
              fontSize: (properties['fontSize'] ?? 16.0).toDouble(),
              color: parseHexColor(properties['textColor'] ?? '0xFF000000'),
              fontWeight: properties['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
            ),
          );
          break;
        case 'toggleSwitch':
          childWidget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Dynamic Toggle:'),
              Switch(
                value: properties['value'] ?? false,
                onChanged: (bool newValue) {
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
          );
          break;
        case 'slider':
          double dynSliderValue = (properties['value'] ?? 0.5).toDouble().clamp(
            (properties['min'] ?? 0.0).toDouble(),
            (properties['max'] ?? 1.0).toDouble(),
          );
          double dynSliderMin = (properties['min'] ?? 0.0).toDouble();
          double dynSliderMax = (properties['max'] ?? 1.0).toDouble();

          childWidget = Column(
            children: [
              Text('Dynamic Slider Value: ${dynSliderValue.toStringAsFixed(2)}'),
              Slider(
                value: dynSliderValue,
                min: dynSliderMin,
                max: dynSliderMax,
                activeColor: parseHexColor(properties['activeColor'] ?? '0xFF2196F3'),
                inactiveColor: parseHexColor(properties['inactiveColor'] ?? '0xFF9E9E9E'),
                onChanged: (double newValue) {
                  setState(() {
                    final int index = _dynamicWidgets.indexWhere((w) => w['id'] == widgetData['id']);
                    if (index != -1) {
                      _dynamicWidgets[index]['properties']['value'] = newValue;
                    }
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${dynSliderMin.toStringAsFixed(1)}'),
                  Text('${dynSliderMax.toStringAsFixed(1)}'),
                ],
              ),
            ],
          );
          break;
        case 'progressIndicator':
          double dynProgressValue = (properties['value'] ?? 0.5).toDouble().clamp(0.0, 1.0);
          childWidget = Column(
            children: [
              Text('Dynamic Progress: ${(dynProgressValue * 100).toStringAsFixed(0)}%'),
              LinearProgressIndicator(
                value: dynProgressValue,
                color: parseHexColor(properties['color'] ?? '0xFF2196F3'),
                backgroundColor: parseHexColor(properties['backgroundColor'] ?? '0xFFE0E0E0'),
              ),
            ],
          );
          break;
        case 'textField':
          TextEditingController dynamicTextController = TextEditingController(text: properties['initialText'] ?? '');
          childWidget = TextField(
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
              setState(() {
                final int index = _dynamicWidgets.indexWhere((w) => w['id'] == widgetData['id']);
                if (index != -1) {
                  _dynamicWidgets[index]['properties']['initialText'] = text;
                }
              });
            },
          );
          break;
        default:
          childWidget = Text('Unknown dynamic widget type: $widgetType');
      }

      return Padding( // Apply padding here
        key: uniqueKey,
        padding: EdgeInsets.all(dynamicPadding),
        child: Align(
          alignment: dynamicAlignment,
          child: childWidget,
        ),
      );
    } catch (e) {
      debugPrint('Error building dynamic widget $widgetType: $e');
      return SizedBox(
        key: uniqueKey,
        child: Text('Error rendering dynamic widget: $widgetType'),
      );
    }
  }

  Widget _buildProfileCard() {
    return Visibility(
      visible: _isProfileCardVisible,
      child: Padding( // Apply padding here
        padding: EdgeInsets.all(_profileCardPadding),
        child: Align(
          alignment: _profileCardAlignment,
          child: AnimatedBuilder(
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
                      Visibility(
                        visible: _isNameTextVisible,
                        child: Padding( // Apply padding here
                          padding: EdgeInsets.all(_nameTextPadding),
                          child: Align(
                            alignment: _nameTextAlignment,
                            child: AnimatedDefaultTextStyle(
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (_isTitleVisible)
                        Padding( // Apply padding here
                          padding: EdgeInsets.all(_titleTextPadding),
                          child: Align(
                            alignment: _titleTextAlignment,
                            child: AnimatedDefaultTextStyle(
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
                          ),
                        ),
                      const SizedBox(height: 15),
                      Visibility(
                        visible: _isBioTextVisible,
                        child: Padding( // Apply padding here
                          padding: EdgeInsets.all(_bioTextPadding),
                          child: Align(
                            alignment: _bioTextAlignment,
                            child: AnimatedDefaultTextStyle(
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox() {
    return Visibility(
      visible: _isColorBoxVisible,
      child: Padding( // Apply padding here
        padding: EdgeInsets.all(_colorBoxPadding),
        child: Align(
          alignment: _colorBoxAlignment,
          child: AnimatedContainer(
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
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicButton() {
    return Visibility(
      visible: _isMainActionButtonVisible,
      child: Padding(
        padding: EdgeInsets.all(_mainActionButtonPadding), // Apply padding here
        child: Align(
          alignment: _mainActionButtonAlignment,
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
        ),
      ),
    );
  }

  Widget _buildDynamicSwitch() {
    return Visibility(
      visible: _isToggleSwitchVisible,
      child: Padding(
        padding: EdgeInsets.all(_toggleSwitchPadding), // Apply padding here
        child: Align(
          alignment: _toggleSwitchAlignment,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }

  Widget _buildDynamicSlider() {
    return Visibility(
      visible: _isSliderVisible,
      child: Padding(
        padding: EdgeInsets.all(_sliderPadding), // Apply padding here
        child: Align(
          alignment: _sliderAlignment,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Visibility(
      visible: _isProgressIndicatorVisible,
      child: Padding(
        padding: EdgeInsets.all(_progressIndicatorPadding), // Apply padding here
        child: Align(
          alignment: _progressIndicatorAlignment,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Visibility(
      visible: _isImageGalleryVisible,
      child: Padding(
        padding: EdgeInsets.all(_imageGalleryPadding), // Apply padding here
        child: Align(
          alignment: _imageGalleryAlignment,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }

  Widget _buildStaticTextField() {
    return Visibility(
      visible: _isStaticTextFieldVisible,
      child: Padding(
        padding: EdgeInsets.all(_staticTextFieldPadding),
        child: Align(
          alignment: _staticTextFieldAlignment,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _staticTextFieldController,
              decoration: const InputDecoration(
                labelText: 'Static Text Field',
                hintText: 'Enter text here',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  _staticTextFieldContent = text;
                });
              },
            ),
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
                    // Updated suffixIcon to include the microphone
                    suffixIcon: IconButton(
                      icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic),
                      color: _speechToText.isListening ? Colors.red : Colors.blue,
                      onPressed: _speechToText.isListening ? _stopListening : _startListening,
                      tooltip: _speechToText.isListening ? 'Stop Listening' : 'Start Listening',
                    ),
                  ),
                  onSubmitted: (_) => _handleCommand(),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing as mic is now in TextField
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
          if (_speechToText.isListening)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Listening: "$_lastWordsSpoken"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey[600],
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
                case 'blank_screen':
                  _makeScreenBlank();
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
                value: 'blank_screen',
                child: ListTile(
                  leading: Icon(Icons.fullscreen_exit),
                  title: Text('Make Screen Blank'),
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
        child: Container(
          color: _mainColumnBackgroundColor,
          child: Column(
            mainAxisAlignment: _mainColumnAlignment,
            crossAxisAlignment: _mainColumnCrossAlignment,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(_mainColumnPadding),
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
                      _buildStaticTextField(), // Added the static text field here
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
