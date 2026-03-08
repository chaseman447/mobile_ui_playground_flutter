import 'package:flutter/material.dart';
import 'navigation/main_navigation.dart';
import 'services/supabase_service.dart';

// Keep existing imports for backward compatibility
import "package:mobile_ui_playground_flutter/services/puter_service.dart"; // Import Puter.js service'; // Import your LLM service
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // For json.encode and json.decode
import 'dart:async'; // For Timer for image carousel
import 'dart:math'; // For random numbers
import 'package:image_picker/image_picker.dart'; // For image selection

// Import navigation and layout management services
import 'services/navigation_service.dart';
import 'services/layout_manager.dart';
import 'screens/layout_manager_screen.dart';

// Import new components
import 'widgets/profile_card.dart';
import 'widgets/color_box_widget.dart';
import 'widgets/dynamic_button_widget.dart';
import 'widgets/dynamic_switch_widget.dart';
import 'widgets/dynamic_slider_widget.dart';
import 'widgets/progress_indicator_widget.dart'; // Corrected import
import 'widgets/image_gallery_widget.dart';
import 'widgets/static_text_field_widget.dart';
import 'widgets/dynamic_widget_builder.dart'; // New: For dynamic widgets
import 'utils/color_parser.dart' as color_parser; // For parseHexColor - Added 'as color_parser'
import 'utils/alignment_parser.dart'; // New: For alignment parsing (parseAlignment, parseMainAxisAlignment, parseCrossAxisAlignment, and parseTextAlign)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    // Continue without Supabase for development
  }
  
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
      navigatorKey: NavigationService.navigatorKey,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const MainNavigation(),
        '/layout-manager': (context) => const LayoutManagerScreen(),
        '/settings': (context) => const MainNavigation(), // Navigate to settings tab
        '/about': (context) => const MainNavigation(), // Navigate to about tab
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    // Listen to auth state changes
    SupabaseService.instance.authStateChanges.listen((authState) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild when auth state changes
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService.instance;
    
    // For development, allow bypassing authentication
    // In production, you might want to enforce authentication
    return const MainNavigation();
    
    // Uncomment below to enforce authentication:
    // return supabaseService.isAuthenticated 
    //     ? const MainNavigation()
    //     : const AuthScreen();
  }
}

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic>? routeArguments;
  
  const MyHomePage({super.key, this.routeArguments});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // --- State Variables for UI Elements ---
  // Profile Card states
  Color _profileCardBackgroundColor = Colors.grey[200]!;
  double _profileCardBorderRadius = 8.0;
  bool _isProfileCardVisible = true;
  Alignment _profileCardAlignment = Alignment.center;
  double _profileCardPadding = 0.0;

  double _profileImageBorderRadius = 50.0;
  double _profileImageSize = 100.0;
  // Ensure this URL is always valid. It's used as a default and should never be empty.
  String _profileImageUrl = 'https://picsum.photos/150?random=4';

  String _nameTextContent = 'Jane Doe';
  double _nameFontSize = 24.0;
  FontWeight _nameFontWeight = FontWeight.bold;
  Color _nameTextColor = Colors.black87;
  TextAlign _nameTextAlign = TextAlign.center;
  bool _isNameTextVisible = true;
  Alignment _nameTextAlignment = Alignment.center;
  double _nameTextPadding = 0.0;

  String _titleTextContent = 'Lead Product Designer';
  double _titleFontSize = 16.0;
  Color _titleTextColor = Colors.grey[700]!;
  bool _isTitleVisible = true;
  TextAlign _titleTextAlign = TextAlign.center;
  Alignment _titleTextAlignment = Alignment.center;
  double _titleTextPadding = 0.0;

  String _bioTextContent = 'Innovating user experiences with a keen eye for detail and a passion for human-centered design.';
  double _bioFontSize = 14.0;
  Color _bioTextColor = Colors.black54;
  TextAlign _bioTextAlign = TextAlign.center;
  bool _isBioTextVisible = true;
  Alignment _bioTextAlignment = Alignment.center;
  double _bioTextPadding = 0.0;

  // Color Box states
  Color _colorBoxBackgroundColor = Colors.purple[200]!;
  double _colorBoxSize = 50.0;
  bool _isColorBoxVisible = true;
  Alignment _colorBoxAlignment = Alignment.center;
  double _colorBoxPadding = 0.0;

  // Button states
  String _buttonTextContent = 'Apply Changes';
  Color _buttonBackgroundColor = Colors.blue;
  Color _buttonTextColor = Colors.white;
  double _buttonBorderRadius = 4.0;
  bool _isMainActionButtonVisible = true;
  Alignment _mainActionButtonAlignment = Alignment.center;
  double _mainActionButtonPadding = 0.0;

  // Switch states
  bool _switchValue = true;
  Color _switchActiveColor = Colors.green;
  Color _switchInactiveThumbColor = Colors.grey;
  bool _isToggleSwitchVisible = true;
  Alignment _toggleSwitchAlignment = Alignment.center;
  double _toggleSwitchPadding = 0.0;

  // Column states - NEW LAYOUT CONTROL
  MainAxisAlignment _mainColumnAlignment = MainAxisAlignment.start;
  CrossAxisAlignment _mainColumnCrossAlignment = CrossAxisAlignment.center;
  double _mainColumnPadding = 16.0;
  Color _mainColumnBackgroundColor = Colors.transparent;

  // Slider states
  double _sliderValue = 0.5;
  double _sliderMin = 0.0;
  double _sliderMax = 1.0;
  Color _sliderActiveColor = Colors.blue;
  Color _sliderInactiveColor = Colors.grey;
  bool _isSliderVisible = true;
  Alignment _sliderAlignment = Alignment.center;
  double _sliderPadding = 0.0;

  // Progress Indicator states
  double _progressValue = 0.3;
  Color _progressColor = Colors.blue;
  Color _progressBackgroundColor = Colors.grey[300]!;
  bool _isProgressIndicatorVisible = true;
  Alignment _progressIndicatorAlignment = Alignment.center;
  double _progressIndicatorPadding = 0.0;

  // Image Gallery states
  final List<String> _imageUrls = List.generate(3, (index) {
    // Generate random images for initial load, ensuring they are valid.
    final random = Random();
    return 'https://picsum.photos/150/150?random=${random.nextInt(1000)}';
  });
  int _currentImageIndex = 0;
  bool _imageAutoPlay = false;
  Timer? _imageAutoPlayTimer;
  bool _isImageGalleryVisible = true;
  Alignment _imageGalleryAlignment = Alignment.center;
  double _imageGalleryPadding = 0.0;

  // Static TextField states
  String _staticTextFieldContent = 'Hello, Flutter!';
  bool _isStaticTextFieldVisible = true;
  Alignment _staticTextFieldAlignment = Alignment.center;
  double _staticTextFieldPadding = 0.0;

  // Animation states
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Dynamic widgets list
  List<Map<String, dynamic>> _dynamicWidgets = [];

  // State management for presets and history
  late Map<String, dynamic> _initialState;
  late SharedPreferences _prefs;
  Map<String, Map<String, dynamic>> _savedPresets = {};
  Map<String, Map<String, dynamic>> _savedWidgets = {};

  final TextEditingController _commandController = TextEditingController();
  final PuterService _puterService = PuterService();
  final NavigationService _navigationService = NavigationService();
  final LayoutManager _layoutManager = LayoutManager();

  bool _isLoading = false;
  String _lastCommand = '';
  List<String> _commandHistory = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    debugPrint('MyHomePage initState: Initializing enhanced UI');

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
    _initializeLayoutManager();
    PuterService.initialize();
    
    // Check for route arguments to auto-load preset
    _checkRouteArguments();
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
      _loadAllSavedWidgets();
      _loadCommandHistory();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
      _showMessage('Error loading saved data', isError: true);
    }
  }

  void _initializeLayoutManager() async {
    await _layoutManager.initialize();
  }

  void _checkRouteArguments() {
    if (widget.routeArguments != null) {
      final String? presetToLoad = widget.routeArguments!['loadPreset'];
      if (presetToLoad != null) {
        // Delay the preset loading to ensure SharedPreferences is initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _loadPreset(presetToLoad);
        });
      }
    }
  }

  Future<void> _handleNavigationCommand(Map<String, dynamic> instruction) async {
    final String action = instruction['action'] ?? '';
    final Map<String, dynamic> parameters = instruction['parameters'] ?? {};
    
    try {
      switch (action) {
        case 'navigateToScreen':
          final String screenName = parameters['screen'] ?? '';
          _navigationService.navigateToScreen(screenName);
          _showMessage('Navigated to $screenName');
          break;
        case 'navigateToLayout':
           final String layoutName = parameters['layout'] ?? '';
           if (layoutName.isNotEmpty) {
             final layouts = _layoutManager.getAllLayouts();
             final layout = layouts.firstWhere(
               (l) => l.name.toLowerCase() == layoutName.toLowerCase(),
               orElse: () => throw Exception('Layout not found'),
             );
             await _navigationService.navigateToLayout(layout.id);
             _showMessage('Switched to layout: $layoutName');
           }
           break;
        case 'openLayoutManager':
          _navigationService.navigateToLayoutManager();
          _showMessage('Opened layout manager');
          break;
        default:
          _showMessage('Unknown navigation command: $action', isError: true);
      }
    } catch (e) {
      debugPrint('Navigation command error: $e');
      _showMessage('Error executing navigation: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleLayoutCommand(Map<String, dynamic> instruction) async {
    final String action = instruction['action'] ?? '';
    final Map<String, dynamic> parameters = instruction['parameters'] ?? {};
    
    try {
      switch (action) {
        case 'saveLayout':
          final String layoutName = parameters['name'] ?? 'Untitled Layout';
          final currentState = _getCurrentUIState();
          await _layoutManager.saveCurrentLayout(layoutName, currentState);
          _showMessage('Layout "$layoutName" saved successfully!');
          break;
        case 'loadLayout':
           final String layoutName = parameters['name'] ?? '';
           if (layoutName.isNotEmpty) {
             final layouts = _layoutManager.getAllLayouts();
             try {
               final layout = layouts.firstWhere(
                 (l) => l.name.toLowerCase() == layoutName.toLowerCase(),
               );
               _applyUIState(layout.uiState);
               await _layoutManager.setCurrentLayout(layout.id);
               _showMessage('Layout "$layoutName" loaded successfully!');
             } catch (e) {
               _showMessage('Layout "$layoutName" not found', isError: true);
             }
           }
           break;
        case 'deleteLayout':
           final String layoutName = parameters['name'] ?? '';
           if (layoutName.isNotEmpty) {
             final layouts = _layoutManager.getAllLayouts();
             try {
               final layout = layouts.firstWhere(
                 (l) => l.name.toLowerCase() == layoutName.toLowerCase(),
               );
               await _layoutManager.deleteLayout(layout.id);
               _showMessage('Layout "$layoutName" deleted successfully!');
             } catch (e) {
               _showMessage('Layout "$layoutName" not found', isError: true);
             }
           }
           break;
        default:
          _showMessage('Unknown layout command: $action', isError: true);
      }
    } catch (e) {
      debugPrint('Layout command error: $e');
      _showMessage('Error executing layout command: ${e.toString()}', isError: true);
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
      'profileCardPadding': _profileCardPadding,
      'profileImageBorderRadius': _profileImageBorderRadius,
      'profileImageSize': _profileImageSize,
      'profileImageUrl': _profileImageUrl, // Added to state
      'nameTextContent': _nameTextContent,
      'nameFontSize': _nameFontSize,
      'nameFontWeight': _nameFontWeight.index,
      'nameTextColor': _nameTextColor.value,
      'nameTextAlign': _nameTextAlign.index,
      'isNameTextVisible': _isNameTextVisible,
      'nameTextAlignment': _nameTextAlignment.toString().split('.').last,
      'nameTextPadding': _nameTextPadding,
      'titleTextContent': _titleTextContent,
      'titleFontSize': _titleFontSize,
      'titleTextColor': _titleTextColor.value,
      'isTitleVisible': _isTitleVisible,
      'titleTextAlign': _titleTextAlign.index,
      'titleTextAlignment': _titleTextAlignment.toString().split('.').last,
      'titleTextPadding': _titleTextPadding,
      'bioTextContent': _bioTextContent,
      'bioFontSize': _bioFontSize,
      'bioTextColor': _bioTextColor.value,
      'bioTextAlign': _bioTextAlign.index,
      'isBioTextVisible': _isBioTextVisible,
      'bioTextAlignment': _bioTextAlignment.toString().split('.').last,
      'bioTextPadding': _bioTextPadding,
      'colorBoxBackgroundColor': _colorBoxBackgroundColor.value,
      'colorBoxSize': _colorBoxSize,
      'isColorBoxVisible': _isColorBoxVisible,
      'colorBoxAlignment': _colorBoxAlignment.toString().split('.').last,
      'colorBoxPadding': _colorBoxPadding,
      'buttonTextContent': _buttonTextContent,
      'buttonBackgroundColor': _buttonBackgroundColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonBorderRadius': _buttonBorderRadius,
      'isMainActionButtonVisible': _isMainActionButtonVisible,
      'mainActionButtonAlignment': _mainActionButtonAlignment.toString().split('.').last,
      'mainActionButtonPadding': _mainActionButtonPadding,
      'switchValue': _switchValue,
      'switchActiveColor': _switchActiveColor.value,
      'switchInactiveThumbColor': _switchInactiveThumbColor.value,
      'isToggleSwitchVisible': _isToggleSwitchVisible,
      'toggleSwitchAlignment': _toggleSwitchAlignment.toString().split('.').last,
      'toggleSwitchPadding': _toggleSwitchPadding,
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
      'sliderPadding': _sliderPadding,
      'progressValue': _progressValue,
      'progressColor': _progressColor.value,
      'progressBackgroundColor': _progressBackgroundColor.value,
      'isProgressIndicatorVisible': _isProgressIndicatorVisible,
      'progressIndicatorAlignment': _progressIndicatorAlignment.toString().split('.').last,
      'progressIndicatorPadding': _progressIndicatorPadding,
      'currentImageIndex': _currentImageIndex,
      'imageAutoPlay': _imageAutoPlay,
      'isImageGalleryVisible': _isImageGalleryVisible,
      'imageGalleryAlignment': _imageGalleryAlignment.toString().split('.').last,
      'imageGalleryPadding': _imageGalleryPadding,
      'staticTextFieldContent': _staticTextFieldContent,
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
        _profileCardAlignment = parseAlignment(state['profileCardAlignment'] ?? 'center');
        _profileCardPadding = (state['profileCardPadding'] ?? 0.0).toDouble();

        _profileImageBorderRadius = (state['profileImageBorderRadius'] ?? 50.0).toDouble();
        _profileImageSize = (state['profileImageSize'] ?? 100.0).toDouble();
        // Defensive check for profileImageUrl when loading from state
        final String loadedProfileImageUrl = state['profileImageUrl'] ?? '';
        if (loadedProfileImageUrl.isNotEmpty && Uri.tryParse(loadedProfileImageUrl)?.hasAbsolutePath == true) {
          _profileImageUrl = loadedProfileImageUrl;
        } else {
          _profileImageUrl = 'https://picsum.photos/150?random=4'; // Fallback to a safe default
          debugPrint('Invalid profileImageUrl loaded from state: "$loadedProfileImageUrl". Using default.');
        }

        _nameTextContent = state['nameTextContent'] ?? 'Jane Doe';
        _nameFontSize = (state['nameFontSize'] ?? 24.0).toDouble();
        _nameFontWeight = FontWeight.values[state['nameFontWeight'] ?? FontWeight.bold.index];
        _nameTextColor = Color(state['nameTextColor'] ?? Colors.black87.value);
        _nameTextAlign = TextAlign.values[state['nameTextAlign'] ?? TextAlign.center.index];
        _isNameTextVisible = state['isNameTextVisible'] ?? true;
        _nameTextAlignment = parseAlignment(state['nameTextAlignment'] ?? 'center');
        _nameTextPadding = (state['nameTextPadding'] ?? 0.0).toDouble();

        _titleTextContent = state['titleTextContent'] ?? 'Lead Product Designer';
        _titleFontSize = (state['titleFontSize'] ?? 16.0).toDouble();
        _titleTextColor = Color(state['titleTextColor'] ?? Colors.grey[700]!.value);
        _isTitleVisible = state['isTitleVisible'] ?? true;
        _titleTextAlign = TextAlign.values[state['titleTextAlign'] ?? TextAlign.center.index];
        _titleTextAlignment = parseAlignment(state['titleTextAlignment'] ?? 'center');
        _titleTextPadding = (state['titleTextPadding'] ?? 0.0).toDouble();

        _bioTextContent = state['bioTextContent'] ?? 'Default bio text';
        _bioFontSize = (state['bioFontSize'] ?? 14.0).toDouble();
        _bioTextColor = Color(state['bioTextColor'] ?? Colors.black54.value);
        _bioTextAlign = TextAlign.values[state['bioTextAlign'] ?? TextAlign.center.index];
        _isBioTextVisible = state['isBioTextVisible'] ?? true;
        _bioTextAlignment = parseAlignment(state['bioTextAlignment'] ?? 'center');
        _bioTextPadding = (state['bioTextPadding'] ?? 0.0).toDouble();

        _colorBoxBackgroundColor = Color(state['colorBoxBackgroundColor'] ?? Colors.purple[200]!.value);
        _colorBoxSize = (state['colorBoxSize'] ?? 50.0).toDouble();
        _isColorBoxVisible = state['isColorBoxVisible'] ?? true;
        _colorBoxAlignment = parseAlignment(state['colorBoxAlignment'] ?? 'center');
        _colorBoxPadding = (state['colorBoxPadding'] ?? 0.0).toDouble();

        _buttonTextContent = state['buttonTextContent'] ?? 'Apply Changes';
        _buttonBackgroundColor = Color(state['buttonBackgroundColor'] ?? Colors.blue.value);
        _buttonTextColor = Color(state['buttonTextColor'] ?? Colors.white.value);
        _buttonBorderRadius = (state['buttonBorderRadius'] ?? 4.0).toDouble();
        _isMainActionButtonVisible = state['isMainActionButtonVisible'] ?? true;
        _mainActionButtonAlignment = parseAlignment(state['mainActionButtonAlignment'] ?? 'center');
        _mainActionButtonPadding = (state['mainActionButtonPadding'] ?? 0.0).toDouble();

        _switchValue = state['switchValue'] ?? true;
        _switchActiveColor = Color(state['switchActiveColor'] ?? Colors.green.value);
        _switchInactiveThumbColor = Color(state['switchInactiveThumbColor'] ?? Colors.grey.value);
        _isToggleSwitchVisible = state['isToggleSwitchVisible'] ?? true;
        _toggleSwitchAlignment = parseAlignment(state['toggleSwitchAlignment'] ?? 'center');
        _toggleSwitchPadding = (state['toggleSwitchPadding'] ?? 0.0).toDouble();

        // NEW: Load main column layout states
        _mainColumnAlignment = MainAxisAlignment.values[state['mainColumnAlignment'] ?? MainAxisAlignment.start.index];
        _mainColumnCrossAlignment = CrossAxisAlignment.values[state['mainColumnCrossAlignment'] ?? CrossAxisAlignment.center.index];
        _mainColumnPadding = (state['mainColumnPadding'] ?? 16.0).toDouble();
        _mainColumnBackgroundColor = Color(state['mainColumnBackgroundColor'] ?? Colors.transparent.value);

        _sliderValue = (state['sliderValue'] ?? 0.5).toDouble();
        _sliderMin = (state['sliderMin'] ?? 0.0).toDouble();
        _sliderMax = (state['sliderMax'] ?? 1.0).toDouble();
        _sliderActiveColor = Color(state['sliderActiveColor'] ?? Colors.blue.value);
        _sliderInactiveColor = Color(state['sliderInactiveColor'] ?? Colors.grey.value);
        _isSliderVisible = state['isSliderVisible'] ?? true;
        _sliderAlignment = parseAlignment(state['sliderAlignment'] ?? 'center');
        _sliderPadding = (state['sliderPadding'] ?? 0.0).toDouble();

        _progressValue = (state['progressValue'] ?? 0.3).toDouble();
        _progressColor = Color(state['progressColor'] ?? Colors.blue.value);
        _progressBackgroundColor = Color(state['progressBackgroundColor'] ?? Colors.grey[300]!.value);
        _isProgressIndicatorVisible = state['isProgressIndicatorVisible'] ?? true;
        _progressIndicatorAlignment = parseAlignment(state['progressIndicatorAlignment'] ?? 'center');
        _progressIndicatorPadding = (state['progressIndicatorPadding'] ?? 0.0).toDouble();

        _currentImageIndex = state['currentImageIndex'] ?? 0;
        _imageAutoPlay = state['imageAutoPlay'] ?? false;
        _isImageGalleryVisible = state['isImageGalleryVisible'] ?? true;
        _imageGalleryAlignment = parseAlignment(state['imageGalleryAlignment'] ?? 'center');
        _imageGalleryPadding = (state['imageGalleryPadding'] ?? 0.0).toDouble();

        _staticTextFieldContent = state['staticTextFieldContent'] ?? 'Hello, Flutter!';
        _isStaticTextFieldVisible = state['isStaticTextFieldVisible'] ?? true;
        _staticTextFieldAlignment = parseAlignment(state['staticTextFieldAlignment'] ?? 'center');
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

  void _loadAllSavedWidgets() {
    if (!mounted) return;

    setState(() {
      _savedWidgets.clear();
      try {
        for (String key in _prefs.getKeys()) {
          if (key.startsWith('saved_widget_')) {
            final widgetName = key.substring(13);
            final String? widgetJson = _prefs.getString(key);
            if (widgetJson != null) {
              _savedWidgets[widgetName] = json.decode(widgetJson);
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading saved widgets: $e');
      }
    });
  }

  Future<void> _saveWidgetRecord(String widgetName, Map<String, dynamic> record) async {
    if (widgetName.trim().isEmpty) {
      _showMessage('Widget name cannot be empty', isError: true);
      return;
    }

    try {
      await _prefs.setString('saved_widget_$widgetName', json.encode(record));
      _loadAllSavedWidgets();
      _showMessage('Widget "$widgetName" saved successfully!');
    } catch (e) {
      debugPrint('Error saving widget: $e');
      _showMessage('Error saving widget', isError: true);
    }
  }

  Future<void> _saveDynamicWidgetInstance(String widgetName, Map<String, dynamic> widgetData) async {
    final record = {
      'kind': 'dynamic',
      'widgetType': widgetData['widgetType'],
      'properties': widgetData['properties'],
    };
    await _saveWidgetRecord(widgetName, record);
  }

  Future<void> _saveStaticWidgetSnapshot(String widgetName, String component) async {
    final snapshot = _buildStaticWidgetSnapshot(component);
    if (snapshot == null) {
      _showMessage('Static widget "$component" cannot be saved', isError: true);
      return;
    }
    final record = {
      'kind': 'static',
      'component': component,
      'properties': snapshot,
    };
    await _saveWidgetRecord(widgetName, record);
  }

  Future<void> _deleteSavedWidget(String widgetName) async {
    try {
      await _prefs.remove('saved_widget_$widgetName');
      _loadAllSavedWidgets();
      _showMessage('Widget "$widgetName" deleted');
    } catch (e) {
      debugPrint('Error deleting widget: $e');
      _showMessage('Error deleting widget', isError: true);
    }
  }

  String _colorToHexString(Color color) {
    return '0x${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  Map<String, dynamic>? _buildStaticWidgetSnapshot(String component) {
    switch (component) {
      case 'profileCard':
        return {
          'backgroundColor': _colorToHexString(_profileCardBackgroundColor),
          'borderRadius': _profileCardBorderRadius,
          'isVisible': _isProfileCardVisible,
          'alignment': _profileCardAlignment.toString().split('.').last,
          'padding': _profileCardPadding,
          'profileImageBorderRadius': _profileImageBorderRadius,
          'profileImageSize': _profileImageSize,
          'profileImageUrl': _profileImageUrl,
        };
      case 'profileImage':
        return {
          'profileImageBorderRadius': _profileImageBorderRadius,
          'profileImageSize': _profileImageSize,
          'profileImageUrl': _profileImageUrl,
        };
      case 'nameText':
        return {
          'fontSize': _nameFontSize,
          'fontWeight': _nameFontWeight == FontWeight.bold ? 'bold' : 'normal',
          'textColor': _colorToHexString(_nameTextColor),
          'content': _nameTextContent,
          'textAlign': _nameTextAlign.toString().split('.').last,
          'isVisible': _isNameTextVisible,
          'alignment': _nameTextAlignment.toString().split('.').last,
          'padding': _nameTextPadding,
        };
      case 'titleText':
        return {
          'fontSize': _titleFontSize,
          'textColor': _colorToHexString(_titleTextColor),
          'content': _titleTextContent,
          'textAlign': _titleTextAlign.toString().split('.').last,
          'isVisible': _isTitleVisible,
          'alignment': _titleTextAlignment.toString().split('.').last,
          'padding': _titleTextPadding,
        };
      case 'bioText':
        return {
          'fontSize': _bioFontSize,
          'textColor': _colorToHexString(_bioTextColor),
          'content': _bioTextContent,
          'textAlign': _bioTextAlign.toString().split('.').last,
          'isVisible': _isBioTextVisible,
          'alignment': _bioTextAlignment.toString().split('.').last,
          'padding': _bioTextPadding,
        };
      case 'colorBox':
        return {
          'backgroundColor': _colorToHexString(_colorBoxBackgroundColor),
          'size': _colorBoxSize,
          'isVisible': _isColorBoxVisible,
          'alignment': _colorBoxAlignment.toString().split('.').last,
          'padding': _colorBoxPadding,
        };
      case 'mainActionButton':
        return {
          'content': _buttonTextContent,
          'backgroundColor': _colorToHexString(_buttonBackgroundColor),
          'textColor': _colorToHexString(_buttonTextColor),
          'borderRadius': _buttonBorderRadius,
          'isVisible': _isMainActionButtonVisible,
          'alignment': _mainActionButtonAlignment.toString().split('.').last,
          'padding': _mainActionButtonPadding,
        };
      case 'toggleSwitch':
        return {
          'activeColor': _colorToHexString(_switchActiveColor),
          'inactiveThumbColor': _colorToHexString(_switchInactiveThumbColor),
          'value': _switchValue,
          'isVisible': _isToggleSwitchVisible,
          'alignment': _toggleSwitchAlignment.toString().split('.').last,
          'padding': _toggleSwitchPadding,
        };
      case 'slider':
        return {
          'value': _sliderValue,
          'min': _sliderMin,
          'max': _sliderMax,
          'activeColor': _colorToHexString(_sliderActiveColor),
          'inactiveColor': _colorToHexString(_sliderInactiveColor),
          'isVisible': _isSliderVisible,
          'alignment': _sliderAlignment.toString().split('.').last,
          'padding': _sliderPadding,
        };
      case 'progressIndicator':
        return {
          'value': _progressValue,
          'color': _colorToHexString(_progressColor),
          'backgroundColor': _colorToHexString(_progressBackgroundColor),
          'isVisible': _isProgressIndicatorVisible,
          'alignment': _progressIndicatorAlignment.toString().split('.').last,
          'padding': _progressIndicatorPadding,
        };
      case 'imageGallery':
        return {
          'currentImageIndex': _currentImageIndex,
          'autoPlay': _imageAutoPlay,
          'isVisible': _isImageGalleryVisible,
          'alignment': _imageGalleryAlignment.toString().split('.').last,
          'padding': _imageGalleryPadding,
          'imageUrls': List<String>.from(_imageUrls),
        };
      case 'mainColumn':
        return {
          'mainAxisAlignment': _mainColumnAlignment.toString().split('.').last,
          'crossAxisAlignment': _mainColumnCrossAlignment.toString().split('.').last,
          'padding': _mainColumnPadding,
          'backgroundColor': _colorToHexString(_mainColumnBackgroundColor),
        };
      case 'staticTextField':
        return {
          'content': _staticTextFieldContent,
          'isVisible': _isStaticTextFieldVisible,
          'alignment': _staticTextFieldAlignment.toString().split('.').last,
          'padding': _staticTextFieldPadding,
        };
      default:
        return null;
    }
  }

  void _applyStaticWidgetSnapshot(String component, Map<String, dynamic> properties) {
    final String normalizedComponent = _normalizeStaticComponentName(component);
    if (!_isStaticComponentName(normalizedComponent) && normalizedComponent != 'profileImage') {
      _showMessage('Saved widget "$component" is invalid', isError: true);
      return;
    }

    setState(() {
      for (final entry in properties.entries) {
        final property = _normalizePropertyName(normalizedComponent, entry.key);
        final value = entry.value;
        switch (normalizedComponent) {
          case 'profileCard':
          case 'profileImage':
            _handleProfileCardInstruction(property, value, null);
            break;
          case 'nameText':
            _handleNameTextInstruction(property, value, null);
            break;
          case 'titleText':
            _handleTitleTextInstruction(property, value, null);
            break;
          case 'bioText':
            _handleBioTextInstruction(property, value, null);
            break;
          case 'colorBox':
            _handleColorBoxInstruction(property, value, null);
            break;
          case 'mainActionButton':
            _handleButtonInstruction(property, value, null);
            break;
          case 'toggleSwitch':
            _handleSwitchInstruction(property, value, null);
            break;
          case 'slider':
            _handleSliderInstruction(property, value, null);
            break;
          case 'progressIndicator':
            _handleProgressInstruction(property, value, null);
            break;
          case 'imageGallery':
            _handleImageGalleryInstruction(property, value, null);
            break;
          case 'mainColumn':
            _handleMainColumnInstruction(property, value, null);
            break;
          case 'staticTextField':
            _handleStaticTextFieldInstruction(property, value, null);
            break;
        }
      }
    });
  }

  void _resetUI() {
    _applyUIState(_initialState);
    _commandController.clear();
    _showMessage('UI has been reset to initial state');
    // Ensure animations are reset and played forward when UI is reset
    _fadeController.forward(from: 0.0);
    _scaleController.forward(from: 0.0);
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
    await _processCommand(_commandController.text);
  }

  Future<void> _processCommand(
    String command, {
    bool clearInput = true,
    bool saveHistory = true,
  }) async {
    final trimmedCommand = command.trim();
    if (trimmedCommand.isEmpty) {
      _showMessage('Please enter a command', isError: true);
      return;
    }

    if (saveHistory && !_commandHistory.contains(trimmedCommand)) {
      _commandHistory.insert(0, trimmedCommand);
      if (_commandHistory.length > 50) {
        _commandHistory = _commandHistory.take(50).toList();
      }
      _saveCommandHistory();
    }

    _lastCommand = trimmedCommand;
    _historyIndex = -1;

    final normalizedCommand = trimmedCommand.toLowerCase();
    if (normalizedCommand == 'reset ui') {
      _resetUI();
      return;
    } else if (normalizedCommand == 'make screen blank') {
      _makeScreenBlank();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic>? instruction = await _puterService.executeCommand(trimmedCommand);

      if (instruction != null && instruction.isNotEmpty) {
        final bool handled = await _applyInstructionBatch(instruction);
        if (!handled) {
          _showMessage('Could not understand the command. Please try rephrasing.', isError: true);
        }
      } else {
        _showMessage('Could not understand the command. Please try rephrasing.', isError: true);
      }
    } catch (e) {
      debugPrint('Command processing error: $e');
      _showMessage('Error processing command: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
      if (clearInput) {
        _commandController.clear();
      }
    }
  }

  Future<bool> _applyInstructionBatch(Map<String, dynamic> instruction) async {
    final dynamic batchCommands = instruction['commands'] ?? instruction['instructions'];
    if (batchCommands is List) {
      int handledCount = 0;
      for (final item in batchCommands) {
        if (item is Map<String, dynamic>) {
          await _applySingleInstruction(item);
          handledCount += 1;
        }
      }
      return handledCount > 0;
    }

    await _applySingleInstruction(instruction);
    return true;
  }

  Future<void> _applySingleInstruction(Map<String, dynamic> instruction) async {
    if (instruction.containsKey('commandType')) {
      switch (instruction['commandType']) {
        case 'addWidget':
          _handleAddWidgetCommand(instruction);
          break;
        case 'modifyWidget':
          _handleModifyWidgetCommand(instruction);
          break;
        case 'saveWidget':
          await _handleSaveWidgetCommand(instruction);
          break;
        case 'loadWidget':
          _handleLoadWidgetCommand(instruction);
          break;
        case 'deleteSavedWidget':
          await _handleDeleteSavedWidgetCommand(instruction);
          break;
        case 'deleteWidget':
          _handleDeleteWidgetCommand(instruction);
          break;
        case 'reorderWidget':
          _handleReorderWidgetCommand(instruction);
          break;
        case 'navigation':
          await _handleNavigationCommand(instruction);
          break;
        case 'layoutManagement':
          await _handleLayoutCommand(instruction);
          break;
        case 'message':
          _showMessage(instruction['message']?.toString() ?? 'Message received.');
          break;
        default:
          await _handlePresetCommand(instruction);
          break;
      }
      return;
    }

    final bool handled = _applyInstructionToStaticComponent(instruction);
    if (!handled) {
      final bool dynamicHandled = _handleDynamicWidgetModification(instruction);
      if (dynamicHandled) {
        _showMessage('Command applied successfully!');
      }
    } else {
      _showMessage('Command applied successfully!');
    }
  }

  Future<void> _handleFullScreenGeneration(String prompt) async {
    await _processBatchPrompt(prompt);
  }

  Future<void> _processBatchPrompt(String prompt) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      _showMessage('Please enter a prompt', isError: true);
      return;
    }

    if (!_commandHistory.contains(trimmedPrompt)) {
      _commandHistory.insert(0, trimmedPrompt);
      if (_commandHistory.length > 50) {
        _commandHistory = _commandHistory.take(50).toList();
      }
      _saveCommandHistory();
    }

    _lastCommand = trimmedPrompt;
    _historyIndex = -1;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic>? instruction = await _puterService.executeBatchCommand(trimmedPrompt);

      if (instruction == null || instruction.isEmpty) {
        _showMessage('Could not understand the prompt. Please try rephrasing.', isError: true);
        return;
      }

      if (instruction['commandType'] == 'message') {
        _showMessage(instruction['message']?.toString() ?? 'Message received.');
        return;
      }

      final bool handled = await _applyInstructionBatch(instruction);
      if (!handled) {
        _showMessage('Could not understand the prompt. Please try rephrasing.', isError: true);
      }
    } catch (e) {
      debugPrint('Batch command processing error: $e');
      _showMessage('Error processing prompt: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
      _commandController.clear();
    }
  }

  void _showFullScreenGenerationDialog() {
    final TextEditingController promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Full Screen Generation'),
            actions: [
              TextButton(
                onPressed: () {
                  final prompt = promptController.text.trim();
                  if (prompt.isEmpty) {
                    _showMessage('Please enter a prompt', isError: true);
                    return;
                  }
                  Navigator.of(context).pop();
                  _handleFullScreenGeneration(prompt);
                },
                child: const Text('Generate'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: promptController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Describe the full screen and list components, one per line if desired',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final prompt = promptController.text.trim();
                      if (prompt.isEmpty) {
                        _showMessage('Please enter a prompt', isError: true);
                        return;
                      }
                      Navigator.of(context).pop();
                      _handleFullScreenGeneration(prompt);
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Components'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleModifyWidgetCommand(Map<String, dynamic> instruction) {
    final String? rawComponent = instruction['component'] ?? instruction['widgetType'];
    final String? rawProperty = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (rawComponent == null || rawProperty == null || value == null) {
      _showMessage('Invalid modifyWidget command format.', isError: true);
      return;
    }

    final String staticComponent = _normalizeStaticComponentName(rawComponent);
    final String dynamicComponent = _normalizeDynamicComponentName(rawComponent);
    final String staticProperty = _normalizePropertyName(staticComponent, rawProperty);
    final String dynamicProperty = _normalizePropertyName(dynamicComponent, rawProperty);
    final String rawComponentLower = rawComponent.trim().toLowerCase();
    final bool prefersDynamic = rawComponentLower.contains('dynamic') || !_isStaticComponentName(staticComponent);

    final bool hasDynamic = _dynamicWidgets.any((widget) {
      final String type = widget['widgetType']?.toString().toLowerCase() ?? '';
      return type == dynamicComponent.toLowerCase();
    });

    if (hasDynamic && (instruction.containsKey('targetIndex') || prefersDynamic)) {
      final bool dynamicHandled = _handleDynamicWidgetModification({
        'component': dynamicComponent,
        'property': dynamicProperty,
        'value': value,
        'operation': operation,
        'targetIndex': instruction['targetIndex'],
      });
      if (dynamicHandled) {
        _showMessage('Command applied successfully!');
      }
      return;
    }

    final bool staticHandled = _applyInstructionToStaticComponent({
      'component': staticComponent,
      'property': staticProperty,
      'value': value,
      'operation': operation,
    });

    if (staticHandled) {
      _showMessage('Command applied successfully!');
      return;
    }

    final bool dynamicHandled = _handleDynamicWidgetModification({
      'component': dynamicComponent,
      'property': dynamicProperty,
      'value': value,
      'operation': operation,
      if (instruction.containsKey('targetIndex')) 'targetIndex': instruction['targetIndex'],
    });

    if (dynamicHandled) {
      _showMessage('Command applied successfully!');
    }
  }

  Future<void> _handleSaveWidgetCommand(Map<String, dynamic> instruction) async {
    final String widgetName = instruction['name']?.toString().trim() ??
        instruction['widgetName']?.toString().trim() ??
        '';
    if (widgetName.isEmpty) {
      _showMessage('Widget name is required', isError: true);
      return;
    }

    final String? source = instruction['source']?.toString();
    final bool hasComponent = instruction.containsKey('component');
    final String? rawComponent = instruction['component']?.toString();
    final String? widgetType = instruction['widgetType']?.toString();
    final int? targetIndex = instruction['targetIndex'] is num ? instruction['targetIndex'].toInt() : null;

    if (source == 'static' || hasComponent) {
      final String component = _normalizeStaticComponentName(rawComponent ?? '');
      if (_isStaticComponentName(component) || component == 'profileImage') {
        await _saveStaticWidgetSnapshot(widgetName, component);
        return;
      }
    }

    if (source == 'dynamic' || widgetType != null || targetIndex != null) {
      final widgetData = _findDynamicWidgetForSave(widgetType, targetIndex);
      if (widgetData == null) {
        _showMessage('No matching dynamic widget found', isError: true);
        return;
      }
      await _saveDynamicWidgetInstance(widgetName, widgetData);
      return;
    }

    if (_dynamicWidgets.isNotEmpty) {
      await _saveDynamicWidgetInstance(widgetName, _dynamicWidgets.first);
      return;
    }

    _showMessage('No widgets available to save', isError: true);
  }

  void _handleLoadWidgetCommand(Map<String, dynamic> instruction) {
    final String widgetName = instruction['name']?.toString().trim() ??
        instruction['widgetName']?.toString().trim() ??
        '';
    if (widgetName.isEmpty) {
      _showMessage('Widget name is required', isError: true);
      return;
    }

    if (_savedWidgets.isEmpty) {
      _loadAllSavedWidgets();
    }

    Map<String, dynamic>? widgetData = _savedWidgets[widgetName];
    String resolvedName = widgetName;
    if (widgetData == null) {
      final lowerName = widgetName.toLowerCase();
      final matchKey = _savedWidgets.keys.firstWhere(
        (key) => key.toLowerCase() == lowerName,
        orElse: () => '',
      );
      if (matchKey.isNotEmpty) {
        resolvedName = matchKey;
        widgetData = _savedWidgets[matchKey];
      }
    }

    if (widgetData != null) {
      _addSavedWidgetToCanvas(resolvedName, widgetData);
      _showSavedWidgetsDialog(focusName: resolvedName, autoCloseOnAdd: false);
      return;
    }

    _showMessage('Saved widget "$widgetName" not found', isError: true);
    _showSavedWidgetsDialog(focusName: null, autoCloseOnAdd: false);
  }

  Future<void> _handleDeleteSavedWidgetCommand(Map<String, dynamic> instruction) async {
    final String widgetName = instruction['name']?.toString().trim() ??
        instruction['widgetName']?.toString().trim() ??
        '';
    if (widgetName.isEmpty) {
      _showMessage('Widget name is required', isError: true);
      return;
    }
    await _deleteSavedWidget(widgetName);
  }

  Map<String, dynamic>? _findDynamicWidgetForSave(String? widgetType, int? targetIndex) {
    if (_dynamicWidgets.isEmpty) {
      return null;
    }

    if (widgetType != null) {
      final int requestedIndex = (targetIndex ?? 1) <= 0 ? 0 : (targetIndex ?? 1) - 1;
      int count = 0;
      for (final widget in _dynamicWidgets) {
        final String type = widget['widgetType']?.toString().toLowerCase() ?? '';
        if (type == widgetType.toLowerCase()) {
          if (count == requestedIndex) {
            return widget;
          }
          count++;
        }
      }
      return null;
    }

    if (targetIndex != null) {
      final int index = targetIndex <= 0 ? 0 : targetIndex - 1;
      if (index >= 0 && index < _dynamicWidgets.length) {
        return _dynamicWidgets[index];
      }
    }

    return _dynamicWidgets.first;
  }

  String _normalizeStaticComponentName(String rawComponent) {
    final String normalized = rawComponent.trim().toLowerCase();
    switch (normalized) {
      case 'button':
      case 'mainbutton':
      case 'mainactionbutton':
      case 'primarybutton':
      case 'dynamicbutton':
        return 'mainActionButton';
      case 'colorbox':
        return 'colorBox';
      case 'progress':
      case 'progressbar':
      case 'progressindicator':
        return 'progressIndicator';
      case 'slider':
        return 'slider';
      case 'gallery':
      case 'imagegallery':
        return 'imageGallery';
      case 'switch':
      case 'toggle':
      case 'toggleswitch':
        return 'toggleSwitch';
      case 'statictextfield':
      case 'textfield':
        return 'staticTextField';
      case 'profile':
      case 'profilecard':
        return 'profileCard';
      case 'profileimage':
        return 'profileImage';
      case 'nametext':
        return 'nameText';
      case 'titletext':
        return 'titleText';
      case 'biotext':
        return 'bioText';
      case 'maincolumn':
        return 'mainColumn';
      default:
        return rawComponent;
    }
  }

  String _normalizeDynamicComponentName(String rawComponent) {
    final String normalized = rawComponent.trim().toLowerCase();
    switch (normalized) {
      case 'button':
      case 'mainbutton':
      case 'mainactionbutton':
      case 'primarybutton':
        return 'dynamicButton';
      case 'dynamicbutton':
        return 'dynamicButton';
      case 'colorbox':
        return 'colorBox';
      case 'progress':
      case 'progressbar':
      case 'progressindicator':
        return 'progressIndicator';
      case 'slider':
        return 'slider';
      case 'gallery':
      case 'imagegallery':
        return 'imageGallery';
      case 'switch':
      case 'toggle':
      case 'toggleswitch':
        return 'toggleSwitch';
      case 'textfield':
      case 'statictextfield':
        return 'textField';
      case 'profile':
      case 'profilecard':
        return 'profileCard';
      case 'profileimage':
        return 'profileImage';
      case 'nametext':
        return 'nameText';
      case 'titletext':
        return 'titleText';
      case 'biotext':
        return 'bioText';
      case 'maincolumn':
        return 'mainColumn';
      default:
        return rawComponent;
    }
  }

  bool _isStaticComponentName(String component) {
    const Set<String> staticComponents = {
      'profileCard',
      'profileImage',
      'nameText',
      'titleText',
      'bioText',
      'colorBox',
      'mainActionButton',
      'toggleSwitch',
      'slider',
      'progressIndicator',
      'imageGallery',
      'mainColumn',
      'staticTextField',
    };
    return staticComponents.contains(component);
  }

  String _normalizePropertyName(String component, String rawProperty) {
    final String property = rawProperty.trim();
    final String componentKey = component.toLowerCase();
    if (componentKey == 'progressindicator') {
      if (property == 'progressColor') return 'color';
      if (property == 'progressBackgroundColor') return 'backgroundColor';
    }
    if (componentKey == 'statictextfield' && property == 'initialText') {
      return 'content';
    }
    if ((componentKey == 'mainactionbutton' ||
            componentKey == 'dynamicbutton' ||
            componentKey == 'nametext' ||
            componentKey == 'titletext' ||
            componentKey == 'biotext' ||
            componentKey == 'text') &&
        property == 'text') {
      return 'content';
    }
    return property;
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
      // Validate image URL for dynamicImage when adding
      if (widgetType == 'dynamicImage' && properties.containsKey('imageUrl')) {
        final String imageUrl = properties['imageUrl'] ?? '';
        if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
          properties['imageUrl'] = imageUrl;
        } else {
          properties['imageUrl'] = 'https://placehold.co/150x150/cccccc/ffffff?text=Invalid+Image';
          _showMessage('Invalid or empty image URL provided for dynamic image. Using a placeholder.', isError: true);
        }
      }

      _dynamicWidgets.add({
        'widgetType': widgetType,
        'properties': properties,
        'id': DateTime.now().microsecondsSinceEpoch,
      });
      _showMessage('Added new $widgetType widget!');
      debugPrint('Dynamic widgets: $_dynamicWidgets');
    });
  }

  void _handleDeleteWidgetCommand(Map<String, dynamic> instruction) {
    final String? widgetTypeToDelete = instruction['widgetType'];
    final int? targetIndex = instruction['targetIndex']; // 1-based index

    if (widgetTypeToDelete == null) {
      _showMessage('Invalid deleteWidget command: widgetType is missing.', isError: true);
      return;
    }

    setState(() {
      List<int> indicesToRemove = [];
      int count = 0;
      for (int i = 0; i < _dynamicWidgets.length; i++) {
        if (_dynamicWidgets[i]['widgetType'].toLowerCase() == widgetTypeToDelete.toLowerCase()) {
          count++;
          if (targetIndex == null || count == targetIndex) {
            indicesToRemove.add(i);
            if (targetIndex != null) break; // If a specific index is targeted, stop after finding it
          }
        }
      }

      if (indicesToRemove.isNotEmpty) {
        // Remove in reverse order to avoid index shifting issues
        for (int i = indicesToRemove.length - 1; i >= 0; i--) {
          _dynamicWidgets.removeAt(indicesToRemove[i]);
        }
        _showMessage('Deleted ${indicesToRemove.length} "$widgetTypeToDelete" widget(s).');
      } else {
        _showMessage('No "$widgetTypeToDelete" widget found to delete or invalid index specified.', isError: true);
      }
      debugPrint('Dynamic widgets after deletion: $_dynamicWidgets');
    });
  }

  void _handleReorderWidgetCommand(Map<String, dynamic> instruction) {
    final String? widgetType = instruction['widgetType'];
    final int? sourceIndex = instruction['sourceIndex']; // 1-based index
    final int? destinationIndex = instruction['destinationIndex']; // 1-based index

    if (widgetType == null || sourceIndex == null || destinationIndex == null) {
      _showMessage('Invalid reorderWidget command: missing widgetType, sourceIndex, or destinationIndex.', isError: true);
      return;
    }

    setState(() {
      int actualSourceListIndex = -1;
      int actualDestinationListIndex = -1;
      int count = 0;
      // Find the actual 0-based index in the _dynamicWidgets list
      // for the Nth occurrence of the specified widgetType
      for (int i = 0; i < _dynamicWidgets.length; i++) {
        if (_dynamicWidgets[i]['widgetType'].toLowerCase() == widgetType.toLowerCase()) {
          count++;
          if (count == sourceIndex) {
            actualSourceListIndex = i;
          }
          if (count == destinationIndex) {
            actualDestinationListIndex = i;
          }
        }
      }

      if (actualSourceListIndex != -1 && actualDestinationListIndex != -1) {
        if (actualSourceListIndex == actualDestinationListIndex) {
          _showMessage('Widget is already at the target position.');
          return;
        }
        final itemToMove = _dynamicWidgets.removeAt(actualSourceListIndex);
        _dynamicWidgets.insert(actualDestinationListIndex, itemToMove);
        _showMessage('Reordered "$widgetType" from position $sourceIndex to $destinationIndex.');
      } else {
        _showMessage('Could not find "$widgetType" at source or destination index for reordering. Please check indices and widget type.', isError: true);
      }
      debugPrint('Dynamic widgets after reordering: $_dynamicWidgets');
    });
  }

  bool _handleDynamicWidgetModification(Map<String, dynamic> instruction) {
    final String? rawComponent = instruction['component'] ?? instruction['widgetType'];
    final String? rawProperty = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (rawComponent == null || rawProperty == null || value == null) {
      _showMessage('Invalid instruction format for dynamic widget modification.', isError: true);
      return false;
    }

    final String component = _normalizeDynamicComponentName(rawComponent);
    final String property = _normalizePropertyName(component, rawProperty);

    int? targetIndexInList;
    if (instruction.containsKey('targetIndex') && instruction['targetIndex'] is num) {
      final int rawIndex = instruction['targetIndex'].toInt();
      final int requestedIndex = rawIndex <= 0 ? 0 : rawIndex - 1;
      int count = 0;
      for (int i = 0; i < _dynamicWidgets.length; i++) {
        final String widgetType = _dynamicWidgets[i]['widgetType']?.toString().toLowerCase() ?? '';
        if (widgetType == component.toLowerCase()) {
          if (count == requestedIndex) {
            targetIndexInList = i;
            break;
          }
          count++;
        }
      }
    } else {
      // If no specific index, target the first found widget of that type
      for (int i = 0; i < _dynamicWidgets.length; i++) {
        final String widgetType = _dynamicWidgets[i]['widgetType']?.toString().toLowerCase() ?? '';
        if (widgetType == component.toLowerCase()) {
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
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
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
              }
              break;
            case 'dynamicImage': // Dynamic Image modifications
              if (property == 'imageUrl' && value is String) {
                // Defensive check for empty or invalid image URLs
                if (value.isNotEmpty && Uri.tryParse(value)?.hasAbsolutePath == true) {
                  targetProperties['imageUrl'] = value;
                } else {
                  // Fallback to a placeholder if the URL is empty or malformed
                  targetProperties['imageUrl'] = 'https://placehold.co/150x150/cccccc/ffffff?text=Invalid+Image';
                  _showMessage('Invalid or empty image URL provided. Using a placeholder.', isError: true);
                }
              } else if (property == 'width' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['width'] = (targetProperties['width'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['width'] = ((targetProperties['width'] ?? 0.0).toDouble() - newValue).clamp(20.0, 400.0);
                } else {
                  targetProperties['width'] = newValue.clamp(20.0, 400.0);
                }
              } else if (property == 'height' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['height'] = (targetProperties['height'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['height'] = ((targetProperties['height'] ?? 0.0).toDouble() - newValue).clamp(20.0, 400.0);
                } else {
                  targetProperties['height'] = newValue.clamp(20.0, 400.0);
                }
              } else if (property == 'borderRadius' && value is num) {
                targetProperties['borderRadius'] = value.toDouble().clamp(0.0, 200.0);
              } else if (property == 'fit' && value is String) {
                targetProperties['fit'] = value;
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
              }
              break;
            case 'dynamicCard': // Dynamic Card modifications
              if (property == 'backgroundColor' && value is String) {
                targetProperties['backgroundColor'] = value;
              } else if (property == 'borderRadius' && value is num) {
                targetProperties['borderRadius'] = value.toDouble().clamp(0.0, 50.0);
              } else if (property == 'elevation' && value is num) {
                targetProperties['elevation'] = value.toDouble().clamp(0.0, 20.0);
              } else if (property == 'margin' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['margin'] = (targetProperties['margin'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['margin'] = ((targetProperties['margin'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['margin'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
              }
              break;
            case 'dynamicIcon': // Dynamic Icon modifications
              if (property == 'iconName' && value is String) {
                // You might want a lookup table here for actual IconData
                // For now, ensuring it's not empty string, as a basic guard.
                if (value.isNotEmpty) {
                  targetProperties['iconName'] = value;
                } else {
                  _showMessage('Icon name cannot be empty. Using default.', isError: true);
                }
              } else if (property == 'size' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['size'] = (targetProperties['size'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['size'] = ((targetProperties['size'] ?? 0.0).toDouble() - newValue).clamp(16.0, 100.0);
                } else {
                  targetProperties['size'] = newValue.clamp(16.0, 100.0);
                }
              } else if (property == 'color' && value is String) {
                targetProperties['color'] = value;
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
              }
              break;
            case 'dynamicDivider': // Dynamic Divider modifications
              if (property == 'color' && value is String) {
                targetProperties['color'] = value;
              } else if (property == 'thickness' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['thickness'] = (targetProperties['thickness'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['thickness'] = ((targetProperties['thickness'] ?? 0.0).toDouble() - newValue).clamp(0.5, 10.0);
                } else {
                  targetProperties['thickness'] = newValue.clamp(0.5, 10.0);
                }
              } else if (property == 'indent' && value is num) {
                targetProperties['indent'] = value.toDouble().clamp(0.0, 100.0);
              } else if (property == 'endIndent' && value is num) {
                targetProperties['endIndent'] = value.toDouble().clamp(0.0, 100.0);
              } else if (property == 'alignment' && value is String) {
                targetProperties['alignment'] = value;
              } else if (property == 'padding' && value is num) {
                final newValue = value.toDouble();
                if (operation == 'add') {
                  targetProperties['padding'] = (targetProperties['padding'] ?? 0.0).toDouble() + newValue;
                } else if (operation == 'subtract') {
                  targetProperties['padding'] = ((targetProperties['padding'] ?? 0.0).toDouble() - newValue).clamp(0.0, 50.0);
                } else {
                  targetProperties['padding'] = newValue.clamp(0.0, 50.0);
                }
              } else if (property == 'isVisible' && value is bool) {
                targetProperties['isVisible'] = value;
              }
              break;
            default:
              _showMessage('Cannot modify dynamic widget of type: $component', isError: true);
              break;
          }
          // Create a new map to ensure setState detects a change
          _dynamicWidgets[targetIndexInList!] = Map.from(_dynamicWidgets[targetIndexInList!]);
          debugPrint('Modified dynamic widget: $_dynamicWidgets');
        } catch (e) {
          debugPrint('Error modifying dynamic widget properties: $e');
          _showMessage('Error modifying dynamic widget properties.', isError: true);
        }
      });
      return true;
    } else {
      _showMessage('No dynamic widget of type "$component" at the specified index found to modify.', isError: true);
      return false;
    }
  }

  bool _applyInstructionToStaticComponent(Map<String, dynamic> instruction) {
    final String? rawComponent = instruction['component'] ?? instruction['widgetType'];
    final String? rawProperty = instruction['property'];
    final dynamic value = instruction['value'];
    final String? operation = instruction['operation'];

    if (rawComponent == null || rawProperty == null || value == null) {
      return false;
    }

    final String component = _normalizeStaticComponentName(rawComponent);
    final String property = _normalizePropertyName(component, rawProperty);

    bool handled = true;

    setState(() {
      try {
        switch (component) {
          case 'profileCard':
          case 'profileImage':
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
          case 'staticTextField':
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
          final Color? newColor = color_parser.parseHexColor(value);
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
        if (value is String) _profileCardAlignment = parseAlignment(value);
        break;
      case 'padding':
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
      case 'profileImageBorderRadius':
        if (value is num) _profileImageBorderRadius = value.toDouble().clamp(0.0, 100.0);
        break;
      case 'profileImageSize':
        if (value is num) _profileImageSize = value.toDouble().clamp(50.0, 200.0);
        break;
      case 'profileImageUrl':
      // Robust validation for profileImageUrl updates
        if (value is String) {
          if (value.isNotEmpty && Uri.tryParse(value)?.hasAbsolutePath == true) {
            _profileImageUrl = value;
          } else {
            _profileImageUrl = 'https://placehold.co/150x150/cccccc/ffffff?text=Invalid+Image';
            _showMessage('Invalid or empty profileImageUrl provided. Using a placeholder.', isError: true);
            debugPrint('LLM tried to set an invalid profileImageUrl: "$value"');
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
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _nameTextColor = newColor;
        }
        break;
      case 'content':
        if (value is String) _nameTextContent = value;
        break;
      case 'textAlign':
        if (value is String) _nameTextAlign = parseTextAlign(value);
        break;
      case 'isVisible':
        if (value is bool) _isNameTextVisible = value;
        break;
      case 'alignment':
        if (value is String) _nameTextAlignment = parseAlignment(value);
        break;
      case 'padding':
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
          final Color? newColor = color_parser.parseHexColor(value);
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
        if (value is String) _titleTextAlign = parseTextAlign(value);
        break;
      case 'alignment':
        if (value is String) _titleTextAlignment = parseAlignment(value);
        break;
      case 'padding':
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
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _bioTextColor = newColor;
        }
        break;
      case 'content':
        if (value is String) _bioTextContent = value;
        break;
      case 'textAlign':
        if (value is String) _bioTextAlign = parseTextAlign(value);
        break;
      case 'isVisible':
        if (value is bool) _isBioTextVisible = value;
        break;
      case 'alignment':
        if (value is String) _bioTextAlignment = parseAlignment(value);
        break;
      case 'padding':
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
          final Color? newColor = color_parser.parseHexColor(value);
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
        if (value is String) _colorBoxAlignment = parseAlignment(value);
        break;
      case 'padding':
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
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _buttonBackgroundColor = newColor;
        }
        break;
      case 'textColor':
        if (value is String) {
          final Color? newColor = color_parser.parseHexColor(value);
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
        if (value is String) _mainActionButtonAlignment = parseAlignment(value);
        break;
      case 'padding':
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
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _switchActiveColor = newColor;
        }
        break;
      case 'inactiveThumbColor':
        if (value is String) {
          final Color? newColor = color_parser.parseHexColor(value);
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
        if (value is String) _toggleSwitchAlignment = parseAlignment(value);
        break;
      case 'padding':
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

  // Handler for mainColumn properties
  void _handleMainColumnInstruction(String property, dynamic value, String? operation) {
    switch (property) {
      case 'mainAxisAlignment':
        if (value is String) {
          _mainColumnAlignment = parseMainAxisAlignment(value);
        }
        break;
      case 'crossAxisAlignment':
        if (value is String) {
          _mainColumnCrossAlignment = parseCrossAxisAlignment(value);
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
          final Color? newColor = color_parser.parseHexColor(value);
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
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _sliderActiveColor = newColor;
        }
        break;
      case 'inactiveColor':
        if (value is String) {
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _sliderInactiveColor = newColor;
        }
        break;
      case 'isVisible':
        if (value is bool) _isSliderVisible = value;
        break;
      case 'alignment':
        if (value is String) _sliderAlignment = parseAlignment(value);
        break;
      case 'padding':
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
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _progressColor = newColor;
        }
        break;
      case 'backgroundColor':
        if (value is String) {
          final Color? newColor = color_parser.parseHexColor(value);
          if (newColor != null) _progressBackgroundColor = newColor;
        }
        break;
      case 'isVisible':
        if (value is bool) _isProgressIndicatorVisible = value;
        break;
      case 'alignment':
        if (value is String) _progressIndicatorAlignment = parseAlignment(value);
        break;
      case 'padding':
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
        if (value is String) _imageGalleryAlignment = parseAlignment(value);
        break;
      case 'padding':
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
      case 'imageUrls':
        if (value is List<dynamic>) {
          // Validate each URL in the list
          List<String> newImageUrls = [];
          for (var url in value) {
            if (url is String && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
              newImageUrls.add(url);
            } else {
              debugPrint('Invalid image URL in list: "$url". Skipping.');
            }
          }
          if (newImageUrls.isNotEmpty) {
            _imageUrls.clear();
            _imageUrls.addAll(newImageUrls);
            // Reset current index if the list changes and is smaller
            if (_currentImageIndex >= _imageUrls.length) {
              _currentImageIndex = max(0, _imageUrls.length - 1);
            }
            _showMessage('Image gallery URLs updated.', isError: false);
          } else {
            _showMessage('All provided image URLs were invalid. Gallery not updated.', isError: true);
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
        }
        break;
      case 'isVisible':
        if (value is bool) _isStaticTextFieldVisible = value;
        break;
      case 'alignment':
        if (value is String) _staticTextFieldAlignment = parseAlignment(value);
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
      _isStaticTextFieldVisible = false;
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

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options to pick from gallery or camera
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (image != null) {
          // For now, we'll use a placeholder since we can't directly use local files in Image.network
          // In a real app, you'd upload this to a server or use Image.file
          setState(() {
            // Generate a random image URL as a demo since we can't use local files with Image.network
            final random = DateTime.now().millisecondsSinceEpoch;
            _profileImageUrl = 'https://picsum.photos/150?random=$random';
          });
          _showMessage('Profile image updated! (Demo: using random image)');
        }
      }
    } catch (e) {
      _showMessage('Error selecting image: $e', isError: true);
    }
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

  void _showSaveWidgetDialog() {
    final TextEditingController widgetNameController = TextEditingController();
    String sourceType = 'dynamic';
    int? selectedDynamicIndex = _dynamicWidgets.isEmpty ? null : 0;
    final List<Map<String, String>> staticOptions = [
      {'label': 'Profile Card', 'value': 'profileCard'},
      {'label': 'Profile Image', 'value': 'profileImage'},
      {'label': 'Name Text', 'value': 'nameText'},
      {'label': 'Title Text', 'value': 'titleText'},
      {'label': 'Bio Text', 'value': 'bioText'},
      {'label': 'Color Box', 'value': 'colorBox'},
      {'label': 'Main Button', 'value': 'mainActionButton'},
      {'label': 'Toggle Switch', 'value': 'toggleSwitch'},
      {'label': 'Slider', 'value': 'slider'},
      {'label': 'Progress Indicator', 'value': 'progressIndicator'},
      {'label': 'Image Gallery', 'value': 'imageGallery'},
      {'label': 'Static Text Field', 'value': 'staticTextField'},
      {'label': 'Main Column', 'value': 'mainColumn'},
    ];
    String selectedStaticComponent = staticOptions.first['value']!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Save Widget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: sourceType,
                decoration: const InputDecoration(
                  labelText: 'Widget source',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'dynamic', child: Text('Dynamic widget')),
                  DropdownMenuItem(value: 'static', child: Text('Static widget')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      sourceType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              if (sourceType == 'dynamic')
                DropdownButtonFormField<int>(
                  value: selectedDynamicIndex,
                  decoration: const InputDecoration(
                    labelText: 'Select dynamic widget',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    _dynamicWidgets.length,
                    (index) {
                      final widgetType = _dynamicWidgets[index]['widgetType']?.toString() ?? 'unknown';
                      return DropdownMenuItem(
                        value: index,
                        child: Text('${index + 1}. $widgetType'),
                      );
                    },
                  ),
                  onChanged: _dynamicWidgets.isEmpty
                      ? null
                      : (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedDynamicIndex = value;
                            });
                          }
                        },
                )
              else
                DropdownButtonFormField<String>(
                  value: selectedStaticComponent,
                  decoration: const InputDecoration(
                    labelText: 'Select static widget',
                    border: OutlineInputBorder(),
                  ),
                  items: staticOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option['value'],
                          child: Text(option['label'] ?? option['value']!),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStaticComponent = value;
                      });
                    }
                  },
                ),
              const SizedBox(height: 8),
              TextField(
                controller: widgetNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter widget name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
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
                final String widgetName = widgetNameController.text.trim();
                if (widgetName.isNotEmpty) {
                  if (sourceType == 'dynamic') {
                    if (_dynamicWidgets.isEmpty) {
                      _showMessage('No dynamic widgets to save', isError: true);
                      return;
                    }
                    if (selectedDynamicIndex == null) {
                      _showMessage('Select a dynamic widget to save', isError: true);
                      return;
                    }
                    final widgetData = _dynamicWidgets[selectedDynamicIndex!];
                    _saveDynamicWidgetInstance(widgetName, widgetData);
                  } else {
                    _saveStaticWidgetSnapshot(widgetName, selectedStaticComponent);
                  }
                  Navigator.pop(context);
                } else {
                  _showMessage('Widget name cannot be empty', isError: true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedWidgetsDialog({String? focusName, bool autoCloseOnAdd = true}) {
    _loadAllSavedWidgets();
    if (_savedWidgets.isEmpty) {
      _showMessage('No saved widgets found', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final Map<String, Map<String, dynamic>> dialogWidgets = Map<String, Map<String, dynamic>>.from(_savedWidgets);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Saved Widgets'),
            content: SizedBox(
              width: double.maxFinite,
              height: 260,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: dialogWidgets.length,
                itemBuilder: (context, index) {
                  final widgetName = dialogWidgets.keys.elementAt(index);
                  final widgetData = dialogWidgets[widgetName];
                  final String kind = widgetData?['kind']?.toString() ?? (widgetData?['component'] != null ? 'static' : 'dynamic');
                  final String widgetType = widgetData?['widgetType']?.toString() ?? '';
                  final String component = widgetData?['component']?.toString() ?? '';
                  final String subtitle = kind == 'static'
                      ? 'static • ${component.isNotEmpty ? component : 'unknown'}'
                      : 'dynamic • ${widgetType.isNotEmpty ? widgetType : 'unknown'}';
                  final bool isFocused = focusName != null && widgetName == focusName;
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          if (isFocused)
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          if (isFocused) const SizedBox(width: 6),
                          Expanded(child: Text(widgetName)),
                        ],
                      ),
                      subtitle: Text(subtitle),
                      leading: _buildSavedWidgetPreview(widgetData),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: widgetData == null
                                ? null
                                : () {
                                    _addSavedWidgetToCanvas(widgetName, widgetData);
                                    if (autoCloseOnAdd) {
                                      Navigator.pop(context);
                                    }
                                  },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setDialogState(() {
                                dialogWidgets.remove(widgetName);
                              });
                              _deleteSavedWidget(widgetName);
                              if (dialogWidgets.isEmpty) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: widgetData == null
                          ? null
                          : () {
                              _addSavedWidgetToCanvas(widgetName, widgetData);
                              if (autoCloseOnAdd) {
                                Navigator.pop(context);
                              }
                            },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSavedWidgetToCanvas(String widgetName, Map<String, dynamic> widgetData) {
    final String kind = widgetData['kind']?.toString() ?? (widgetData['component'] != null ? 'static' : 'dynamic');
    final Map<String, dynamic> properties = widgetData['properties'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(widgetData['properties'])
        : {};

    if (kind == 'static') {
      final String component = widgetData['component']?.toString() ?? '';
      if (component.isEmpty) {
        _showMessage('Saved widget "$widgetName" is invalid', isError: true);
        return;
      }
      _applyStaticWidgetSnapshot(component, properties);
      _showMessage('Applied widget "$widgetName"');
      return;
    }

    final String widgetType = widgetData['widgetType']?.toString() ?? '';
    if (widgetType.isEmpty) {
      _showMessage('Saved widget "$widgetName" is invalid', isError: true);
      return;
    }

    setState(() {
      _dynamicWidgets.add({
        'widgetType': widgetType,
        'properties': properties,
        'id': DateTime.now().microsecondsSinceEpoch,
      });
    });
    _showMessage('Added widget "$widgetName"');
  }

  Widget _buildSavedWidgetPreview(Map<String, dynamic>? widgetData) {
    if (widgetData == null) {
      return const SizedBox(width: 48, height: 48);
    }

    final String kind = widgetData['kind']?.toString() ?? (widgetData['component'] != null ? 'static' : 'dynamic');
    final Map<String, dynamic> properties = widgetData['properties'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(widgetData['properties'])
        : {};
    final Color borderColor = Theme.of(context).dividerColor;

    Widget content;
    if (kind == 'static') {
      final String component = widgetData['component']?.toString() ?? '';
      content = _buildStaticPreview(component, properties);
    } else {
      final String widgetType = widgetData['widgetType']?.toString() ?? '';
      content = _buildDynamicPreview(widgetType, properties);
    }

    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: FittedBox(child: content)),
    );
  }

  Widget _buildStaticPreview(String component, Map<String, dynamic> properties) {
    switch (_normalizeStaticComponentName(component)) {
      case 'profileCard':
      case 'profileImage':
        final String url = properties['profileImageUrl']?.toString() ?? '';
        return CircleAvatar(
          radius: 18,
          backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
          child: url.isEmpty ? const Icon(Icons.person, size: 18) : null,
        );
      case 'nameText':
      case 'titleText':
      case 'bioText':
      case 'staticTextField':
        return Text(
          properties['content']?.toString() ?? 'Text',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: color_parser.parseHexColor(properties['textColor'] ?? '0xFF000000'),
          ),
        );
      case 'colorBox':
        return Container(
          width: 28,
          height: 28,
          color: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFF9C27B0'),
        );
      case 'mainActionButton':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFF2196F3'),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            properties['content']?.toString() ?? 'Button',
            style: TextStyle(
              fontSize: 8,
              color: color_parser.parseHexColor(properties['textColor'] ?? '0xFFFFFFFF'),
            ),
          ),
        );
      case 'toggleSwitch':
        return Icon(
          (properties['value'] ?? false) == true ? Icons.toggle_on : Icons.toggle_off,
          size: 24,
          color: color_parser.parseHexColor(properties['activeColor'] ?? '0xFF4CAF50'),
        );
      case 'slider':
        return SizedBox(
          width: 32,
          child: LinearProgressIndicator(
            value: ((properties['value'] ?? 0.5) as num).toDouble().clamp(0.0, 1.0),
            color: color_parser.parseHexColor(properties['activeColor'] ?? '0xFF2196F3'),
            backgroundColor: color_parser.parseHexColor(properties['inactiveColor'] ?? '0xFF9E9E9E'),
          ),
        );
      case 'progressIndicator':
        return SizedBox(
          width: 32,
          child: LinearProgressIndicator(
            value: ((properties['value'] ?? 0.5) as num).toDouble().clamp(0.0, 1.0),
            color: color_parser.parseHexColor(properties['color'] ?? '0xFF2196F3'),
            backgroundColor: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFFE0E0E0'),
          ),
        );
      case 'imageGallery':
        final List<dynamic> urls = properties['imageUrls'] is List<dynamic> ? properties['imageUrls'] : [];
        final String url = urls.isNotEmpty ? urls.first.toString() : '';
        return url.isNotEmpty
            ? Image.network(url, width: 28, height: 28, fit: BoxFit.cover)
            : const Icon(Icons.photo, size: 18);
      case 'mainColumn':
        return const Icon(Icons.view_column, size: 18);
      default:
        return const Icon(Icons.widgets, size: 18);
    }
  }

  Widget _buildDynamicPreview(String widgetType, Map<String, dynamic> properties) {
    switch (widgetType) {
      case 'dynamicButton':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFF2196F3'),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            properties['content']?.toString() ?? 'Button',
            style: TextStyle(
              fontSize: 8,
              color: color_parser.parseHexColor(properties['textColor'] ?? '0xFFFFFFFF'),
            ),
          ),
        );
      case 'colorBox':
        return Container(
          width: 28,
          height: 28,
          color: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFF9C27B0'),
        );
      case 'text':
        return Text(
          properties['content']?.toString() ?? 'Text',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: color_parser.parseHexColor(properties['textColor'] ?? '0xFF000000'),
          ),
        );
      case 'toggleSwitch':
        return Icon(
          (properties['value'] ?? false) == true ? Icons.toggle_on : Icons.toggle_off,
          size: 24,
          color: color_parser.parseHexColor(properties['activeColor'] ?? '0xFF4CAF50'),
        );
      case 'slider':
        return SizedBox(
          width: 32,
          child: LinearProgressIndicator(
            value: ((properties['value'] ?? 0.5) as num).toDouble().clamp(0.0, 1.0),
            color: color_parser.parseHexColor(properties['activeColor'] ?? '0xFF2196F3'),
            backgroundColor: color_parser.parseHexColor(properties['inactiveColor'] ?? '0xFF9E9E9E'),
          ),
        );
      case 'progressIndicator':
        return SizedBox(
          width: 32,
          child: LinearProgressIndicator(
            value: ((properties['value'] ?? 0.5) as num).toDouble().clamp(0.0, 1.0),
            color: color_parser.parseHexColor(properties['color'] ?? '0xFF2196F3'),
            backgroundColor: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFFE0E0E0'),
          ),
        );
      case 'textField':
        return const Icon(Icons.text_fields, size: 18);
      case 'dynamicImage':
        final String url = properties['imageUrl']?.toString() ?? '';
        return url.isNotEmpty
            ? Image.network(url, width: 28, height: 28, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 18);
      case 'dynamicCard':
        return Container(
          width: 28,
          height: 18,
          decoration: BoxDecoration(
            color: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFFFFFFFF'),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
        );
      case 'dynamicIcon':
        return Icon(Icons.star, size: 18, color: color_parser.parseHexColor(properties['color'] ?? '0xFF000000'));
      case 'dynamicDivider':
        return Container(
          width: 28,
          height: 2,
          color: color_parser.parseHexColor(properties['color'] ?? '0xFFE0E0E0'),
        );
      default:
        return const Icon(Icons.widgets, size: 18);
    }
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
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save Widget',
            onPressed: _showSaveWidgetDialog,
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'Saved Widgets',
            onPressed: _showSavedWidgetsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Full Screen Generate',
            onPressed: _showFullScreenGenerationDialog,
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
          color: _mainColumnBackgroundColor, // Applied background color
          child: Column(
            mainAxisAlignment: _mainColumnAlignment, // Applied main axis alignment
            crossAxisAlignment: _mainColumnCrossAlignment, // Applied cross axis alignment
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(_mainColumnPadding), // Applied padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileCard(
                        backgroundColor: _profileCardBackgroundColor,
                        borderRadius: _profileCardBorderRadius,
                        isVisible: _isProfileCardVisible,
                        alignment: _profileCardAlignment,
                        padding: _profileCardPadding,
                        profileImageBorderRadius: _profileImageBorderRadius,
                        profileImageSize: _profileImageSize,
                        profileImageUrl: _profileImageUrl, // Pass the profile image URL
                        onImageTap: _pickProfileImage, // Add image tap callback
                        nameTextContent: _nameTextContent,
                        nameFontSize: _nameFontSize,
                        nameFontWeight: _nameFontWeight,
                        nameTextColor: _nameTextColor,
                        nameTextAlign: _nameTextAlign,
                        isNameTextVisible: _isNameTextVisible,
                        nameTextAlignment: _nameTextAlignment,
                        nameTextPadding: _nameTextPadding,
                        titleTextContent: _titleTextContent,
                        titleFontSize: _titleFontSize,
                        titleTextColor: _titleTextColor,
                        isTitleVisible: _isTitleVisible,
                        titleTextAlign: _titleTextAlign,
                        titleTextAlignment: _titleTextAlignment,
                        titleTextPadding: _titleTextPadding,
                        bioTextContent: _bioTextContent,
                        bioFontSize: _bioFontSize,
                        bioTextColor: _bioTextColor,
                        bioTextAlign: _bioTextAlign,
                        isBioTextVisible: _isBioTextVisible,
                        bioTextAlignment: _bioTextAlignment,
                        bioTextPadding: _bioTextPadding,
                        scaleAnimation: _scaleAnimation,
                      ),
                      ColorBoxWidget(
                        backgroundColor: _colorBoxBackgroundColor,
                        size: _colorBoxSize,
                        isVisible: _isColorBoxVisible,
                        alignment: _colorBoxAlignment,
                        padding: _colorBoxPadding,
                      ),
                      DynamicButtonWidget(
                        buttonTextContent: _buttonTextContent,
                        buttonBackgroundColor: _buttonBackgroundColor,
                        buttonTextColor: _buttonTextColor,
                        buttonBorderRadius: _buttonBorderRadius,
                        isVisible: _isMainActionButtonVisible,
                        alignment: _mainActionButtonAlignment,
                        padding: _mainActionButtonPadding,
                        onPressed: () {
                          _showMessage('Button pressed! Current state: ${_getCurrentUIState().keys.length} properties');
                        },
                      ),
                      DynamicSwitchWidget(
                        switchValue: _switchValue,
                        activeColor: _switchActiveColor,
                        inactiveThumbColor: _switchInactiveThumbColor,
                        isVisible: _isToggleSwitchVisible,
                        alignment: _toggleSwitchAlignment,
                        padding: _toggleSwitchPadding,
                        onChanged: (newValue) {
                          setState(() {
                            _switchValue = newValue;
                          });
                          _showMessage('Switch toggled to: $newValue');
                        },
                      ),
                      DynamicSliderWidget(
                        sliderValue: _sliderValue,
                        sliderMin: _sliderMin,
                        sliderMax: _sliderMax,
                        sliderActiveColor: _sliderActiveColor,
                        sliderInactiveColor: _sliderInactiveColor,
                        isVisible: _isSliderVisible,
                        alignment: _sliderAlignment,
                        padding: _sliderPadding,
                        onChanged: (newValue) {
                          setState(() {
                            _sliderValue = newValue;
                          });
                        },
                      ),
                      ProgressIndicatorWidget(
                        progressValue: _progressValue,
                        progressColor: _progressColor,
                        progressBackgroundColor: _progressBackgroundColor,
                        isVisible: _isProgressIndicatorVisible,
                        alignment: _progressIndicatorAlignment,
                        padding: _progressIndicatorPadding,
                      ),
                      ImageGalleryWidget(
                        imageUrls: _imageUrls,
                        currentImageIndex: _currentImageIndex,
                        imageAutoPlay: _imageAutoPlay,
                        isVisible: _isImageGalleryVisible,
                        alignment: _imageGalleryAlignment,
                        padding: _imageGalleryPadding,
                        onNextImage: () {
                          setState(() {
                            _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
                          });
                        },
                        onPrevImage: () {
                          setState(() {
                            _currentImageIndex = (_currentImageIndex - 1 + _imageUrls.length) % _imageUrls.length;
                          });
                        },
                        onToggleAutoPlay: () {
                          setState(() {
                            _imageAutoPlay = !_imageAutoPlay;
                            _startImageAutoPlayTimer();
                          });
                        },
                      ),
                      StaticTextFieldWidget(
                        initialContent: _staticTextFieldContent,
                        isVisible: _isStaticTextFieldVisible,
                        alignment: _staticTextFieldAlignment,
                        padding: _staticTextFieldPadding,
                        onChanged: (newText) {
                          setState(() {
                            _staticTextFieldContent = newText;
                          });
                        },
                      ),
                      // Use the new DynamicWidgetBuilder for dynamic widgets
                      ..._dynamicWidgets.map((widgetData) => DynamicWidgetBuilder(
                        widgetData: widgetData,
                        onPropertyChange: (id, property, value) {
                          setState(() {
                            final index = _dynamicWidgets.indexWhere((w) => w['id'] == id);
                            if (index != -1) {
                              _dynamicWidgets[index]['properties'][property] = value;
                            }
                          });
                        },
                        showMessage: _showMessage,
                      )).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
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
              ),
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
