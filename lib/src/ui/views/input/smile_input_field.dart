import 'package:flutter/material.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/step/question_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:reviews_slider/reviews_slider.dart';

// ignore: must_be_immutable
class SmileInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  SmileInputWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});

  final FocusNode _focusNode = FocusNode();
  int value = 0;
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      value = formStep.result;
    } else {
      value = 2;
    }

    return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ReviewSlider(
              onChange: (int value) => this.value = value, initialValue: value),
        ));
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    return resultFormat.isValid(value);
  }

  @override
  String validationError() {
    _focusNode.requestFocus();
    return resultFormat.error();
  }

  @override
  void requestFocus() {
    _focusNode.requestFocus();
  }

  @override
  dynamic resultValue() {
    return value;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}
