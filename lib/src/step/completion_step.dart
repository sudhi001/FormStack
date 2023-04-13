import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';

typedef OnBeforeFinishCallback = Future<bool> Function();

class CompletionStep extends FormStep {
  final String? title;
  final String? text;
  final Display display;
  final OnBeforeFinishCallback? onBeforeFinishCallback;
  final Function(Map<String, dynamic>)? onFinish;

  CompletionStep(
      {super.id,
      this.title,
      this.text,
      this.display = Display.normal,
      super.isOptional = false,
      this.onFinish,
      super.resultFormat,
      this.onBeforeFinishCallback,
      super.nextButtonText = "Finish",
      super.backButtonText,
      super.cancelButtonText,
      super.cancellable})
      : super();
  @override
  FormStepView buildView(FormStackForm formKitForm) {
    formKitForm.onFinish = onFinish;
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss a");
    return _CompletionStepView(formKitForm, this, text,
        title: title,
        display: display,
        onBeforeFinishCallback: onBeforeFinishCallback);
  }
}

// ignore: must_be_immutable
class _CompletionStepView extends InputWidgetView<CompletionStep> {
  final OnBeforeFinishCallback? onBeforeFinishCallback;
  _CompletionStepView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.title,
    this.onBeforeFinishCallback,
    super.display = Display.normal,
  });

  @override
  Widget? buildWInputWidget(BuildContext context, CompletionStep formStep) {
    return const SizedBox(
      height: 100.0,
      width: 100.0,
      child: CircularProgressIndicator(),
    );
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  Future<bool> onBeforeFinish() {
    if (onBeforeFinishCallback != null) {
      return onBeforeFinishCallback!.call();
    }
    return super.onBeforeFinish();
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
