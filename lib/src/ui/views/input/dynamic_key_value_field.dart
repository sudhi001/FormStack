import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class DynamicKeyValueWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final int maxCount;
  DynamicKeyValueWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, required this.maxCount});

  final List<KeyValue?> _result = [];
  final List<TextEditingController?> _keycontrollers = [];
  final List<TextEditingController?> _valuecontrollers = [];
  List<Widget> textFields = [];
  int index = 1;
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      _result.clear();
      _result.addAll(formStep.result);
    }

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
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 400),
        child: StatefulBuilder(builder: (context, setState) {
          textFields = List.generate(index, (int i) {
            _keycontrollers.add(TextEditingController());
            _valuecontrollers.add(TextEditingController());
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: generateTextFields(context, i == 0, i, setState),
            );
          });
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(child: Column(children: textFields)),
          );
        }));
  }

  Widget generateTextFields(
      BuildContext context, bool primary, int ind, setState) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
          child: _buildTextField(
              context: context, name: "Key", isKey: true, index: ind)),
      Expanded(
          child: _buildTextField(
              context: context, name: "Value", isKey: false, index: ind)),
      Container(
          decoration: BoxDecoration(
              color: primary ? Colors.green : Colors.red,
              shape: BoxShape.circle),
          child: IconButton(
            onPressed: () {
              setState(() {
                if (primary) {
                  index++;
                } else {
                  index--;
                }
              });
            },
            icon: Icon(primary ? Icons.add : Icons.remove, color: Colors.white),
          ))
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _keycontrollers) {
      controller?.dispose();
    }
    for (var controller in _valuecontrollers) {
      controller?.dispose();
    }
  }

  Widget _buildTextField(
      {required BuildContext context,
      required String name,
      required bool isKey,
      required int index}) {
    return Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        child: TextFormField(
          autofocus: true,
          enabled: !formStep.disabled,
          autocorrect: false,
          minLines: 1,
          controller: isKey ? _keycontrollers[index] : _valuecontrollers[index],
          maxLines: 1,
          keyboardType: TextInputType.text,
          validator: (input) => !isKey
              ? null
              : _keycontrollers[index]!.text.isEmpty
                  ? "Cannot Be emepty"
                  : null,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z@.]"))
          ],
          decoration: InputDecoration(
              enabledBorder: inputBoder(),
              border: inputBoder(),
              labelText: name,
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
    _result.clear();
    for (int i = 0; i < index; i++) {
      if (_keycontrollers[i] != null) {
        _result.add(KeyValue(_keycontrollers[i]!.text.trim(),
            _valuecontrollers[i]!.text.trim()));
      }
    }

    return resultFormat.isValid(_result);
  }

  @override
  String validationError() {
    return resultFormat.error();
  }

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() {
    return _result;
  }

  @override
  void clearFocus() {}
}
