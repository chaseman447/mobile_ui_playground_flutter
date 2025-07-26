import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class DynamicSliderWidget extends StatelessWidget {
  final double sliderValue;
  final double sliderMin;
  final double sliderMax;
  final Color sliderActiveColor;
  final Color sliderInactiveColor;
  final bool isVisible;
  final Alignment alignment;
  final double padding;
  final ValueChanged<double> onChanged;

  const DynamicSliderWidget({
    super.key,
    required this.sliderValue,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderActiveColor,
    required this.sliderInactiveColor,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Slider Value: ${sliderValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: sliderValue,
                    min: sliderMin,
                    max: sliderMax,
                    activeColor: sliderActiveColor,
                    inactiveColor: sliderInactiveColor,
                    divisions: 20,
                    label: sliderValue.toStringAsFixed(2),
                    onChanged: onChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${sliderMin.toStringAsFixed(1)}'),
                      Text('${sliderMax.toStringAsFixed(1)}'),
                    ],
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
