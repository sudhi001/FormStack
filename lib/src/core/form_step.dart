import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formstack/src/core/identifiers.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';

abstract class FormStep<T> extends LinkedListEntry<FormStep> {
  bool isOptional;
  bool cancellable;
  Identifier? id;
  dynamic result;
  ResultFormat? resultFormat;

  FormStep(
      {this.id,
      this.isOptional = false,
      this.cancellable = true,
      this.resultFormat}) {
    id ??= StepIdentifier();
  }
  FormStepView buildView(FormStackForm formKitForm);
}

abstract class FormStepView<T extends FormStep> extends StatelessWidget {
  final String? title;
  final String? text;
  final String? hint;
  final String previousButtonText;
  final String nextButtonText;
  final String cancelButtonText;
  final String skipButtonText;
  final FormStackForm formKitForm;
  final T formStep;
  const FormStepView(this.formKitForm, this.formStep, this.text,
      {super.key,
      this.hint = "",
      this.title,
      this.previousButtonText = "Back",
      this.nextButtonText = "Next",
      this.cancelButtonText = "Cancel",
      this.skipButtonText = "Skip"});

  Widget buildWithFrom(BuildContext context, T formStep);

  void onNext();
  void onBack();
  void onCancel();

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
    super.previousButtonText = "Back",
    super.nextButtonText = "Next",
    super.cancelButtonText = "Cancel",
    super.skipButtonText = "Skip",
  });

  final GlobalKey<State> errorKey = GlobalKey<State>();
  bool showError = false;
  @override
  Widget buildWithFrom(BuildContext context, T formStep) {
    Widget? inputWidget = buildWInputWidget(context, formStep);
    return Scaffold(
        appBar: formStep.cancellable
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                actions: [
                  IconButton(
                    constraints: const BoxConstraints.expand(width: 80),
                    icon: Text(cancelButtonText),
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
                    if (title != null) ...[
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
                    Text(text ?? "",
                        style: display == Display.medium
                            ? Theme.of(context).textTheme.titleLarge
                            : (display == Display.large
                                ? Theme.of(context).textTheme.headlineSmall
                                : (display == Display.extraLarge
                                    ? Theme.of(context).textTheme.headlineSmall
                                    : Theme.of(context).textTheme.bodyLarge)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 14),
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
        bottomNavigationBar: nextButtonText.isNotEmpty
            ? SafeArea(
                child: SizedBox(
                  height: kToolbarHeight * 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 3),
                      child: CupertinoButton(
                        color: Colors.blue,
                        onPressed: onNext,
                        child: Text(nextButtonText),
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
