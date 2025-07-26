import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class ProgressIndicatorWidget extends StatelessWidget {
  final double progressValue;
  final Color progressColor;
  final Color progressBackgroundColor;
  final bool isVisible;
  final Alignment alignment;
  final double padding;

  const ProgressIndicatorWidget({
    super.key,
    required this.progressValue,
    required this.progressColor,
    required this.progressBackgroundColor,
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Progress: ${(progressValue * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      color: progressColor,
                      backgroundColor: progressBackgroundColor,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progressValue,
                      color: progressColor,
                      backgroundColor: progressBackgroundColor,
                      strokeWidth: 6,
                    ),
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
