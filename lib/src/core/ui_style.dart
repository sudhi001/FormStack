import 'package:flutter/material.dart';

class UIStyle {
  ///
  ///
  ///```dart
  ///     UIStyle(Colors.black,Colors.white, 10.0)
  ///```
  /// [borderRadius]
  ///[foregroundColor]
  ///[borderRadius]
  ///
  UIStyle(this.backgroundColor, this.foregroundColor, this.borderRadius);

  /// The [backgroundColor] is used for th background color..
  final Color backgroundColor;

  /// The [foregroundColor] is used for th foreground color..
  final Color foregroundColor;

  /// The [borderRadius] is used border radius or corner curve..
  final double borderRadius;

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
