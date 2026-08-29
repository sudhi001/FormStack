import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/instruction_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// An informational step: a title, body text and optional media, with no
/// input to collect.
///
/// Typically opens a form to explain what is being asked and why.
class InstructionStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "InstructionStep";

  /// Bulleted points listed beneath the body text.
  final List<DynamicData>? instructions;

  /// Creates an [InstructionStep].
  InstructionStep({
    super.id,
    super.title = "",
    super.text,
    super.display = Display.normal,
    super.isOptional = false,
    super.style,
    super.relevantConditions,
    super.nextButtonText = "Start",
    super.backButtonText,
    this.instructions = const [],
    super.titleIconMaxWidth,
    super.titleIconAnimationFile,
    super.titleIconImagePath,
    super.videoUrl,
    super.cancelButtonText,
    super.crossAxisAlignmentContent,
    super.resultFormat,
    super.cancellable,
  }) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    resultFormat = resultFormat ??= ResultFormat.date(
      "",
      "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
    );
    return InstructionStepView(formStackForm, this, text, title: title);
  }

  /// Creates an [InstructionStep] from its JSON form.
  factory InstructionStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
  ) {
    return InstructionStep(
      display: element?["display"] != null
          ? Display.values.firstWhere((e) => e.name == element?["display"])
          : Display.normal,
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            element?["crossAxisAlignmentContent"] ?? "center",
          ) ??
          CrossAxisAlignment.center,
      style: UIStyle.maybeFrom(element?["style"]),
      cancellable: element?["cancellable"],
      relevantConditions: relevantConditions,
      backButtonText: element?["backButtonText"],
      cancelButtonText: element?["cancelButtonText"],
      isOptional: element?["isOptional"],
      instructions: DynamicData.parseDynamicData(
        cast<List<dynamic>>(element?["instructions"]) ?? const [],
      ),
      nextButtonText: element?["nextButtonText"],
      text: element?["text"],
      title: element?["title"],
      titleIconAnimationFile: element?["titleIconAnimationFile"],
      titleIconImagePath: element?["titleIconImagePath"],
      videoUrl: element?["videoUrl"],
      titleIconMaxWidth: element?["titleIconMaxWidth"],
      id: GenericIdentifier(id: element?["id"]),
    );
  }
}
