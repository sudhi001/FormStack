import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/instruction_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class InstructionStep extends FormStep {
  static const String tag = "InstructionStep";

  final List<DynamicData>? instructions;

  InstructionStep(
      {super.id,
      super.title = "",
      super.text,
      super.display = Display.normal,
      super.isOptional = false,
      super.buttonStyle,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      this.instructions = const [],
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.crossAxisAlignmentContent,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss.SSSSSSS a");
    return InstructionStepView(formKitForm, this, text, title: title);
  }
}
