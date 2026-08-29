import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// The view for one [FormStep].
///
/// Subclass [BaseStepView] rather than this directly: it supplies the scaffold,
/// title, progress bar, footer buttons and error display, leaving you the input
/// widget and four small methods.
///
/// These views are `StatelessWidget`s that hold mutable state, so the framework
/// never disposes them — [FormStackForm] does, when it evicts the view from its
/// cache or the form leaves the tree. Any subclass that allocates a
/// `TextEditingController`, `FocusNode` or listener must override [dispose] and
/// call `super.dispose()`.
abstract class FormStepView<T extends FormStep> extends StatelessWidget {
  /// Heading shown above the input.
  final String? title;

  /// Body text shown below the heading.
  final String? text;

  /// The form that owns [formStep], used to navigate and collect results.
  final FormStackForm formStackForm;

  /// The step this view renders.
  final T formStep;

  /// Creates a [FormStepView].
  const FormStepView(
    this.formStackForm,
    this.formStep,
    this.text, {
    super.key,
    this.title,
  });

  /// Builds the view for [formStep].
  Widget buildWithFrom(BuildContext context, T formStep);

  /// Validates the answer and advances, or shows the validation error.
  void onNext();

  /// Returns to the previous step, preserving the current answer.
  void onBack();

  /// Releases anything this view allocated.
  ///
  /// Called by [FormStackForm]; overrides must call `super.dispose()`.
  void dispose();

  /// Abandons the form, or returns to the first step.
  void onCancel();

  /// Handles a tap on the primary button: collects the answer, runs
  /// [onBeforeFinish], then [onNext].
  void onNextButtonClick();

  /// Called when the busy state changes, for example during [onBeforeFinish].
  void onLoading(bool isLoading);

  /// Runs before the form completes, for a final async check or submission.
  ///
  /// Returning false does not currently halt navigation; use it for side
  /// effects such as posting results.
  Future<bool> onBeforeFinish(Map<String, dynamic> result);

  @override
  Widget build(BuildContext context) {
    return buildWithFrom(context, formStep);
  }
}
