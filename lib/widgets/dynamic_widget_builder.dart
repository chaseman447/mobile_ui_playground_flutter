import 'package:flutter/material.dart';
import '../utils/color_parser.dart' as color_parser; // Added prefix
import '../utils/alignment_parser.dart';

class DynamicWidgetBuilder extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final Function(int id, String property, dynamic value) onPropertyChange;
  final Function(String message, {bool isError}) showMessage;

  const DynamicWidgetBuilder({
    super.key,
    required this.widgetData,
    required this.onPropertyChange,
    required this.showMessage,
  });

  @override
  State<DynamicWidgetBuilder> createState() => _DynamicWidgetBuilderState();
}

class _DynamicWidgetBuilderState extends State<DynamicWidgetBuilder> {
  late TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    if (widget.widgetData['widgetType'] == 'textField') {
      _textFieldController = TextEditingController(text: widget.widgetData['properties']['initialText'] ?? '');
    }
  }

  @override
  void didUpdateWidget(covariant DynamicWidgetBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.widgetData['widgetType'] == 'textField' &&
        widget.widgetData['properties']['initialText'] != oldWidget.widgetData['properties']['initialText']) {
      _textFieldController.text = widget.widgetData['properties']['initialText'];
    }
  }

  @override
  void dispose() {
    if (widget.widgetData['widgetType'] == 'textField') {
      _textFieldController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String widgetType = widget.widgetData['widgetType'];
    final Map<String, dynamic> properties = Map<String, dynamic>.from(widget.widgetData['properties']);
    final Key uniqueKey = ValueKey('dynamic_widget_${widget.widgetData['id']}');

    try {
      Alignment dynamicAlignment = parseAlignment(properties['alignment'] ?? 'center');
      double dynamicPadding = (properties['padding'] ?? 0.0).toDouble();

      Widget childWidget;
      switch (widgetType) {
        case 'dynamicButton':
          childWidget = ElevatedButton(
            onPressed: () {
              widget.showMessage('Dynamic Button Pressed: ${properties['content'] ?? 'No Text'}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFF2196F3'), // Used prefix
              foregroundColor: color_parser.parseHexColor(properties['textColor'] ?? '0xFFFFFFFF'), // Used prefix
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
              color: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFF9C27B0'), // Used prefix
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
            textAlign: parseTextAlign(properties['textAlign'] ?? 'center'),
            style: TextStyle(
              fontSize: (properties['fontSize'] ?? 16.0).toDouble(),
              color: color_parser.parseHexColor(properties['textColor'] ?? '0xFF000000'), // Used prefix
              fontWeight: properties['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
            ),
          );
          break;
        case 'toggleSwitch':
          childWidget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Dynamic Toggle:'),
              Switch(
                value: properties['value'] ?? false,
                onChanged: (bool newValue) {
                  widget.onPropertyChange(widget.widgetData['id'], 'value', newValue);
                  widget.showMessage('Dynamic Switch toggled to: $newValue');
                },
                activeColor: color_parser.parseHexColor(properties['activeColor'] ?? '0xFF4CAF50'), // Used prefix
                inactiveThumbColor: color_parser.parseHexColor(properties['inactiveThumbColor'] ?? '0xFF9E9E9E'), // Used prefix
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
                activeColor: color_parser.parseHexColor(properties['activeColor'] ?? '0xFF2196F3'), // Used prefix
                inactiveColor: color_parser.parseHexColor(properties['inactiveColor'] ?? '0xFF9E9E9E'), // Used prefix
                onChanged: (double newValue) {
                  widget.onPropertyChange(widget.widgetData['id'], 'value', newValue);
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
                color: color_parser.parseHexColor(properties['color'] ?? '0xFF2196F3'), // Used prefix
                backgroundColor: color_parser.parseHexColor(properties['backgroundColor'] ?? '0xFFE0E0E0'), // Used prefix
              ),
            ],
          );
          break;
        case 'textField':
          childWidget = TextField(
            controller: _textFieldController,
            decoration: InputDecoration(
              hintText: properties['hintText'] ?? 'Dynamic Text Field',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                borderSide: BorderSide(color: color_parser.parseHexColor(properties['borderColor'] ?? '0xFF9E9E9E') ?? Colors.grey), // Used prefix
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                borderSide: BorderSide(color: color_parser.parseHexColor(properties['borderColor'] ?? '0xFF9E9E9E') ?? Colors.grey, width: 1.0), // Used prefix
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
                borderSide: BorderSide(color: color_parser.parseHexColor(properties['focusedBorderColor'] ?? '0xFF2196F3') ?? Colors.blue, width: 2.0), // Used prefix
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            style: TextStyle(
              fontSize: (properties['fontSize'] ?? 16.0).toDouble(),
              color: color_parser.parseHexColor(properties['textColor'] ?? '0xFF000000'), // Used prefix
            ),
            onChanged: (text) {
              widget.onPropertyChange(widget.widgetData['id'], 'initialText', text);
            },
          );
          break;
        default:
          childWidget = Text('Unknown dynamic widget type: $widgetType');
      }

      return Padding(
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
}
