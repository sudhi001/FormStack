import 'package:formstack/src/relevant/relevant_condition.dart';

/// A [RelevantCondition] that uses a custom callback function.
///
/// Use this when you need complex logic that cannot be expressed
/// as a simple expression string.
///
/// ```dart
/// DynamicConditionalRelevant(
///   identifier: GenericIdentifier(id: "next_step"),
///   isValidCallBack: (result) => result == "expected_value",
/// )
/// ```
class DynamicConditionalRelevant extends RelevantCondition {
  /// Creates a callback-based condition.
  DynamicConditionalRelevant(
      {required super.identifier,
      super.formName,
      required Function(dynamic)? isValidCallBack})
      : _isValidCallBack = isValidCallBack;

  final Function(dynamic)? _isValidCallBack;

  @override
  bool isValid(dynamic result) {
    return _isValidCallBack!.call(result);
  }
}
