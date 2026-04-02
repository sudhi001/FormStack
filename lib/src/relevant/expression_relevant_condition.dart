import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/expression/base_expression.dart';

/// A [RelevantCondition] that evaluates an expression string against the result.
///
/// Supported expressions:
/// - `IN value` - result contains the value
/// - `NOT_IN value` - result does not contain the value
/// - `FOR_ALL` - always matches (used to converge paths)
/// - `= value` / `!= value` - exact match / not equal
///
/// ```dart
/// ExpressionRelevant(
///   identifier: GenericIdentifier(id: "next_step"),
///   expression: "IN selected_option",
///   formName: "optional_form",  // for cross-form navigation
/// )
/// ```
class ExpressionRelevant extends RelevantCondition {
  /// Creates an expression-based condition.
  ExpressionRelevant(
      {required super.identifier, super.formName, required String expression})
      : _expression = expression;

  final String _expression;

  @override
  bool isValid(result) {
    return ExpressionEvaluator.of(result).evaluate(_expression);
  }
}
