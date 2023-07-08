import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/ui/views/display_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

class DisplayStep extends FormStep {
  static const String tag = "DisplayStep";
  final String url;
  final DisplayStepType displayStepType;
  final List<DynamicData> data;
  DisplayStep(
      {super.id,
      this.url = "",
      super.title = "",
      super.text,
      super.isOptional = false,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.componentsStyle,
      super.style,
      this.data = const [],
      this.displayStepType = DisplayStepType.web,
      super.crossAxisAlignmentContent,
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    return DisplayStepView(formKitForm, this, text, title: title);
  }

  factory DisplayStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return DisplayStep(
        data: DynamicData.parseDynamicData(cast<List>(element?["data"]) ?? []),
        componentsStyle: element?["componentsStyle"] != null
            ? ComponentsStyle.values
                .firstWhere((e) => e.name == element?["componentsStyle"])
            : ComponentsStyle.minimal,
        displayStepType: element?["displayStepType"] != null
            ? DisplayStepType.values
                .firstWhere((e) => e.name == element?["displayStepType"])
            : DisplayStepType.web,
        style: UIStyle.from(element?["style"]),
        cancellable: element?["cancellable"],
        crossAxisAlignmentContent: crossAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        relevantConditions: relevantConditions,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        text: element?["text"],
        title: element?["title"],
        nextButtonText: element?["nextButtonText"],
        url: element?["url"] ?? "",
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }
}

enum DisplayStepType { web, listTile }
