import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';
import 'package:lottie/lottie.dart';

typedef OnBeforeFinishCallback = Future<bool> Function();

class CompletionStep extends FormStep {
  final String? title;
  final String? text;
  final Display display;
  final bool? autoTrigger;
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
      super.relevantConditions,
      super.titleIconAnimationFile,
      this.onBeforeFinishCallback,
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
        resultFormat ??= ResultFormat.date("", "dd-MM-yyyy HH:mm:ss a");
    return _CompletionStepView(formKitForm, this, text,
        title: title,
        display: display,
        autoTrigger: autoTrigger ?? false,
        onBeforeFinishCallback: onBeforeFinishCallback);
  }
}

// ignore: must_be_immutable
class _CompletionStepView extends InputWidgetView<CompletionStep> {
  final OnBeforeFinishCallback? onBeforeFinishCallback;
  final bool autoTrigger;
  _CompletionStepView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.title,
    this.onBeforeFinishCallback,
    required this.autoTrigger,
    super.display = Display.normal,
  });
  final GlobalKey<State> loadingKey = GlobalKey<State>();
  bool isCompleted = false;
  bool isLoading = true;
  @override
  Widget? buildWInputWidget(BuildContext context, CompletionStep formStep) {
    if (autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        onFinish();
      });
    }
    return StatefulBuilder(
        key: loadingKey,
        builder: (context, state) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200.0,
              maxWidth: 200.0,
            ),
            child: isLoading
                ? Lottie.asset(
                    'packages/formstack/assets/lottiefiles/loading.json')
                : isCompleted
                    ? Lottie.asset(
                        'packages/formstack/assets/lottiefiles/success.json')
                    : Lottie.asset(
                        'packages/formstack/assets/lottiefiles/failed.json'),
          );
        });
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  Future<bool> onBeforeFinish() async {
    if (onBeforeFinishCallback != null) {
      isLoading = true;
      isCompleted = await onBeforeFinishCallback!.call();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      isCompleted = await super.onBeforeFinish();
    }

    isLoading = false;
    // ignore: invalid_use_of_protected_member
    loadingKey.currentState!.setState(() {});
    return Future.value(isCompleted);
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
