import 'package:formstack/src/expression/base_expression.dart';

///This grammar allows us to define list conditions with a comparison
///operator (e.g.=,!= IN) and one expressions,
//(e.g., IN DEMO  or  NOT_IN DEMO).
///
class StringExpressionEvaluator extends ExpressionEvaluator<String> {
  StringExpressionEvaluator(super.intput);

  @override
  bool isValid(String condition, String input) {
    var parts = condition.split(' ');
    var operator = parts[0];
    dynamic right = parts.length > 1 ? parts[1] : "";

    switch (operator) {
      case '=':
        return input == right;
      case '!=':
        return input != right;
      case 'FOR_ALL':
        return true;
      case 'IN':
        return input.contains(right);
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }
}
