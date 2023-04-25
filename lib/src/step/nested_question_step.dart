import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/nested_questions_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class NestedQuestionStep extends FormStep {
  static const String tag = "NestedStepView";
  final List<FormStep>? steps;

  NestedQuestionStep(
      {super.id,
      super.title = "",
      super.text,
      super.display = Display.normal,
      super.isOptional = false,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.buttonStyle,
      this.steps = const [],
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.crossAxisAlignmentContent,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    return NestedStepView(formKitForm, this, text, title: title);
  }
}
