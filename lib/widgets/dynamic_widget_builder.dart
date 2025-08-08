import 'package:flutter/material.dart';
import 'package:mobile_ui_playground_flutter/utils/color_parser.dart' as color_parser;
import 'package:mobile_ui_playground_flutter/utils/alignment_parser.dart'; // Import alignment_parser

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
  late Map<String, dynamic> _properties;

  @override
  void initState() {
    super.initState();
    _properties = Map<String, dynamic>.from(widget.widgetData['properties']);
  }

  @override
  void didUpdateWidget(covariant DynamicWidgetBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.widgetData['properties'] != oldWidget.widgetData['properties']) {
      setState(() {
        _properties = Map<String, dynamic>.from(widget.widgetData['properties']);
      });
    }
  }

  // Helper to parse TextAlign from string
  TextAlign _parseTextAlign(String alignString) {
    switch (alignString.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      default:
        return TextAlign.center; // Default if unknown
    }
  }

  // Helper to parse BoxFit from string
  BoxFit _parseBoxFit(String fitString) {
    switch (fitString.toLowerCase()) {
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaledown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover; // Default to cover
    }
  }

  // Helper to parse IconData from string (simplified for common icons)
  IconData _parseIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'check_circle':
        return Icons.check_circle;
      case 'favorite':
        return Icons.favorite;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'menu':
        return Icons.menu;
      case 'add':
        return Icons.add;
      case 'close':
        return Icons.close;
      case 'delete':
        return Icons.delete;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'thumb_down':
        return Icons.thumb_down;
      default:
        return Icons.help_outline; // Default icon for unknown names
    }
  }

  @override
  Widget build(BuildContext context) {
    final String widgetType = widget.widgetData['widgetType'];
    final int id = widget.widgetData['id'];

    // Common properties for all dynamic widgets
    final Alignment alignment = parseAlignment(_properties['alignment'] ?? 'center');
    final double padding = (_properties['padding'] ?? 0.0).toDouble();
    final bool isVisible = _properties['isVisible'] ?? true;

    if (!isVisible) {
      return const SizedBox.shrink(); // Don't render if not visible
    }

    Widget currentWidget;

    switch (widgetType) {
      case 'dynamicButton':
        final String content = _properties['content'] ?? 'Dynamic Button';
        final Color backgroundColor = color_parser.parseHexColor(_properties['backgroundColor']) ?? Colors.orange;
        final Color textColor = color_parser.parseHexColor(_properties['textColor']) ?? Colors.white;
        final double borderRadius = (_properties['borderRadius'] ?? 8.0).toDouble();

        currentWidget = ElevatedButton(
          onPressed: () {
            widget.showMessage('Dynamic Button "$content" pressed!', isError: false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(content),
        );
        break;
      case 'colorBox':
        final Color backgroundColor = color_parser.parseHexColor(_properties['backgroundColor']) ?? Colors.teal;
        final double size = (_properties['size'] ?? 60.0).toDouble();

        currentWidget = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
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
        final String content = _properties['content'] ?? 'Dynamic Text';
        final double fontSize = (_properties['fontSize'] ?? 16.0).toDouble();
        final Color textColor = color_parser.parseHexColor(_properties['textColor']) ?? Colors.black;
        final TextAlign textAlign = _parseTextAlign(_properties['textAlign'] ?? 'center');
        final FontWeight fontWeight = (_properties['fontWeight']?.toLowerCase() == 'bold' ? FontWeight.bold : FontWeight.normal);

        currentWidget = Text(
          content,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: fontWeight,
          ),
        );
        break;
      case 'toggleSwitch':
        final bool value = _properties['value'] ?? true;
        final Color activeColor = color_parser.parseHexColor(_properties['activeColor']) ?? Colors.green;
        final Color inactiveThumbColor = color_parser.parseHexColor(_properties['inactiveThumbColor']) ?? Colors.grey;

        currentWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dynamic Toggle:'),
            Switch(
              value: value,
              onChanged: (newValue) {
                widget.onPropertyChange(id, 'value', newValue);
                widget.showMessage('Dynamic Switch toggled to: $newValue', isError: false);
              },
              activeColor: activeColor,
              inactiveThumbColor: inactiveThumbColor,
            ),
          ],
        );
        break;
      case 'slider':
        final double sliderValue = (_properties['value'] ?? 0.5).toDouble();
        final double sliderMin = (_properties['min'] ?? 0.0).toDouble();
        final double sliderMax = (_properties['max'] ?? 1.0).toDouble();
        final Color activeColor = color_parser.parseHexColor(_properties['activeColor']) ?? Colors.blue;
        final Color inactiveColor = color_parser.parseHexColor(_properties['inactiveColor']) ?? Colors.grey;

        currentWidget = Slider(
          value: sliderValue.clamp(sliderMin, sliderMax),
          min: sliderMin,
          max: sliderMax,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          divisions: 20,
          label: sliderValue.toStringAsFixed(2),
          onChanged: (newValue) {
            widget.onPropertyChange(id, 'value', newValue);
          },
        );
        break;
      case 'progressIndicator':
        final double value = (_properties['value'] ?? 0.5).toDouble().clamp(0.0, 1.0);
        final Color color = color_parser.parseHexColor(_properties['color']) ?? Colors.blue;
        final Color backgroundColor = color_parser.parseHexColor(_properties['backgroundColor']) ?? Colors.grey[300]!;

        currentWidget = LinearProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          backgroundColor: backgroundColor,
        );
        break;
      case 'textField':
        final String initialText = _properties['initialText'] ?? '';
        final String hintText = _properties['hintText'] ?? 'Enter text...';
        final Color textColor = color_parser.parseHexColor(_properties['textColor']) ?? Colors.black;
        final double fontSize = (_properties['fontSize'] ?? 16.0).toDouble();
        final Color borderColor = color_parser.parseHexColor(_properties['borderColor']) ?? Colors.grey;
        final double borderRadius = (_properties['borderRadius'] ?? 4.0).toDouble();
        final Color focusedBorderColor = color_parser.parseHexColor(_properties['focusedBorderColor']) ?? Colors.blue;

        currentWidget = TextField(
          controller: TextEditingController(text: initialText),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: focusedBorderColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: TextStyle(color: textColor, fontSize: fontSize),
          onChanged: (newValue) {
            widget.onPropertyChange(id, 'initialText', newValue);
          },
        );
        break;
      case 'dynamicImage':
        final String imageUrl = _properties['imageUrl'] ?? 'https://via.placeholder.com/150';
        final double width = (_properties['width'] ?? 150.0).toDouble();
        final double height = (_properties['height'] ?? 150.0).toDouble();
        final double borderRadius = (_properties['borderRadius'] ?? 0.0).toDouble();
        final BoxFit fit = _parseBoxFit(_properties['fit'] ?? 'cover');

        currentWidget = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              );
            },
          ),
        );
        break;
      case 'dynamicCard':
        final Color backgroundColor = color_parser.parseHexColor(_properties['backgroundColor']) ?? Colors.white;
        final double borderRadius = (_properties['borderRadius'] ?? 8.0).toDouble();
        final double elevation = (_properties['elevation'] ?? 4.0).toDouble();
        final double margin = (_properties['margin'] ?? 8.0).toDouble();
        final double cardPadding = (_properties['padding'] ?? 16.0).toDouble();

        currentWidget = Card(
          color: backgroundColor,
          elevation: elevation,
          margin: EdgeInsets.all(margin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: const Text('Dynamic Card Content'), // Placeholder content for now
          ),
        );
        break;
      case 'dynamicIcon':
        final String iconName = _properties['iconName'] ?? 'help_outline';
        final double size = (_properties['size'] ?? 24.0).toDouble();
        final Color color = color_parser.parseHexColor(_properties['color']) ?? Colors.black;

        currentWidget = Icon(
          _parseIconData(iconName),
          size: size,
          color: color,
        );
        break;
      case 'dynamicDivider':
        final Color color = color_parser.parseHexColor(_properties['color']) ?? Colors.grey;
        final double thickness = (_properties['thickness'] ?? 1.0).toDouble();
        final double indent = (_properties['indent'] ?? 0.0).toDouble();
        final double endIndent = (_properties['endIndent'] ?? 0.0).toDouble();

        currentWidget = Divider(
          color: color,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
        );
        break;
      default:
        currentWidget = Text('Unknown dynamic widget type: $widgetType');
        break;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: currentWidget,
      ),
    );
  }
}
