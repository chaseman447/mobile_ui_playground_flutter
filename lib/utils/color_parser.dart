import 'package:flutter/material.dart';

Color? parseHexColor(String hexColorString) {
  String hex = hexColorString.toUpperCase().replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF$hex"; // Add alpha if not provided
  }
  if (hex.length == 8) {
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('Error parsing color string: $hexColorString, Error: $e');
      return null;
    }
  }
  return null;
}
