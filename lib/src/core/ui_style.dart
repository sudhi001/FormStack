import 'package:flutter/material.dart';

/// Visual styling configuration for form steps and input fields.
///
/// Can be defined in Dart or loaded from JSON with hex color strings.
///
/// **Dart:**
/// ```dart
/// UIStyle(
///   Colors.indigo, Colors.white, Colors.indigo, 8.0, 12.0,
///   inputBackground: Colors.grey.shade100,
///   inputTextColor: Colors.black,
///   titleColor: Colors.indigo,
///   subtitleColor: Colors.grey,
///   iconColor: Colors.indigo,
///   cardBackground: Colors.white,
///   fontSize: 16.0,
/// )
/// ```
///
/// **JSON:**
/// ```json
/// {
///   "style": {
///     "backgroundColor": "#3F51B5",
///     "foregroundColor": "#FFFFFF",
///     "borderColor": "#3F51B5",
///     "borderRadius": 12,
///     "titleBottomPadding": 8,
///     "inputBackground": "#F5F5F5",
///     "inputTextColor": "#212121",
///     "titleColor": "#3F51B5",
///     "subtitleColor": "#757575",
///     "iconColor": "#3F51B5",
///     "cardBackground": "#FFFFFF",
///     "fontSize": 16
///   }
/// }
/// ```
class UIStyle {
  /// Button background color.
  final Color backgroundColor;

  /// Button foreground (text) color.
  final Color foregroundColor;

  /// Input field border color.
  final Color borderColor;

  /// Button corner radius.
  final double borderRadius;

  /// Padding below the title text.
  final double titleBottomPadding;

  /// Input field background color. Defaults to theme surface if not set.
  final Color? inputBackground;

  /// Input field text color.
  final Color? inputTextColor;

  /// Title text color.
  final Color? titleColor;

  /// Subtitle/description text color.
  final Color? subtitleColor;

  /// Icon color for selection indicators and decorations.
  final Color? iconColor;

  /// Card/list item background color.
  final Color? cardBackground;

  /// Base font size override.
  final double? fontSize;

  /// Creates a [UIStyle].
  UIStyle(this.backgroundColor, this.foregroundColor, this.borderColor,
      this.titleBottomPadding, this.borderRadius,
      {this.inputBackground,
      this.inputTextColor,
      this.titleColor,
      this.subtitleColor,
      this.iconColor,
      this.cardBackground,
      this.fontSize});

  /// Creates a [UIStyle] from a JSON map with hex color strings.
  factory UIStyle.from(Map<String, dynamic>? style) {
    return UIStyle(
      HexColor(style?["backgroundColor"] ?? "#000000"),
      HexColor(style?["foregroundColor"] ?? "#FFFFFF"),
      HexColor(style?["borderColor"] ?? "#000000"),
      (style?["titleBottomPadding"] ?? 7.0).toDouble(),
      (style?["borderRadius"] ?? 10.0).toDouble(),
      inputBackground: style?["inputBackground"] != null
          ? HexColor(style!["inputBackground"])
          : null,
      inputTextColor: style?["inputTextColor"] != null
          ? HexColor(style!["inputTextColor"])
          : null,
      titleColor:
          style?["titleColor"] != null ? HexColor(style!["titleColor"]) : null,
      subtitleColor: style?["subtitleColor"] != null
          ? HexColor(style!["subtitleColor"])
          : null,
      iconColor:
          style?["iconColor"] != null ? HexColor(style!["iconColor"]) : null,
      cardBackground: style?["cardBackground"] != null
          ? HexColor(style!["cardBackground"])
          : null,
      fontSize: style?["fontSize"]?.toDouble(),
    );
  }
}

/// Parses hex color strings (e.g., "#FF5722", "#AABBCC") into [Color] objects.
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  /// Creates a [Color] from a hex string like "#FF5722".
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
