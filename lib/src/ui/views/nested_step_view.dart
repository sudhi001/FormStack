import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/nested_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class NestedStepView extends BaseStepView<NestedStep> {
  NestedStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, cancellable});

  final List<BaseStepView> _components = [];
  ResultFormat? resultFormat;
  bool _isInitialized = false;

  @override
  Widget? buildWInputWidget(BuildContext context, NestedStep formStep) {
    // Initialize components only once
    if (!_isInitialized && formStep.steps != null) {
      _components.clear();
      for (var element in formStep.steps!) {
        FormStep questions = element;
        questions.componentOnly = true;
        _components.add(questions.buildView(formKitForm) as BaseStepView);
      }
      _isInitialized = true;
    }

    // Use post frame callback for focus management
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      requestFocus();
    });

    return Wrap(
      spacing: 7,
      runSpacing: formStep.verticalPadding.toDouble(),
      children: _components,
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }

    bool isAllValid = true;
    for (var element in _components) {
      if (!element.isValid()) {
        isAllValid = false;
        element.showValidationError();
        // Break early on first validation failure for better performance
        break;
      }
    }

    if (isAllValid && formStep.validationExpression.isNotEmpty) {
      resultFormat = ResultFormat.expression(formStep.validationExpression);
      isAllValid = resultFormat!.isValid(resultValue());
    }

    return isAllValid;
  }

  @override
  String validationError() {
    return resultFormat?.error() ?? "";
  }

  @override
  Map<String, dynamic> resultValue() {
    final Map<String, dynamic> result = {};
    for (var element in _components) {
      element.formStep.result = element.resultValue();
      result[element.formStep.id?.id ?? ""] = element.resultValue();
    }
    return result;
  }

  @override
  void requestFocus() {
    // Request focus on the first component
    if (_components.isNotEmpty) {
      _components.first.requestFocus();
    }
  }

  @override
  void clearFocus() {
    // Clear focus from all components
    for (var element in _components) {
      element.clearFocus();
    }
  }

  @override
  void dispose() {
    // Clean up components
    _components.clear();
    super.dispose();
  }
}
