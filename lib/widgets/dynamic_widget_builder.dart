import 'package:flutter/material.dart';
import '../utils/color_parser.dart';
import '../utils/alignment_parser.dart';
import '../services/navigation_service.dart';

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

  VoidCallback? _getButtonAction(Map<String, dynamic> properties) {
    final NavigationService navigationService = NavigationService();
    
    // Check if there's a navigation action
    if (properties.containsKey('navigationAction')) {
      final String? navAction = properties['navigationAction'];
      final String? navigationTarget = properties['navigationTarget'];
      
      return () {
        switch (navAction) {
          case 'home':
            navigationService.navigateToScreen('/home');
            break;
          case 'settings':
            navigationService.navigateToScreen('/settings');
            break;
          case 'about':
            navigationService.navigateToScreen('/about');
            break;
          case 'layout-manager':
            navigationService.navigateToLayoutManager();
            break;
          case 'navigate-to-layout':
            if (navigationTarget != null) {
              navigationService.navigateToLayoutByName(navigationTarget);
            } else {
              widget.showMessage('No layout specified');
            }
            break;
          default:
            widget.showMessage('Dynamic Button Pressed: ${properties['content'] ?? 'No Text'}');
        }
      };
    }
    
    // Default action if no navigation
    return () {
      widget.showMessage('Dynamic Button Pressed: ${properties['content'] ?? 'No Text'}');
    };
  }

  // Helper to parse BoxFit from string
  BoxFit _parseBoxFit(String fitString) {
    switch (fitString.toLowerCase()) {
      case 'fill': return BoxFit.fill;
      case 'contain': return BoxFit.contain;
      case 'cover': return BoxFit.cover;
      case 'fitwidth': return BoxFit.fitWidth;
      case 'fitheight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      case 'scalepath': return BoxFit.scaleDown; // scaleDown is often used when none is not suitable
      default: return BoxFit.cover;
    }
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
            onPressed: _getButtonAction(properties),
            style: ElevatedButton.styleFrom(
              backgroundColor: parseHexColor(properties['backgroundColor'] ?? '0xFF2196F3'),
              foregroundColor: parseHexColor(properties['textColor'] ?? '0xFFFFFFFF'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 4.0).toDouble()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 3,
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
            textAlign: parseTextAlign(properties['textAlign'] ?? 'center'),
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
              const Text('Dynamic Toggle:'),
              Switch(
                value: properties['value'] ?? false,
                onChanged: (bool newValue) {
                  widget.onPropertyChange(widget.widgetData['id'], 'value', newValue);
                  widget.showMessage('Dynamic Switch toggled to: $newValue');
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
                color: parseHexColor(properties['color'] ?? '0xFF2196F3'),
                backgroundColor: parseHexColor(properties['backgroundColor'] ?? '0xFFE0E0E0'),
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
              widget.onPropertyChange(widget.widgetData['id'], 'initialText', text);
            },
          );
          break;
        case 'dynamicImage':
          final String imageUrlToUse = (properties['imageUrl'] is String && (properties['imageUrl'] as String).isNotEmpty && Uri.tryParse(properties['imageUrl'])?.hasAbsolutePath == true)
              ? properties['imageUrl']
              : 'https://placehold.co/150x150/cccccc/ffffff?text=Image+Error';

          childWidget = Image.network(
            imageUrlToUse,
            width: (properties['width'] ?? 150.0).toDouble(),
            height: (properties['height'] ?? 150.0).toDouble(),
            fit: _parseBoxFit(properties['fit'] ?? 'cover'),
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading dynamic image: $error');
              return Container(
                width: (properties['width'] ?? 150.0).toDouble(),
                height: (properties['height'] ?? 150.0).toDouble(),
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40),
              );
            },
          );
          break;
        case 'dynamicCard': // Example of a dynamic card widget
          childWidget = Card(
            elevation: (properties['elevation'] ?? 4.0).toDouble(),
            margin: EdgeInsets.all((properties['margin'] ?? 8.0).toDouble()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((properties['borderRadius'] ?? 8.0).toDouble()),
            ),
            color: parseHexColor(properties['backgroundColor'] ?? '0xFFFFFFFF'),
            child: Padding(
              padding: EdgeInsets.all((properties['padding'] ?? 16.0).toDouble()),
              child: Text(
                properties['content'] ?? 'Dynamic Card Content',
                style: TextStyle(color: parseHexColor(properties['textColor'] ?? '0xFF000000')),
              ),
            ),
          );
          break;
        case 'dynamicIcon': // Example of a dynamic icon widget
          IconData iconData;
          switch ((properties['iconName'] ?? 'help').toLowerCase()) {
            case 'home': iconData = Icons.home; break;
            case 'settings': iconData = Icons.settings; break;
            case 'star': iconData = Icons.star; break;
            case 'favorite': iconData = Icons.favorite; break;
            case 'add': iconData = Icons.add; break;
            case 'delete': iconData = Icons.delete; break;
            case 'edit': iconData = Icons.edit; break;
            default: iconData = Icons.help; break;
          }
          childWidget = Icon(
            iconData,
            size: (properties['size'] ?? 24.0).toDouble(),
            color: parseHexColor(properties['color'] ?? '0xFF000000'),
          );
          break;
        case 'dynamicDivider': // Example of a dynamic divider widget
          childWidget = Divider(
            color: parseHexColor(properties['color'] ?? '0xFFE0E0E0'),
            thickness: (properties['thickness'] ?? 1.0).toDouble(),
            indent: (properties['indent'] ?? 0.0).toDouble(),
            endIndent: (properties['endIndent'] ?? 0.0).toDouble(),
          );
          break;
        default:
          childWidget = Text('Unknown dynamic widget type: $widgetType');
      }

      return Visibility(
        visible: properties['isVisible'] ?? true, // Respect isVisible property for dynamic widgets
        child: Padding(
          key: uniqueKey,
          padding: EdgeInsets.all(dynamicPadding),
          child: Align(
            alignment: dynamicAlignment,
            child: childWidget,
          ),
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
