import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
// import 'package:flutter_quill/flutter_quill.dart';

// ignore: must_be_immutable
class HTMLWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  HTMLWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});
  // final controller = QuillController.basic();
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    // Listen to document changes and update formStep result
    // controller.addListener(() {
    //   final text = controller.document.toPlainText();
    //   formStep.result = text;
    // });

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
          const BoxConstraints(minWidth: 300, maxWidth: 1200, maxHeight: 300),
      child: Column(
        children: [
          // QuillEditor.basic(
          //   controller: controller,
          // ),
          Text(
              'HTML Editor temporarily disabled due to flutter_quill compatibility issues'),
        ],
      ),
    );
  }

  void unFocusEditor() {
    // Clear selection and move cursor to end
    // controller.updateSelection(
    //   TextSelection.collapsed(offset: controller.document.length),
    //   ChangeSource.local,
    // );
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

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }
}
