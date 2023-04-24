import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/formstack_form.dart';
import 'package:formstack/src/ui/views/completion_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

typedef OnBeforeFinishCallback = Future<bool> Function(
    Map<String, dynamic> result);

class CompletionStep extends FormStep {
  final String? title;
  final String? text;
  final Display display;
  final bool? autoTrigger;
  OnBeforeFinishCallback? onBeforeFinishCallback;
  Function(Map<String, dynamic>)? onFinish;

  CompletionStep(
      {super.id,
      this.title,
      this.text,
      this.display = Display.normal,
      super.isOptional = false,
      this.onFinish,
      super.resultFormat,
      super.relevantConditions,
      super.titleIconAnimationFile,
      this.onBeforeFinishCallback,
      super.titleIconMaxWidth,
      super.nextButtonText = "Finish",
      super.backButtonText,
      this.autoTrigger = false,
      super.cancelButtonText,
      super.cancellable})
      : super();
  @override
  FormStepView buildView(FormStackForm formKitForm) {
    formKitForm.onFinish = onFinish;
    resultFormat =
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss.SSSSSSS a");
    return CompletionStepView(formKitForm, this, text,
        title: title,
        display: display,
        autoTrigger: autoTrigger ?? false,
        onBeforeFinishCallback: onBeforeFinishCallback);
  }
}
