import 'package:flutter/material.dart';

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

  // --- Mocked Prompt Handling ---
  void _handleCommand() {
    final command = _commandController.text.toLowerCase().trim();
    bool commandHandled = true;

    setState(() { // Use setState to trigger UI updates
      switch (command) {
        case 'make picture square':
          _profileImageBorderRadius = 0.0;
          break;
        case 'make picture round':
          _profileImageBorderRadius = _profileImageSize / 2; // Make it perfectly round
          break;
        case 'change card background to lightblue':
          _profileCardBackgroundColor = Colors.lightBlue[100]!;
          break;
        case 'increase name font size':
          _nameFontSize += 4.0;
          break;
        case 'hide title':
          _isTitleVisible = false;
          break;
        case 'show title':
          _isTitleVisible = true;
          break;
        case 'reset ui':
          _resetUI(); // Call the dedicated reset function
          commandHandled = true; // Handled by reset, no need for default message
          return; // Exit setState early as reset will handle its own state update
        default:
          commandHandled = false;
          break;
      }
    });

    if (commandHandled) {
      _commandController.clear();
      _showMessage('Command applied!', success: true);
    } else {
      _showMessage(
          'Unknown command. Try:\n- make picture square\n- make picture round\n- change card background to lightblue\n- increase name font size\n- hide title\n- show title\n- reset ui',
          success: false);
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
        title: const Text('Mobile UI Playground'),
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
                  ElevatedButton(
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