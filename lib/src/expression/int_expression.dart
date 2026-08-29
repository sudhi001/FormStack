import 'package:formstack/src/expression/base_expression.dart';

class InExpressionEvaluator extends ExpressionEvaluator<int> {
  InExpressionEvaluator(super.input);

  @override
  bool isValid(String condition, int input) {
    final parts = condition.split(' ');
    final operator = parts[0];
    final dynamic right = parts.length > 1 ? parts[1] : "";

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
