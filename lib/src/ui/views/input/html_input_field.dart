import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class HTMLWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  HTMLWidgetView(
    super.formStackForm,
    super.formStep,
    super.text,
    this.resultFormat, {
    super.key,
    super.title,
  });

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    return Container(
      decoration: formStep.componentsStyle == ComponentsStyle.basic
          ? const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey),
                bottom: BorderSide(color: Colors.grey),
              ),
            )
          : null,
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 1200,
        maxHeight: 300,
      ),
      child: const Column(
        children: [
          Text(
            'HTML Editor temporarily disabled due to flutter_quill compatibility issues',
          ),
        ],
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
