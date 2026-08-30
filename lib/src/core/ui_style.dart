import 'package:flutter/material.dart';
import 'package:formstack/src/core/json_reader.dart';

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
  UIStyle(
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.titleBottomPadding,
    this.borderRadius, {
    this.inputBackground,
    this.inputTextColor,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
    this.cardBackground,
    this.fontSize,
  });

  /// Creates a [UIStyle] from a JSON map, or returns null when [style] is null.
  ///
  /// Step factories must use this rather than [UIStyle.from]: an unstyled step
  /// has to end up with a null `style` so the form-level `theme` can be
  /// applied as its default. [UIStyle.from] returns a fully-defaulted style
  /// for a null map, which silently shadowed the form theme on every
  /// JSON-defined step.
  static UIStyle? maybeFrom(Map<String, dynamic>? style) =>
      style == null ? null : UIStyle.from(style);

  /// Creates a [UIStyle] from a JSON map with hex color strings.
  ///
  /// A null map yields a style with all defaults. Use [maybeFrom] when a
  /// missing map should mean "no style of my own".
  factory UIStyle.from(Map<String, dynamic>? style) {
    final read = JsonReader(style, context: 'UIStyle');
    return UIStyle(
      HexColor(read.string('backgroundColor') ?? "#000000"),
      HexColor(read.string('foregroundColor') ?? "#FFFFFF"),
      HexColor(read.string('borderColor') ?? "#000000"),
      read.decimal('titleBottomPadding') ?? 7.0,
      read.decimal('borderRadius') ?? 10.0,
      inputBackground: read.has('inputBackground')
          ? HexColor(read.string('inputBackground')!)
          : null,
      inputTextColor: read.has('inputTextColor')
          ? HexColor(read.string('inputTextColor')!)
          : null,
      titleColor: read.has('titleColor')
          ? HexColor(read.string('titleColor')!)
          : null,
      subtitleColor: read.has('subtitleColor')
          ? HexColor(read.string('subtitleColor')!)
          : null,
      iconColor: read.has('iconColor')
          ? HexColor(read.string('iconColor')!)
          : null,
      cardBackground: read.has('cardBackground')
          ? HexColor(read.string('cardBackground')!)
          : null,
      fontSize: read.decimal('fontSize'),
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
