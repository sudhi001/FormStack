import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
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
        decoration: formStep.inputStyle == InputStyle.basic
            ? const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
              )
            : null,
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, minHeight: 50),
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
          decoration: InputDecoration(
              enabledBorder: inputBoder(),
              border: inputBoder(),
              hintText: formStep.hint,
              labelText: formStep.label,
              hintStyle: Theme.of(context).textTheme.bodySmall),
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
    return resultFormat.isValid(_controller.text);
  }

  @override
  void requestFocus() {
    _focusNode.requestFocus();
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
