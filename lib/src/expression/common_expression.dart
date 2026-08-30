import 'package:formstack/src/expression/base_expression.dart';
import 'package:formstack/src/expression/expression_terms.dart';

/// Evaluates navigation conditions against answers with no dedicated
/// evaluator — booleans, doubles, maps, and null.
///
/// Comparison is textual, against the answer's `toString()`, which reads
/// naturally for the types that land here: `= true` for a boolean toggle,
/// `= 2.5` for a decimal.
///
/// This used to return `true` unconditionally, so *every* condition on such an
/// answer matched and navigation always took the first branch — a boolean
/// question could not route to its "no" path at all.
class CommonExpressionEvaluator extends ExpressionEvaluator<dynamic> {
  /// Creates a [CommonExpressionEvaluator] for [input].
  CommonExpressionEvaluator(super.input);

  @override
  bool isValid(String condition, dynamic input) {
    final terms = ExpressionTerms.parse(condition);
    if (terms.operator == 'FOR_ALL') return true;

    final text = input?.toString() ?? '';
    switch (terms.operator) {
      case '=':
        return text == terms.operand;
      case '!=':
        return text != terms.operand;
      case 'IN':
        return text.contains(terms.operand);
      case 'NOT_IN':
        return !text.contains(terms.operand);
      default:
        throw ArgumentError('Invalid operator: ${terms.operator}');
    }
  }
}
