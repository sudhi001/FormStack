import 'package:formstack/src/relevant/relevant_condition.dart';

class DynamicConditionalRelevant extends RelevantCondition {
  DynamicConditionalRelevant(
      {required super.identifier, required Function(dynamic)? isValidCallBack})
      : _isValidCallBack = isValidCallBack;

  final Function(dynamic)? _isValidCallBack;
  @override
  bool isValid(dynamic result) {
    return _isValidCallBack!.call(result);
  }
}
