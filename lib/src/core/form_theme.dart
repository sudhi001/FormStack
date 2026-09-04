import 'package:flutter/material.dart';

/// Centralized sizing configuration for FormStack forms.
///
/// Colors come from the ambient [ThemeData], so a form inherits the host
/// application's palette and dark mode without configuration. This class
/// covers the dimensions Material does not describe: how wide step content is
/// allowed to grow, how much padding surrounds it, and the default corner
/// radius.
///
/// Provide one with [FormStackThemeScope] to change those dimensions for a
/// subtree:
///
/// ```dart
/// FormStackThemeScope(
///   theme: const FormStackTheme(maxContentWidth: 800, contentPadding: 32),
///   child: FormStack.api().render(),
/// )
/// ```
///
/// Without a scope, [defaults] applies.
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

  /// The theme used when no [FormStackThemeScope] is present.
  static const FormStackTheme defaults = FormStackTheme();

  /// The theme provided by the nearest [FormStackThemeScope], or [defaults].
  ///
  /// Establishes a dependency, so a subtree rebuilds when the scope changes.
  static FormStackTheme of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FormStackThemeScope>()
          ?.theme ??
      defaults;

  /// Returns a copy with the given fields replaced.
  FormStackTheme copyWith({
    double? maxContentWidth,
    double? inputMaxWidth,
    double? borderRadius,
    double? contentPadding,
    double? elementSpacing,
  }) => FormStackTheme(
    maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    inputMaxWidth: inputMaxWidth ?? this.inputMaxWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    contentPadding: contentPadding ?? this.contentPadding,
    elementSpacing: elementSpacing ?? this.elementSpacing,
  );

  @override
  bool operator ==(Object other) =>
      other is FormStackTheme &&
      other.maxContentWidth == maxContentWidth &&
      other.inputMaxWidth == inputMaxWidth &&
      other.borderRadius == borderRadius &&
      other.contentPadding == contentPadding &&
      other.elementSpacing == elementSpacing;

  @override
  int get hashCode => Object.hash(
    maxContentWidth,
    inputMaxWidth,
    borderRadius,
    contentPadding,
    elementSpacing,
  );

  /// Responsive content width based on screen size.
  ///
  /// Below 600 logical pixels the content uses the full width; above it, it is
  /// capped at [maxContentWidth] from the scoped theme so text does not run to
  /// uncomfortable line lengths on tablets and desktops.
  ///
  /// [maxWidth] overrides the scoped value for a single call.
  static double responsiveMaxWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = FormStackAvailableWidth.of(context);
    if (screenWidth < 600) return screenWidth;
    return maxWidth ?? of(context).maxContentWidth;
  }

  /// Responsive input width based on screen size.
  static double responsiveInputWidth(BuildContext context, {double? maxWidth}) {
    final theme = of(context);
    final screenWidth = FormStackAvailableWidth.of(context);
    if (screenWidth < 600) return screenWidth - theme.contentPadding * 2;
    return maxWidth ?? theme.inputMaxWidth;
  }

  /// Responsive padding based on screen size.
  ///
  /// Scales the scoped [contentPadding] down on narrow screens rather than
  /// returning fixed values, so a custom padding is honoured everywhere.
  static double responsivePadding(BuildContext context) {
    final padding = of(context).contentPadding;
    final screenWidth = FormStackAvailableWidth.of(context);
    if (screenWidth < 400) return padding * 0.6;
    if (screenWidth < 600) return padding * 0.8;
    return padding;
  }

  /// The default corner radius for cards, inputs and buttons.
  ///
  /// A step's own [UIStyle.borderRadius] takes precedence where one is set.
  static double radius(BuildContext context) => of(context).borderRadius;

  /// The default spacing between elements in a step.
  static double spacing(BuildContext context) => of(context).elementSpacing;

  /// Responsive icon size based on screen size.
  static double responsiveIconSize(BuildContext context, {double base = 40}) {
    final screenWidth = FormStackAvailableWidth.of(context);
    if (screenWidth < 400) return base * 0.75;
    if (screenWidth > 1200) return base * 1.25;
    return base;
  }

  /// Responsive button height based on screen size.
  static double responsiveButtonHeight(BuildContext context) {
    final screenWidth = FormStackAvailableWidth.of(context);
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
  static Color npsDetractorColor(
    BuildContext context, {
    bool selected = false,
  }) {
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

/// Provides a [FormStackTheme] to the forms rendered beneath it.
///
/// Colors still come from the ambient [ThemeData]; this only overrides the
/// dimensions FormStack chooses for itself.
///
/// ```dart
/// FormStackThemeScope(
///   theme: const FormStackTheme(maxContentWidth: 800, borderRadius: 4),
///   child: FormStack.api().render(),
/// )
/// ```
class FormStackThemeScope extends InheritedWidget {
  /// The theme applied to descendants.
  final FormStackTheme theme;

  /// Creates a [FormStackThemeScope].
  const FormStackThemeScope({
    required this.theme,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(FormStackThemeScope oldWidget) =>
      oldWidget.theme != theme;
}

/// The width available to the form, as measured where it is mounted.
///
/// Every responsive decision below used to read
/// `MediaQuery.of(context).size.width`, which is the width of the *window* —
/// not of the space the form was handed. A form inside a 600px dialog on a
/// 1500px monitor therefore took every "desktop" branch and sized its inputs
/// for a viewport it did not have, and the same form inside a narrow side panel
/// would do the reverse.
///
/// [FormStackView] publishes the real constraint here. The helpers prefer it and
/// fall back to the window when a form is mounted outside one, so nothing that
/// worked before changes.
class FormStackAvailableWidth extends InheritedWidget {
  /// The maximum width the form may occupy.
  final double width;

  /// Creates a [FormStackAvailableWidth].
  const FormStackAvailableWidth({
    required this.width,
    required super.child,
    super.key,
  });

  /// The available width, or the window width when unscoped.
  static double of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FormStackAvailableWidth>()
          ?.width ??
      MediaQuery.of(context).size.width;

  @override
  bool updateShouldNotify(FormStackAvailableWidth oldWidget) =>
      oldWidget.width != width;
}
