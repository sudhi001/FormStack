import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class CurrencyInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final String currencySymbol;

  CurrencyInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.currencySymbol = "\$"});

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasRequestedFocus = false;
  bool _hasRestoredResult = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_hasRestoredResult) {
      _hasRestoredResult = true;
      if (formStep.result != null) {
        _controller.text = formStep.result.toString();
      }
    }

    if (!_hasRequestedFocus) {
      _hasRequestedFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: !formStep.disabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onChanged: (value) {
          formStep.result = value;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          prefixText: '$currencySymbol ',
          prefixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          hintText: formStep.hint ?? "0.00",
          labelText: formStep.label,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_controller.text);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() => _focusNode.requestFocus();

  @override
  dynamic resultValue() => _controller.text;

  @override
  void clearFocus() => _focusNode.unfocus();
}
