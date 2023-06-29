import 'package:flutter/material.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:formstack/src/ui/views/tiles_view.dart';
import 'package:formstack/src/ui/views/web_view.dart';

// ignore: must_be_immutable
class DisplayStepView extends BaseStepView<DisplayStep> {
  DisplayStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, DisplayStep formStep) {
    switch (formStep.displayStepType) {
      case DisplayStepType.listTile:
        return ListTitlesView.buildView(context, formStep);
      case DisplayStepType.web:
      default:
        return WebViewBuild.buildView(context, formStep);
    }
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
  void requestFocus() {}
  @override
  void clearFocus() {}
}
