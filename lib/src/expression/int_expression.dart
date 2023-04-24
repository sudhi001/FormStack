import 'package:formstack/src/expression/base_expression.dart';

class InExpressionEvaluator extends ExpressionEvaluator<int> {
  InExpressionEvaluator(super.intput);

  @override
  bool isValid(String condition, int input) {
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
        return input.toString().contains(right);
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }
}
