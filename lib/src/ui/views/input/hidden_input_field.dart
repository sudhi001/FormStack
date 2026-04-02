import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Hidden field that stores data without rendering any UI.
/// Used for metadata, calculated values, or pre-set data.
// ignore: must_be_immutable
class HiddenInputWidgetView extends BaseStepView<QuestionStep> {
  HiddenInputWidgetView(super.formStackForm, super.formStep, super.text,
      {super.key, super.title});

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) {
    // Auto-advance hidden fields immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onNextButtonClick();
    });
    return const SizedBox.shrink();
  }

  @override
  bool isValid() => true;

  @override
  String validationError() => "";

  @override
  dynamic resultValue() => formStep.result ?? formStep.defaultValue;

  @override
  void requestFocus() {}

  @override
  void clearFocus() {}
}
