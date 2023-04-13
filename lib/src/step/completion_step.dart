import 'package:flutter/widgets.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';

class CompletionStep extends FormStep {
  final String? title;
  final String? text;
  final String buttonText;
  final Display display;
  final Function(Map<String, dynamic>)? onFinish;

  CompletionStep(
      {super.id,
      this.buttonText = "Finish",
      this.title,
      this.text,
      this.display = Display.normal,
      super.isOptional = false,
      this.onFinish,
      super.resultFormat,
      super.cancellable})
      : super();
  @override
  FormStepView buildView(FormStackForm formKitForm) {
    formKitForm.onFinish = onFinish;
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss a");
    return _CompletionStepView(formKitForm, this, text,
        title: title, display: display, nextButtonText: buttonText);
  }
}

// ignore: must_be_immutable
class _CompletionStepView extends InputWidgetView<CompletionStep> {
  _CompletionStepView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.title,
    super.display = Display.normal,
    super.nextButtonText,
  });

  @override
  Widget? buildWInputWidget(BuildContext context, CompletionStep formStep) {
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
