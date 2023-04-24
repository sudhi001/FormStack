import 'package:formstack/src/expression/base_expression.dart';

class CommonExpressionEvaluator extends ExpressionEvaluator<dynamic> {
  CommonExpressionEvaluator(super.intput);

  @override
  bool isValid(String condition, dynamic input) {
    return true;
  }
}
