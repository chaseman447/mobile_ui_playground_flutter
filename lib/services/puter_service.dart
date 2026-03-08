import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Conditional imports for web vs mobile platforms
import 'js_stub.dart' as js if (dart.library.js) 'dart:js';

/// Puter.js Service for AI integration (platform-aware)
class PuterService {
  static bool _isInitialized = false;
  static bool _isAvailable = false;
  static const String _backendUrl = 'http://10.0.2.2:3001'; // Android emulator localhost

  /// Initialize Puter.js service (platform-aware)
  static Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('Puter Service: Initializing...');

    if (kIsWeb) {
      // Web platform - try to initialize Puter.js
      await _initializeWeb();
    } else {
      // Mobile platform - use backend API
      await _initializeMobile();
    }
  }

  /// Initialize web-specific Puter.js functionality
  static Future<void> _initializeWeb() async {
    debugPrint('Puter Service Web: Initializing with Puter.js SDK...');

    // Wait for Puter.js to be available
    int attempts = 0;
    while (!_isAvailable && attempts < 20) {
      await Future.delayed(Duration(milliseconds: 500));

      try {
        // Check if js is available and has context
        if (js.context != null) {
          final hasPuter = js.context.hasProperty('puter');
          if (hasPuter) {
            _isAvailable = true;
            debugPrint('Puter Service Web: Puter.js SDK found after ${attempts + 1} attempts');
            break;
          }
        }
      } catch (e) {
        debugPrint('Puter Service Web: Error checking for puter (attempt ${attempts + 1}): $e');
      }

      attempts++;
    }

    _isInitialized = true;

    if (_isAvailable) {
      debugPrint('Puter Service Web: Puter.js SDK initialized successfully!');
    } else {
      debugPrint('Puter Service Web: Puter.js not available after 20 attempts');
    }
  }

  /// Initialize mobile backend connectivity
  static Future<void> _initializeMobile() async {
    debugPrint('Puter Service Mobile: Initializing backend connectivity...');

    try {
      // Test backend connection
      final response = await http.get(Uri.parse('$_backendUrl/health')).timeout(
        Duration(seconds: 5),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode == 200) {
        _isAvailable = true;
        debugPrint('Puter Service Mobile: Backend server available');
      } else {
        _isAvailable = false;
        debugPrint('Puter Service Mobile: Backend server not responding (${response.statusCode})');
      }
    } catch (e) {
      _isAvailable = false;
      debugPrint('Puter Service Mobile: Error connecting to backend: $e');
    }

    _isInitialized = true;

    if (!_isAvailable) {
      debugPrint('Puter Service Mobile: Falling back to simulation mode');
    }
  }

  /// Execute command (platform-aware)
  static Future<Map<String, dynamic>?> executeCommandStatic(String command) async {
    if (!_isInitialized) {
      debugPrint('Puter Service: Not initialized');
      return null;
    }

    if (kIsWeb && _isAvailable) {
      // Use Puter.js on web
      return await _executeCommandWeb(command);
    } else if (!kIsWeb && _isAvailable) {
      // Use backend API on mobile
      return await _executeCommandMobile(command);
    } else {
      // Use simulation fallback (works on all platforms)
      return _simulateAIResponse(command);
    }
  }

  /// Execute batch command (platform-aware)
  static Future<Map<String, dynamic>?> executeBatchCommandStatic(String prompt) async {
    if (!_isInitialized) {
      debugPrint('Puter Service: Not initialized');
      return null;
    }

    if (kIsWeb && _isAvailable) {
      return await _executeBatchCommandWeb(prompt);
    } else if (!kIsWeb && _isAvailable) {
      return await _executeBatchCommandMobile(prompt);
    } else {
      return _simulateBatchResponse(prompt);
    }
  }

  /// Execute command using Puter.js on web
  static Future<Map<String, dynamic>?> _executeCommandWeb(String command) async {
    debugPrint('Puter Service Web: Executing command: $command');

    try {
      // Check if js is available at runtime
      if (js.context == null) {
        throw Exception('JavaScript context not available');
      }

      // Call puter.ai.chat with correct parameters and system prompt
      final promise = js.context.callMethod('puter.ai.chat', [
        'CRITICAL: You are a Flutter UI controller AI. Respond ONLY with valid JSON. No explanations, no HTML, no CSS, no markdown.\n\nFor "make button red" respond exactly: {"commandType": "modifyWidget", "widgetType": "dynamicButton", "property": "backgroundColor", "value": "0xFFFF0000", "targetIndex": 0}\nFor "add button" respond exactly: {"commandType": "addWidget", "widgetType": "dynamicButton", "properties": {"content": "New Button", "backgroundColor": "0xFF2196F3", "textColor": "0xFFFFFFFF", "fontSize": 16}}\nFor "hide progress" respond exactly: {"commandType": "modifyWidget", "widgetType": "progressIndicator", "property": "isVisible", "value": false, "targetIndex": 0}\nFor "show progress" respond exactly: {"commandType": "modifyWidget", "widgetType": "progressIndicator", "property": "isVisible", "value": true, "targetIndex": 0}\nFor "hide profile" respond exactly: {"commandType": "modifyWidget", "widgetType": "profileCard", "property": "isVisible", "value": false, "targetIndex": 0}\n\nUser command: $command',
        js.JsObject.jsify({
          'model': 'gpt-4o',
          'temperature': 0.1
        })
      ]);

      // Convert JS Promise to Dart Future
      final response = await _jsPromiseToFuture(promise);

      final responseStr = response.toString();
      debugPrint('Puter Service Web: Raw response: $responseStr');

      // Try to parse as JSON
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseStr);
        debugPrint('Puter Service Web: Successfully parsed AI response');
        return jsonResponse;
      } catch (e) {
        debugPrint('Puter Service Web: Failed to parse AI response: $e');
        // Return as message if not JSON
        return {
          'commandType': 'message',
          'message': responseStr,
          'rawResponse': true
        };
      }
    } catch (e) {
      debugPrint('Puter Service Web: Error executing command: $e');
      return {
        'commandType': 'message',
        'message': 'Error: $e',
        'error': true
      };
    }
  }

  /// Execute batch command using Puter.js on web
  static Future<Map<String, dynamic>?> _executeBatchCommandWeb(String prompt) async {
    debugPrint('Puter Service Web: Executing batch command: $prompt');

    try {
      if (js.context == null) {
        throw Exception('JavaScript context not available');
      }

      final promise = js.context.callMethod('puter.ai.chat', [
        'CRITICAL: You are a Flutter UI controller AI. Respond ONLY with valid JSON. No explanations, no HTML, no CSS, no markdown.\n\nReturn a single JSON object with a top-level "commands" array. Each item must be a valid command like:\n{"commandType": "addWidget", "widgetType": "dynamicButton", "properties": {"content": "New Button", "backgroundColor": "0xFF2196F3", "textColor": "0xFFFFFFFF", "fontSize": 16}}\n{"commandType": "modifyWidget", "widgetType": "dynamicButton", "property": "backgroundColor", "value": "0xFFFF0000", "targetIndex": 0}\n\nIf the prompt describes multiple components, include multiple addWidget commands. Always return the "commands" array even if only one command.\n\nUser request: $prompt',
        js.JsObject.jsify({
          'model': 'gpt-4o',
          'temperature': 0.2
        })
      ]);

      final response = await _jsPromiseToFuture(promise);
      final responseStr = response.toString();
      debugPrint('Puter Service Web: Raw batch response: $responseStr');

      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseStr);
        debugPrint('Puter Service Web: Successfully parsed batch response');
        return jsonResponse;
      } catch (e) {
        debugPrint('Puter Service Web: Failed to parse batch response: $e');
        return {
          'commandType': 'message',
          'message': responseStr,
          'rawResponse': true
        };
      }
    } catch (e) {
      debugPrint('Puter Service Web: Error executing batch command: $e');
      return {
        'commandType': 'message',
        'message': 'Error: $e',
        'error': true
      };
    }
  }

  /// Execute command using backend API on mobile
  static Future<Map<String, dynamic>?> _executeCommandMobile(String command) async {
    debugPrint('Puter Service Mobile: Executing command via backend: $command');

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/ai-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => http.Response('{"commandType": "message", "message": "Request timeout", "error": true}', 408),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        debugPrint('Puter Service Mobile: Successfully received AI response from backend');
        return jsonResponse;
      } else {
        debugPrint('Puter Service Mobile: Backend error (${response.statusCode}): ${response.body}');
        return {
          'commandType': 'message',
          'message': 'Backend error: ${response.statusCode}',
          'error': true
        };
      }
    } catch (e) {
      debugPrint('Puter Service Mobile: Error calling backend: $e');
      return {
        'commandType': 'message',
        'message': 'Network error: $e',
        'error': true
      };
    }
  }

  /// Execute batch command using backend API on mobile
  static Future<Map<String, dynamic>?> _executeBatchCommandMobile(String prompt) async {
    final wrappedPrompt =
        'Return JSON only with {"commands":[...]} for multiple UI actions. User request: $prompt';
    return _executeCommandMobile(wrappedPrompt);
  }

  /// Convert JS Promise to Dart Future
  static Future<dynamic> _jsPromiseToFuture(dynamic promise) {
    final completer = Completer<dynamic>();

    promise.callMethod('then', [
      js.allowInterop((result) {
        completer.complete(result);
      })
    ]).callMethod('catch', [
      js.allowInterop((error) {
        completer.completeError(error);
      })
    ]);

    return completer.future;
  }

  /// Execute command (instance method)
  Future<Map<String, dynamic>?> executeCommand(String command) async {
    return PuterService.executeCommandStatic(command);
  }

  /// Execute batch command (instance method)
  Future<Map<String, dynamic>?> executeBatchCommand(String prompt) async {
    return PuterService.executeBatchCommandStatic(prompt);
  }

  /// Simulate AI response for fallback (works on all platforms)
  static Map<String, dynamic>? _simulateAIResponse(String command) {
    debugPrint('Puter Service: Using simulation fallback for command: $command');

    final cmd = command.toLowerCase().trim();

    if (_isLoginScreenPrompt(cmd)) {
      return {'commands': _buildLoginScreenCommands()};
    }

    // Simple command parsing for common commands
    if (cmd.contains('make button red') || cmd.contains('button red')) {
      return {
        'commandType': 'modifyWidget',
        'widgetType': 'dynamicButton',
        'property': 'backgroundColor',
        'value': '0xFFFF0000',
        'targetIndex': 0
      };
    }

    if (cmd.contains('add button')) {
      return {
        'commandType': 'addWidget',
        'widgetType': 'dynamicButton',
        'properties': {
          'content': 'New Button',
          'backgroundColor': '0xFF2196F3',
          'textColor': '0xFFFFFFFF',
          'fontSize': 16
        }
      };
    }

    if (cmd.contains('hide progress')) {
      return {
        'commandType': 'modifyWidget',
        'widgetType': 'progressIndicator',
        'property': 'isVisible',
        'value': false,
        'targetIndex': 0
      };
    }

    if (cmd.contains('show progress')) {
      return {
        'commandType': 'modifyWidget',
        'widgetType': 'progressIndicator',
        'property': 'isVisible',
        'value': true,
        'targetIndex': 0
      };
    }

    if (cmd.contains('hide profile')) {
      return {
        'commandType': 'modifyWidget',
        'widgetType': 'profileCard',
        'property': 'isVisible',
        'value': false,
        'targetIndex': 0
      };
    }

    if (cmd.contains('show profile')) {
      return {
        'commandType': 'modifyWidget',
        'widgetType': 'profileCard',
        'property': 'isVisible',
        'value': true,
        'targetIndex': 0
      };
    }

    // Default message response
    return {
      'commandType': 'message',
      'message': 'Command processed (simulation mode)',
      'rawResponse': true
    };
  }

  static Map<String, dynamic> _simulateBatchResponse(String prompt) {
    final normalizedPrompt = prompt.toLowerCase();
    if (_isLoginScreenPrompt(normalizedPrompt)) {
      return {'commands': _buildLoginScreenCommands()};
    }

    final segments = prompt
        .split(RegExp(r'[\n;]+'))
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    final List<Map<String, dynamic>> commands = [];
    for (final segment in segments) {
      final response = _simulateAIResponse(segment);
      if (response == null) {
        continue;
      }
      if (response['commandType'] == 'message') {
        continue;
      }
      commands.add(Map<String, dynamic>.from(response));
    }

    if (commands.isEmpty) {
      return {
        'commandType': 'message',
        'message': 'Command processed (simulation mode)',
        'rawResponse': true
      };
    }

    return {'commands': commands};
  }

  static bool _isLoginScreenPrompt(String prompt) {
    return prompt.contains('login') ||
        prompt.contains('log in') ||
        prompt.contains('sign in') ||
        prompt.contains('signin');
  }

  static List<Map<String, dynamic>> _buildLoginScreenCommands() {
    return [
      {
        'commandType': 'addWidget',
        'widgetType': 'text',
        'properties': {
          'content': 'Welcome back',
          'fontSize': 26,
          'textColor': '0xFF111827',
          'fontWeight': 'bold',
          'alignment': 'center',
          'padding': 12.0
        }
      },
      {
        'commandType': 'addWidget',
        'widgetType': 'text',
        'properties': {
          'content': 'Sign in to continue',
          'fontSize': 14,
          'textColor': '0xFF6B7280',
          'alignment': 'center',
          'padding': 4.0
        }
      },
      {
        'commandType': 'addWidget',
        'widgetType': 'textField',
        'properties': {
          'hintText': 'Email address',
          'fontSize': 16,
          'textColor': '0xFF111827',
          'borderColor': '0xFFD1D5DB',
          'focusedBorderColor': '0xFF2563EB',
          'borderRadius': 12.0,
          'alignment': 'center',
          'padding': 12.0
        }
      },
      {
        'commandType': 'addWidget',
        'widgetType': 'textField',
        'properties': {
          'hintText': 'Password',
          'fontSize': 16,
          'textColor': '0xFF111827',
          'borderColor': '0xFFD1D5DB',
          'focusedBorderColor': '0xFF2563EB',
          'borderRadius': 12.0,
          'alignment': 'center',
          'padding': 12.0
        }
      },
      {
        'commandType': 'addWidget',
        'widgetType': 'dynamicButton',
        'properties': {
          'content': 'Sign In',
          'backgroundColor': '0xFF2563EB',
          'textColor': '0xFFFFFFFF',
          'borderRadius': 12.0,
          'alignment': 'center',
          'padding': 12.0
        }
      },
      {
        'commandType': 'addWidget',
        'widgetType': 'text',
        'properties': {
          'content': 'Forgot password?',
          'fontSize': 12,
          'textColor': '0xFF2563EB',
          'alignment': 'center',
          'padding': 4.0
        }
      }
    ];
  }
}
