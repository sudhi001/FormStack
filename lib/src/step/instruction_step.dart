import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/ui/views/instruction_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

class InstructionStep extends FormStep {
  static const String tag = "InstructionStep";

  final List<DynamicData>? instructions;

  InstructionStep(
      {super.id,
      super.title = "",
      super.text,
      super.display = Display.normal,
      super.isOptional = false,
      super.buttonStyle,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      this.instructions = const [],
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.crossAxisAlignmentContent,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss.SSSSSSS a");
    return InstructionStepView(formKitForm, this, text, title: title);
  }

  factory InstructionStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return InstructionStep(
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        crossAxisAlignmentContent: textAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        buttonStyle: UIStyle.from(element?["buttonStyle"]),
        cancellable: element?["cancellable"],
        relevantConditions: relevantConditions,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        instructions: DynamicData.parseDynamicData(
            cast<List>(element?["instructions"]) ?? []),
        nextButtonText: element?["nextButtonText"],
        text: element?["text"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }
}
