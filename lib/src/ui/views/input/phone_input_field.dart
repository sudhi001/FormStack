import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class PhoneInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final String defaultCountryCode;

  PhoneInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.defaultCountryCode = "+1"});

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _countryCode = "+1";
  bool _isInitialized = false;
  bool _hasRequestedFocus = false;

  static const List<String> _countryCodes = [
    "+1",
    "+44",
    "+91",
    "+61",
    "+81",
    "+86",
    "+49",
    "+33",
    "+39",
    "+55",
    "+7",
    "+82",
    "+34",
    "+46",
    "+31",
    "+47",
    "+48",
    "+90",
    "+966",
    "+971",
    "+65",
    "+60",
    "+62",
    "+63",
    "+66",
    "+84",
    "+92",
    "+94",
    "+880",
    "+20",
    "+27",
    "+234",
    "+254",
    "+255",
  ];

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _countryCode = defaultCountryCode;
      if (formStep.result is String) {
        final result = formStep.result as String;
        // Try to split country code from number
        for (final code in _countryCodes) {
          if (result.startsWith(code)) {
            _countryCode = code;
            _controller.text = result.substring(code.length);
            break;
          }
        }
      }
      _isInitialized = true;
    }

    if (!_hasRequestedFocus) {
      _hasRequestedFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
      child: StatefulBuilder(builder: (context, setState) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _countryCode,
                  items: _countryCodes
                      .map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(code,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ))
                      .toList(),
                  onChanged: formStep.disabled
                      ? null
                      : (value) {
                          setState(() {
                            _countryCode = value ?? _countryCode;
                            formStep.result =
                                '$_countryCode${_controller.text}';
                          });
                        },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !formStep.disabled,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                onChanged: (value) {
                  formStep.result = '$_countryCode$value';
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: formStep.hint ?? "Phone number",
                  labelText: formStep.label,
                ),
              ),
            ),
          ],
        );
      }),
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
    return resultFormat.isValid('$_countryCode${_controller.text}');
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() => _focusNode.requestFocus();

  @override
  dynamic resultValue() => '$_countryCode${_controller.text}';

  @override
  void clearFocus() => _focusNode.unfocus();
}
