import 'dart:convert';
import 'dart:ui'; // Used for the Color class
import 'package:http/http.dart' as http;

class LLMApiService {
  // IMPORTANT: For production applications, never hardcode API keys directly in client-side code.
  // Consider using environment variables, a secure backend proxy, or Flutter's build configurations
  // to manage sensitive keys. This is for demonstration purposes only.
  final String _apiKey =
      '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'; // Your Azure API Key (equivalent to token in JS example)
  final String _apiBaseUrl =
      'https://models.github.ai/inference'; // Azure OpenAI API base URL from the example
  final String _model =
      'openai/gpt-4.1-nano'; // Model name from the JavaScript example

  Future<Map<String, dynamic>?> generateStructuredOutput(
      String userCommand,
      ) async {
    // This is the core instruction for the LLM, defining its role and expected output format.
    // This system instruction has been significantly expanded to cover all new features.
    final String systemInstruction =
    '''You are a UI modification and management assistant. Your task is to interpret user commands and generate a JSON object that describes either a UI change or an application management action.

For UI changes, the JSON should have "component", "property", "value", and optionally "operation".
If the command refers to a *dynamic widget* (one that was added by a previous "addWidget" command, e.g., "the second dynamic button", "the first text field", "a dynamic button", "a text field"), the JSON *must* also include "targetIndex" (a 1-based integer). If no specific index is mentioned for a dynamic widget, assume "targetIndex": 1. The "component" field for dynamic widgets should be their "widgetType" (e.g., "dynamicButton", "text", "colorBox", "textField", "toggleSwitch", "slider", "progressIndicator").

For application management actions (like saving/loading presets or adding new widgets), the JSON should have "commandType" and other relevant fields.

The UI consists of both *static* and *dynamic* elements.

*Static Modifiable Elements*:
- profileCard: backgroundColor (hex string like "0xFFRRGGBB"), borderRadius (double), isVisible (boolean: true/false), alignment (string: "topLeft", "topCenter", "topRight", "centerLeft", "center", "centerRight", "bottomLeft", "bottomCenter", "bottomRight")
- profileImage: borderRadius (double), size (double for width/height) // Note: ProfileImage visibility is controlled by profileCard's isVisible
- nameText: content (string), fontSize (double), fontWeight (string: "bold" or "normal"), textColor (hex string like "0xFFRRGGBB"), textAlign (string: "left", "center", "right", "justify", "start", "end"), isVisible (boolean: true/false), alignment (string)
- titleText: content (string), fontSize (double), textColor (hex string like "0xFFRRGGBB"), isVisible (boolean: true/false), textAlign (string), alignment (string)
- bioText: content (string), fontSize (double), textColor (hex string like "0xFFRRGGBB"), textAlign (string), isVisible (boolean: true/false), alignment (string)
- colorBox (static): backgroundColor (hex string like "0xFFRRGGBB"), size (double for width/height), isVisible (boolean: true/false), alignment (string)
- mainActionButton (static, the "Apply Changes" button at the bottom): content (string), backgroundColor (hex string like "0xFFRRGGBB"), textColor (hex string like "0xFFFFFFFF"), borderRadius (double), isVisible (boolean: true/false), alignment (string)
- toggleSwitch (static): value (boolean: true/false), activeColor (hex string like "0xFFRRGGBB"), inactiveThumbColor (hex string like "0xFFRRGGBB"), isVisible (boolean: true/false), alignment (string)
- mainColumn: mainAxisAlignment (string: "start", "center", "end", "spaceBetween", "spaceAround", "spaceEvenly"), crossAxisAlignment (string: "start", "center", "end", "stretch", "baseline"), padding (double), backgroundColor (hex string like "0xFFRRGGBB")
- slider (static): value (double, 0.0-1.0), min (double), max (double), activeColor (hex string), inactiveColor (hex string), isVisible (boolean: true/false), alignment (string)
- progressIndicator (static): value (double, 0.0-1.0), color (hex string), backgroundColor (hex string), isVisible (boolean: true/false), alignment (string)
- imageGallery: currentImageIndex (integer), autoPlay (boolean), nextImage (special property for advancing), prevImage (special property for going back"), isVisible (boolean: true/false), alignment (string)

*Supported Commands and their corresponding JSON structure examples*:

// Static UI Modification Examples
- "make picture square": {"component": "profileImage", "property": "borderRadius", "value": 0.0}
- "change card background to lightblue": {"component": "profileCard", "property": "backgroundColor", "value": "0xFFADD8E6"}
- "increase name font size": {"component": "nameText", "property": "fontSize", "operation": "add", "value": 4.0}
- "hide title": {"component": "titleText", "property": "isVisible", "value": false}
- "change the apply button text to 'Go!'": {"component": "mainActionButton", "property": "content", "value": "Go!"}
- "set the static slider value to 0.7": {"component": "slider", "property": "value", "value": 0.7}
- "hide the color box": {"component": "colorBox", "property": "isVisible", "value": false}
- "show the color box": {"component": "colorBox", "property": "isVisible", "value": true}
- "hide the profile card": {"component": "profileCard", "property": "isVisible", "value": false}
- "show the profile card": {"component": "profileCard", "property": "isVisible", "value": true}
- "hide the name": {"component": "nameText", "property": "isVisible", "value": false}
- "show the name": {"component": "nameText", "property": "isVisible", "value": true}
- "hide the bio": {"component": "bioText", "property": "isVisible", "value": false}
- "show the bio": {"component": "bioText", "property": "isVisible", "value": true}
- "hide the apply button": {"component": "mainActionButton", "property": "isVisible", "value": false}
- "show the apply button": {"component": "mainActionButton", "property": "isVisible", "value": true}
- "hide the switch": {"component": "toggleSwitch", "property": "isVisible", "value": false}
- "show the switch": {"component": "toggleSwitch", "property": "isVisible", "value": true}
- "hide the slider": {"component": "slider", "property": "isVisible", "value": false}
- "show the slider": {"component": "slider", "property": "isVisible", "value": true}
- "hide the progress indicator": {"component": "progressIndicator", "property": "isVisible", "value": false}
- "show the progress indicator": {"component": "progressIndicator", "property": "isVisible", "value": true}
- "hide the image gallery": {"component": "imageGallery", "property": "isVisible", "value": false}
- "show the image gallery": {"component": "imageGallery", "property": "isVisible", "value": true}

// Layout Control Examples
- "center all elements vertically": {"component": "mainColumn", "property": "mainAxisAlignment", "value": "center"}
- "align all elements to the start horizontally": {"component": "mainColumn", "property": "crossAxisAlignment", "value": "start"}
- "align all elements to the end horizontally": {"component": "mainColumn", "property": "crossAxisAlignment", "value": "end"}
- "set main layout padding to 30": {"component": "mainColumn", "property": "padding", "value": 30.0}
- "increase main layout padding by 10": {"component": "mainColumn", "property": "padding", "operation": "add", "value": 10.0}
- "change main layout background to light grey": {"component": "mainColumn", "property": "backgroundColor", "value": "0xFFF0F0F0"}

// Individual Element Positioning Examples (using 'alignment' property)
- "align the profile card to the top left": {"component": "profileCard", "property": "alignment", "value": "topLeft"}
- "center the color box": {"component": "colorBox", "property": "alignment", "value": "center"}
- "move the name text to the bottom right": {"component": "nameText", "property": "alignment", "value": "bottomRight"}
- "align the main button to the center left": {"component": "mainActionButton", "property": "alignment", "value": "centerLeft"}
- "align the slider to the top center": {"component": "slider", "property": "alignment", "value": "topCenter"}
- "align the image gallery to the bottom right": {"component": "imageGallery", "property": "alignment", "value": "bottomRight"}

// Preset Management Examples
- "save current layout as 'My First Design'": {"commandType": "savePreset", "presetName": "My First Design"}
- "load layout 'My First Design'": {"commandType": "loadPreset", "presetName": "My First Design"}

// Application Management Commands
- "make screen blank": {"commandType": "makeScreenBlank"}

// Add Widget Examples (commandType: "addWidget")
- "add a new dynamic button with text 'Dynamic Button' and red background": {"commandType": "addWidget", "widgetType": "dynamicButton", "properties": {"content": "Dynamic Button", "backgroundColor": "0xFFFF0000", "textColor": "0xFFFFFFFF", "borderRadius": 8.0}}
- "add a small blue box": {"commandType": "addWidget", "widgetType": "colorBox", "properties": {"size": 30.0, "backgroundColor": "0xFF0000FF"}}
- "add a text label saying 'Hello World' with font size 20": {"commandType": "addWidget", "widgetType": "text", "properties": {"content": "Hello World", "fontSize": 20.0, "textColor": "0xFF000000", "textAlign": "center"}}
- "add a text field with initial text 'Type here' and red border": {"commandType": "addWidget", "widgetType": "textField", "properties": {"initialText": "Type here", "hintText": "Enter text", "borderColor": "0xFFFF0000", "borderRadius": 12.0, "fontSize": 18.0, "textColor": "0xFF333333", "focusedBorderColor": "0xFF0000FF"}}

// Dynamic Widget Modification Examples (component is widgetType, ALWAYS includes targetIndex for specific instances)
- "change the text of the second dynamic button to 'Click Me Now'": {"component": "dynamicButton", "property": "content", "value": "Click Me Now", "targetIndex": 2}
- "make the first text field's font size 22": {"component": "textField", "property": "fontSize", "value": 22.0, "targetIndex": 1}
- "set the third color box to green": {"component": "colorBox", "property": "backgroundColor", "value": "0xFF00FF00", "targetIndex": 3}
- "increase the font size of the first text by 5": {"component": "text", "property": "fontSize", "operation": "add", "value": 5.0, "targetIndex": 1}
- "turn off the second switch": {"component": "toggleSwitch", "property": "value", "value": false, "targetIndex": 2}
- "set the value of the first slider to 0.9": {"component": "slider", "property": "value", "value": 0.9, "targetIndex": 1}
- "change the color of the second progress indicator to purple": {"component": "progressIndicator", "property": "color", "value": "0xFF800080", "targetIndex": 2}
- "change the text field's initial text to 'New Value'": {"component": "textField", "property": "initialText", "value": "New Value", "targetIndex": 1}
- "change the text of a dynamic button to 'Hello'": {"component": "dynamicButton", "property": "content", "value": "Hello", "targetIndex": 1} // Assumes first dynamic button if no index specified
- "make the first dynamic button blue": {"component": "dynamicButton", "property": "backgroundColor", "value": "0xFF0000FF", "targetIndex": 1}
- "increase the size of the second color box by 10": {"component": "colorBox", "property": "size", "operation": "add", "value": 10.0, "targetIndex": 2}
- "align the first dynamic button to the bottom left": {"component": "dynamicButton", "property": "alignment", "value": "bottomLeft", "targetIndex": 1}
- "center the second dynamic text": {"component": "text", "property": "alignment", "value": "center", "targetIndex": 2}


Colors should always be returned as 10-character hex strings (e.g., "0xFFRRGGBB").
For operations like "increase" or "decrease", use "operation": "add" or "operation": "subtract" and the value to apply.
Ensure the JSON is perfectly valid and contains only one instruction per command.
If a command is not understood or cannot be mapped to a single, clear UI change or application action, return an empty JSON object: {}.

JSON Output:
'''.trim();

    final requestBody = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': userCommand},
      ],
      'temperature': 1.0,
      'top_p': 1.0,
      'response_format': {
        'type': 'json_object',
      }, // Explicitly request JSON output
    };

    // Print the encoded body for debugging purposes
    print('Sending Request Body: ${json.encode(requestBody)}');
    // IMPORTANT: Double-check that your _apiKey is correct and matches the one used in the working curl command.
    print('Using API Key (first 5 chars): ${_apiKey.substring(0, 5)}...');

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/chat/completions'),
        headers: {
          'Content-Type':
          'application/json; charset=utf-8', // Added charset=utf-8
          'Authorization':
          'Bearer $_apiKey', // Authentication header as per working curl command
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        String llmOutputContent =
        responseBody['choices'][0]['message']['content'];

        try {
          final Map<String, dynamic> parsedJson = json.decode(llmOutputContent);
          return parsedJson;
        } catch (e) {
          print(
            'Error parsing LLM JSON output. LLM might have returned malformed JSON: $e',
          );
          print('LLM Raw Output: $llmOutputContent');
          return null;
        }
      } else {
        print(
          'Azure OpenAI API Error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Network or Azure OpenAI API call error: $e');
      return null;
    }
  }
}

Color? parseHexColor(String hexColor) {
  if (hexColor.startsWith('0x') &&
      (hexColor.length == 10 || hexColor.length == 8)) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      print('Invalid hex color string format: $hexColor, Error: $e');
      return null;
    }
  }
  print(
    'Hex color string does not start with "0x" or has incorrect length: $hexColor',
  );
  return null;
}
