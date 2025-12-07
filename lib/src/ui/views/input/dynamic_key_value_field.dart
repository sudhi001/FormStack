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

  final List<KeyValue> _result = [];
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _valueControllers = [];
  int _fieldCount = 1;
  dynamic _lastFormStepResult;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (_lastFormStepResult != formStep.result) {
      _initializeFromFormStep(formStep);
      _ensureControllersExist();
      _lastFormStepResult = formStep.result;
    } else {
      _ensureControllersExist();
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
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 300),
        child: StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_fieldCount, (int i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: _generateTextFields(context, i == 0, i, setState),
                  );
                }),
              ),
            ),
          );
        }));
  }

  Widget _generateTextFields(
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
                if (primary && _fieldCount < maxCount) {
                  _addField();
                } else if (!primary && _fieldCount > 1) {
                  _removeField(ind);
                }
              });
            },
            icon: Icon(primary ? Icons.add : Icons.remove, color: Colors.white),
          ))
    ]);
  }

  void _initializeFromFormStep(QuestionStep formStep) {
    // Ensure _result is initialized
    _result.clear();

    if (formStep.result != null && formStep.result is List) {
      List<dynamic> resultList = formStep.result as List;
      _fieldCount = resultList.isNotEmpty ? resultList.length : 1;

      for (var item in resultList) {
        if (item is Map) {
          _result.add(KeyValue(item["key"] ?? "", item["value"] ?? ""));
        } else if (item is KeyValue) {
          _result.add(item);
        }
      }
    } else {
      // Initialize with default values if no result
      _fieldCount = 1;
    }
  }

  void _ensureControllersExist() {
    // Ensure _fieldCount is valid
    if (_fieldCount < 1) {
      _fieldCount = 1;
    }

    // Ensure we have enough controllers
    while (_keyControllers.length < _fieldCount) {
      _keyControllers.add(TextEditingController());
      _valueControllers.add(TextEditingController());
    }

    // Populate controllers with existing data
    if (_result.isNotEmpty) {
      for (int i = 0; i < _result.length && i < _keyControllers.length; i++) {
        _keyControllers[i].text = _result[i].key;
        _valueControllers[i].text = _result[i].value;
      }
    }
  }

  void _addField() {
    _keyControllers.add(TextEditingController());
    _valueControllers.add(TextEditingController());
    _fieldCount++;
  }

  void _removeField(int index) {
    if (index >= 0 && index < _keyControllers.length && _fieldCount > 1) {
      _keyControllers[index].dispose();
      _valueControllers[index].dispose();
      _keyControllers.removeAt(index);
      _valueControllers.removeAt(index);
      _fieldCount--;
    }
  }

  @override
  void dispose() {
    for (var controller in _keyControllers) {
      controller.dispose();
    }
    for (var controller in _valueControllers) {
      controller.dispose();
    }
    super.dispose();
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
          controller: isKey ? _keyControllers[index] : _valueControllers[index],
          maxLines: 1,
          keyboardType: TextInputType.text,
          validator: (input) => !isKey
              ? null
              : _keyControllers[index].text.isEmpty
                  ? "Cannot Be empty"
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
    _updateResultFromControllers();
    if (formStep.isOptional ?? false) {
      return true;
    }
    return resultFormat.isValid(_result);
  }

  void _updateResultFromControllers() {
    _result.clear();
    if (_fieldCount > 0 &&
        _keyControllers.isNotEmpty &&
        _valueControllers.isNotEmpty) {
      for (int i = 0;
          i < _fieldCount &&
              i < _keyControllers.length &&
              i < _valueControllers.length;
          i++) {
        String key = _keyControllers[i].text.trim();
        String value = _valueControllers[i].text.trim();
        if (key.isNotEmpty) {
          _result.add(KeyValue(key, value));
        }
      }
    }
    formStep.result = _result;
  }

  @override
  String validationError() {
    return resultFormat.error();
  }

  @override
  void requestFocus() {
    // Focus management is handled by the TextFormField widgets
  }

  @override
  dynamic resultValue() {
    _updateResultFromControllers();
    return _result;
  }

  @override
  void clearFocus() {
    for (var controller in _keyControllers) {
      controller.clear();
    }
    for (var controller in _valueControllers) {
      controller.clear();
    }
  }
}
