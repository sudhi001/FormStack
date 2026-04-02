import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/repeat_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// A step that renders its child steps N times dynamically.
///
/// Users can add and remove repetitions (e.g., "Add another household member").
/// Each repetition is a complete copy of the child steps.
/// Results are stored as a `List<Map<String, dynamic>>`.
///
/// Modeled after ODK's `repeat` with `jr:count`.
///
/// ```dart
/// RepeatStep(
///   id: GenericIdentifier(id: "members"),
///   title: "Household Members",
///   text: "Add each member",
///   minRepeat: 1,
///   maxRepeat: 10,
///   steps: [
///     QuestionStep(title: "", inputType: InputType.name, label: "Name",
///         id: GenericIdentifier(id: "name"), width: 400),
///     QuestionStep(title: "", inputType: InputType.number, label: "Age",
///         id: GenericIdentifier(id: "age"), width: 400),
///   ],
/// )
/// ```
class RepeatStep extends FormStep {
  static const String tag = "RepeatStep";

  /// Template steps that are repeated for each entry.
  final List<FormStep>? steps;

  /// Minimum number of repetitions required.
  final int minRepeat;

  /// Maximum number of repetitions allowed.
  final int maxRepeat;

  /// Label for the "Add" button.
  final String addButtonText;

  Function(Map<String, dynamic>)? onFinish;

  /// Creates a [RepeatStep].
  RepeatStep({
    super.id,
    super.title = "",
    super.text,
    super.display = Display.normal,
    super.isOptional = false,
    super.relevantConditions,
    super.nextButtonText = "Next",
    super.backButtonText,
    super.style,
    this.onFinish,
    super.footerBackButton = false,
    this.steps = const [],
    super.titleIconMaxWidth,
    super.titleIconAnimationFile,
    super.cancelButtonText,
    super.crossAxisAlignmentContent,
    super.resultFormat,
    super.cancellable,
    this.minRepeat = 1,
    this.maxRepeat = 10,
    this.addButtonText = "Add Another",
  }) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    formStackForm.onFinish = onFinish;
    return RepeatStepView(formStackForm, this, text, title: title);
  }

  /// Creates a [RepeatStep] from a JSON map.
  factory RepeatStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions, List<FormStep> steps) {
    return RepeatStep(
      display: element?["display"] != null
          ? Display.values.firstWhere((e) => e.name == element?["display"])
          : Display.normal,
      crossAxisAlignmentContent: crossAlignmentFromString(
              element?["crossAxisAlignmentContent"] ?? "center") ??
          CrossAxisAlignment.center,
      cancellable: element?["cancellable"],
      footerBackButton: element?["footerBackButton"] ?? false,
      style: UIStyle.from(element?["style"]),
      relevantConditions: relevantConditions,
      backButtonText: element?["backButtonText"],
      cancelButtonText: element?["cancelButtonText"],
      isOptional: element?["isOptional"],
      steps: steps,
      nextButtonText: element?["nextButtonText"],
      text: element?["text"],
      title: element?["title"],
      titleIconAnimationFile: element?["titleIconAnimationFile"],
      titleIconMaxWidth: element?["titleIconMaxWidth"],
      minRepeat: element?["minRepeat"] ?? 1,
      maxRepeat: element?["maxRepeat"] ?? 10,
      addButtonText: element?["addButtonText"] ?? "Add Another",
      id: GenericIdentifier(id: element?["id"]),
    );
  }
}
