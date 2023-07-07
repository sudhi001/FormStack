import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/ui/views/completion_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

typedef OnBeforeFinishCallback = Future<bool> Function(
    Map<String, dynamic> result);

class CompletionStep extends FormStep {
  static const String tag = "CompletionStep";
  final bool? autoTrigger;
  OnBeforeFinishCallback? onBeforeFinishCallback;
  Function(Map<String, dynamic>)? onFinish;

  CompletionStep(
      {super.id,
      super.title,
      super.text,
      super.buttonStyle,
      super.display = Display.normal,
      super.isOptional = false,
      this.onFinish,
      super.crossAxisAlignmentContent,
      super.resultFormat,
      super.relevantConditions,
      super.titleIconAnimationFile,
      this.onBeforeFinishCallback,
      super.titleIconMaxWidth,
      super.nextButtonText = "Finish",
      super.backButtonText,
      this.autoTrigger = false,
      super.cancelButtonText,
      super.cancellable})
      : super();
  @override
  FormStepView buildView(FormStackForm formKitForm) {
    formKitForm.onFinish = onFinish;
    resultFormat =
        resultFormat ??= ResultFormat.date("", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS");
    return CompletionStepView(formKitForm, this, text,
        title: title,
        autoTrigger: autoTrigger ?? false,
        onBeforeFinishCallback: onBeforeFinishCallback);
  }

  factory CompletionStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return CompletionStep(
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        crossAxisAlignmentContent: crossAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        cancellable: element?["cancellable"],
        autoTrigger: element?["autoTrigger"] ?? false,
        buttonStyle: UIStyle.from(element?["buttonStyle"]),
        relevantConditions: relevantConditions,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        nextButtonText: element?["nextButtonText"],
        text: element?["text"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }
}
