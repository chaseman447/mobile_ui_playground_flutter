import 'package:flutter/material.dart';

/// Parses a hex color string into a Flutter Color object.
/// Supports formats like "RRGGBB", "#RRGGBB", "AARRGGBB", or "#AARRGGBB".
/// Returns null if the string cannot be parsed into a valid color.
Color? parseHexColor(String hexColorString) {
  // Remove any '#' prefix
  String cleanHex = hexColorString.replaceAll('#', '');

  // Ensure the string is a valid hex string (contains only hex characters)
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanHex)) {
    debugPrint('Invalid hex color string format: $hexColorString');
    return null;
  }

  // Pad with 'FF' if alpha is missing (e.g., RRGGBB -> FFRRGGBB)
  if (cleanHex.length == 6) {
    cleanHex = 'FF$cleanHex';
  }

  // Check if the length is exactly 8 (AARRGGBB)
  if (cleanHex.length == 8) {
    try {
      // Parse the hex string to an integer and create a Color object
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      debugPrint('Error parsing hex color string "$cleanHex": $e');
      return null;
    }
  } else {
    debugPrint('Hex color string has unexpected length: $hexColorString (cleaned: $cleanHex)');
    return null;
  }
}
