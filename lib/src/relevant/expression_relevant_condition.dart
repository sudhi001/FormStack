import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/expression/base_expression.dart';

class ExpressionRelevant extends RelevantCondition {
  ExpressionRelevant({required super.identifier, required String expression})
      : _expression = expression;
  final String _expression;
  @override
  bool isValid(result) {
    return ExpressionEvaluator.of(result).evaluate(_expression);
  }
}
