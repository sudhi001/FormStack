import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/review_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// A step that displays all collected form results for review before submission.
///
/// Place this before [CompletionStep] to let users verify their answers.
///
/// ```dart
/// ReviewStep(
///   id: GenericIdentifier(id: "review"),
///   title: "Review Your Answers",
///   text: "Please verify your information before submitting",
/// )
/// ```
class ReviewStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "ReviewStep";

  /// Creates a [ReviewStep].
  ReviewStep({
    super.id,
    super.title = "Review",
    super.text,
    super.display = Display.normal,
    super.isOptional = false,
    super.style,
    super.relevantConditions,
    super.nextButtonText = "Submit",
    super.backButtonText,
    super.titleIconMaxWidth,
    super.titleIconAnimationFile,
    super.titleIconImagePath,
    super.cancelButtonText,
    super.crossAxisAlignmentContent,
    super.cancellable,
  }) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    return ReviewStepView(formStackForm, this, text, title: title);
  }

  /// Creates a [ReviewStep] from a JSON map.
  factory ReviewStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
  ) {
    final json = JsonReader(element, context: 'ReviewStep');
    return ReviewStep(
      display: json.enumValue('display', Display.values) ?? Display.normal,
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            json.string('crossAxisAlignmentContent') ?? "center",
          ) ??
          CrossAxisAlignment.center,
      style: UIStyle.maybeFrom(json.map('style')),
      cancellable: json.boolean('cancellable'),
      relevantConditions: relevantConditions,
      backButtonText: json.string('backButtonText') ?? "Back",
      cancelButtonText: json.string('cancelButtonText') ?? "Cancel",
      isOptional: json.boolean('isOptional'),
      nextButtonText: json.string('nextButtonText') ?? "Submit",
      text: json.string('text'),
      title: json.string('title'),
      titleIconAnimationFile: json.string('titleIconAnimationFile'),
      titleIconImagePath: json.string('titleIconImagePath'),
      titleIconMaxWidth: json.decimal('titleIconMaxWidth'),
      id: GenericIdentifier(id: json.string('id')),
    );
  }
}
