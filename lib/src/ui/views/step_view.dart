import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// The view for one [FormStep].
///
/// Subclass [BaseStepView] rather than this directly: it supplies the scaffold,
/// title, progress bar, footer buttons and error display, leaving you the input
/// widget and four small methods.
///
/// ## Lifetime
///
/// This is a [StatefulWidget] whose [State] exists only to own the view's
/// lifetime: it builds through [buildWithFrom] and calls [dispose] when the
/// view leaves the tree. Subclasses therefore keep their controllers and
/// notifiers as fields on the widget — unusual for Flutter, but it is what
/// makes [isValid], [resultValue] and the rest readable as plain methods — and
/// the framework still releases them at the right moment.
///
/// Before 3.1 this was a `StatelessWidget`, which has no disposal lifecycle at
/// all, so [dispose] was only ever called by [FormStackForm]'s own bookkeeping.
/// Any subclass that allocates a `TextEditingController`, `FocusNode` or
/// listener must override [dispose] and call `super.dispose()`.
///
/// ## State and back navigation
///
/// A view is rebuilt from scratch when the user navigates back to its step, so
/// it must restore what it shows from `formStep.result` rather than relying on
/// its own fields surviving. The answer is written back to the step before
/// every navigation, so the model is always the source of truth.
abstract class FormStepView<T extends FormStep> extends StatefulWidget {
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
  /// Called by the framework when the view leaves the tree. Overrides must
  /// call `super.dispose()`, and must tolerate being called twice.
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
  State<FormStepView<T>> createState() => _FormStepViewLifetime<T>();
}

/// Owns the lifetime of a [FormStepView].
///
/// Deliberately holds no state of its own: the view's fields are the state,
/// and this exists so the framework calls [FormStepView.dispose] when the view
/// is removed from the tree.
class _FormStepViewLifetime<T extends FormStep> extends State<FormStepView<T>> {
  @override
  Widget build(BuildContext context) =>
      widget.buildWithFrom(context, widget.formStep);

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}
