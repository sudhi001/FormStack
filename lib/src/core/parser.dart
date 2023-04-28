import 'package:formstack/formstack.dart';
import 'package:formstack/src/relevant/expression_relevant_condition.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:formstack/src/step/nested_step.dart';
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
    return QuestionStep.from(element, relevantConditions);
  }

  static FormStep _createCompletion(
      element, List<RelevantCondition> relevantConditions) {
    return CompletionStep.from(element, relevantConditions);
  }

  static FormStep _createInstruction(
      element, List<RelevantCondition> relevantConditions) {
    return InstructionStep.from(element, relevantConditions);
  }

  static FormStep _createDisplay(
      element, List<RelevantCondition> relevantConditions) {
    return DisplayStep.from(element, relevantConditions);
  }

  static List<RelevantCondition> _parseRelevant(element) {
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
    return NestedStep.from(element, relaventCondition, steps);
  }

  static void _addFormStep(List<FormStep> step, element) {
    var type = element["type"];
    if (type == QuestionStep.tag) {
      step.add(_createQuestion(element, _parseRelevant(element)));
    } else if (type == CompletionStep.tag) {
      step.add(_createCompletion(element, _parseRelevant(element)));
    } else if (type == InstructionStep.tag) {
      step.add(_createInstruction(element, _parseRelevant(element)));
    } else if (type == DisplayStep.tag) {
      step.add(_createDisplay(element, _parseRelevant(element)));
    } else if (type == PopStep.tag) {
      step.add(PopStep(id: GenericIdentifier(id: element?["id"])));
    } else if (type == NestedStep.tag) {
      step.add(createNestedStep(element, _parseRelevant(element)));
    }
  }
}
