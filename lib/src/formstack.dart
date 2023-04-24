import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/relevant/expression_relevant_condition.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/ui/views/formstack_view.dart';
import 'package:formstack/src/utils/alignment.dart';

class FormStack {
  // Ensures end-users cannot initialize the class.
  FormStack._();

  static final Map<String, FormStack> _delegate = {};

  final Map<String, FormStackForm> _forms = {};

  static FormStack api({String name = "default"}) {
    if (!_delegate.containsKey(name)) {
      _delegate.putIfAbsent(name, () => FormStack._());
    }
    return _delegate[name]!;
  }

  static FormStackForm? formByInstaceAndName(
      {String name = "default", String formName = "default"}) {
    return api(name: name)._forms[formName];
  }

  ///Clear your instant.
  ///Are you sure to use this.
  static void clearConfiguration() {
    _delegate.clear();
  }

  ///Clear forms.
  ///Clear Forms only.
  static void clearForms({String name = "default"}) {
    if (_delegate.containsKey(name)) {
      _delegate.remove(name);
    }
  }

  FormStack form({
    String name = "default",
    String? googleMapAPIKey,
    GeoLocationResult? initialPosition,
    String? backgroundAnimationFile,
    Alignment? backgroundAlignment,
    required List<FormStep> steps,
  }) {
    var list = LinkedList<FormStep>();
    list.addAll(steps);
    FormWizard form = FormWizard(list,
        googleMapAPIKey: googleMapAPIKey,
        fromInstanceName: name,
        backgroundAlignment: backgroundAlignment,
        backgroundAnimationFile: backgroundAnimationFile);
    _forms.putIfAbsent(name, () => form);
    return this;
  }

  Future<FormStack> buildFormFromJsonString(String data) async {
    Map<String, dynamic>? body = await json.decode(data);
    return buildFormFromJson(body);
  }

  Future<FormStack> buildFormFromJson(Map<String, dynamic>? body) async {
    if (body != null) {
      body.forEach((key, value) {
        List<FormStep> formStep = [];
        List<dynamic>? tsteps = value?["steps"] ?? [];
        tsteps?.forEach((element) {
          List<RelevantCondition> relevantConditions = [];
          cast<List>(element?["relevantConditions"])?.forEach((el) {
            relevantConditions.add(ExpressionRelevant(
                expression: el?["expression"],
                formName: el?["formName"] ?? "",
                identifier: GenericIdentifier(id: el?["id"])));
          });

          if (element["type"] == "QuestionStep") {
            List<Options> options = [];
            cast<List>(element?["options"])?.forEach((el) {
              options.add(Options(el?["key"], el?["text"]));
            });
            InputType inputType = InputType.values
                .firstWhere((e) => e.name == element?["inputType"]);
            QuestionStep step = QuestionStep(
                inputType: inputType,
                options: options,
                relevantConditions: relevantConditions,
                cancellable: element?["cancellable"],
                autoTrigger: element?["autoTrigger"] ?? false,
                backButtonText: element?["backButtonText"],
                cancelButtonText: element?["cancelButtonText"],
                isOptional: element?["isOptional"],
                nextButtonText: element?["nextButtonText"],
                numberOfLines: element?["numberOfLines"],
                text: element?["text"],
                title: element?["title"],
                titleIconAnimationFile: element?["titleIconAnimationFile"],
                titleIconMaxWidth: element?["titleIconMaxWidth"],
                id: GenericIdentifier(id: element?["id"]));
            formStep.add(step);
          } else if (element["type"] == "CompletionStep") {
            CompletionStep step = CompletionStep(
                display: element?["display"] != null
                    ? Display.values
                        .firstWhere((e) => e.name == element?["display"])
                    : Display.normal,
                cancellable: element?["cancellable"],
                autoTrigger: element?["autoTrigger"] ?? false,
                relevantConditions: relevantConditions,
                backButtonText: element?["backButtonText"],
                cancelButtonText: element?["cancelButtonText"],
                isOptional: element?["isOptional"],
                nextButtonText: element?["nextButtonText"],
                text: element?["text"],
                title: element?["title"],
                titleIconAnimationFile: element?["titleIconAnimationFile"],
                titleIconMaxWidth: element?["titleIconMaxWidth"],
                id: GenericIdentifier(id: element?["id"]));
            formStep.add(step);
          } else if (element["type"] == "InstructionStep") {
            InstructionStep step = InstructionStep(
                display: element?["display"] != null
                    ? Display.values
                        .firstWhere((e) => e.name == element?["display"])
                    : Display.normal,
                cancellable: element?["cancellable"],
                relevantConditions: relevantConditions,
                backButtonText: element?["backButtonText"],
                cancelButtonText: element?["cancelButtonText"],
                isOptional: element?["isOptional"],
                nextButtonText: element?["nextButtonText"],
                text: element?["text"],
                title: element?["title"],
                titleIconAnimationFile: element?["titleIconAnimationFile"],
                titleIconMaxWidth: element?["titleIconMaxWidth"],
                id: GenericIdentifier(id: element?["id"]));
            formStep.add(step);
          }
        });
        form(
            steps: formStep,
            name: key,
            googleMapAPIKey: value?["googleMapAPIKey"],
            backgroundAnimationFile: value?["backgroundAnimationFile"],
            backgroundAlignment:
                alignmentFromString(value?["backgroundAlignment"]),
            initialPosition: value?["initialPosition"] != null
                ? GeoLocationResult(
                    latitude: value?["initialPosition"]["latitude"],
                    longitude: value?["initialPosition"]["longitude"])
                : null);
      });
    }
    return this;
  }

  FormStack addResultForm(Identifier identifier, ResultFormat? resultFormat,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms["formName"];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry.id?.id == identifier.id) {
          entry.resultFormat = resultFormat;
        }
      }
    }
    return this;
  }

  FormStack addOnValidationError(
      Identifier identifier, Function(String)? onValidationError,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is QuestionStep) {
          if (entry.id?.id == identifier.id) {
            entry.onValidationError = onValidationError;
          }
        }
      }
    }
    return this;
  }

  FormStack systemBackNavigation(
      bool disabled, VoidCallback onBackNavigationClick,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      formStack.preventSystemBackNavigation = disabled;
      formStack.onSystemNagiationBackClick = onBackNavigationClick;
    }
    return this;
  }

  FormStack addCompletionCallback(
    Identifier identifier, {
    String? formName = "default",
    Function(Map<String, dynamic>)? onFinish,
    OnBeforeFinishCallback? onBeforeFinishCallback,
  }) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is CompletionStep) {
          if (entry.id?.id == identifier.id) {
            entry.onFinish = onFinish;
            entry.onBeforeFinishCallback = onBeforeFinishCallback;
          }
        }
      }
    }
    return this;
  }

  Widget render({String name = "default"}) {
    return FormStackView(_forms[name]!);
  }
}
