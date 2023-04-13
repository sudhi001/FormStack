///This grammar allows us to define list conditions with a comparison
///operator (e.g.IN,NOT_IN, FOR_ALL), and one expressions,
//(e.g., IN DEMO  or  NOT_IN DEMO).
///
class ListExpressionEvaluator {
  ListExpressionEvaluator._();
  static bool evaluateCondition(String condition, List input) {
    var parts = condition.split(' ');
    List right = parts[1].split(',');
    var operator = parts[0];

    switch (operator) {
      case 'IN':
        return right.every((element) => input.contains(element));
      case 'FOR_ALL':
        return true;
      case 'NOT_IN':
        return !right.every((element) => input.contains(element));
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }
}
