import 'package:formstack/src/expression/base_expression.dart';

///This grammar allows us to define list conditions with a comparison
///operator (e.g.IN,NOT_IN, FOR_ALL), and one expressions,
//(e.g., IN DEMO  or  NOT_IN DEMO).
///
class ListExpressionEvaluator extends ExpressionEvaluator<List> {
  ListExpressionEvaluator(super.intput);

  @override
  bool isValid(String condition, List input) {
    var parts = condition.split(' ');
    var operator = parts[0];
    List right = parts.length > 1 ? parts[1].split(',') : [];

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
