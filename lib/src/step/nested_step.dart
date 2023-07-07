import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/ui/views/nested_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

class NestedStep extends FormStep {
  static const String tag = "NestedStep";
  final List<FormStep>? steps;
  final String validationExpression;
  Function(Map<String, dynamic>)? onFinish;

  NestedStep(
      {super.id,
      super.title = "",
      super.text,
      super.display = Display.normal,
      super.isOptional = false,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.buttonStyle,
      this.onFinish,
      super.footerBackButton = false,
      this.steps = const [],
      super.titleIconMaxWidth,
      required this.validationExpression,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.crossAxisAlignmentContent,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    formKitForm.onFinish = onFinish;
    return NestedStepView(formKitForm, this, text, title: title);
  }

  factory NestedStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions, List<FormStep> steps) {
    return NestedStep(
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        crossAxisAlignmentContent: crossAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        cancellable: element?["cancellable"],
        footerBackButton: element?["footerBackButton"] ?? false,
        buttonStyle: UIStyle.from(element?["buttonStyle"]),
        relevantConditions: relevantConditions,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        steps: steps,
        nextButtonText: element?["nextButtonText"],
        text: element?["text"],
        validationExpression: element?["validationExpression"] ?? "",
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }
}
