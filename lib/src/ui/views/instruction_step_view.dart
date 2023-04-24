import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class InstructionStepView extends BaseStepView<InstructionStep> {
  InstructionStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, super.display = Display.normal, cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, InstructionStep formStep) {
    return null;
  }

  @override
  bool isValid() {
    return true;
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
