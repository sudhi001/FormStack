import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class MapWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final double maxHeight;
  MapWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.maxHeight = 600});
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formKitForm.mapKey.web.isEmpty) {
      return const Text("Google map WEB  key is empty");
    }
    if (formKitForm.mapKey.android.isEmpty) {
      return const Text("Google map Android  key is empty");
    }
    return Container(
        decoration: formStep.componentsStyle == ComponentsStyle.basic
            ? const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
              )
            : null,
        constraints:
            BoxConstraints(minWidth: 300, maxWidth: 1200, maxHeight: maxHeight),
        child: MapWidget(formKitForm.mapKey, formKitForm.initialLocation,
            (p0) => {formStep.result = p0}));
  }

  InputBorder inputBoder() {
    switch (formStep.inputStyle) {
      case InputStyle.basic:
        return InputBorder.none;
      case InputStyle.outline:
        return const OutlineInputBorder();
      case InputStyle.underLined:
        return const UnderlineInputBorder();
      default:
        return InputBorder.none;
    }
  }

  @override
  bool isValid() {
    return resultFormat.isValid(formStep.result);
  }

  @override
  String validationError() {
    return resultFormat.error();
  }

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() {
    return formStep.result;
  }

  @override
  void clearFocus() {}
}
