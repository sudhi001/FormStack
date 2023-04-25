import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/expression/base_expression.dart';

// Relevant check using the expresion language
class ExpressionRelevant extends RelevantCondition {
  ExpressionRelevant(
      {required super.identifier, super.formName, required String expression})
      : _expression = expression;
  final String _expression;

  ///
  /// Check the result is valid or not
  ///
  @override
  bool isValid(result) {
    return ExpressionEvaluator.of(result).evaluate(_expression);
  }
}
