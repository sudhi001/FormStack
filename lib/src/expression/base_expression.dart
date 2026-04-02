import 'package:formstack/formstack.dart';
import 'package:formstack/src/expression/common_expression.dart';
import 'package:formstack/src/expression/date_expression.dart';
import 'package:formstack/src/expression/int_expression.dart';
import 'package:formstack/src/expression/list_expression.dart';
import 'package:formstack/src/expression/string_expression.dart';

abstract class ExpressionEvaluator<T> {
  const ExpressionEvaluator(this.input);
  factory ExpressionEvaluator.of(T input) {
    if (input is DateTime) {
      return DateTimeExpressionEvaluator(cast<DateTime>(input)!)
          as ExpressionEvaluator<T>;
    } else if (input is List) {
      return ListExpressionEvaluator(cast<List>(input)!)
          as ExpressionEvaluator<T>;
    } else if (input is String) {
      return StringExpressionEvaluator(cast<String>(input)!)
          as ExpressionEvaluator<T>;
    } else if (input is int) {
      return InExpressionEvaluator(_intOrStringValue(input))
          as ExpressionEvaluator<T>;
    } else {
      return CommonExpressionEvaluator(input) as ExpressionEvaluator<T>;
    }
  }
  final T input;
  bool isValid(String condition, T input);

  bool evaluate(String condition) => isValid(condition, input);
}

int _intOrStringValue(dynamic o) {
  if (o is String) o = int.tryParse(o);
  return o ?? 0;
}
