import 'package:file_picker/file_picker.dart';
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
  final List<dynamic> filter;
  TextFieldInputWidgetView(super.formKitForm, super.formStep, super.text,
      this.resultFormat, this.formatter,
      {super.key,
      super.title,
      this.keyboardType = TextInputType.none,
      this.numberOfLines = 1,
      this.filter = const [],
      this.textCapitalization = TextCapitalization.none});

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  FilePickerResult? fileResult;
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      if (formStep.inputType == InputType.file) {
        _controller.text = cast<PlatformFile>(formStep.result)!.name;
      } else {
        _controller.text = formStep.result;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
    return Container(
        color: formStep.inputStyle != InputStyle.basic
            ? const Color.fromRGBO(242, 242, 247, 1)
            : null,
        decoration: formStep.inputStyle == InputStyle.basic
            ? const BoxDecoration(
                color: Color.fromRGBO(242, 242, 247, 1),
                border: Border(
                    top: BorderSide(color: Colors.grey),
                    bottom: BorderSide(color: Colors.grey)),
              )
            : null,
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, minHeight: 50),
        child: _buildComponent(context));
  }

  Widget _buildComponent(BuildContext context) {
    return TextFormField(
      autofocus: true,
      enabled: !formStep.disabled,
      readOnly: formStep.inputType == InputType.file,
      enableInteractiveSelection:
          formStep.inputType == InputType.file ? false : true,
      autocorrect: false,
      minLines: numberOfLines,
      maxLines: numberOfLines,
      obscureText: keyboardType == TextInputType.visiblePassword,
      focusNode: formStep.inputType == InputType.file ? null : _focusNode,
      controller: _controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onTap: formStep.inputType == InputType.file ? suffixButtonClick : null,
      validator: (input) =>
          resultFormat.isValid(_controller.text) ? null : validationError(),
      inputFormatters: formatter,
      decoration: InputDecoration(
          enabledBorder: inputBoder(),
          border: inputBoder(),
          suffixIcon: formStep.inputType == InputType.file
              ? IconButton(
                  focusNode: _focusNode,
                  onPressed: suffixButtonClick,
                  icon: const Icon(Icons.file_open))
              : null,
          hintText: formStep.hint,
          labelText: formStep.label,
          hintStyle: Theme.of(context).textTheme.bodySmall),
    );
  }

  void suffixButtonClick() async {
    if (filter.isEmpty) {
      fileResult = await FilePicker.platform.pickFiles();
    } else {
      fileResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: filter.map((item) => item as String).toList());
    }

    _controller.text = fileResult?.files.single.name ?? "";
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
    if (formStep.isOptional ?? false) {
      return true;
    }
    if (formStep.inputType == InputType.file) {
      return resultFormat.isValid(fileResult?.files.single);
    }
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
    if (formStep.inputType == InputType.file) {
      return fileResult?.files.single;
    }
    return _controller.text;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}
