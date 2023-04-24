import 'package:formstack/formstack.dart';
import 'package:formstack/src/relevant/expression_relevant_condition.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:formstack/src/utils/alignment.dart';

class Parser {
  static void buildFormFromJson(
      FormStack formStack, Map<String, dynamic>? body) async {
    if (body != null) {
      body.forEach((key, value) {
        List<FormStep> formStep = [];
        List<dynamic>? tsteps = value?["steps"] ?? [];
        tsteps?.forEach((element) {
          List<RelevantCondition> relevantConditions = [];
          cast<List>(element?["relevantConditions"])?.forEach((el) {
            relevantConditions.add(ExpressionRelevant(
                expression: el?["expression"],
                formName: el?["formName"] ?? "",
                identifier: GenericIdentifier(id: el?["id"])));
          });

          if (element["type"] == "QuestionStep") {
            List<Options> options = [];
            cast<List>(element?["options"])?.forEach((el) {
              options.add(Options(el?["key"], el?["text"]));
            });
            InputType inputType = InputType.values
                .firstWhere((e) => e.name == element?["inputType"]);
            QuestionStep step = QuestionStep(
                inputType: inputType,
                options: options,
                relevantConditions: relevantConditions,
                cancellable: element?["cancellable"],
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
            formStep.add(step);
          } else if (element["type"] == "CompletionStep") {
            CompletionStep step = CompletionStep(
                display: element?["display"] != null
                    ? Display.values
                        .firstWhere((e) => e.name == element?["display"])
                    : Display.normal,
                cancellable: element?["cancellable"],
                autoTrigger: element?["autoTrigger"] ?? false,
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
            formStep.add(step);
          } else if (element["type"] == "InstructionStep") {
            List<Instruction> instructions = [];
            cast<List>(element?["instructions"])?.forEach((el) {
              instructions.add(Instruction(el?["title"],
                  subTitle: el?["subTitle"],
                  trailing: el?["trailing"],
                  leading: el?["leading"]));
            });
            InstructionStep step = InstructionStep(
                display: element?["display"] != null
                    ? Display.values
                        .firstWhere((e) => e.name == element?["display"])
                    : Display.normal,
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
            formStep.add(step);
          } else if (element["type"] == "DisplayStep") {
            DisplayStep step = DisplayStep(
                cancellable: element?["cancellable"],
                relevantConditions: relevantConditions,
                backButtonText: element?["backButtonText"],
                cancelButtonText: element?["cancelButtonText"],
                isOptional: element?["isOptional"],
                text: element?["text"],
                title: element?["title"],
                nextButtonText: element?["nextButtonText"],
                url: element?["url"],
                titleIconAnimationFile: element?["titleIconAnimationFile"],
                titleIconMaxWidth: element?["titleIconMaxWidth"],
                id: GenericIdentifier(id: element?["id"]));
            formStep.add(step);
          }
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
}
