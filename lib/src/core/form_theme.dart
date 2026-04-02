import 'package:flutter/material.dart';

/// Centralized theme configuration for FormStack forms.
///
/// Provides responsive sizing, dark/light mode colors, and accessibility
/// settings. All FormStack widgets use this to resolve colors and dimensions.
///
/// ```dart
/// // FormStack automatically inherits the app's ThemeData.
/// // For custom form-specific theming:
/// FormStackTheme(
///   maxContentWidth: 600,
///   inputMaxWidth: 500,
///   borderRadius: 12,
/// )
/// ```
class FormStackTheme {
  /// Maximum width for step content area. Adapts responsively.
  final double maxContentWidth;

  /// Maximum width for input fields. Adapts responsively.
  final double inputMaxWidth;

  /// Default border radius for cards, inputs, and buttons.
  final double borderRadius;

  /// Default padding around step content.
  final double contentPadding;

  /// Default spacing between elements.
  final double elementSpacing;

  /// Creates a [FormStackTheme].
  const FormStackTheme({
    this.maxContentWidth = 600,
    this.inputMaxWidth = 500,
    this.borderRadius = 12,
    this.contentPadding = 20,
    this.elementSpacing = 8,
  });

  /// Responsive content width based on screen size.
  /// - Mobile (< 600): 100% of available width
  /// - Tablet (600-1200): maxContentWidth
  /// - Desktop (> 1200): maxContentWidth
  static double responsiveMaxWidth(BuildContext context,
      {double maxWidth = 600}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return screenWidth;
    return maxWidth;
  }

  /// Responsive input width based on screen size.
  static double responsiveInputWidth(BuildContext context,
      {double maxWidth = 500}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return screenWidth - 40; // padding
    return maxWidth;
  }

  /// Responsive padding based on screen size.
  static double responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) return 12;
    if (screenWidth < 600) return 16;
    return 20;
  }

  /// Responsive icon size based on screen size.
  static double responsiveIconSize(BuildContext context, {double base = 40}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) return base * 0.75;
    if (screenWidth > 1200) return base * 1.25;
    return base;
  }

  /// Responsive button height based on screen size.
  static double responsiveButtonHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) return 44;
    return 50;
  }

  // --- Color Helpers (resolve from Theme, support dark mode) ---

  /// Surface color for input backgrounds.
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  /// Border color for input fields and cards.
  static Color borderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Subtle border color for dividers and separators.
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  /// Background color for selected/active items.
  static Color selectedBackground(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
  }

  /// Background color for cards and list items.
  static Color cardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerLow;
  }

  /// Error color.
  static Color errorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Color for drawing on canvas (signature pad). Adapts to dark mode.
  static Color canvasStrokeColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  /// Background for canvas areas. Adapts to dark mode.
  static Color canvasBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white;
  }

  // --- NPS-specific semantic colors (adapt to dark mode) ---

  /// NPS detractor color (0-6).
  static Color npsDetractorColor(BuildContext context,
      {bool selected = false}) {
    final brightness = Theme.of(context).brightness;
    if (selected) return Colors.red.shade400;
    return brightness == Brightness.dark
        ? Colors.red.shade900.withValues(alpha: 0.4)
        : Colors.red.shade50;
  }

  /// NPS passive color (7-8).
  static Color npsPassiveColor(BuildContext context, {bool selected = false}) {
    final brightness = Theme.of(context).brightness;
    if (selected) return Colors.amber.shade400;
    return brightness == Brightness.dark
        ? Colors.amber.shade900.withValues(alpha: 0.4)
        : Colors.amber.shade50;
  }

  /// NPS promoter color (9-10).
  static Color npsPromoterColor(BuildContext context, {bool selected = false}) {
    final brightness = Theme.of(context).brightness;
    if (selected) return Colors.green.shade400;
    return brightness == Brightness.dark
        ? Colors.green.shade900.withValues(alpha: 0.4)
        : Colors.green.shade50;
  }
}
