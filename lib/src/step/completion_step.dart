import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/formstack_form.dart';
import 'package:formstack/src/ui/views/completion_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

typedef OnBeforeFinishCallback = Future<bool> Function(
    Map<String, dynamic> result);

class CompletionStep extends FormStep {
  final bool? autoTrigger;
  OnBeforeFinishCallback? onBeforeFinishCallback;
  Function(Map<String, dynamic>)? onFinish;

  CompletionStep(
      {super.id,
      super.title,
      super.text,
      super.buttonStyle,
      super.display = Display.normal,
      super.isOptional = false,
      this.onFinish,
      super.crossAxisAlignmentContent,
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
        autoTrigger: autoTrigger ?? false,
        onBeforeFinishCallback: onBeforeFinishCallback);
  }
}
