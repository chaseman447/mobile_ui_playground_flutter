import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class DynamicSwitchWidget extends StatelessWidget {
  final bool switchValue;
  final Color activeColor;
  final Color inactiveThumbColor;
  final bool isVisible;
  final Alignment alignment;
  final double padding;
  final ValueChanged<bool> onChanged;

  const DynamicSwitchWidget({
    super.key,
    required this.switchValue,
    required this.activeColor,
    required this.inactiveThumbColor,
    required this.isVisible,
    required this.alignment,
    required this.padding,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: alignment,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Feature Toggle',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Switch(
                    value: switchValue,
                    onChanged: onChanged,
                    activeColor: activeColor,
                    inactiveThumbColor: inactiveThumbColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
