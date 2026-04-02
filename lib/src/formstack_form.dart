import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:intl/intl.dart';

/// Abstract base class managing form state, step navigation, and result collection.
///
/// Handles the linked-list based step navigation, conditional routing via
/// [RelevantCondition], result aggregation, and UI rendering callbacks.
/// Use [FormStack.api().form()] to create instances rather than subclassing directly.
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
    _viewCache.clear();
    for (var entry in steps) {
      entry.result = null;
      entry.startTime = null;
      entry.endTime = null;
      if (entry is NestedStep) {
        for (var stepEntry in entry.steps ?? []) {
          stepEntry.result = null;
        }
      }
    }
  }

  /// Current step being displayed.
  FormStep? _currentStep;

  /// Cached step views to prevent state loss on back navigation.
  final Map<String, Widget> _viewCache = {};

  /// Clears the view cache, forcing widgets to rebuild on next render.
  void clearViewCache() {
    _viewCache.clear();
  }

  /// Returns the progress of the form as a value between 0.0 and 1.0.
  double getProgress() {
    final total = getTotalSteps();
    if (total <= 0) return 0.0;
    final current = getCurrentIndex();
    return (current / total).clamp(0.0, 1.0);
  }

  /// Returns the zero-based index of the current step.
  int getCurrentIndex() {
    if (_currentStep == null) return 0;
    int index = 0;
    for (var step in steps) {
      if (step == _currentStep) return index;
      index++;
    }
    return 0;
  }

  /// Returns the total number of steps in the form.
  int getTotalSteps() => steps.length;

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
        FormStackForm? nextFormStack = FormStack.formByInstaceAndName(
            name: fromInstanceName, formName: formName!);
        if (nextFormStack != null) {
          nextFormStack.previousFormStackForm = this;
          onRenderFormStackForm?.call(nextFormStack);
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
    final step = formStep ?? steps.first;
    // Record timestamps and fire lifecycle callbacks
    if (_currentStep != null && _currentStep != step) {
      _currentStep!.endTime ??= DateTime.now().toUtc();
      _currentStep!.onStepDidComplete
          ?.call(_currentStep!, _currentStep!.result);
    }
    _currentStep = step;
    if (step.startTime == null) {
      step.startTime = DateTime.now().toUtc();
      step.onStepWillPresent?.call(step);
    }
    // Cache step views to prevent state loss on navigation
    final stepId = step.id?.id ?? '';
    return _viewCache.putIfAbsent(stepId, () => step.buildView(this));
  }

  /// Retrieves a step by its identifier string.
  FormStep? getStep(String stepId) {
    for (var step in steps) {
      if (step.id?.id == stepId) return step;
    }
    return null;
  }

  /// Retrieves the result value of a specific step by ID.
  dynamic getStepResult(String stepId) {
    return getStep(stepId)?.result;
  }

  /// Generates a structured [TaskResult] with all step results and metadata.
  TaskResult getTaskResult() {
    generateResult();
    final stepResults = <StepResult>[];
    for (var step in steps) {
      if (step.id?.id != null) {
        stepResults.add(StepResult.fromStep(step));
      }
    }
    return TaskResult(
      taskRunId: id?.id ?? '',
      formName: fromInstanceName,
      startTime: steps.isNotEmpty ? steps.first.startTime : null,
      endTime: _currentStep?.endTime ?? DateTime.now().toUtc(),
      stepResults: stepResults,
      flatResults: Map.from(result),
    );
  }

  /// Exports the complete task result as a JSON-serializable map.
  Map<String, dynamic> exportAsJson() {
    return getTaskResult().toJson();
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
