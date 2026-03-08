String buildExportPubspec() {
  return '''
name: exported_ui_app
description: Exported app from Flutter UI Playground
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.7.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
''';
}

String buildExportReadme(String exportDirName) {
  return '''
Exported Flutter App

Path: $exportDirName

Run:
  flutter pub get
  flutter run
''';
}

String buildExportAppMain(String exportBase64) {
  return '''
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExportedApp());
}

class ExportedApp extends StatelessWidget {
  const ExportedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exported UI App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ExportedHomePage(),
    );
  }
}

class ExportedHomePage extends StatefulWidget {
  const ExportedHomePage({super.key});

  @override
  State<ExportedHomePage> createState() => _ExportedHomePageState();
}

class _ExportedHomePageState extends State<ExportedHomePage> {
  late final Map<String, dynamic> exportData;
  late Map<String, dynamic> currentState;
  List<Map<String, dynamic>> layouts = [];
  List<Map<String, dynamic>> links = [];
  List<Map<String, dynamic>> screens = [];
  Map<String, dynamic> savedPresets = {};

  @override
  void initState() {
    super.initState();
    final jsonString = utf8.decode(base64Decode('$exportBase64'));
    exportData = json.decode(jsonString);
    currentState = Map<String, dynamic>.from(exportData['currentUIState'] ?? {});
    layouts = (exportData['savedLayouts'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    links = (exportData['links'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    screens = (exportData['screens'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    savedPresets = Map<String, dynamic>.from(exportData['savedPresets'] ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exported UI App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildLayout(currentState),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (layouts.isNotEmpty) ...[
                  const Text('Layouts', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: layouts.map((layout) {
                      return ElevatedButton(
                        onPressed: () {
                          final state = layout['uiState'];
                          if (state is Map<String, dynamic>) {
                            setState(() {
                              currentState = Map<String, dynamic>.from(state);
                            });
                          }
                        },
                        child: Text(layout['name']?.toString() ?? 'Layout'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (links.isNotEmpty) ...[
                  const Text('Links', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: links.map((link) {
                      final label = link['name']?.toString() ?? link['type']?.toString() ?? 'Link';
                      return OutlinedButton(
                        onPressed: () {
                          if (link['type'] == 'layout') {
                            final layoutId = link['id']?.toString();
                            final match = layouts.firstWhere(
                              (l) => l['id']?.toString() == layoutId,
                              orElse: () => {},
                            );
                            if (match.isNotEmpty) {
                              final state = match['uiState'];
                              if (state is Map<String, dynamic>) {
                                setState(() {
                                  currentState = Map<String, dynamic>.from(state);
                                });
                              }
                            }
                          } else if (link['type'] == 'preset') {
                            final presetName = link['name']?.toString();
                            if (presetName != null && savedPresets[presetName] is Map<String, dynamic>) {
                              setState(() {
                                currentState = Map<String, dynamic>.from(savedPresets[presetName]);
                              });
                            }
                          }
                        },
                        child: Text(label),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (screens.isNotEmpty) ...[
                  const Text('Screens', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: screens.map((screen) {
                      final label = screen['label']?.toString() ?? screen['route']?.toString() ?? 'Screen';
                      return TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ScreenPage(label: label),
                            ),
                          );
                        },
                        child: Text(label),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(Map<String, dynamic> state) {
    final mainAxisAlignment = _parseMainAxisAlignment(state['mainColumnAlignment']);
    final crossAxisAlignment = _parseCrossAxisAlignment(state['mainColumnCrossAlignment']);
    final padding = (state['mainColumnPadding'] ?? 16.0).toDouble();
    final backgroundColor = _parseColor(state['mainColumnBackgroundColor'], Colors.transparent);

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileCard(state),
          _buildColorBox(state),
          _buildMainButton(state),
          _buildToggleSwitch(state),
          _buildSlider(state),
          _buildProgress(state),
          _buildImageGallery(state),
          _buildStaticTextField(state),
          ..._buildDynamicWidgets(state),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicWidgets(Map<String, dynamic> state) {
    final dynamicWidgets = state['dynamicWidgets'] as List<dynamic>? ?? [];
    return dynamicWidgets.map((item) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(item);
      final widgetType = data['widgetType']?.toString() ?? '';
      final properties = data['properties'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['properties'])
          : <String, dynamic>{};
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: _buildDynamicWidget(widgetType, properties),
      );
    }).toList();
  }

  Widget _buildDynamicWidget(String widgetType, Map<String, dynamic> properties) {
    switch (widgetType) {
      case 'dynamicButton':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _parseColor(properties['backgroundColor'], Colors.blue),
          ),
          onPressed: () {},
          child: Text(
            properties['content']?.toString() ?? 'Button',
            style: TextStyle(
              color: _parseColor(properties['textColor'], Colors.white),
            ),
          ),
        );
      case 'text':
        return Text(
          properties['content']?.toString() ?? 'Text',
          style: TextStyle(
            color: _parseColor(properties['textColor'], Colors.black),
            fontSize: (properties['fontSize'] ?? 14).toDouble(),
          ),
        );
      case 'colorBox':
        return Container(
          width: (properties['size'] ?? 60).toDouble(),
          height: (properties['size'] ?? 60).toDouble(),
          color: _parseColor(properties['backgroundColor'], Colors.purple),
        );
      case 'toggleSwitch':
        return Switch(
          value: (properties['value'] ?? false) == true,
          onChanged: null,
          activeColor: _parseColor(properties['activeColor'], Colors.green),
        );
      case 'slider':
        return Slider(
          value: (properties['value'] ?? 0.5).toDouble(),
          min: (properties['min'] ?? 0.0).toDouble(),
          max: (properties['max'] ?? 1.0).toDouble(),
          onChanged: null,
          activeColor: _parseColor(properties['activeColor'], Colors.blue),
        );
      case 'progressIndicator':
        return LinearProgressIndicator(
          value: (properties['value'] ?? 0.4).toDouble(),
          color: _parseColor(properties['color'], Colors.blue),
          backgroundColor: _parseColor(properties['backgroundColor'], Colors.grey.shade300),
        );
      case 'dynamicImage':
        final url = properties['imageUrl']?.toString() ?? '';
        return url.isNotEmpty
            ? Image.network(url, height: 120, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 48);
      case 'dynamicCard':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(properties['content']?.toString() ?? 'Card'),
          ),
        );
      case 'dynamicIcon':
        return Icon(Icons.star, color: _parseColor(properties['color'], Colors.black));
      case 'dynamicDivider':
        return Divider(color: _parseColor(properties['color'], Colors.grey));
      case 'textField':
        return TextField(
          decoration: InputDecoration(
            hintText: properties['placeholder']?.toString() ?? 'Text field',
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfileCard(Map<String, dynamic> state) {
    if (state['isProfileCardVisible'] == false) {
      return const SizedBox.shrink();
    }
    final profileImageUrl = state['profileImageUrl']?.toString() ?? '';
    final backgroundColor = _parseColor(state['profileCardBackgroundColor'], Colors.grey.shade200);
    final borderRadius = (state['profileCardBorderRadius'] ?? 8.0).toDouble();
    final padding = (state['profileCardPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['profileCardAlignment']);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: (state['profileImageSize'] ?? 100.0).toDouble() / 4,
                backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                child: profileImageUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state['isNameTextVisible'] != false)
                    Text(
                      state['nameTextContent']?.toString() ?? 'Name',
                      style: TextStyle(
                        fontSize: (state['nameFontSize'] ?? 20).toDouble(),
                        fontWeight: (state['nameFontWeight'] ?? 0) == 1 ? FontWeight.bold : FontWeight.normal,
                        color: _parseColor(state['nameTextColor'], Colors.black),
                      ),
                    ),
                  if (state['isTitleVisible'] != false)
                    Text(
                      state['titleTextContent']?.toString() ?? 'Title',
                      style: TextStyle(
                        fontSize: (state['titleFontSize'] ?? 16).toDouble(),
                        color: _parseColor(state['titleTextColor'], Colors.black54),
                      ),
                    ),
                  if (state['isBioTextVisible'] != false)
                    Text(
                      state['bioTextContent']?.toString() ?? 'Bio',
                      style: TextStyle(
                        fontSize: (state['bioFontSize'] ?? 12).toDouble(),
                        color: _parseColor(state['bioTextColor'], Colors.black54),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(Map<String, dynamic> state) {
    if (state['isColorBoxVisible'] == false) {
      return const SizedBox.shrink();
    }
    final size = (state['colorBoxSize'] ?? 60.0).toDouble();
    final padding = (state['colorBoxPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['colorBoxAlignment']);
    final color = _parseColor(state['colorBoxBackgroundColor'], Colors.purple);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }

  Widget _buildMainButton(Map<String, dynamic> state) {
    if (state['isMainActionButtonVisible'] == false) {
      return const SizedBox.shrink();
    }
    final padding = (state['mainActionButtonPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['mainActionButtonAlignment']);
    final background = _parseColor(state['buttonBackgroundColor'], Colors.blue);
    final textColor = _parseColor(state['buttonTextColor'], Colors.white);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: background),
          onPressed: () {},
          child: Text(
            state['buttonTextContent']?.toString() ?? 'Button',
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(Map<String, dynamic> state) {
    if (state['isToggleSwitchVisible'] == false) {
      return const SizedBox.shrink();
    }
    final padding = (state['toggleSwitchPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['toggleSwitchAlignment']);
    final value = (state['switchValue'] ?? false) == true;
    final activeColor = _parseColor(state['switchActiveColor'], Colors.green);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Switch(value: value, onChanged: null, activeColor: activeColor),
      ),
    );
  }

  Widget _buildSlider(Map<String, dynamic> state) {
    if (state['isSliderVisible'] == false) {
      return const SizedBox.shrink();
    }
    final padding = (state['sliderPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['sliderAlignment']);
    final value = (state['sliderValue'] ?? 0.5).toDouble();
    final min = (state['sliderMin'] ?? 0.0).toDouble();
    final max = (state['sliderMax'] ?? 1.0).toDouble();
    final activeColor = _parseColor(state['sliderActiveColor'], Colors.blue);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: null,
          activeColor: activeColor,
        ),
      ),
    );
  }

  Widget _buildProgress(Map<String, dynamic> state) {
    if (state['isProgressIndicatorVisible'] == false) {
      return const SizedBox.shrink();
    }
    final padding = (state['progressIndicatorPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['progressIndicatorAlignment']);
    final value = (state['progressValue'] ?? 0.3).toDouble();
    final color = _parseColor(state['progressColor'], Colors.blue);
    final background = _parseColor(state['progressBackgroundColor'], Colors.grey.shade300);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: LinearProgressIndicator(value: value, color: color, backgroundColor: background),
      ),
    );
  }

  Widget _buildImageGallery(Map<String, dynamic> state) {
    if (state['isImageGalleryVisible'] == false) {
      return const SizedBox.shrink();
    }
    final padding = (state['imageGalleryPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['imageGalleryAlignment']);
    final urls = (state['imageUrls'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final url = urls.isNotEmpty ? urls.first : '';
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: url.isNotEmpty
            ? Image.network(url, height: 120, fit: BoxFit.cover)
            : const Icon(Icons.photo, size: 48),
      ),
    );
  }

  Widget _buildStaticTextField(Map<String, dynamic> state) {
    if (state['isStaticTextFieldVisible'] == false) {
      return const SizedBox.shrink();
    }
    final padding = (state['staticTextFieldPadding'] ?? 0.0).toDouble();
    final alignment = _parseAlignment(state['staticTextFieldAlignment']);
    final content = state['staticTextFieldContent']?.toString() ?? 'Text field';
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: TextField(
          controller: TextEditingController(text: content),
          readOnly: true,
        ),
      ),
    );
  }

  Alignment _parseAlignment(dynamic raw) {
    final value = raw?.toString() ?? 'center';
    switch (value) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(dynamic raw) {
    final index = raw is int ? raw : 0;
    return MainAxisAlignment.values[index.clamp(0, MainAxisAlignment.values.length - 1)];
  }

  CrossAxisAlignment _parseCrossAxisAlignment(dynamic raw) {
    final index = raw is int ? raw : 2;
    return CrossAxisAlignment.values[index.clamp(0, CrossAxisAlignment.values.length - 1)];
  }

  Color _parseColor(dynamic raw, Color fallback) {
    if (raw is int) {
      return Color(raw);
    }
    if (raw is String) {
      final normalized = raw.startsWith('0x') ? raw.substring(2) : raw;
      final parsed = int.tryParse(normalized, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return fallback;
  }
}

class ScreenPage extends StatelessWidget {
  final String label;

  const ScreenPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label)),
    );
  }
}
''';
}
