import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/nested_questions_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class NestedQuestionStep extends FormStep {
  final List<QuestionStep>? questions;

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
      this.questions = const [],
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.crossAxisAlignmentContent,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    return NestedQuestionsStepView(formKitForm, this, text, title: title);
  }
}
