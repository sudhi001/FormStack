import 'package:formstack/src/expression/base_expression.dart';
import 'package:formstack/src/expression/expression_terms.dart';

/// Evaluates navigation conditions against a numeric answer.
///
/// Supports `=`, `!=`, `<`, `<=`, `>`, `>=`, `IN` and `FOR_ALL`. Comparisons
/// are numeric: the operand used to be compared as a string against an `int`,
/// so `= 5` was always false and `!= 5` always true — every numeric condition
/// failed to match.
class InExpressionEvaluator extends ExpressionEvaluator<num> {
  /// Creates an [InExpressionEvaluator] for [input].
  InExpressionEvaluator(super.input);

  @override
  bool isValid(String condition, num input) {
    final terms = ExpressionTerms.parse(condition);
    if (terms.operator == 'FOR_ALL') return true;

    // `IN` stays textual: it asks whether the answer contains the operand,
    // which is how it reads for codes and identifiers.
    if (terms.operator == 'IN') {
      return input.toString().contains(terms.operand);
    }
    if (terms.operator == 'NOT_IN') {
      return !input.toString().contains(terms.operand);
    }

    final right = terms.numericOperand;
    if (right == null) {
      throw ArgumentError(
        'Condition "$condition" compares a number against '
        '"${terms.operand}", which is not numeric.',
      );
    }

    switch (terms.operator) {
      case '=':
        return input == right;
      case '!=':
        return input != right;
      case '<':
        return input < right;
      case '<=':
        return input <= right;
      case '>':
        return input > right;
      case '>=':
        return input >= right;
      default:
        throw ArgumentError('Invalid operator: ${terms.operator}');
    }
  }
}
