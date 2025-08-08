import 'package:flutter/material.dart';

/// Parses a string into a Flutter AlignmentGeometry object.
/// Supports common alignment strings like 'center', 'topLeft', 'bottomRight', etc.
/// Defaults to Alignment.center if the string is unrecognized.
Alignment parseAlignment(String alignmentString) {
  switch (alignmentString.toLowerCase()) {
    case 'topleft':
      return Alignment.topLeft;
    case 'topcenter':
      return Alignment.topCenter;
    case 'topright':
      return Alignment.topRight;
    case 'centerleft':
      return Alignment.centerLeft;
    case 'center':
      return Alignment.center;
    case 'centerright':
      return Alignment.centerRight;
    case 'bottomleft':
      return Alignment.bottomLeft;
    case 'bottomcenter':
      return Alignment.bottomCenter;
    case 'bottomright':
      return Alignment.bottomRight;
    default:
      debugPrint('Warning: Unrecognized alignment string: $alignmentString. Defaulting to Alignment.center.');
      return Alignment.center;
  }
}

/// Parses a string into a Flutter MainAxisAlignment enum.
/// Supports strings like 'start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly'.
/// Defaults to MainAxisAlignment.start if the string is unrecognized.
MainAxisAlignment parseMainAxisAlignment(String axisAlignmentString) {
  switch (axisAlignmentString.toLowerCase()) {
    case 'start':
      return MainAxisAlignment.start;
    case 'end':
      return MainAxisAlignment.end;
    case 'center':
      return MainAxisAlignment.center;
    case 'spacebetween':
      return MainAxisAlignment.spaceBetween;
    case 'spacearound':
      return MainAxisAlignment.spaceAround;
    case 'spaceevenly':
      return MainAxisAlignment.spaceEvenly;
    default:
      debugPrint('Warning: Unrecognized main axis alignment string: $axisAlignmentString. Defaulting to MainAxisAlignment.start.');
      return MainAxisAlignment.start;
  }
}

/// Parses a string into a Flutter CrossAxisAlignment enum.
/// Supports strings like 'start', 'end', 'center', 'stretch', 'baseline'.
/// Defaults to CrossAxisAlignment.center if the string is unrecognized.
CrossAxisAlignment parseCrossAxisAlignment(String axisAlignmentString) {
  switch (axisAlignmentString.toLowerCase()) {
    case 'start':
      return CrossAxisAlignment.start;
    case 'end':
      return CrossAxisAlignment.end;
    case 'center':
      return CrossAxisAlignment.center;
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'baseline':
      return CrossAxisAlignment.baseline;
    default:
      debugPrint('Warning: Unrecognized cross axis alignment string: $axisAlignmentString. Defaulting to CrossAxisAlignment.center.');
      return CrossAxisAlignment.center;
  }
}

/// Parses a string into a Flutter TextAlign enum.
/// Supports strings like 'left', 'center', 'right', 'justify', 'start', 'end'.
/// Defaults to TextAlign.center if the string is unrecognized.
TextAlign parseTextAlign(String textAlignString) {
  switch (textAlignString.toLowerCase()) {
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
      debugPrint('Warning: Unrecognized text align string: $textAlignString. Defaulting to TextAlign.center.');
      return TextAlign.center;
  }
}
