import 'dart:convert';
import 'dart:ui'; // Used for the Color class
import 'package:http/http.dart' as http;

class LLMApiService {
  // IMPORTANT: For production applications, never hardcode API keys directly in client-side code.
  // Consider using environment variables, a secure backend proxy, or Flutter's build configurations
  // to manage sensitive keys. This is for demonstration purposes only.
  final String _apiKey = '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'; // Your Azure API Key (equivalent to token in JS example)
  final String _apiBaseUrl = 'https://models.github.ai/inference'; // Azure OpenAI API base URL from the example
  final String _model = 'openai/gpt-4.1-nano'; // Model name from the JavaScript example

  Future<Map<String, dynamic>?> generateStructuredOutput(String userCommand) async {
    // This is the core instruction for the LLM, defining its role and expected output format.
    // Cleaned up leading whitespace for better JSON compatibility.
    final String systemInstruction = '''You are a UI modification assistant. Your task is to interpret user commands and generate a JSON object that describes the UI changes.
    
The UI consists of a profile card with the following modifiable elements:
- profileCard: backgroundColor (hex string like "0xFFRRGGBB"), borderRadius (double)
- profileImage: borderRadius (double), size (double for width/height)
- nameText: fontSize (double), fontWeight (string: "bold" or "normal"), textColor (hex string like "0xFFRRGGBB")
- titleText: fontSize (double), textColor (hex string like "0xFFRRGGBB"), isVisible (boolean: true/false)
- bioText: fontSize (double), textColor (hex string like "0xFFRRGGBB")

Supported commands and their corresponding JSON structure examples:
- "make picture square": {"component": "profileImage", "property": "borderRadius", "value": 0.0}
- "make picture round": {"component": "profileImage", "property": "borderRadius", "value": 50.0}
- "change card background to lightblue": {"component": "profileCard", "property": "backgroundColor", "value": "0xFFADD8E6"}
- "increase name font size": {"component": "nameText", "property": "fontSize", "operation": "add", "value": 4.0}
- "hide title": {"component": "titleText", "property": "isVisible", "value": false}
- "show title": {"component": "titleText", "property": "isVisible", "value": true}
- "set name font size to 30": {"component": "nameText", "property": "fontSize", "value": 30.0}
- "change bio text color to red": {"component": "bioText", "property": "textColor", "value": "0xFFFF0000"}
- "make card corners very rounded": {"component": "profileCard", "property": "borderRadius", "value": 20.0}
- "set profile image size to 120": {"component": "profileImage", "property": "size", "value": 120.0}
- "make name bold": {"component": "nameText", "property": "fontWeight", "value": "bold"}
- "make name normal weight": {"component": "nameText", "property": "fontWeight", "value": "normal"}

Colors should always be returned as 10-character hex strings (e.g., "0xFFRRGGBB").
For operations like "increase" or "decrease", use "operation": "add" or "operation": "subtract" and the value to apply.
Ensure the JSON is perfectly valid and contains only one instruction per command.
If a command is not understood or cannot be mapped to a single, clear UI change, return an empty JSON object: {}.

JSON Output:
'''.trim(); // Added .trim() to remove any leading/trailing whitespace from the entire string

    final requestBody = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': userCommand}
      ],
      'temperature': 1.0,
      'top_p': 1.0,
      'response_format': {'type': 'json_object'} // Re-added this for explicit JSON request
    };

    // Print the encoded body for debugging purposes
    print('Sending Request Body: ${json.encode(requestBody)}');
    // IMPORTANT: Double-check that your _apiKey is correct and matches the one used in the working curl command.
    print('Using API Key (first 5 chars): ${_apiKey.substring(0, 5)}...');


    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // Added charset=utf-8
          'Authorization': 'Bearer $_apiKey', // Authentication header as per working curl command
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        String llmOutputContent = responseBody['choices'][0]['message']['content'];

        try {
          final Map<String, dynamic> parsedJson = json.decode(llmOutputContent);
          return parsedJson;
        } catch (e) {
          print('Error parsing LLM JSON output. LLM might have returned malformed JSON: $e');
          print('LLM Raw Output: $llmOutputContent');
          return null;
        }
      } else {
        print('Azure OpenAI API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network or Azure OpenAI API call error: $e');
      return null;
    }
  }
}

Color? parseHexColor(String hexColor) {
  if (hexColor.startsWith('0x') && (hexColor.length == 10 || hexColor.length == 8)) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      print('Invalid hex color string format: $hexColor, Error: $e');
      return null;
    }
  }
  print('Hex color string does not start with "0x" or has incorrect length: $hexColor');
  return null;
}

