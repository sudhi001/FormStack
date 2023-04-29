import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class OTPInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final int count;
  OTPInputWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, required this.count});

  final List<TextEditingController?> _textControllers = [];
  final List<FocusNode?> _focusNodes = [];
  final List<String?> _verificationCode = [];
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      if (formStep.result is int) {
        var iStr = formStep.result.toString().split('');
        _verificationCode.addAll(iStr);
      }
    }

    return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: generateTextFields(context),
        ));
  }

  Widget generateTextFields(BuildContext context) {
    _textControllers.clear();
    _focusNodes.clear();
    _verificationCode.clear();
    List<Widget> textFields = List.generate(count, (int i) {
      _textControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _verificationCode.add("");
      return _buildTextField(context: context, index: i);
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: textFields);
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _textControllers) {
      controller?.dispose();
    }
  }

  Widget _buildTextField({required BuildContext context, required int index}) {
    return Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        child: TextFormField(
          autofocus: true,
          enabled: !formStep.disabled,
          autocorrect: false,
          minLines: 1,
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          controller: _textControllers[index],
          maxLines: 1,
          onEditingComplete: () {
            _focusNodes[index + 1]?.requestFocus();
          },
          onChanged: (value) {
            _verificationCode[index] = value;
            if (index >= count - 1) {
              onNextButtonClick();
            } else {
              _focusNodes[index]?.unfocus();
              _focusNodes[index + 1]?.requestFocus();
            }
          },
          keyboardType: TextInputType.number,
          validator: (input) =>
              resultFormat.isValid(_textControllers[index]!.text)
                  ? null
                  : validationError(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
            LengthLimitingTextInputFormatter(1)
          ],
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
    return resultFormat.isValid(int.parse(_verificationCode.join("")));
  }

  @override
  String validationError() {
    _focusNodes[0]?.requestFocus();
    return resultFormat.error();
  }

  @override
  void requestFocus() {
    _focusNodes[0]?.requestFocus();
  }

  @override
  dynamic resultValue() {
    return int.parse(_verificationCode.join(""));
  }

  @override
  void clearFocus() {
    for (var focusNode in _focusNodes) {
      focusNode?.unfocus();
    }
  }
}
