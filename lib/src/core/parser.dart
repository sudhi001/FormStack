import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/pop_step.dart';
import 'package:formstack/src/utils/alignment.dart';

///
/// ParserUtils - to handle JSON parsing related process.
/// This class will change in future.
///
class ParserUtils {
  /// Build FormStep List from JSON
  static void buildFormFromJson(FormStack formStack, Map<String, dynamic>? body,
      MapKey mapKey, LocationWrapper locationWrapper) async {
    if (body == null) {
      throw ArgumentError('JSON body cannot be null');
    }
    try {
      body.forEach((key, value) {
        try {
          List<FormStep> formStep = [];
          List<dynamic>? tsteps = value?["steps"] ?? [];
          tsteps?.forEach((element) {
            _addFormStep(formStep, element);
          });
          formStack.form(
              steps: formStep,
              name: key,
              mapKey: mapKey,
              backgroundAnimationFile: value?["backgroundAnimationFile"],
              backgroundAlignment:
                  alignmentFromString(value?["backgroundAlignment"]),
              defaultStyle: value?["theme"] != null
                  ? UIStyle.from(value!["theme"])
                  : null,
              initialLocation: locationWrapper);
        } catch (e) {
          throw FormatException('Error parsing form "$key": $e');
        }
      });
    } catch (e) {
      throw FormatException('Error parsing form JSON: $e');
    }
  }

  /// Build QuestionStep  from JSON
  static QuestionStep _createQuestion(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return QuestionStep.from(element, relevantConditions);
  }

  static FormStep _createCompletion(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return CompletionStep.from(element, relevantConditions);
  }

  static FormStep _createInstruction(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return InstructionStep.from(element, relevantConditions);
  }

  static FormStep _createDisplay(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    return DisplayStep.from(element, relevantConditions);
  }

  static List<RelevantCondition> _parseRelevant(Map<String, dynamic>? element) {
    List<RelevantCondition> relevantConditions = [];
    cast<List>(element?["relevantConditions"])?.forEach((el) {
      relevantConditions.add(ExpressionRelevant(
          expression: el?["expression"],
          formName: el?["formName"] ?? "",
          identifier: GenericIdentifier(id: el?["id"])));
    });
    return relevantConditions;
  }

  static FormStep _createRepeatStep(Map<String, dynamic>? element,
      List<RelevantCondition> relevantCondition) {
    List<FormStep> steps = [];
    cast<List>(element?["steps"])?.forEach((el) {
      _addFormStep(steps, el);
    });
    return RepeatStep.from(element, relevantCondition, steps);
  }

  static FormStep createNestedStep(Map<String, dynamic>? element,
      List<RelevantCondition> relevantCondition) {
    List<FormStep> steps = [];
    cast<List>(element?["steps"])?.forEach((el) {
      _addFormStep(steps, el);
    });
    return NestedStep.from(element, relevantCondition, steps);
  }

  static void _addFormStep(List<FormStep> step, element) {
    if (element == null) {
      throw FormatException('Step element cannot be null');
    }
    final type = element["type"];
    if (type == null) {
      throw FormatException('Step element must have a "type" field');
    }
    try {
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
      } else if (type == ReviewStep.tag) {
        step.add(ReviewStep.from(element, _parseRelevant(element)));
      } else if (type == ConsentStep.tag) {
        step.add(ConsentStep.from(element, _parseRelevant(element)));
      } else if (type == RepeatStep.tag) {
        step.add(_createRepeatStep(element, _parseRelevant(element)));
      } else {
        throw FormatException('Unknown step type: $type');
      }
    } catch (e) {
      throw FormatException('Error creating step of type "$type": $e');
    }
  }
}
