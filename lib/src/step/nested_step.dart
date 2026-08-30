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
  void Function(Map<String, dynamic>)? onFinish;

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
    final json = JsonReader(element, context: 'NestedStep');
    return NestedStep(
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
      verticalPadding: json.integer('verticalPadding') ?? 0,
      validationExpression: json.string('validationExpression') ?? "",
      title: json.string('title'),
      titleIconAnimationFile: json.string('titleIconAnimationFile'),
      titleIconMaxWidth: json.decimal('titleIconMaxWidth'),
      id: GenericIdentifier(id: json.string('id')),
    );
  }
}
