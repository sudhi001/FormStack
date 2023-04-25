import 'package:formstack/src/relevant/relevant_condition.dart';

/// Condition Relevant for dynamic check
class DynamicConditionalRelevant extends RelevantCondition {
  ///
  /// DynamicConditionalRelevant(identifier: GenericIdentifier(id:"DEMO"),isValidCallBack(resut){})
  ///
  DynamicConditionalRelevant(
      {required super.identifier,
      super.formName,
      required Function(dynamic)? isValidCallBack})
      : _isValidCallBack = isValidCallBack;

  final Function(dynamic)? _isValidCallBack;

  ///
  /// Check the result is valid or not
  ///
  @override
  bool isValid(dynamic result) {
    return _isValidCallBack!.call(result);
  }
}
