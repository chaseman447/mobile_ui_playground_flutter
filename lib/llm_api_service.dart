import 'dart:convert';
import 'dart:ui'; // Used for the Color class
import 'package:http/http.dart' as http;

class LLMApiService {
  // IMPORTANT: For production applications, never hardcode API keys directly in client-side code.
  // Consider using environment variables, a secure backend proxy, or Flutter's build configurations
  // to manage sensitive keys. This is for demonstration purposes only.
  final String _apiKey =
      ''; // Your Azure API Key (equivalent to token in JS example)
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

For UI changes, the JSON should have "component", "property", "value", and optionally "operation" and "targetIndex". The "targetIndex" is a 1-based integer that specifies which instance of a dynamic widget to modify (e.g., 1 for the first, 2 for the second). If not specified, assume targetIndex is 1.
For application management actions (like saving/loading presets or adding new widgets), the JSON should have "commandType" and other relevant fields.

The UI consists of a profile card with the following modifiable elements:
- profileCard: backgroundColor (hex string like "0xFFRRGGBB"), borderRadius (double)
- profileImage: borderRadius (double), size (double for width/height)
- nameText: content (string), fontSize (double), fontWeight (string: "bold" or "normal"), textColor (hex string like "0xFFRRGGBB"), textAlign (string: "left", "center", "right", "justify", "start", "end")
- titleText: content (string), fontSize (double), textColor (hex string like "0xFFRRGGBB"), isVisible (boolean: true/false), textAlign (string: "left", "center", "right", "justify", "start", "end")
- bioText: content (string), fontSize (double), textColor (hex string like "0xFFRRGGBB"), textAlign (string: "left", "center", "right", "justify", "start", "end")
- colorBox: backgroundColor (hex string like "0xFFRRGGBB"), size (double for width/height)
- button: content (string), backgroundColor (hex string like "0xFFRRGGBB"), textColor (hex string like "0xFFRRGGBB"), borderRadius (double)
- toggleSwitch: value (boolean: true/false), activeColor (hex string like "0xFFRRGGBB"), inactiveThumbColor (hex string like "0xFFRRGGBB")
- mainColumn: mainAxisAlignment (string: "start", "center", "end", "spaceBetween", "spaceAround", "spaceEvenly")
- slider: value (double, 0.0-1.0), min (double), max (double), activeColor (hex string), inactiveColor (hex string)
- progressIndicator: value (double, 0.0-1.0), color (hex string), backgroundColor (hex string)
- imageGallery: currentImageIndex (integer), autoPlay (boolean), nextImage (special property for advancing), prevImage (special property for going back)
- textField: initialText (string), hintText (string), textColor (hex string), fontSize (double), borderColor (hex string), borderRadius (double), focusedBorderColor (hex string)


Supported commands and their corresponding JSON structure examples:
- "make picture square": {"component": "profileImage", "property": "borderRadius", "value": 0.0}
- "make picture round": {"component": "profileImage", "property": "borderRadius", "value": 50.0}
- "change card background to lightblue": {"component": "profileCard", "property": "backgroundColor", "value": "0xFFADD8E6"}
- "increase name font size": {"component": "nameText", "property": "fontSize", "operation": "add", "value": 4.0}
- "decrease bio font size": {"component": "bioText", "property": "fontSize", "operation": "subtract", "value": 2.0}
- "hide title": {"component": "titleText", "property": "isVisible", "value": false}
- "show title": {"component": "titleText", "property": "isVisible", "value": true}
- "set name font size to 30": {"component": "nameText", "property": "fontSize", "value": 30.0}
- "change bio text color to red": {"component": "bioText", "property": "textColor", "value": "0xFFFF0000"}
- "make card corners very rounded": {"component": "profileCard", "property": "borderRadius", "value": 20.0}
- "set profile image size to 120": {"component": "profileImage", "property": "size", "value": 120.0}
- "make name bold": {"component": "nameText", "property": "fontWeight", "value": "bold"}
- "make name normal weight": {"component": "nameText", "property": "fontWeight", "value": "normal"}
- "change name to 'Alice Wonderland'": {"component": "nameText", "property": "content", "value": "Alice Wonderland"}
- "set bio text to 'A creative individual.'": {"component": "bioText", "property": "content", "value": "A creative individual."}
- "make the box red": {"component": "colorBox", "property": "backgroundColor", "value": "0xFFFF0000"}
- "make the box bigger": {"component": "colorBox", "operation": "add", "value": 20.0}
- "make the box smaller": {"component": "colorBox", "operation": "subtract", "value": 10.0}
- "set the box size to 80": {"component": "colorBox", "property": "size", "value": 80.0}
- "update title to 'Senior Designer'": {"component": "titleText", "property": "content", "value": "Senior Designer"}
- "set name to 'John Smith'": {"component": "nameText", "property": "content", "value": "John Smith"}
- "change bio to 'Passionate about AI and Flutter development.'": {"component": "bioText", "property": "content", "value": "Passionate about AI and Flutter development."}
- "make the button green": {"component": "button", "property": "backgroundColor", "value": "0xFF00FF00"}
- "change button text to 'Click Me'": {"component": "button", "property": "content", "value": "Click Me"}
- "make button corners round": {"component": "button", "property": "borderRadius", "value": 20.0}
- "align bio text to center": {"component": "bioText", "property": "textAlign", "value": "center"}
- "align name to left": {"component": "nameText", "property": "textAlign", "value": "left"}
- "turn on the switch": {"component": "toggleSwitch", "property": "value", "value": true}
- "turn off the switch": {"component": "toggleSwitch", "property": "value", "value": false}
- "change switch color to red": {"component": "toggleSwitch", "property": "activeColor", "value": "0xFFFF0000"}

// Layout Control Examples
- "center all elements vertically": {"component": "mainColumn", "property": "mainAxisAlignment", "value": "center"}
- "move everything to the top": {"component": "mainColumn", "property": "mainAxisAlignment", "value": "start"}
- "distribute elements evenly": {"component": "mainColumn", "property": "mainAxisAlignment", "value": "spaceEvenly"}

// Preset Management Examples
- "save current layout as 'My First Design'": {"commandType": "savePreset", "presetName": "My First Design"}
- "load layout 'My First Design'": {"commandType": "loadPreset", "presetName": "My First Design"}

// Slider Examples
- "set slider value to 0.7": {"component": "slider", "property": "value", "value": 0.7}
- "set slider min to 0.1": {"component": "slider", "property": "min", "value": 0.1}
- "set slider max to 2.0": {"component": "slider", "property": "max", "value": 2.0}
- "change slider color to orange": {"component": "slider", "property": "activeColor", "value": "0xFFFFA500"}
- "change slider inactive color to light grey": {"component": "slider", "property": "inactiveColor", "value": "0xFFD3D3D3"}

// Progress Indicator Examples
- "set progress to 50%": {"component": "progressIndicator", "property": "value", "value": 0.5}
- "make progress bar blue": {"component": "progressIndicator", "property": "color", "value": "0xFF0000FF"}
- "change progress background to light green": {"component": "progressIndicator", "property": "backgroundColor", "value": "0xFF90EE90"}

// Image Gallery Examples
- "show next image": {"component": "imageGallery", "property": "nextImage", "value": true} // Value can be ignored
- "show previous image": {"component": "imageGallery", "property": "prevImage", "value": true} // Value can be ignored
- "start image slideshow": {"component": "imageGallery", "property": "autoPlay", "value": true}
- "stop image slideshow": {"component": "imageGallery", "property": "autoPlay", "value": false}
- "show image 2": {"component": "imageGallery", "property": "currentImageIndex", "value": 1} // 0-indexed

// Add Widget Examples
- "add a new button with text 'New Button' and red background": {"commandType": "addWidget", "widgetType": "button", "properties": {"content": "New Button", "backgroundColor": "0xFFFF0000", "textColor": "0xFFFFFFFF", "borderRadius": 8.0}}
- "add a small blue box": {"commandType": "addWidget", "widgetType": "colorBox", "properties": {"size": 30.0, "backgroundColor": "0xFF0000FF"}}
- "add a text label saying 'Hello World' with font size 20": {"commandType": "addWidget", "widgetType": "text", "properties": {"content": "Hello World", "fontSize": 20.0, "textColor": "0xFF000000", "textAlign": "center"}}
- "add a new switch": {"commandType": "addWidget", "widgetType": "toggleSwitch", "properties": {"value": true, "activeColor": "0xFF00FF00"}}
- "add a new slider with value 0.2": {"commandType": "addWidget", "widgetType": "slider", "properties": {"value": 0.2, "min": 0.0, "max": 1.0, "activeColor": "0xFF0000FF"}}
- "add a new progress indicator at 75%": {"commandType": "addWidget", "widgetType": "progressIndicator", "properties": {"value": 0.75, "color": "0xFF800080"}}
- "add a text field with initial text 'Type here' and red border": {"commandType": "addWidget", "widgetType": "textField", "properties": {"initialText": "Type here", "hintText": "Enter text", "borderColor": "0xFFFF0000", "borderRadius": 12.0, "fontSize": 18.0, "textColor": "0xFF333333", "focusedBorderColor": "0xFF0000FF"}}

// New: Modify Dynamic Widget Examples with targetIndex
- "change the text of the second button to 'Click Me Now'": {"component": "button", "property": "content", "value": "Click Me Now", "targetIndex": 2}
- "make the first text field's font size 22": {"component": "textField", "property": "fontSize", "value": 22.0, "targetIndex": 1}
- "set the third color box to green": {"component": "colorBox", "property": "backgroundColor", "value": "0xFF00FF00", "targetIndex": 3}


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
