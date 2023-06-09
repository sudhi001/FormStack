// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class CompletionStepView extends BaseStepView<CompletionStep> {
  final OnBeforeFinishCallback? onBeforeFinishCallback;
  final bool autoTrigger;
  CompletionStepView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
    this.onBeforeFinishCallback,
    required this.autoTrigger,
  });
  final GlobalKey<State> loadingKey = GlobalKey<State>();
  bool isCompleted = false;
  bool isLoading = true;
  @override
  Widget? buildWInputWidget(BuildContext context, CompletionStep formStep) {
    if (autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        onNextButtonClick();
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
                ? Lottie.asset(formStep.loadingLottieAssetsFilePath ??
                    'packages/formstack/assets/lottiefiles/loading.json')
                : isCompleted
                    ? Lottie.asset(formStep.successLottieAssetsFilePath ??
                        'packages/formstack/assets/lottiefiles/success.json')
                    : Lottie.asset(formStep.errorLottieAssetsFilePath ??
                        'packages/formstack/assets/lottiefiles/failed.json'),
          );
        });
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  Future<bool> onBeforeFinish(Map<String, dynamic> result) async {
    if (onBeforeFinishCallback != null) {
      isLoading = true;
      isCompleted = await onBeforeFinishCallback!.call(result);
    } else {
      await Future.delayed(const Duration(milliseconds: 90));
      isCompleted = await super.onBeforeFinish(result);
    }

    isLoading = false;
    // ignore: invalid_use_of_protected_member
    loadingKey.currentState!.setState(() {});
    await Future.delayed(const Duration(seconds: 1));
    return Future.value(isCompleted);
  }

  @override
  String validationError() {
    return "";
  }

  @override
  void requestFocus() {}
  @override
  resultValue() {
    return DateTime.now().toUtc();
  }

  @override
  void clearFocus() {}
}
