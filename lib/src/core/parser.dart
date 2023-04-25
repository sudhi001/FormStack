import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/expression_relevant_condition.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:formstack/src/step/nested_question_step.dart';
import 'package:formstack/src/step/pop_step.dart';
import 'package:formstack/src/utils/alignment.dart';

///
/// ParserUtils - to hanlde JSON parsing related process.
/// This class will change in future.
///
class ParserUtils {
  /// Build FormStep List from JSON
  static void buildFormFromJson(
      FormStack formStack, Map<String, dynamic>? body) async {
    if (body != null) {
      body.forEach((key, value) {
        List<FormStep> formStep = [];
        List<dynamic>? tsteps = value?["steps"] ?? [];
        tsteps?.forEach((element) {
          _addFormStep(formStep, element);
        });
        formStack.form(
            steps: formStep,
            name: key,
            googleMapAPIKey: value?["googleMapAPIKey"],
            backgroundAnimationFile: value?["backgroundAnimationFile"],
            backgroundAlignment:
                alignmentFromString(value?["backgroundAlignment"]),
            initialPosition: value?["initialPosition"] != null
                ? GeoLocationResult(
                    latitude: value?["initialPosition"]["latitude"],
                    longitude: value?["initialPosition"]["longitude"])
                : null);
      });
    }
  }

  /// Build QuestionStep  from JSON
  static QuestionStep _createQuestion(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    List<Options> options = [];
    cast<List>(element?["options"])?.forEach((el) {
      options.add(Options(el?["key"], el?["title"], subTitle: el?["subTitle"]));
    });
    InputType inputType =
        InputType.values.firstWhere((e) => e.name == element?["inputType"]);
    QuestionStep step = QuestionStep(
        inputType: inputType,
        options: options,
        buttonStyle: UIStyle.from(element?["buttonStyle"]),
        crossAxisAlignmentContent: textAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        relevantConditions: relevantConditions,
        cancellable: element?["cancellable"],
        hint: element?["hint"],
        label: element?["label"],
        componentsStyle: element?["componentsStyle"] != null
            ? ComponentsStyle.values
                .firstWhere((e) => e.name == element?["componentsStyle"])
            : ComponentsStyle.minimal,
        inputStyle: element?["inputStyle"] != null
            ? InputStyle.values
                .firstWhere((e) => e.name == element?["inputStyle"])
            : InputStyle.basic,
        autoTrigger: element?["autoTrigger"] ?? false,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        nextButtonText: element?["nextButtonText"],
        numberOfLines: element?["numberOfLines"],
        text: element?["text"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
    return step;
  }

  static FormStep _createCompletion(
      element, List<RelevantCondition> relevantConditions) {
    return CompletionStep(
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        crossAxisAlignmentContent: textAlignmentFromString(
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

  static FormStep _createInstruction(
      element, List<RelevantCondition> relevantConditions) {
    List<DynamicData> instructions = [];
    cast<List>(element?["instructions"])?.forEach((el) {
      instructions.add(DynamicData(el?["title"],
          subTitle: el?["subTitle"],
          trailing: el?["trailing"],
          leading: el?["leading"]));
    });
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
        instructions: instructions,
        nextButtonText: element?["nextButtonText"],
        text: element?["text"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }

  static FormStep _createDisplay(
      element, List<RelevantCondition> relevantConditions) {
    List<DynamicData> data = [];
    cast<List>(element?["data"])?.forEach((el) {
      data.add(DynamicData(el?["title"],
          subTitle: el?["subTitle"],
          trailing: el?["trailing"],
          leading: el?["leading"]));
    });
    return DisplayStep(
        data: data,
        componentsStyle: element?["componentsStyle"] != null
            ? ComponentsStyle.values
                .firstWhere((e) => e.name == element?["componentsStyle"])
            : ComponentsStyle.minimal,
        displayStepType: element?["displayStepType"] != null
            ? DisplayStepType.values
                .firstWhere((e) => e.name == element?["displayStepType"])
            : DisplayStepType.web,
        buttonStyle: UIStyle.from(element?["buttonStyle"]),
        cancellable: element?["cancellable"],
        crossAxisAlignmentContent: textAlignmentFromString(
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

  static List<RelevantCondition> getRelaventCondition(element) {
    List<RelevantCondition> relevantConditions = [];
    cast<List>(element?["relevantConditions"])?.forEach((el) {
      relevantConditions.add(ExpressionRelevant(
          expression: el?["expression"],
          formName: el?["formName"] ?? "",
          identifier: GenericIdentifier(id: el?["id"])));
    });
    return relevantConditions;
  }

  static FormStep createNestedStep(
      element, List<RelevantCondition> relaventCondition) {
    List<FormStep> steps = [];
    cast<List>(element?["steps"])?.forEach((el) {
      _addFormStep(steps, el);
    });
    return NestedQuestionStep(
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        crossAxisAlignmentContent: textAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        cancellable: element?["cancellable"],
        buttonStyle: UIStyle.from(element?["buttonStyle"]),
        relevantConditions: getRelaventCondition(element),
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        steps: steps,
        nextButtonText: element?["nextButtonText"],
        text: element?["text"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        id: GenericIdentifier(id: element?["id"]));
  }

  static void _addFormStep(List<FormStep> step, element) {
    if (element["type"] == QuestionStep.tag) {
      step.add(_createQuestion(element, getRelaventCondition(element)));
    } else if (element["type"] == CompletionStep.tag) {
      step.add(_createCompletion(element, getRelaventCondition(element)));
    } else if (element["type"] == InstructionStep.tag) {
      step.add(_createInstruction(element, getRelaventCondition(element)));
    } else if (element["type"] == DisplayStep.tag) {
      step.add(_createDisplay(element, getRelaventCondition(element)));
    } else if (element["type"] == PopStep.tag) {
      step.add(PopStep(id: GenericIdentifier(id: element?["id"])));
    } else if (element["type"] == NestedQuestionStep.tag) {
      step.add(createNestedStep(element, getRelaventCondition(element)));
    }
  }
}
