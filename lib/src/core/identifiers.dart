import 'package:formstack/formstack.dart';
import 'package:formstack/src/expression/date_bnf.dart';
import 'package:formstack/src/expression/list_bnf.dart';
import 'package:formstack/src/expression/common_bnf.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

abstract class Identifier {
  String? id;
  Identifier({this.id}) {
    if (id?.isEmpty ?? true) {
      id = uuid.v1();
    }
  }
  @override
  bool operator ==(other) => other is Identifier && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class FormIdentifier extends Identifier {}

class StepIdentifier extends Identifier {}

class InputIdentifier extends Identifier {}

class GenericIdentifier extends Identifier {
  GenericIdentifier({super.id});
}

abstract class RelevantCondition {
  Identifier identifier;

  RelevantCondition({required this.identifier});

  bool isValid(dynamic result);
}

class DynamicConditionalRelevant extends RelevantCondition {
  Function(dynamic)? isValidCallBack;
  DynamicConditionalRelevant(
      {required super.identifier, required this.isValidCallBack});

  @override
  bool isValid(dynamic result) {
    return isValidCallBack!.call(result);
  }
}

class ExpressionRelevant extends RelevantCondition {
  final String expression;
  ExpressionRelevant({required super.identifier, required this.expression});

  @override
  bool isValid(result) {
    if (result is DateTime) {
      return DateTimeExpressionEvaluator.evaluateCondition(
          expression, cast<DateTime>(result)!);
    } else if (result is List) {
      return ListExpressionEvaluator.evaluateCondition(
          expression, cast<List>(result)!);
    } else if (result is String) {
      return StringExpressionEvaluator.evaluateCondition(
          expression, cast<String>(result)!);
    } else if (result is int) {
      return InExpressionEvaluator.evaluateCondition(
          expression, intOrStringValue(result));
    }
    return true;
  }

  int intOrStringValue(dynamic o) {
    if (o is String) o = int.tryParse(o);
    return o ?? 0;
  }
}
