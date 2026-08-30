/// The operator and operand of a navigation condition.
///
/// Conditions are written `<OPERATOR> <operand>` — `= yes`, `IN dev,designer`,
/// `FOR_ALL`. Splitting on every space truncated any operand containing one,
/// so `= New York` compared against `"New"` and silently never matched. The
/// operand is everything after the first space, kept whole.
class ExpressionTerms {
  /// The comparison operator, e.g. `=`, `!=`, `IN`, `NOT_IN`, `FOR_ALL`.
  final String operator;

  /// Everything after the operator, verbatim. Empty when the condition is a
  /// bare operator such as `FOR_ALL`.
  final String operand;

  const ExpressionTerms._(this.operator, this.operand);

  /// Splits [condition] into its operator and operand.
  factory ExpressionTerms.parse(String condition) {
    final trimmed = condition.trim();
    final separator = trimmed.indexOf(' ');
    if (separator < 0) return ExpressionTerms._(trimmed, '');
    return ExpressionTerms._(
      trimmed.substring(0, separator),
      trimmed.substring(separator + 1).trim(),
    );
  }

  /// The operand split on commas, with surrounding whitespace removed.
  ///
  /// `IN dev, designer` yields `['dev', 'designer']`.
  List<String> get operands => operand.isEmpty
      ? const []
      : operand.split(',').map((e) => e.trim()).toList();

  /// The operand parsed as a number, or null when it is not numeric.
  num? get numericOperand => num.tryParse(operand);
}
