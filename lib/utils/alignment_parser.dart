import 'package:flutter/material.dart';

/// Parses a string into a TextAlign enum value.
TextAlign parseTextAlign(String alignString) {
  switch (alignString.toLowerCase()) {
    case 'left': return TextAlign.left;
    case 'center': return TextAlign.center;
    case 'right': return TextAlign.right;
    case 'justify': return TextAlign.justify;
    case 'start': return TextAlign.start;
    case 'end': return TextAlign.end;
    default: return TextAlign.center;
  }
}

/// Parses a string into a MainAxisAlignment enum value.
MainAxisAlignment parseMainAxisAlignment(String alignString) {
  switch (alignString.toLowerCase()) {
    case 'start': return MainAxisAlignment.start;
    case 'center': return MainAxisAlignment.center;
    case 'end': return MainAxisAlignment.end;
    case 'spacebetween': return MainAxisAlignment.spaceBetween;
    case 'spacearound': return MainAxisAlignment.spaceAround;
    case 'spaceevenly': return MainAxisAlignment.spaceEvenly;
    default: return MainAxisAlignment.start;
  }
}

/// Parses a string into a CrossAxisAlignment enum value.
CrossAxisAlignment parseCrossAxisAlignment(String alignString) {
  switch (alignString.toLowerCase()) {
    case 'start': return CrossAxisAlignment.start;
    case 'center': return CrossAxisAlignment.center;
    case 'end': return CrossAxisAlignment.end;
    case 'stretch': return CrossAxisAlignment.stretch;
    case 'baseline': return CrossAxisAlignment.baseline;
    default: return CrossAxisAlignment.center;
  }
}

/// Parses a string into an Alignment enum value.
Alignment parseAlignment(String alignString) {
  switch (alignString.toLowerCase()) {
    case 'topleft': return Alignment.topLeft;
    case 'topcenter': return Alignment.topCenter;
    case 'topright': return Alignment.topRight;
    case 'centerleft': return Alignment.centerLeft;
    case 'center': return Alignment.center;
    case 'centerright': return Alignment.centerRight;
    case 'bottomleft': return Alignment.bottomLeft;
    case 'bottomcenter': return Alignment.bottomCenter;
    case 'bottomright': return Alignment.bottomRight;
    default: return Alignment.center;
  }
}
