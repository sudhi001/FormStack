import 'dart:ffi';

///This grammar allows us to define list conditions with a comparison
///operator (e.g.=,!= IN) and one expressions,
//(e.g., IN DEMO  or  NOT_IN DEMO).
///
class StringExpressionEvaluator {
  StringExpressionEvaluator._();
  static bool evaluateCondition(String condition, String input) {
    var parts = condition.split(' ');
    var operator = parts[0];
    dynamic right = parts.length > 1 ? parts[1] : "";

    switch (operator) {
      case '=':
        return input == right;
      case '!=':
        return input != right;
      case 'IN':
        return input.contains(right);
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }
}

class InExpressionEvaluator {
  InExpressionEvaluator._();
  static bool evaluateCondition(String condition, Int input) {
    var parts = condition.split(' ');
    dynamic right = parts[1];
    var operator = parts[0];

    switch (operator) {
      case '=':
        return input == right;
      case '!=':
        return input != right;
      case 'IN':
        return input.toString().contains(right);
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }
}
