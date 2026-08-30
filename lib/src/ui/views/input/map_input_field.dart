import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class MapWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final double maxHeight;
  MapWidgetView(
    super.formStackForm,
    super.formStep,
    super.text,
    this.resultFormat, {
    super.key,
    super.title,
    this.maxHeight = 600,
  });
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStackForm.mapKey.web.isEmpty) {
      return const Text("Google map WEB  key is empty");
    }
    if (formStackForm.mapKey.android.isEmpty) {
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
      constraints: BoxConstraints(
        minWidth: 300,
        maxWidth: 1200,
        maxHeight: maxHeight,
      ),
      child: MapWidget(
        formStackForm.mapKey,
        formStackForm.initialLocation,
        (location) => formStep.result = location,
      ),
    );
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
