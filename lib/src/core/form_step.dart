import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formstack/src/core/identifiers.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';
import 'package:lottie/lottie.dart';

abstract class FormStep<T> extends LinkedListEntry<FormStep> {
  bool isOptional;
  bool cancellable;
  Identifier? id;
  dynamic result;
  ResultFormat? resultFormat;
  String nextButtonText;
  String? titleIconAnimationFile;
  String backButtonText;
  String cancelButtonText;
  List<RelevantCondition>? relevantConditions;

  FormStep(
      {this.id,
      this.isOptional = false,
      this.cancellable = true,
      this.nextButtonText = "Next",
      this.backButtonText = "Back",
      this.titleIconAnimationFile,
      this.relevantConditions,
      this.cancelButtonText = "Cancel",
      this.resultFormat}) {
    id ??= StepIdentifier();
  }
  FormStepView buildView(FormStackForm formKitForm);
}

abstract class FormStepView<T extends FormStep> extends StatelessWidget {
  final String? title;
  final String? text;
  final String? hint;
  final FormStackForm formKitForm;
  final T formStep;
  const FormStepView(this.formKitForm, this.formStep, this.text,
      {super.key, this.hint = "", this.title});

  Widget buildWithFrom(BuildContext context, T formStep);

  void onNext();
  void onBack();
  void onCancel();
  void onFinish();
  void onLoding(bool isLoading);
  Future<bool> onBeforeFinish();

  @override
  Widget build(BuildContext context) {
    return buildWithFrom(context, formStep);
  }
}

enum Display { normal, medium, large, extraLarge }

// ignore: must_be_immutable
abstract class InputWidgetView<T extends FormStep> extends FormStepView<T> {
  final Display display;
  InputWidgetView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.key,
    super.hint = "",
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
        appBar: formStep.cancellable
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                actions: [
                  IconButton(
                    constraints: const BoxConstraints.expand(width: 80),
                    icon: Text(formStep.cancelButtonText),
                    onPressed: onCancel,
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
                          constraints: const BoxConstraints(
                              minWidth: 75,
                              maxWidth: 300,
                              minHeight: 75,
                              maxHeight: 300),
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
        bottomNavigationBar: formStep.nextButtonText.isNotEmpty
            ? SafeArea(
                child: SizedBox(
                  height: kToolbarHeight * 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 3),
                      child: CupertinoButton(
                        color: Colors.blue,
                        onPressed: onFinish,
                        child: Text(formStep.nextButtonText),
                      ),
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
  void onFinish() async {
    if (isProcessing) return;
    setLoading(true);
    if (await onBeforeFinish()) {
      setLoading(false);
      onNext();
    }
  }

  @override
  void onLoding(bool isLoading) {}

  void setLoading(bool isLoading) {
    isProcessing = isLoading;
    onLoding(isProcessing);
  }

  @override
  Future<bool> onBeforeFinish() {
    return Future.value(true);
  }

  @override
  void onNext() {
    formStep.result = resultValue();
    if (isValid()) {
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
