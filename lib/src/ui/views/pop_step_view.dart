import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/pop_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class PopStepView extends BaseStepView<PopStep> {
  PopStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, super.display = Display.normal, cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, PopStep formStep) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.pop(context);
    });
    return Container();
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
    return null;
  }

  @override
  void clearFocus() {}
}
