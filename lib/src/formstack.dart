import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/nested_step.dart';
import 'package:formstack/src/ui/views/formstack_view.dart';
import 'package:formstack/src/core/parser.dart';

///
///
/// FormStack - Comprehensive Library for Creating Dynamic Form
///
/// FormStack is a library designed to help developers create dynamic user interfaces in Flutter.
///  Specifically, the library is focused on creating forms and surveys using a JSON or Dart language model.
///
/// The primary goal of FormStack is to make it easy for developers to create dynamic UIs without having to write a lot of code.
///  By using a JSON or Dart model to define the structure of a form or survey, developers can quickly create UIs that are easy to customize and update.
///
///While the library was initially created to help developers create survey UIs, the focus has expanded to include any type of dynamic application UI.
/// With FormStack, developers can create UIs that are responsive and adaptable to different devices and screen sizes.
///
///Overall, FormStack is a powerful tool for creating dynamic user interfaces in Flutter.
///It offers a flexible and customizable approach to UI design, allowing developers to create UIs that are easy to use and maintain.
///
///```dart
///
///   await FormStack.api().loadFromAsset('assets/app.json');
///
///
/// class SampleScreen extends StatelessWidget {
///   const SampleScreen({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: FormStack.api().render(),
///     );
///   }
/// }
///
///```
///
///
///
class FormStack {
  // Ensures end-users cannot initialize the class.
  FormStack._();

  static final Map<String, FormStack> _delegate = {};

  final Map<String, FormStackForm> _forms = {};
  String instanceName = "";

  ///
  ///Create the instnce for the app
  /// name - instance name.
  ///
  static FormStack api({String name = "default"}) {
    if (!_delegate.containsKey(name)) {
      _delegate.putIfAbsent(name, () => FormStack._());
    }
    FormStack formStack = _delegate[name]!;
    formStack.instanceName = name;
    return formStack;
  }

  /// Get the purticular from from different instance.
  static FormStackForm? formByInstaceAndName(
      {String name = "default", String formName = "default"}) {
    return api(name: name)._forms[formName];
  }

  ///Clear your instant.
  ///Are you sure to use this.
  static void clearConfiguration() {
    _delegate.clear();
  }

  ///Clear forms from instance name .
  static void clearForms({String name = "default"}) {
    if (_delegate.containsKey(name)) {
      _delegate.remove(name);
    }
  }

  /// Load the form from dart language model
  ///
  ///```dart
  ///FormStack.api().form(steps: [
  ///   InstructionStep(
  ///       id: GenericIdentifier(id: "IS_STARTED"),
  ///       title: "Example Survey",
  ///       text: "Simple survey example using dart model",
  ///       cancellable: false),
  ///   QuestionStep(
  ///     title: "Name",
  ///     text: "Your name",
  ///     inputType: InputType.name,
  ///     id: GenericIdentifier(id: "NAME"),
  ///   )
  ///   CompletionStep(
  ///     id: GenericIdentifier(id: "IS_COMPLETED"),
  ///     title: "Survey Completed",
  ///     text: "ENd Of ",
  ///     onFinish: (result) {
  ///       debugPrint("Completed With Result : $result");
  ///     },
  ///   ),
  /// ]);
  ///
  ///````
  ///
  ///
  ///
  FormStack form(
      {String name = "default",
      String? googleMapAPIKey,
      GeoLocationResult? initialPosition,
      String? backgroundAnimationFile,
      Alignment? backgroundAlignment,
      required List<FormStep> steps}) {
    var list = LinkedList<FormStep>();
    list.addAll(steps);
    FormWizard form = FormWizard(list,
        googleMapAPIKey: googleMapAPIKey,
        fromInstanceName: instanceName,
        backgroundAlignment: backgroundAlignment,
        backgroundAnimationFile: backgroundAnimationFile);
    _forms.putIfAbsent(name, () => form);
    return this;
  }

  ///Load single json file from assets folder
  Future<FormStack> loadFromAsset(String path) async {
    return loadFromAssets([path]);
  }

  ///Import and parse multiple JSON files located in the assets folder.
  Future<FormStack> loadFromAssets(List<String> files) async {
    for (var element in files) {
      String data = await rootBundle.loadString(element);
      ParserUtils.buildFormFromJson(this, json.decode(data));
    }
    return this;
  }

  /// Build the form from the JSON content
  Future<FormStack> buildFormFromJsonString(String data) async {
    Map<String, dynamic>? body = await json.decode(data);
    return buildFormFromJson(body);
  }

  /// Build the from from Map (JSON)
  Future<FormStack> buildFormFromJson(Map<String, dynamic>? body) async {
    ParserUtils.buildFormFromJson(this, body);
    return this;
  }

  FormStack addResultForm(Identifier identifier, ResultFormat? resultFormat,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms["formName"];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (element.id?.id == identifier.id) {
              element.resultFormat = resultFormat;
            }
          });
        } else if (entry.id?.id == identifier.id) {
          entry.resultFormat = resultFormat;
        }
      }
    }
    return this;
  }

  /// Add validation error listener
  FormStack addOnValidationError(
      Identifier identifier, Function(String)? onValidationError,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (element is QuestionStep) {
              if (element.id?.id == identifier.id) {
                element.onValidationError = onValidationError;
              }
            }
          });
        } else if (entry is QuestionStep) {
          if (entry.id?.id == identifier.id) {
            entry.onValidationError = onValidationError;
          }
        }
      }
    }
    return this;
  }

  /// Prevent System back navigation or getting call back when the user click the system back button.
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

  /// Add the completion handler to add you logic when the form finish
  FormStack addCompletionCallback(
    Identifier identifier, {
    String? formName = "default",
    Function(Map<String, dynamic>)? onFinish,
    OnBeforeFinishCallback? onBeforeFinishCallback,
  }) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (element is CompletionStep) {
              if (element.id?.id == identifier.id) {
                element.onFinish = onFinish;
                element.onBeforeFinishCallback = onBeforeFinishCallback;
              }
            }
          });
        } else if (entry is CompletionStep) {
          if (entry.id?.id == identifier.id) {
            entry.onFinish = onFinish;
            entry.onBeforeFinishCallback = onBeforeFinishCallback;
          }
        }
      }
    }
    return this;
  }

  /// Add the Error
  FormStack setError(Identifier identifier, String message,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (element.id?.id == identifier.id) {
              element.error = message;
            }
          });
        } else if (entry.id?.id == identifier.id) {
          entry.error = message;
        }
      }
    }
    return this;
  }

  /// Add the Result
  FormStack setResult(Map<String, dynamic> input,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (input.containsKey(element.id?.id)) {
              element.result = input[element.id?.id];
            }
          });
        } else if (input.containsKey(entry.id?.id)) {
          entry.result = input[entry.id?.id];
        }
      }
    }
    return this;
  }

  /// Render the form to the UI
  /// Primary method to implement in you Widget tree.
  Widget render({String name = "default"}) {
    return FormStackView(_forms[name]!);
  }
}
