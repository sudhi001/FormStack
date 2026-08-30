import 'package:flutter/material.dart';
import 'package:formstack/src/step/pop_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class PopStepView extends BaseStepView<PopStep> {
  PopStepView(
    super.formStackForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
    cancellable,
  });

  @override
  Widget? buildWInputWidget(BuildContext context, PopStep formStep) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // The view can be gone before the frame lands, and a form rendered at
      // the root of the app has nothing to pop -- both threw.
      if (isDisposed || !context.mounted) return;
      final navigator = Navigator.maybeOf(context);
      if (navigator?.canPop() ?? false) navigator!.pop();
    });
    return const SizedBox.shrink();
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
  Null resultValue() {
    return null;
  }

  @override
  void clearFocus() {}

  @override
  void requestFocus() {}
}
