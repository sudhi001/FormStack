import 'package:formstack/formstack.dart' show ResultFormat;
import 'package:formstack/src/result/result_format.dart' show ResultFormat;

/// The outcome of validating a single step result.
///
/// [ResultFormat.validate] returns this instead of a bare `bool` so callers can
/// react to *why* validation failed — render a localized message, report the
/// code to analytics, or surface the offending constraint — without parsing
/// the human-readable string.
///
/// ```dart
/// final outcome = ResultFormat.minLength('Too short', 3).validate('ab');
/// outcome.isValid;   // false
/// outcome.code;      // 'minLength'
/// outcome.params;    // {'min': 3, 'actual': 2}
/// outcome.message;   // 'Too short'
/// ```
///
/// Localize by mapping [code] through your own catalogue and interpolating
/// [params], falling back to [message] when the code is unknown:
///
/// ```dart
/// String localize(ValidationResult r, FormStackLocale l10n) =>
///     r.isValid ? '' : l10n.tf('validation.${r.code}', [...r.params.values.map((v) => '$v')]);
/// ```
class ValidationResult {
  /// Whether the value satisfied the constraint.
  final bool isValid;

  /// Stable machine-readable identifier of the failed constraint.
  ///
  /// Matches the [ResultFormat] factory name (`email`, `minLength`, `range`,
  /// `custom`, …). Empty when [isValid] is true.
  final String code;

  /// Human-readable fallback message supplied when the validator was built.
  final String message;

  /// Constraint parameters, useful for interpolating a localized message.
  ///
  /// For example `{'min': 3, 'actual': 2}` for a `minLength` failure.
  final Map<String, Object?> params;

  /// Nested failures, populated by [ResultFormat.compose].
  final List<ValidationResult> children;

  const ValidationResult._({
    required this.isValid,
    required this.code,
    required this.message,
    this.params = const {},
    this.children = const [],
  });

  /// A successful validation.
  const ValidationResult.valid()
      : isValid = true,
        code = '',
        message = '',
        params = const {},
        children = const [];

  /// A failed validation for constraint [code] with a fallback [message].
  const ValidationResult.invalid(
    String code,
    String message, {
    Map<String, Object?> params = const {},
    List<ValidationResult> children = const [],
  }) : this._(
          isValid: false,
          code: code,
          message: message,
          params: params,
          children: children,
        );

  /// Converts to a JSON-serializable map for logging or transport.
  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        if (!isValid) 'code': code,
        if (!isValid) 'message': message,
        if (params.isNotEmpty) 'params': params,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
      };

  @override
  String toString() => isValid
      ? 'ValidationResult.valid()'
      : 'ValidationResult($code: $message)';
}
