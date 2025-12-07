import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
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
  ///Create the instance for the app
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

  /// Get the particular form from different instance.
  static FormStackForm? formByInstaceAndName(
      {String name = "default", String formName = "default"}) {
    return api(name: name)._forms[formName];
  }

  ///Clear your instance.
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

  /// Helper method to apply an action to a step matching the identifier
  void _applyToStep(
    FormStackForm formStack,
    Identifier identifier,
    void Function(FormStep) action,
  ) {
    for (var entry in formStack.steps) {
      if (entry is NestedStep) {
        entry.steps?.forEach((element) {
          if (element.id?.id == identifier.id) {
            action(element);
          }
        });
      } else if (entry.id?.id == identifier.id) {
        action(entry);
      }
    }
  }

  /// Helper method to apply an action to a step matching the identifier with type check
  void _applyToStepWithType<T extends FormStep>(
    FormStackForm formStack,
    Identifier identifier,
    void Function(T) action,
  ) {
    for (var entry in formStack.steps) {
      if (entry is NestedStep) {
        entry.steps?.forEach((element) {
          if (element is T && element.id?.id == identifier.id) {
            action(element);
          }
        });
      } else if (entry is T && entry.id?.id == identifier.id) {
        action(entry);
      }
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
      required MapKey mapKey,
      required LocationWrapper initialLocation,
      String? backgroundAnimationFile,
      Alignment? backgroundAlignment,
      required List<FormStep> steps}) {
    var list = LinkedList<FormStep>();
    list.addAll(steps);
    FormWizard form = FormWizard(list,
        mapKey: mapKey,
        fromInstanceName: instanceName,
        backgroundAlignment: backgroundAlignment,
        backgroundAnimationFile: backgroundAnimationFile,
        initialLocation: initialLocation);
    _forms.putIfAbsent(name, () => form);
    return this;
  }

  ///Load single json file from assets folder
  Future<FormStack> loadFromAsset(String path,
      {MapKey? mapKey, LocationWrapper? initialLocation}) async {
    return loadFromAssets([path],
        mapKey: mapKey, initialLocation: initialLocation);
  }

  ///Import and parse multiple JSON files located in the assets folder.
  Future<FormStack> loadFromAssets(List<String> files,
      {MapKey? mapKey, LocationWrapper? initialLocation}) async {
    for (var element in files) {
      try {
        String data = await rootBundle.loadString(element);
        Map<String, dynamic> jsonData = json.decode(data);
        ParserUtils.buildFormFromJson(
            this,
            jsonData,
            mapKey ?? MapKey("", "", ""),
            initialLocation ?? LocationWrapper(0, 0));
      } catch (e) {
        throw FormatException('Error loading asset $element: $e');
      }
    }
    return this;
  }

  /// Build the form from the JSON content
  Future<FormStack> buildFormFromJsonString(String data,
      {MapKey? mapKey, LocationWrapper? initialLocation}) async {
    try {
      Map<String, dynamic>? body = json.decode(data);
      return buildFormFromJson(body,
          mapKey: mapKey, initialLocation: initialLocation);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Build the form from Map (JSON)
  Future<FormStack> buildFormFromJson(Map<String, dynamic>? body,
      {MapKey? mapKey, LocationWrapper? initialLocation}) async {
    if (body == null) {
      throw ArgumentError('JSON body cannot be null');
    }
    ParserUtils.buildFormFromJson(this, body, mapKey ?? MapKey("", "", ""),
        initialLocation ?? LocationWrapper(0, 0));
    return this;
  }

  FormStack addResultForm(Identifier identifier, ResultFormat? resultFormat,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      _applyToStep(formStack, identifier, (step) {
        step.resultFormat = resultFormat;
      });
    }
    return this;
  }

  /// Add validation error listener
  FormStack addOnValidationError(
      Identifier identifier, Function(String)? onValidationError,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      _applyToStepWithType<QuestionStep>(formStack, identifier, (step) {
        step.onValidationError = onValidationError;
      });
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
      formStack.onSystemNavigationBackClick = onBackNavigationClick;
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
          if (entry.id?.id == identifier.id) {
            entry.onFinish = onFinish;
            if (onBeforeFinishCallback != null) {
              log("onBeforeFinishCallback is not supported for NestedStep");
            }
          } else {
            entry.steps?.forEach((element) {
              if (element is CompletionStep) {
                if (element.id?.id == identifier.id) {
                  element.onFinish = onFinish;
                  element.onBeforeFinishCallback = onBeforeFinishCallback;
                }
              } else if (element is QuestionStep) {
                if (element.id?.id == identifier.id) {
                  element.onFinish = onFinish;
                }
              }
            });
          }
        } else if (entry is CompletionStep) {
          if (entry.id?.id == identifier.id) {
            entry.onFinish = onFinish;
            entry.onBeforeFinishCallback = onBeforeFinishCallback;
          }
        } else if (entry is QuestionStep) {
          if (entry.id?.id == identifier.id) {
            entry.onFinish = onFinish;
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
      _applyToStep(formStack, identifier, (step) {
        step.error = message;
      });
    }
    return this;
  }

  /// Add the Result
  FormStack setOptions(List<Options> options, GenericIdentifier identifier,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (element is NestedStep) {
              element.steps?.forEach((ele) {
                if (ele.id?.id == identifier.id) {
                  if (ele is QuestionStep) {
                    ele.options = options;
                  }
                }
              });
            } else {
              if (element.id?.id == identifier.id) {
                if (element is QuestionStep) {
                  element.options = options;
                }
              }
            }
          });
        } else if (entry.id?.id == identifier.id) {
          if (entry is QuestionStep) {
            entry.options = options;
          }
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
            if (element is NestedStep) {
              element.steps?.forEach((ele) {
                if (input.containsKey(ele.id?.id)) {
                  ele.result = input[ele.id?.id];
                }
              });
            } else {
              if (input.containsKey(element.id?.id)) {
                element.result = input[element.id?.id];
              }
            }
          });
        } else if (input.containsKey(entry.id?.id)) {
          entry.result = input[entry.id?.id];
        }
      }
    }
    return this;
  }

  /// Disable UI
  FormStack setDisabledUI(List<String> disabledUIIds,
      {String? formName = "default"}) {
    FormStackForm? formStack = _forms[formName];
    if (formStack != null) {
      for (var entry in formStack.steps) {
        if (entry is NestedStep) {
          entry.steps?.forEach((element) {
            if (disabledUIIds.contains(element.id?.id)) {
              element.disabled = true;
            }
          });
        } else if (disabledUIIds.contains(entry.id?.id)) {
          entry.disabled = true;
        }
      }
    }
    return this;
  }

  /// Render the form to the UI
  /// Primary method to implement in your Widget tree.
  Widget render({String name = "default"}) {
    final form = _forms[name];
    if (form == null) {
      throw StateError(
          'Form "$name" not found. Create it first using FormStack.api().form(...)');
    }
    return FormStackView(form);
  }

  /// Get form progress (0.0 to 1.0)
  double getFormProgress({String name = "default"}) {
    FormStackForm? form = _forms[name];
    if (form == null) return 0.0;

    int totalSteps = form.steps.length;
    int completedSteps = 0;

    for (var step in form.steps) {
      if (step.result != null) {
        completedSteps++;
      }
    }

    return totalSteps > 0 ? completedSteps / totalSteps : 0.0;
  }

  /// Get current step index
  int getCurrentStepIndex({String name = "default"}) {
    FormStackForm? form = _forms[name];
    if (form == null) return 0;

    int currentIndex = 0;
    for (var step in form.steps) {
      if (step.result == null) break;
      currentIndex++;
    }

    return currentIndex;
  }

  /// Check if form is completed
  bool isFormCompleted({String name = "default"}) {
    FormStackForm? form = _forms[name];
    if (form == null) return false;

    for (var step in form.steps) {
      if (step.result == null && !(step.isOptional ?? false)) {
        return false;
      }
    }

    return true;
  }

  /// Get form statistics
  Map<String, dynamic> getFormStats({String name = "default"}) {
    FormStackForm? form = _forms[name];
    if (form == null) return {};

    int totalSteps = form.steps.length;
    int completedSteps = 0;
    int optionalSteps = 0;
    int requiredSteps = 0;

    for (var step in form.steps) {
      if (step.isOptional ?? false) {
        optionalSteps++;
      } else {
        requiredSteps++;
      }

      if (step.result != null) {
        completedSteps++;
      }
    }

    return {
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
      'requiredSteps': requiredSteps,
      'optionalSteps': optionalSteps,
      'progress': totalSteps > 0 ? completedSteps / totalSteps : 0.0,
      'isCompleted': isFormCompleted(name: name),
    };
  }

  /// Auto-save form data
  FormStack enableAutoSave(
      {String name = "default",
      Duration interval = const Duration(seconds: 30)}) {
    FormStackForm? form = _forms[name];
    if (form != null) {
      // Implementation would go here for auto-save functionality
      // This is a placeholder for future implementation
    }
    return this;
  }

  /// Add form analytics
  FormStack enableAnalytics({String name = "default"}) {
    FormStackForm? form = _forms[name];
    if (form != null) {
      // Implementation would go here for analytics functionality
      // This is a placeholder for future implementation
    }
    return this;
  }
}
