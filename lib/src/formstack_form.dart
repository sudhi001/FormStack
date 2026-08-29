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
  Function(FormStep)? onUpdate;

  /// Called when the OS back gesture fires and it was not prevented.
  VoidCallback? onSystemNavigationBackClick;

  /// Called to hand rendering over to another form, for cross-form navigation.
  Function(FormStackForm)? onRenderFormStackForm;

  /// Called with the flattened results when the form completes.
  Function(Map<String, dynamic> result)? onFinish;

  /// Called when the user cancels from the first step.
  Function()? onCancel;

  /// Called with the message whenever a step fails validation.
  Function(String)? onValidationError;

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
    disposeViews();
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

  /// Cached step views to prevent state loss on back navigation.
  ///
  /// Insertion-ordered so the least-recently-created entry can be evicted
  /// once [maxCachedViews] is exceeded. Evicted views are disposed, which
  /// releases their `TextEditingController`s, `FocusNode`s and listeners.
  final Map<String, FormStepView> _viewCache = {};

  /// Upper bound on retained step views.
  ///
  /// Long forms (hundreds of steps) would otherwise hold every controller
  /// and focus node alive for the lifetime of the form. Set to `0` to
  /// disable caching entirely, or a larger value to trade memory for
  /// back-navigation fidelity.
  int maxCachedViews = 12;

  /// Clears the view cache, disposing every cached view.
  ///
  /// Forces widgets to rebuild on the next render.
  void clearViewCache() => disposeViews();

  /// Disposes every cached step view and empties the cache.
  ///
  /// Called by `FormStackView.dispose`; safe to call more than once.
  void disposeViews() {
    for (final view in _viewCache.values) {
      view.dispose();
    }
    _viewCache.clear();
  }

  /// Evicts cached views beyond [maxCachedViews], never evicting [keep].
  void _evictStaleViews(String keep) {
    if (maxCachedViews <= 0) {
      for (final entry in _viewCache.entries.toList()) {
        if (entry.key == keep) continue;
        entry.value.dispose();
        _viewCache.remove(entry.key);
      }
      return;
    }
    while (_viewCache.length > maxCachedViews) {
      final victim = _viewCache.keys.firstWhere(
        (k) => k != keep,
        orElse: () => keep,
      );
      if (victim == keep) return;
      _viewCache.remove(victim)?.dispose();
    }
  }

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
    final resultValue = entry.result;
    if (resultValue != null && resultValue is DateTime) {
      if (entry.resultFormat != null) {
        final dateResultType = cast<DateResultType>(entry.resultFormat);
        if (dateResultType != null) {
          final formattedDate = DateFormat(
            dateResultType.format,
          ).format(resultValue);
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

  /// Cancels the form: returns to the first step, or invokes [onCancel] if
  /// already there.
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
    Function(FormStep) onUpdate,
    Function(FormStackForm)? onRenderFormStackForm, {
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
    // Cache step views to prevent state loss on navigation.
    final stepId = step.id?.id ?? '';
    final view = _viewCache.putIfAbsent(stepId, () => step.buildView(this));
    _evictStaleViews(stepId);
    return view;
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
