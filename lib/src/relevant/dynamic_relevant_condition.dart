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
  DynamicConditionalRelevant({
    required super.identifier,
    super.formName,
    required bool Function(dynamic)? isValidCallBack,
  }) : _isValidCallBack = isValidCallBack;

  final bool Function(dynamic)? _isValidCallBack;

  @override
  bool isValid(dynamic result) {
    // The callback is nullable, and force-unwrapping it turned a condition
    // built without one into a null-check crash during navigation. A condition
    // that cannot decide simply does not match.
    return _isValidCallBack?.call(result) ?? false;
  }
}
