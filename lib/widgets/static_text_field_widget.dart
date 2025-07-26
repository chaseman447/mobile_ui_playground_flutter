import 'package:flutter/material.dart';
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class StaticTextFieldWidget extends StatefulWidget {
  final String initialContent;
  final bool isVisible;
  final Alignment alignment;
  final double padding;
  final ValueChanged<String> onChanged;

  const StaticTextFieldWidget({
    super.key,
    required this.initialContent,
    required this.isVisible,
    required this.alignment,
    required this.padding,
    required this.onChanged,
  });

  @override
  State<StaticTextFieldWidget> createState() => _StaticTextFieldWidgetState();
}

class _StaticTextFieldWidgetState extends State<StaticTextFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void didUpdateWidget(covariant StaticTextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContent != oldWidget.initialContent) {
      _controller.text = widget.initialContent;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Padding(
        padding: EdgeInsets.all(widget.padding),
        child: Align(
          alignment: widget.alignment,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Static Text Field',
                hintText: 'Enter text here',
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
