import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/src/form_step.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
abstract class BaseStepView<T extends FormStep> extends FormStepView<T> {
  final Display display;
  BaseStepView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
    this.display = Display.normal,
  });

  final GlobalKey<State> errorKey = GlobalKey<State>();
  bool showError = false;
  @override
  Widget buildWithFrom(BuildContext context, T formStep) {
    Widget? inputWidget = buildWInputWidget(context, formStep);
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: (formStep.cancellable ?? false)
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                actions: [
                  IconButton(
                    constraints: const BoxConstraints.expand(width: 80),
                    icon: Text(formStep.cancelButtonText ?? "Cancel"),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onBack();
                    },
                  ),
                ],
              )
            : null,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (formStep.titleIconAnimationFile != null) ...[
                      Container(
                          constraints: BoxConstraints(
                              minWidth: 75,
                              maxWidth: formStep.titleIconMaxWidth ?? 300,
                              minHeight: 75,
                              maxHeight: formStep.titleIconMaxWidth ?? 300),
                          child:
                              Lottie.asset(formStep.titleIconAnimationFile!)),
                      const SizedBox(height: 7)
                    ],
                    if (title != null && title!.isNotEmpty) ...[
                      Text(title ?? "",
                          style: display == Display.medium
                              ? Theme.of(context).textTheme.headlineMedium
                              : (display == Display.large
                                  ? Theme.of(context).textTheme.headlineLarge
                                  : (display == Display.extraLarge
                                      ? Theme.of(context).textTheme.displaySmall
                                      : Theme.of(context)
                                          .textTheme
                                          .headlineSmall)),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 7)
                    ],
                    if (text != null && text!.isNotEmpty) ...[
                      Text(text ?? "",
                          style: display == Display.medium
                              ? Theme.of(context).textTheme.titleLarge
                              : (display == Display.large
                                  ? Theme.of(context).textTheme.headlineSmall
                                  : (display == Display.extraLarge
                                      ? Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                      : Theme.of(context).textTheme.bodyLarge)),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 14),
                    ],
                    StatefulBuilder(
                        key: errorKey,
                        builder: (context, setState) {
                          return Text(
                            showError ? validationError() : "",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .apply(color: Colors.red.shade900),
                          );
                        }),
                    const SizedBox(height: 7),
                    if (inputWidget != null) ...[
                      inputWidget,
                      const SizedBox(height: 7),
                    ],
                    Text(hint ?? "",
                        style: display == Display.medium
                            ? Theme.of(context).textTheme.bodyMedium
                            : (display == Display.large
                                ? Theme.of(context).textTheme.bodyLarge
                                : (display == Display.extraLarge
                                    ? Theme.of(context).textTheme.bodyLarge
                                    : Theme.of(context).textTheme.bodySmall)),
                        textAlign: TextAlign.center),
                  ]),
            ),
          ),
        ),
        bottomNavigationBar: (formStep.nextButtonText?.isNotEmpty ?? true)
            ? SafeArea(
                child: SizedBox(
                  height: kToolbarHeight * 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              onNextButtonClick();
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 50),
                                maximumSize: const Size(400, 70)),
                            child: Text(formStep.nextButtonText ?? "Next")),
                      ],
                    ),
                  ),
                ),
              )
            : null);
  }

  bool isValid();
  String validationError();
  dynamic resultValue();
  bool isProcessing = false;
  Widget? buildWInputWidget(BuildContext context, T formStep);

  @override
  void onBack() {
    clearFocus();
    formStep.result = resultValue();
    formKitForm.backStep(formStep);
  }

  @override
  void onCancel() {
    formKitForm.cancelStep(formStep);
  }

  @override
  void onNextButtonClick() async {
    if (isProcessing) return;
    setLoading(true);
    formStep.result = resultValue();
    formKitForm.generateResult();
    await onBeforeFinish(formKitForm.result);
    setLoading(false);
    onNext();
  }

  @override
  void onLoding(bool isLoading) {}

  void setLoading(bool isLoading) {
    isProcessing = isLoading;
    onLoding(isProcessing);
  }

  @override
  Future<bool> onBeforeFinish(Map<String, dynamic> result) {
    return Future.value(true);
  }

  @override
  void onNext() {
    if (formStep.isOptional ?? false) {
      clearFocus();
      formKitForm.nextStep(formStep);
    } else if (isValid()) {
      clearFocus();
      formKitForm.nextStep(formStep);
    } else {
      // ignore: invalid_use_of_protected_member
      errorKey.currentState!.setState(() {
        showError = true;
      });
      formKitForm.validationError(validationError());
    }
  }

  void clearFocus();
}
