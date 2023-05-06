import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/result/identifiers.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/formstack_form.dart';
import 'package:formstack/src/ui/views/step_view.dart';

abstract class FormStep<T> extends LinkedListEntry<FormStep> {
  bool? isOptional;
  bool? cancellable;
  Identifier? id;
  dynamic result;
  String? title;
  String? text;
  String? hint;
  String? label;
  ResultFormat? resultFormat;
  String? nextButtonText;
  double? titleIconMaxWidth;
  String? titleIconAnimationFile;
  String? backButtonText;
  String? cancelButtonText;
  List<RelevantCondition>? relevantConditions;
  bool componentOnly;
  Display display;
  ComponentsStyle componentsStyle;
  CrossAxisAlignment crossAxisAlignmentContent;
  UIStyle? buttonStyle;
  String? error;
  bool disabled;
  FormStep(
      {this.id,
      this.title,
      this.text,
      this.hint,
      this.buttonStyle,
      this.error,
      this.disabled = false,
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
      this.resultFormat}) {
    id ??= StepIdentifier();
  }
  FormStepView buildView(FormStackForm formKitForm);
}

enum Display { small, normal, medium, large, extraLarge }

enum InputStyle { basic, underLined, outline }

enum ComponentsStyle { minimal, basic }

enum SelectionType { arrow, tick, toggle, dropdown }
