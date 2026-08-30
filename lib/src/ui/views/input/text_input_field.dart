import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/input_border_style.dart';

// ignore: must_be_immutable
class TextFieldInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final List<TextInputFormatter> formatter;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final int? numberOfLines;
  final List<dynamic> filter;
  TextFieldInputWidgetView(
    super.formStackForm,
    super.formStep,
    super.text,
    this.resultFormat,
    this.formatter, {
    super.key,
    super.title,
    this.keyboardType = TextInputType.none,
    this.numberOfLines = 1,
    this.filter = const [],
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  PlatformFile? pickedFile;
  bool _hasRequestedFocus = false;
  bool _hasRestoredResult = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    // Sync controller with formStep result only on first build
    if (!_hasRestoredResult) {
      _hasRestoredResult = true;
      if (formStep.result != null) {
        if (formStep.inputType == InputType.file) {
          final restored = cast<PlatformFile>(formStep.result);
          if (restored != null) {
            pickedFile = restored;
            _controller.text = restored.name;
          }
        } else {
          _controller.text = formStep.result.toString();
        }
      }
    }

    // Only request focus once if not a file input
    if (!_hasRequestedFocus && formStep.inputType != InputType.file) {
      _hasRequestedFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // The view can be disposed before the frame lands -- an auto-advancing
        // step, or a fast tap -- and focusing a disposed FocusNode throws.
        if (isDisposed) return;
        _focusNode.requestFocus();
      });
    }
    return Container(
      decoration: formStep.inputStyle == InputStyle.basic
          ? BoxDecoration(
              color: FormStackTheme.surfaceColor(context),
              border: Border(
                top: BorderSide(color: FormStackTheme.borderColor(context)),
                bottom: BorderSide(color: FormStackTheme.borderColor(context)),
              ),
            )
          : null,
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 400,
        minHeight: 50,
      ),
      child: _buildComponent(context),
    );
  }

  Widget _buildComponent(BuildContext context) {
    return TextFormField(
      autofocus: true,
      textAlign: formStep.textAlign,
      enabled: !formStep.disabled,
      readOnly: formStep.inputType == InputType.file,
      enableInteractiveSelection: formStep.inputType == InputType.file
          ? false
          : true,
      autocorrect: false,
      minLines: numberOfLines,
      maxLines: numberOfLines,
      obscureText: keyboardType == TextInputType.visiblePassword,
      focusNode: formStep.inputType == InputType.file ? null : _focusNode,
      controller: _controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onTap: formStep.inputType == InputType.file ? suffixButtonClick : () {},
      onChanged: (value) {
        formStep.result = value;
      },
      validator: (input) =>
          resultFormat.isValid(input ?? '') ? null : validationError(),
      inputFormatters: formatter,
      decoration: InputDecoration(
        border: formStep.inputStyle.toInputBorder(style: formStep.style),
        enabledBorder: formStep.inputStyle.toInputBorder(style: formStep.style),
        suffixIcon: formStep.inputType == InputType.file
            ? IconButton(
                focusNode: _focusNode,
                onPressed: suffixButtonClick,
                icon: const Icon(Icons.file_open),
              )
            : null,
        hintText: formStep.hint,
        labelText: formStep.label,
        hintStyle: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void suffixButtonClick() async {
    pickedFile = filter.isEmpty
        ? await FilePicker.pickFile()
        : await FilePicker.pickFile(
            type: FileType.custom,
            allowedExtensions: filter.map((item) => item as String).toList(),
          );

    if (pickedFile != null) {
      _controller.text = pickedFile!.name;
      formStep.result = pickedFile;
    } else {
      // A cancelled pick leaves any previous selection in place rather than
      // silently clearing the answer the user already gave.
      if (formStep.result == null) _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    if (formStep.inputType == InputType.file) {
      return resultFormat.isValid(pickedFile ?? formStep.result);
    }
    return resultFormat.isValid(_controller.text.trim());
  }

  @override
  void requestFocus() {
    _focusNode.requestFocus();
  }

  @override
  String validationError() {
    return resultFormat.error();
  }

  @override
  dynamic resultValue() {
    if (formStep.inputType == InputType.file) {
      return pickedFile ?? formStep.result;
    }
    return _controller.text;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}
