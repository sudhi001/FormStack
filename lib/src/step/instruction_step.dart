import 'package:formstack/src/form_step.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/formstack_form.dart';
import 'package:formstack/src/ui/views/instruction_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class InstructionStep extends FormStep {
  final String title;
  final String? text;
  final Display display;

  InstructionStep(
      {super.id,
      this.title = "",
      this.text,
      this.display = Display.normal,
      super.isOptional = false,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss.SSSSSSS a");
    return InstructionStepView(formKitForm, this, text,
        title: title, display: display);
  }
}
