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
  /// Identifier of this form. Generated if not supplied.
  Identifier? id;

  /// Name of the [FormStack] instance that owns this form.
  ///
  /// Used to resolve cross-form navigation, where a [RelevantCondition]
  /// carries a `formName` instead of a step id.
  String fromInstanceName;

  /// Path to a Lottie animation drawn behind every step, or null for none.
  String? backgroundAnimationFile;

  /// The ordered steps of this form.
  ///
  /// Order defines default (unconditional) navigation; [RelevantCondition]s on
  /// a step can route elsewhere. Mutating this list invalidates the internal
  /// index automatically on the next lookup.
  List<FormStep> steps;

  /// API keys for the map inputs. Empty when the form uses no map.
  MapKey mapKey;

  /// Alignment of [backgroundAnimationFile] within the step.
  Alignment? backgroundAlignment;

  /// Starting camera position for map inputs.
  LocationWrapper initialLocation;

  /// Legacy accent colour. Prefer the ambient [ThemeData] and [UIStyle].
  Color primaryColor;

  /// When true, the OS back gesture is intercepted rather than popping the
  /// route, and [onSystemNavigationBackClick] is called instead.
  bool preventSystemBackNavigation;

  /// Called with the step to display next. Set by the rendering widget.
  void Function(FormStep)? onUpdate;

  /// Called when the OS back gesture fires and it was not prevented.
  VoidCallback? onSystemNavigationBackClick;

  /// Called to hand rendering over to another form, for cross-form navigation.
  void Function(FormStackForm)? onRenderFormStackForm;

  /// Called with the flattened results when the form completes.
  void Function(Map<String, dynamic> result)? onFinish;

  /// Called when the user cancels from the first step.
  void Function()? onCancel;

  /// Called with the message whenever a step fails validation.
  void Function(String)? onValidationError;

  /// Records which step routed to each branch target, so back navigation
  /// retraces the path actually taken rather than declaration order.
  Map<String, dynamic> relevantStack = {};

  /// The flattened answers, keyed by step id. Refreshed by [generateResult].
  Map<String, dynamic> result = {};

  /// The form that navigated here, for returning from a cross-form branch.
  FormStackForm? previousFormStackForm;

  /// Creates a [FormStackForm] over [steps].
  FormStackForm(
    this.steps, {
    this.id,
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
    required this.initialLocation,
  }) {
    id ??= FormIdentifier();
  }

  /// Reports a validation failure to [onValidationError].
  void validationError(String error) {
    onValidationError?.call(error);
  }

  /// Clears every answer, timestamp and cached view, returning the form to
  /// its initial state.
  void clearResult() {
    relevantStack.clear();
    for (var entry in steps) {
      entry.result = null;
      entry.startTime = null;
      entry.endTime = null;
      if (entry is NestedStep) {
        for (final FormStep stepEntry in entry.steps ?? const <FormStep>[]) {
          stepEntry.result = null;
        }
      }
    }
  }

  /// Current step being displayed.
  FormStep? _currentStep;

  /// The step currently rendered on screen, or null before the first render.
  FormStep? get currentStep => _currentStep;

  /// The view for the step currently on screen.
  ///
  /// A single entry rather than a cache: [FormStepView] is a `StatefulWidget`
  /// whose `State` disposes it when it leaves the tree, so a view retained
  /// after being replaced would be reused after disposal. Holding only the
  /// current one keeps the framework's lifetime and this reference in step.
  ///
  /// Navigating back therefore builds a fresh view, which restores what it
  /// shows from `formStep.result` — the answer is written back to the step
  /// before every navigation, so the model is the source of truth.
  FormStepView? _currentView;

  /// The step [_currentView] was built for.
  FormStep? _viewStep;

  /// Upper bound on retained step views.
  @Deprecated(
    'Views are owned by the widget tree and released by the framework, so '
    'nothing is retained to bound. This has no effect and will be removed in '
    '4.0.',
  )
  int maxCachedViews = 0;

  /// Discards the current view so the next render rebuilds it.
  @Deprecated(
    'Views are rebuilt per navigation and disposed by the framework. This has '
    'no effect and will be removed in 4.0.',
  )
  void clearViewCache() {}

  /// Formerly disposed the cached views.
  @Deprecated(
    'The framework disposes step views when they leave the tree. This has no '
    'effect and will be removed in 4.0.',
  )
  void disposeViews() {}

  // --- Step index -----------------------------------------------------------
  //
  // Position and id lookups used to walk the linked list on every call.
  // getCurrentIndex() alone runs twice per progress-bar build, so a long form
  // paid O(steps) per frame. The maps below are built once and rebuilt only
  // when the step list changes.

  Map<FormStep, int>? _positions;
  Map<String, FormStep>? _byId;
  int _indexedLength = -1;

  void _ensureIndex() {
    if (_positions != null && _indexedLength == steps.length) return;
    final positions = <FormStep, int>{};
    final byId = <String, FormStep>{};
    var i = 0;
    for (final step in steps) {
      positions[step] = i++;
      final id = step.id?.id;
      if (id != null) byId.putIfAbsent(id, () => step);
    }
    _positions = positions;
    _byId = byId;
    _indexedLength = steps.length;
  }

  /// Invalidates the cached step index.
  ///
  /// Call after mutating [steps] in place; adding or removing steps through
  /// the normal API is detected automatically.
  void invalidateStepIndex() {
    _positions = null;
    _byId = null;
    _indexedLength = -1;
  }

  /// A snapshot of the current position and total, computed in one pass.
  ///
  /// Prefer this over calling [getCurrentIndex] and [getTotalSteps]
  /// separately when rendering — it avoids indexing twice per build.
  FormProgress get progress {
    final total = steps.length;
    return FormProgress(index: getCurrentIndex(), total: total);
  }

  /// Returns the progress of the form as a value between 0.0 and 1.0.
  double getProgress() => progress.fraction;

  /// Returns the zero-based index of the current step.
  int getCurrentIndex() {
    final current = _currentStep;
    if (current == null) return 0;
    _ensureIndex();
    return _positions?[current] ?? 0;
  }

  /// Returns the total number of steps in the form.
  int getTotalSteps() => steps.length;

  /// The step following [step] in declaration order, or null at the end.
  ///
  /// Replaces the linked-list `next` pointer that used to live on the step
  /// itself; ordering is a property of the form, not of the step.
  FormStep? stepAfter(FormStep? step) {
    if (step == null) return null;
    _ensureIndex();
    final i = _positions?[step];
    if (i == null || i + 1 >= steps.length) return null;
    return steps[i + 1];
  }

  /// The step preceding [step] in declaration order, or null at the start.
  FormStep? stepBefore(FormStep? step) {
    if (step == null) return null;
    _ensureIndex();
    final i = _positions?[step];
    if (i == null || i <= 0) return null;
    return steps[i - 1];
  }

  /// Navigates back from [currentStep], retracing any branch that was taken.
  void backStep(FormStep? currentStep) {
    FormStep? nextStep;
    final currentStepId = currentStep?.id?.id;
    if (currentStepId != null && relevantStack.containsKey(currentStepId)) {
      nextStep = relevantStack[currentStepId] as FormStep?;
    } else {
      nextStep = currentStep?.previousStep ?? stepBefore(currentStep);
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

  /// Navigates forward from [currentStep].
  ///
  /// Evaluates the step's [RelevantCondition]s first; the first match wins and
  /// may route to another step or another form. Falls through to the next step
  /// in declaration order when none match.
  void nextStep(FormStep? currentStep) {
    FormStep? nextStep;
    if (currentStep?.relevantConditions == null) {
      nextStep = stepAfter(currentStep);
    } else {
      String? formName;
      for (RelevantCondition element in currentStep!.relevantConditions!) {
        if (element.isValid(currentStep.result)) {
          nextStep = steps.firstWhereOrNull(
            (e) => (e.id?.id ?? "") == element.identifier.id,
          );
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
        final FormStackForm? nextFormStack = FormStack.formByInstaceAndName(
          name: fromInstanceName,
          formName: formName!,
        );
        if (nextFormStack != null) {
          nextFormStack.previousFormStackForm = this;
          onRenderFormStackForm?.call(nextFormStack);
          return;
        } else {
          nextStep = stepAfter(currentStep);
          nextStep?.previousStep = currentStep;
        }
      } else {
        nextStep = stepAfter(currentStep);
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

  /// Rebuilds [result] from the current answers of every step.
  void generateResult() {
    result.clear();
    for (var entry in steps) {
      addItem(entry);
    }
  }

  /// Folds one step's answer into [result], flattening nested steps and
  /// formatting dates according to their [DateResultType].
  void addItem(FormStep entry) {
    // A NestedStep contributes its children, not itself.
    if (entry is NestedStep) {
      for (final FormStep child in entry.steps ?? const <FormStep>[]) {
        addItem(child);
      }
      return;
    }

    final entryId = entry.id?.id;
    if (entryId == null) return;
    final resultValue = entry.result;

    if (resultValue is DateTime) {
      // Formatted when the step declares how, ISO-8601 otherwise. The date
      // used to be dropped entirely unless a DateResultType was attached, so
      // it was missing from exportAsJson, from saved drafts and from the map
      // handed to onFinish -- silently, and only for date answers.
      final format = cast<DateResultType>(entry.resultFormat)?.format;
      result.putIfAbsent(
        entryId,
        () => format == null
            ? resultValue.toIso8601String()
            : DateFormat(format).format(resultValue),
      );
      return;
    }

    // A step whose answer is itself a map of answers -- a repeat group, or a
    // nested step rendered as a component -- merges into the result.
    if (resultValue is Map) {
      result.addAll(Map<String, dynamic>.from(resultValue));
      return;
    }

    result.putIfAbsent(entryId, () => resultValue);
  }

  void cancelStep(FormStep? currentStep) {
    clearResult();
    if (steps.first == currentStep) {
      onCancel?.call();
    } else {
      onUpdate?.call(steps.first);
    }
  }

  /// Builds the view for [formStep], or the first step when none is given.
  ///
  /// Records step timestamps, fires the step lifecycle callbacks, and caches
  /// the view so navigating back preserves what the user typed.
  Widget render(
    void Function(FormStep) onUpdate,
    void Function(FormStackForm)? onRenderFormStackForm, {
    FormStep? formStep,
  }) {
    this.onUpdate = onUpdate;
    this.onRenderFormStackForm = onRenderFormStackForm;
    final step = formStep ?? steps.first;
    // Record timestamps and fire lifecycle callbacks
    if (_currentStep != null && _currentStep != step) {
      _currentStep!.endTime ??= DateTime.now().toUtc();
      _currentStep!.onStepDidComplete?.call(
        _currentStep!,
        _currentStep!.result,
      );
    }
    _currentStep = step;
    if (step.startTime == null) {
      step.startTime = DateTime.now().toUtc();
      step.onStepWillPresent?.call(step);
    }
    // One view per step occupancy. Rebuilding on every call would discard
    // half-typed input whenever an unrelated rebuild reached the form, so the
    // view is kept for as long as its step is the one on screen.
    if (_currentView == null || !identical(_viewStep, step)) {
      _viewStep = step;
      _currentView = step.buildView(this);
    }
    // Keyed by step, because consecutive steps commonly use the same view
    // class: without a differing key Flutter reconciles them onto one element,
    // reuses the State, and never disposes the outgoing view -- leaking its
    // controllers and carrying the previous step's focus into the next one.
    return KeyedSubtree(
      key: ValueKey<String>('formstack.step.${step.id?.id}'),
      child: _currentView!,
    );
  }

  /// Retrieves a step by its identifier string.
  ///
  /// Backed by an index, so this is a constant-time lookup rather than a walk
  /// of the step list.
  FormStep? getStep(String stepId) {
    _ensureIndex();
    return _byId?[stepId];
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

/// The concrete [FormStackForm] created by `FormStack.api().form(...)`.
///
/// Subclass [FormStackForm] directly only to change navigation or result
/// aggregation; for ordinary forms this is what you get.
class FormWizard extends FormStackForm {
  /// Creates a [FormWizard] over [steps].
  FormWizard(
    super.steps, {
    required super.mapKey,
    required super.fromInstanceName,
    required super.initialLocation,
    super.backgroundAlignment,
    super.id,
    super.backgroundAnimationFile,
  });
}

/// An immutable snapshot of how far through a form the user is.
///
/// Produced by [FormStackForm.progress] in a single pass so a widget can show
/// the counter and the bar without indexing the step list twice.
class FormProgress {
  /// Zero-based index of the step currently displayed.
  final int index;

  /// Total number of steps in the form.
  final int total;

  /// Creates a [FormProgress].
  const FormProgress({required this.index, required this.total});

  /// Completion as a value between 0.0 and 1.0.
  double get fraction =>
      total <= 0 ? 0.0 : (index / total).clamp(0.0, 1.0).toDouble();

  /// Completion as a whole percentage, 0-100.
  int get percent => (fraction * 100).round();

  /// One-based step number, suitable for display.
  int get step => index + 1;

  /// Whether the form has more than one step, i.e. a bar is worth showing.
  bool get isMeaningful => total > 1;

  @override
  bool operator ==(Object other) =>
      other is FormProgress && other.index == index && other.total == total;

  @override
  int get hashCode => Object.hash(index, total);

  @override
  String toString() => 'FormProgress(step $step of $total, $percent%)';
}
