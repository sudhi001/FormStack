import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/step/nested_step.dart';
import 'package:intl/intl.dart';

abstract class FormStackForm {
  Identifier? id;
  String fromInstanceName;
  String? backgroundAnimationFile;
  LinkedList<FormStep> steps;
  MapKey mapKey;
  Alignment? backgroundAlignment;
  LocationWrapper initialLocation;
  Color primaryColor;
  bool preventSystemBackNavigation;
  Function(FormStep)? onUpdate;
  VoidCallback? onSystemNavigationBackClick;
  Function(FormStackForm)? onRenderFormStackForm;
  Function(Map<String, dynamic> result)? onFinish;
  Function()? onCancel;
  Function(String)? onValidationError;
  Map<String, dynamic> relevantStack = {};
  Map<String, dynamic> result = {};
  FormStackForm? previousFormStackForm;

  FormStackForm(this.steps,
      {this.id,
      required this.fromInstanceName,
      this.onUpdate,
      this.onRenderFormStackForm,
      this.backgroundAnimationFile,
      this.onValidationError,
      this.onSystemNavigationBackClick,
      this.primaryColor = Colors.black,
      required this.mapKey,
      this.preventSystemBackNavigation = false,
      this.backgroundAlignment,
      required this.initialLocation}) {
    id ??= FormIdentifier();
  }

  void validationError(String error) {
    onValidationError?.call(error);
  }

  void clearResult() {
    relevantStack.clear();
    for (var entry in steps) {
      entry.result = null;
      if (entry is NestedStep) {
        for (var stepEntry in entry.steps ?? []) {
          stepEntry.result = null;
        }
      }
    }
  }

  void backStep(FormStep? currentStep) {
    FormStep? nextStep;
    final currentStepId = currentStep?.id?.id;
    if (currentStepId != null && relevantStack.containsKey(currentStepId)) {
      nextStep = relevantStack[currentStepId] as FormStep?;
    } else {
      nextStep = currentStep?.previousStep ?? currentStep?.previous;
      if (nextStep != null) {
        onUpdate?.call(nextStep);
      } else if (previousFormStackForm != null) {
        onRenderFormStackForm?.call(previousFormStackForm!);
        return;
      }
    }
    if (nextStep != null) {
      onUpdate?.call(nextStep);
    } else {
      onFinish?.call(result);
    }
  }

  void nextStep(FormStep? currentStep) {
    FormStep? nextStep;
    if (currentStep?.relevantConditions == null) {
      nextStep = currentStep?.next;
    } else {
      String? formName;
      for (RelevantCondition element in currentStep!.relevantConditions!) {
        if (element.isValid(currentStep.result)) {
          nextStep = steps.firstWhereOrNull(
              (e) => (e.id?.id ?? "") == element.identifier.id);
          formName = element.formName;
          break;
        }
      }
      if (nextStep != null) {
        final nextStepId = nextStep.id?.id;
        if (nextStepId != null) {
          relevantStack.putIfAbsent(nextStepId, () => currentStep);
        }
      } else if (formName?.isNotEmpty ?? false) {
        FormStackForm? nextFormSatck = FormStack.formByInstaceAndName(
            name: fromInstanceName, formName: formName!);
        if (nextFormSatck != null) {
          nextFormSatck.previousFormStackForm = this;
          onRenderFormStackForm?.call(nextFormSatck);
          return;
        } else {
          nextStep = currentStep.next;
          nextStep?.previousStep = currentStep;
        }
      } else {
        nextStep = currentStep.next;
        nextStep?.previousStep = currentStep;
        if (nextStep == null) {
          onFinish?.call(result);
          clearResult();
        }
      }
    }

    if (nextStep != null) {
      onUpdate?.call(nextStep);
    } else {
      onUpdate?.call(steps.first);
      onFinish?.call(result);
      clearResult();
    }
  }

  void generateResult() {
    result.clear();
    for (var entry in steps) {
      addItem(entry);
    }
  }

  void addItem(FormStep entry) {
    final resultValue = entry.result;
    if (resultValue != null && resultValue is DateTime) {
      if (entry.resultFormat != null) {
        final dateResultType = cast<DateResultType>(entry.resultFormat);
        if (dateResultType != null) {
          final formattedDate =
              DateFormat(dateResultType.format).format(resultValue);
          final entryId = entry.id?.id;
          if (entryId != null) {
            result.putIfAbsent(entryId, () => formattedDate);
          }
        }
      }
    } else if (entry is NestedStep) {
      for (var child in entry.steps ?? []) {
        addItem(child);
      }
    } else if (resultValue != null && resultValue is Map) {
      result.addAll(resultValue as Map<String, dynamic>);
    } else {
      final entryId = entry.id?.id;
      if (entryId != null) {
        result.putIfAbsent(entryId, () => resultValue);
      }
    }
  }

  void cancelStep(FormStep? currentStep) {
    clearResult();
    if (steps.first == currentStep) {
      onCancel?.call();
    } else {
      onUpdate?.call(steps.first);
    }
  }

  Widget render(Function(FormStep) onUpdate,
      Function(FormStackForm)? onRenderFormStackForm,
      {FormStep? formStep}) {
    this.onUpdate = onUpdate;
    this.onRenderFormStackForm = onRenderFormStackForm;
    if (formStep != null) {
      return formStep.buildView(this);
    }
    return steps.first.buildView(this);
  }
}

class FormWizard extends FormStackForm {
  FormWizard(super.steps,
      {required super.mapKey,
      required super.fromInstanceName,
      required super.initialLocation,
      super.backgroundAlignment,
      super.id,
      super.backgroundAnimationFile});
}
