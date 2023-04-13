import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/navigation_rule.dart';
import 'package:intl/intl.dart';

abstract class FormStackForm {
  Identifier? id;
  String? backgroundAnimationFile;
  LinkedList<FormStep> steps;
  String? googleMapAPIKey;
  GeoLocationResult? initialPosition;
  Function(FormStep)? onUpdate;
  Function(Map<String, dynamic> result)? onFinish;
  Function(String)? onValidtionError;

  Map<StepIdentifier, NavigationRule> navigationRuleMap = {};
  FormStackForm(this.steps,
      {this.id,
      this.onUpdate,
      this.backgroundAnimationFile,
      this.onValidtionError,
      this.googleMapAPIKey,
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
    for (var entry in steps) {
      entry.result = null;
    }
  }

  void nextStep(FormStep? currentStep) {
    FormStep? nextStep = currentStep?.next;
    if (nextStep != null) {
      onUpdate?.call(nextStep);
    } else {
      onUpdate?.call(steps.first);
      Map<String, dynamic> result = {};
      for (var entry in steps) {
        if (entry.result != null && entry.result is DateTime) {
          if (entry.resultFormat != null) {
            DateResultType dateResultType = cast(entry.resultFormat);
            String formattedDate =
                DateFormat(dateResultType.format).format(entry.result);
            result.putIfAbsent(entry.id!.id!, () => formattedDate);
          }
        } else {
          result.putIfAbsent(entry.id!.id!, () => entry.result);
        }
      }
      clearResult();
      onFinish?.call(result);
    }
  }

  void backStep(FormStep? currentStep) {
    FormStep? nextStep = currentStep?.previous;
    if (nextStep != null) {
      onUpdate?.call(nextStep);
    }
  }

  void cancelStep(FormStep? currentStep) {
    clearResult();
    onUpdate?.call(steps.first);
  }

  Widget render(Function(FormStep) onUpdate, {FormStep? formStep}) {
    this.onUpdate = onUpdate;
    if (formStep != null) {
      return formStep.buildView(this);
    }
    return steps.first.buildView(this);
  }
}

class FormWizard extends FormStackForm {
  FormWizard(super.steps,
      {super.googleMapAPIKey,
      super.initialPosition,
      super.id,
      super.backgroundAnimationFile});
}
