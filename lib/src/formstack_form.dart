import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/core/navigation_rule.dart';
import 'package:intl/intl.dart';

abstract class FormStackForm {
  Identifier? id;
  String fromInstanceName;
  String? backgroundAnimationFile;
  LinkedList<FormStep> steps;
  String? googleMapAPIKey;
  Alignment? backgroundAlignment;
  GeoLocationResult? initialPosition;
  Color primaryColor;
  bool preventSystemBackNavigation;
  Function(FormStep)? onUpdate;
  VoidCallback? onSystemNagiationBackClick;
  Function(FormStackForm)? onRenderFormSatackForm;
  Function(Map<String, dynamic> result)? onFinish;
  Function(String)? onValidtionError;
  Map<String, dynamic> relevantStack = {};
  Map<String, dynamic> result = {};
  FormStackForm? previousFormStackForm;

  Map<StepIdentifier, NavigationRule> navigationRuleMap = {};
  FormStackForm(this.steps,
      {this.id,
      required this.fromInstanceName,
      this.onUpdate,
      this.onRenderFormSatackForm,
      this.backgroundAnimationFile,
      this.onValidtionError,
      this.onSystemNagiationBackClick,
      this.primaryColor = Colors.black,
      this.googleMapAPIKey,
      this.preventSystemBackNavigation = false,
      this.backgroundAlignment,
      this.initialPosition}) {
    id ??= FormIdentifier();
  }

  NavigationRule? getRule(StepIdentifier stepIdentifier) =>
      navigationRuleMap[stepIdentifier];

  void setNavigationRule(
      StepIdentifier identifier, NavigationRule navigationRule) {
    navigationRuleMap[identifier] = navigationRule;
  }

  void validationError(String error) {
    onValidtionError?.call(error);
  }

  void clearResult() {
    relevantStack.clear();
    for (var entry in steps) {
      entry.result = null;
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
        relevantStack.putIfAbsent((nextStep.id?.id ?? ""), () => currentStep);
      } else if (formName?.isNotEmpty??false) {
        FormStackForm? nextFormSatck = FormStack.formByInstaceAndName(
            name: fromInstanceName, formName: formName!);
        if (nextFormSatck != null) {
          nextFormSatck.previousFormStackForm = this;
          onRenderFormSatackForm?.call(nextFormSatck);
          return;
        } else {
          nextStep = currentStep.next;
        }
      } else {
        nextStep = currentStep.next;
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
      if (entry.result != null && entry.result is DateTime) {
        if (entry.resultFormat != null) {
          DateResultType dateResultType = cast(entry.resultFormat);
          String formattedDate =
              DateFormat(dateResultType.format).format(entry.result);
          result.putIfAbsent((entry.id?.id ?? ""), () => formattedDate);
        }
      } else {
        result.putIfAbsent((entry.id?.id ?? ""), () => entry.result);
      }
    }
  }

  void backStep(FormStep? currentStep) {
    FormStep? nextStep;
    if (relevantStack.containsKey(currentStep?.id?.id)) {
      nextStep = relevantStack[currentStep?.id?.id];
    } else {
      nextStep = currentStep?.previous;
      if (previousFormStackForm != null) {
        onRenderFormSatackForm?.call(previousFormStackForm!);
        return;
      }
    }
    if (nextStep != null) {
      onUpdate?.call(nextStep);
    }
  }

  void cancelStep(FormStep? currentStep) {
    clearResult();
    onUpdate?.call(steps.first);
  }

  Widget render(Function(FormStep) onUpdate,
      Function(FormStackForm)? onRenderFormSatackForm,
      {FormStep? formStep}) {
    this.onUpdate = onUpdate;
    this.onRenderFormSatackForm = onRenderFormSatackForm;
    if (formStep != null) {
      return formStep.buildView(this);
    }
    return steps.first.buildView(this);
  }
}

class FormWizard extends FormStackForm {
  FormWizard(super.steps,
      {super.googleMapAPIKey,
      required super.fromInstanceName,
      super.initialPosition,
      super.backgroundAlignment,
      super.id,
      super.backgroundAnimationFile});
}
