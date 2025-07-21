import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:quill_html_editor_v2/quill_html_editor_v2.dart';

// ignore: must_be_immutable
class HTMLWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  HTMLWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});
  final controller = QuillEditorController();
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    controller.onTextChanged((text) {
      formStep.result = text;
    });
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
          ToolBar.scroll(
            padding: const EdgeInsets.all(8),
            iconSize: 25,
            controller: controller,
            crossAxisAlignment: CrossAxisAlignment.center,
            direction: Axis.horizontal,
          ),
          Expanded(
            child: QuillHtmlEditor(
              text: formStep.result,
              hintText: 'Type here',
              controller: controller,
              isEnabled: true,
              minHeight: 200,
              hintTextAlign: TextAlign.start,
              padding: const EdgeInsets.only(left: 10, top: 10),
              hintTextPadding: const EdgeInsets.only(left: 20),
              onFocusChanged: (hasFocus) => debugPrint('has focus $hasFocus'),
              onTextChanged: (text) => debugPrint('widget text change $text'),
              onEditorCreated: () {
                debugPrint('Editor has been loaded');
              },
              onEditorResized: (height) => debugPrint('Editor resized $height'),
              onSelectionChanged: (sel) =>
                  debugPrint('index ${sel.index}, range ${sel.length}'),
            ),
          ),
        ],
      ),
    );
  }

  void unFocusEditor() => controller.unFocus();
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
