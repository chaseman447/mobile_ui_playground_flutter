import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class DynamicButtonWidget extends StatelessWidget {
  final String buttonTextContent;
  final Color buttonBackgroundColor;
  final Color buttonTextColor;
  final double buttonBorderRadius;
  final bool isVisible;
  final Alignment alignment;
  final double padding;
  final VoidCallback onPressed;

  const DynamicButtonWidget({
    super.key,
    required this.buttonTextContent,
    required this.buttonBackgroundColor,
    required this.buttonTextColor,
    required this.buttonBorderRadius,
    required this.isVisible,
    required this.alignment,
    required this.padding,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: alignment,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 3,
              ),
              child: Text(buttonTextContent),
            ),
          ),
        ),
      ),
    );
  }
}
