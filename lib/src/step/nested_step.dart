import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/nested_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// A step that shows several questions on one screen.
///
/// Children render in component-only mode, so they contribute their input
/// widget without their own scaffold. [validationExpression] adds a rule
/// across the group, beyond each child's own validator.
class NestedStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "NestedStep";

  /// The questions shown together on this screen.
  final List<FormStep>? steps;

  /// Cross-field rule applied once every child is individually valid.
  final String validationExpression;

  /// Vertical gap between wrapped rows of children.
  final int verticalPadding;

  /// Called with all results when this step completes the form.
  Function(Map<String, dynamic>)? onFinish;

  /// Creates a [NestedStep].
  NestedStep({
    super.id,
    super.title = "",
    super.text,
    super.display = Display.normal,
    super.isOptional = false,
    super.relevantConditions,
    super.nextButtonText = "Start",
    super.backButtonText,
    super.style,
    this.onFinish,
    required this.verticalPadding,
    super.footerBackButton = false,
    this.steps = const [],
    super.titleIconMaxWidth,
    required this.validationExpression,
    super.titleIconAnimationFile,
    super.cancelButtonText,
    super.crossAxisAlignmentContent,
    super.resultFormat,
    super.cancellable,
  }) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    formStackForm.onFinish = onFinish;
    return NestedStepView(formStackForm, this, text, title: title);
  }

  /// Creates a [NestedStep] from its JSON form.
  factory NestedStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
    List<FormStep> steps,
  ) {
    return NestedStep(
      display: element?["display"] != null
          ? Display.values.firstWhere((e) => e.name == element?["display"])
          : Display.normal,
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            element?["crossAxisAlignmentContent"] ?? "center",
          ) ??
          CrossAxisAlignment.center,
      cancellable: element?["cancellable"],
      footerBackButton: element?["footerBackButton"] ?? false,
      style: UIStyle.maybeFrom(element?["style"]),
      relevantConditions: relevantConditions,
      backButtonText: element?["backButtonText"],
      cancelButtonText: element?["cancelButtonText"],
      isOptional: element?["isOptional"],
      steps: steps,
      nextButtonText: element?["nextButtonText"],
      text: element?["text"],
      verticalPadding: element?["verticalPadding"] ?? 0,
      validationExpression: element?["validationExpression"] ?? "",
      title: element?["title"],
      titleIconAnimationFile: element?["titleIconAnimationFile"],
      titleIconMaxWidth: element?["titleIconMaxWidth"],
      id: GenericIdentifier(id: element?["id"]),
    );
  }
}
