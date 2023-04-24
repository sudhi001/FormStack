import 'package:formstack/formstack.dart';
import 'package:formstack/src/expression/common_expression.dart';
import 'package:formstack/src/expression/date_expression.dart';
import 'package:formstack/src/expression/int_expression.dart';
import 'package:formstack/src/expression/list_expression.dart';
import 'package:formstack/src/expression/string_expression.dart';

abstract class ExpressionEvaluator<T> {
  const ExpressionEvaluator(this.intput);
  factory ExpressionEvaluator.of(T intput) {
    if (intput is DateTime) {
      return DateTimeExpressionEvaluator(cast<DateTime>(intput)!)
          as ExpressionEvaluator<T>;
    } else if (intput is List) {
      return ListExpressionEvaluator(cast<List>(intput)!)
          as ExpressionEvaluator<T>;
    } else if (intput is String) {
      return StringExpressionEvaluator(cast<String>(intput)!)
          as ExpressionEvaluator<T>;
    } else if (intput is int) {
      return InExpressionEvaluator(_intOrStringValue(intput))
          as ExpressionEvaluator<T>;
    } else {
      return CommonExpressionEvaluator(intput) as ExpressionEvaluator<T>;
    }
  }
  final T intput;
  bool isValid(String condition, T input);

  bool evaluate(String condition) => isValid(condition, intput);
}

int _intOrStringValue(dynamic o) {
  if (o is String) o = int.tryParse(o);
  return o ?? 0;
}
