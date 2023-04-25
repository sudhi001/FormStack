import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/step/question_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class TextFieldInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final List<TextInputFormatter> formatter;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final int? numberOfLines;
  TextFieldInputWidgetView(super.formKitForm, super.formStep, super.text,
      this.resultFormat, this.formatter,
      {super.key,
      super.title,
      this.keyboardType = TextInputType.none,
      this.numberOfLines = 1,
      this.textCapitalization = TextCapitalization.none});

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      _controller.text = formStep.result;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
    return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
        child: TextFormField(
          autofocus: true,
          autocorrect: false,
          minLines: numberOfLines,
          maxLines: numberOfLines,
          obscureText: keyboardType == TextInputType.visiblePassword,
          focusNode: _focusNode,
          controller: _controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: (input) =>
              resultFormat.isValid(_controller.text) ? null : validationError(),
          inputFormatters: formatter,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ));
  }

  @override
  bool isValid() {
    return resultFormat.isValid(_controller.text);
  }

  @override
  String validationError() {
    _focusNode.requestFocus();
    return resultFormat.error();
  }

  @override
  dynamic resultValue() {
    return _controller.text;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}
