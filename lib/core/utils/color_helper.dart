import 'package:flutter/material.dart';

class ColorHelper {
  static Color getMaterialColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'червоний':
      case 'red': return Colors.red.shade600;
      case 'чорний':
      case 'black': return Colors.black87;
      case 'зелений':
      case 'green': return Colors.green.shade600;
      case 'білий':
      case 'white': return Colors.grey.shade400;
      default: return Colors.blueGrey;
    }
  }
}