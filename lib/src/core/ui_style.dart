import 'package:flutter/material.dart';

class UIStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  UIStyle(this.backgroundColor, this.foregroundColor, this.borderRadius);

  factory UIStyle.from(Map<String, dynamic>? style) {
    return UIStyle(
        HexColor(style?["backgroundColor"] ?? "#000000"),
        HexColor(style?["foregroundColor"] ?? "#FFFFFF"),
        style?["borderRadius"] ?? 10.0);
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
