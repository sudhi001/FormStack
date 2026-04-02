import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/result/identifiers.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/formstack_form.dart';
import 'package:formstack/src/ui/views/step_view.dart';

/// Base class for all form steps.
///
/// Subclasses include [QuestionStep], [InstructionStep], [CompletionStep],
/// [NestedStep], [DisplayStep], and `PopStep`. Each step holds its
/// configuration, result value, validation, and navigation properties.
abstract class FormStep<T> extends LinkedListEntry<FormStep> {
  /// Whether this step can be skipped without validation.
  bool? isOptional;

  /// Whether a cancel button is shown.
  bool? cancellable;

  /// Unique identifier for this step.
  Identifier? id;

  /// The current result value of this step.
  dynamic result;

  /// Title text displayed at the top of the step.
  String? title;

  /// Descriptive text displayed below the title.
  String? text;

  /// Placeholder hint text for input fields.
  String? hint;

  /// Label text for input fields.
  String? label;

  /// Validation format applied to this step's result.
  ResultFormat? resultFormat;

  /// Custom text for the next/submit button.
  String? nextButtonText;

  /// Additional description text displayed below the input.
  final String? description;

  /// Maximum width for the title icon animation.
  double? titleIconMaxWidth;

  /// Path to a Lottie animation file displayed above the title.
  String? titleIconAnimationFile;

  /// Custom text for the back button.
  String? backButtonText;

  /// Custom text for the cancel button.
  String? cancelButtonText;

  /// Conditions that determine navigation after this step.
  List<RelevantCondition>? relevantConditions;

  /// When true, renders only the input widget without scaffold wrapper.
  bool componentOnly;

  /// When true, shows the back button in the footer instead of the app bar.
  bool footerBackButton;

  /// Controls the text size of the title and description.
  Display display;

  /// Visual style of list-based components (choices, tiles).
  ComponentsStyle componentsStyle;

  /// Horizontal alignment of the step content.
  CrossAxisAlignment crossAxisAlignmentContent;

  /// Custom color and border styling for buttons and inputs.
  UIStyle? style;

  /// Pre-set error message shown when the step first loads.
  String? error;

  /// When true, the input is disabled and cannot be interacted with.
  bool disabled;

  /// Fixed width for the step widget (used in [NestedStep]).
  final double? width;

  /// Reference to the previous step for back navigation.
  FormStep? previousStep;

  /// Persistent helper text displayed below the input field.
  final String? helperText;

  /// Initial value to pre-fill the input with.
  dynamic defaultValue;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  /// Path to a static image asset displayed above the title.
  final String? titleIconImagePath;

  /// URL of a video to display in instruction steps.
  final String? videoUrl;

  /// Timestamp when this step was first displayed.
  DateTime? startTime;

  /// Timestamp when this step was completed/navigated away.
  DateTime? endTime;

  /// Whether to show a progress bar in the form UI.
  final bool showProgressBar;

  /// Called when this step is about to be displayed.
  ///
  /// Use this for setup logic before the step renders.
  final void Function(FormStep step)? onStepWillPresent;

  /// Called after this step has been completed or navigated away from.
  ///
  /// Use this for cleanup or analytics logging.
  final void Function(FormStep step, dynamic result)? onStepDidComplete;

  /// Creates a [FormStep] with the given configuration.
  FormStep(
      {this.id,
      this.title,
      this.text,
      this.description,
      this.hint,
      this.style,
      this.error,
      this.footerBackButton = false,
      this.disabled = false,
      this.width,
      this.crossAxisAlignmentContent = CrossAxisAlignment.center,
      this.display = Display.normal,
      this.componentOnly = false,
      this.isOptional = false,
      this.cancellable = true,
      this.label,
      this.componentsStyle = ComponentsStyle.minimal,
      this.nextButtonText = "Next",
      this.backButtonText = "Back",
      this.titleIconMaxWidth = 300,
      this.titleIconAnimationFile,
      this.relevantConditions,
      this.cancelButtonText = "Cancel",
      this.previousStep,
      this.resultFormat,
      this.helperText,
      this.defaultValue,
      this.semanticLabel,
      this.titleIconImagePath,
      this.videoUrl,
      this.showProgressBar = true,
      this.onStepWillPresent,
      this.onStepDidComplete}) {
    id ??= StepIdentifier();
    if (defaultValue != null && result == null) {
      result = defaultValue;
    }
  }

  /// Builds the UI widget for this step.
  FormStepView buildView(FormStackForm formStackForm);
}

/// Controls the text size of step titles and descriptions.
enum Display {
  /// Compact text for dense layouts.
  small,

  /// Standard text size (default).
  normal,

  /// Larger headings for emphasis.
  medium,

  /// Big text for hero-style sections.
  large,

  /// Maximum text size for splash screens.
  extraLarge,
}

/// Visual style of text input fields.
enum InputStyle {
  /// Flat input with no border.
  basic,

  /// Input with bottom border only.
  underLined,

  /// Input with full border outline.
  outline,
}

/// Visual style of list-based components (choices, tiles).
enum ComponentsStyle {
  /// Clean minimal design with separator lines.
  minimal,

  /// Card-style with background color and rounded corners.
  basic,
}

/// Display style for choice selection indicators.
enum SelectionType {
  /// Forward arrow icon (ideal for drill-down navigation).
  arrow,

  /// Checkmark icon (classic single/multi-select).
  tick,

  /// Switch toggle (ideal for settings-style multi-select).
  toggle,

  /// Traditional dropdown menu.
  dropdown,
}
