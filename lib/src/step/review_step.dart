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
  static const String tag = "ReviewStep";

  /// Creates a [ReviewStep].
  ReviewStep(
      {super.id,
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
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    return ReviewStepView(formStackForm, this, text, title: title);
  }

  /// Creates a [ReviewStep] from a JSON map.
  factory ReviewStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return ReviewStep(
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        crossAxisAlignmentContent: crossAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        style: UIStyle.from(element?["style"]),
        cancellable: element?["cancellable"],
        relevantConditions: relevantConditions,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        nextButtonText: element?["nextButtonText"],
        text: element?["text"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconImagePath: element?["titleIconImagePath"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }
}
