/// FormStack - A dynamic form and survey builder for Flutter.
///
/// Build forms from Dart objects or JSON with 28 input types, 30+ validators,
/// conditional navigation, nested steps, and customizable styling.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:formstack/formstack.dart';
///
/// FormStack.api().form(steps: [
///   QuestionStep(
///     title: "Your Name",
///     inputType: InputType.name,
///     id: GenericIdentifier(id: "name"),
///   ),
///   CompletionStep(
///     title: "Done!",
///     id: GenericIdentifier(id: "done"),
///     onFinish: (result) => print(result),
///   ),
/// ]);
///
/// // In your widget build method:
/// Scaffold(body: FormStack.api().render());
/// ```
///
/// See the [README](https://github.com/sudhi001/FormStack) for full documentation.
library;

export 'package:formstack/src/core/form_step.dart';
export 'package:formstack/src/core/ui_style.dart';
export 'package:formstack/src/formstack.dart';
export 'package:formstack/src/formstack_form.dart';
export 'package:formstack/src/input_types.dart';
export 'package:formstack/src/relevant/dynamic_relevant_condition.dart';
export 'package:formstack/src/relevant/expression_relevant_condition.dart';
export 'package:formstack/src/relevant/relevant_condition.dart';
export 'package:formstack/src/result/common_result.dart';
export 'package:formstack/src/result/identifiers.dart';
export 'package:formstack/src/result/result_format.dart';
export 'package:formstack/src/result/step_result.dart';
export 'package:formstack/src/step/completion_step.dart';
export 'package:formstack/src/step/display_step.dart';
export 'package:formstack/src/step/instruction_step.dart';
export 'package:formstack/src/step/nested_step.dart';
export 'package:formstack/src/step/question_step.dart';
export 'package:formstack/src/step/review_step.dart';
export 'package:formstack/src/step/consent_step.dart';
export 'package:formstack/src/ui/map/map_widget.dart';
export 'package:formstack/src/ui/views/step_view.dart';
export 'package:formstack/src/ui/views/base_step_view.dart';
