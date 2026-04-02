import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class ConsentInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final String consentText;

  ConsentInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key,
      super.title,
      this.consentText = "I agree to the terms and conditions"});

  bool _isChecked = false;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _isChecked = formStep.result == true;
      _isInitialized = true;
    }

    return Container(
      constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
      child: StatefulBuilder(builder: (context, setState) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: formStep.disabled
              ? null
              : () {
                  setState(() {
                    _isChecked = !_isChecked;
                    formStep.result = _isChecked;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: formStep.disabled
                      ? null
                      : (value) {
                          setState(() {
                            _isChecked = value ?? false;
                            formStep.result = _isChecked;
                          });
                        },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    consentText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_isChecked);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _isChecked;

  @override
  void clearFocus() {}
}
