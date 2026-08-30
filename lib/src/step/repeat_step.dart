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
  /// The JSON `type` discriminator for this step.
  static const String tag = "RepeatStep";

  /// Template steps that are repeated for each entry.
  final List<FormStep>? steps;

  /// Minimum number of repetitions required.
  final int minRepeat;

  /// Maximum number of repetitions allowed.
  final int maxRepeat;

  /// Label for the "Add" button.
  final String addButtonText;

  /// Called with all results when this step completes the form.
  void Function(Map<String, dynamic>)? onFinish;

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
  factory RepeatStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
    List<FormStep> steps,
  ) {
    final json = JsonReader(element, context: 'RepeatStep');
    return RepeatStep(
      display: json.string('display') != null
          ? Display.values.firstWhere((e) => e.name == json.string('display'))
          : Display.normal,
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            json.string('crossAxisAlignmentContent') ?? "center",
          ) ??
          CrossAxisAlignment.center,
      cancellable: json.boolean('cancellable'),
      footerBackButton: json.boolean('footerBackButton') ?? false,
      style: UIStyle.maybeFrom(json.map('style')),
      relevantConditions: relevantConditions,
      backButtonText: json.string('backButtonText'),
      cancelButtonText: json.string('cancelButtonText'),
      isOptional: json.boolean('isOptional'),
      steps: steps,
      nextButtonText: json.string('nextButtonText'),
      text: json.string('text'),
      title: json.string('title'),
      titleIconAnimationFile: json.string('titleIconAnimationFile'),
      titleIconMaxWidth: json.decimal('titleIconMaxWidth'),
      minRepeat: json.integer('minRepeat') ?? 1,
      maxRepeat: json.integer('maxRepeat') ?? 10,
      addButtonText: json.string('addButtonText') ?? "Add Another",
      id: GenericIdentifier(id: json.string('id')),
    );
  }
}
