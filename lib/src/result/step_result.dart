import 'package:formstack/formstack.dart';

/// Result data from a single form step.
///
/// Contains the step's identifier, result value, timestamps, and metadata.
/// Part of the [TaskResult] hierarchy, modeled after Apple ResearchKit's
/// ORKStepResult.
class StepResult {
  /// Identifier of the step that produced this result.
  final String? stepIdentifier;

  /// Title of the step.
  final String? stepTitle;

  /// The result value (type depends on the input type).
  final dynamic value;

  /// When the step was first displayed to the user.
  final DateTime? startTime;

  /// When the step was completed or navigated away from.
  final DateTime? endTime;

  /// Whether this step was optional.
  final bool isOptional;

  /// Creates a [StepResult].
  StepResult({
    this.stepIdentifier,
    this.stepTitle,
    this.value,
    this.startTime,
    this.endTime,
    this.isOptional = false,
  });

  /// Creates a [StepResult] from a [FormStep].
  factory StepResult.fromStep(FormStep step) {
    return StepResult(
      stepIdentifier: step.id?.id,
      stepTitle: step.title,
      value: step.result,
      startTime: step.startTime,
      endTime: step.endTime,
      isOptional: step.isOptional ?? false,
    );
  }

  /// Duration spent on this step, or null if timestamps are missing.
  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// Converts to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'stepIdentifier': stepIdentifier,
      'stepTitle': stepTitle,
      'value': _serializeValue(value),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMs': duration?.inMilliseconds,
      'isOptional': isOptional,
    };
  }

  dynamic _serializeValue(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toIso8601String();
    if (v is List<Options>) return v.map((o) => o.toJson()).toList();
    if (v is List<KeyValue>) return v.map((kv) => kv.toJson()).toList();
    if (v is Map) return v;
    if (v is List) return v.map((e) => _serializeValue(e)).toList();
    return v;
  }
}

/// Aggregated result from an entire form/task run.
///
/// Contains all step results, timestamps, and metadata.
/// Modeled after Apple ResearchKit's ORKTaskResult.
///
/// ```dart
/// final taskResult = FormStack.api().getTaskResult(formName: "myForm");
/// final json = taskResult.toJson();
/// ```
class TaskResult {
  /// Unique identifier for this task run.
  final String taskRunId;

  /// Name of the form that produced this result.
  final String? formName;

  /// When the task was started.
  final DateTime? startTime;

  /// When the task was completed.
  final DateTime? endTime;

  /// Results from each step, ordered by completion.
  final List<StepResult> stepResults;

  /// Flat key-value map of results (backward compatible).
  final Map<String, dynamic> flatResults;

  /// Creates a [TaskResult].
  TaskResult({
    required this.taskRunId,
    this.formName,
    this.startTime,
    this.endTime,
    this.stepResults = const [],
    this.flatResults = const {},
  });

  /// Total duration of the task.
  Duration? get totalDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// Number of steps completed (non-null result).
  int get completedSteps => stepResults.where((s) => s.value != null).length;

  /// Number of steps skipped (null result on optional step).
  int get skippedSteps =>
      stepResults.where((s) => s.value == null && s.isOptional).length;

  /// Converts the full task result to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'taskRunId': taskRunId,
      'formName': formName,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalDurationMs': totalDuration?.inMilliseconds,
      'completedSteps': completedSteps,
      'skippedSteps': skippedSteps,
      'totalSteps': stepResults.length,
      'stepResults': stepResults.map((s) => s.toJson()).toList(),
      'results': flatResults,
    };
  }
}
