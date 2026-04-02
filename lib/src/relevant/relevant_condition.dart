import 'package:formstack/src/result/identifiers.dart';

/// Base class for conditional navigation between form steps.
///
/// Attach to a [QuestionStep] via `relevantConditions` to route users
/// to different steps based on their answer. Subclasses:
/// - [ExpressionRelevant] for expression-based conditions
/// - [DynamicConditionalRelevant] for callback-based conditions
abstract class RelevantCondition {
  /// Creates a condition that targets the step with [identifier].
  RelevantCondition({required this.identifier, this.formName});

  /// The target step to navigate to when this condition is met.
  final Identifier identifier;

  /// Optional form name for cross-form navigation.
  final String? formName;

  /// Returns true if the given [result] satisfies this condition.
  bool isValid(dynamic result);
}
