import 'package:formstack/src/expression/base_expression.dart';
import 'package:formstack/src/expression/expression_terms.dart';

/// Evaluates navigation conditions against a text answer.
///
/// Supports `=`, `!=`, `IN`, `NOT_IN` and `FOR_ALL`. `IN` is a substring test,
/// which is what makes `IN dev` match a stored key of `dev`.
class StringExpressionEvaluator extends ExpressionEvaluator<String> {
  /// Creates a [StringExpressionEvaluator] for [input].
  StringExpressionEvaluator(super.input);

  @override
  bool isValid(String condition, String input) {
    final terms = ExpressionTerms.parse(condition);
    switch (terms.operator) {
      case 'FOR_ALL':
        return true;
      case '=':
        return input == terms.operand;
      case '!=':
        return input != terms.operand;
      case 'IN':
        return input.contains(terms.operand);
      case 'NOT_IN':
        return !input.contains(terms.operand);
      default:
        throw ArgumentError('Invalid operator: ${terms.operator}');
    }
  }
}
