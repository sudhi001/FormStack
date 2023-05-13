import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:html_editor_enhanced/html_editor.dart';

// ignore: must_be_immutable
class HTMLWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  HTMLWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});
  final controller = HtmlEditorController();
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
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 1200, maxHeight: 400),
        child: HtmlEditor(
          controller: controller, //required
          htmlEditorOptions: HtmlEditorOptions(
              spellCheck: true, initialText: formStep.result ?? '', hint: ''),
          callbacks: Callbacks(
            onChangeContent: (p0) {
              formStep.result = p0;
            },
          ),
        ));
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
