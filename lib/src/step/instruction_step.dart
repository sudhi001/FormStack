import 'package:flutter/widgets.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';

class InstructionStep extends FormStep {
  final String title;
  final String hint;
  final String? text;
  final Display display;

  InstructionStep(
      {super.id,
      this.title = "",
      this.hint = "",
      this.text,
      this.display = Display.normal,
      super.isOptional = false,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.resultFormat,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss a");
    return InstructionStepView(formKitForm, this, text,
        title: title, hint: hint, display: display);
  }
}

// ignore: must_be_immutable
class InstructionStepView extends InputWidgetView<InstructionStep> {
  InstructionStepView(super.formKitForm, super.formStep, super.text,
      {super.key,
      super.hint,
      super.title,
      super.display = Display.normal,
      cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, InstructionStep formStep) {
    return null;
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  String validationError() {
    return "";
  }

  @override
  resultValue() {
    return DateTime.now();
  }

  @override
  void clearFocus() {}
}
