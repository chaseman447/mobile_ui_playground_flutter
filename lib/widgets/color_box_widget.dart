import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class ColorBoxWidget extends StatelessWidget {
  final Color backgroundColor;
  final double size;
  final bool isVisible;
  final Alignment alignment;
  final double padding;

  const ColorBoxWidget({
    super.key,
    required this.backgroundColor,
    required this.size,
    required this.isVisible,
    required this.alignment,
    required this.padding,
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
            curve: Curves.easeInOut,
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
            margin: const EdgeInsets.only(bottom: 20),
          ),
        ),
      ),
    );
  }
}
