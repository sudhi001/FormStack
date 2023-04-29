// ignore: must_be_immutable
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/choice_input_field.dart';

///
/// Single & Mutiple choice compoents creation
///
///
// ignore: must_be_immutable
class ChoiceInputWidget extends ChoiceInputWidgetView {
  ChoiceInputWidget(super.formKitForm, super.formStep, super.text,
      super.resultFormat, super.options,
      {super.key,
      super.title,
      super.singleSelection,
      super.autoTrigger,
      required super.selectionType});

  ///
  ///Create Single choice components.
  ///
  factory ChoiceInputWidget.single(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<Options>? options,
      SelectionType selectionType,
      bool autoTrigger) {
    return ChoiceInputWidget(
        formKitForm, questionStep, text, resultFormat, options ?? [],
        title: title,
        singleSelection: true,
        autoTrigger: autoTrigger,
        selectionType: selectionType);
  }

  ///
  /// Create mutiple choice components.
  ///
  factory ChoiceInputWidget.multiple(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      SelectionType selectionType,
      List<Options>? options) {
    return ChoiceInputWidget(
        formKitForm, questionStep, text, resultFormat, options ?? [],
        title: title, singleSelection: false, selectionType: selectionType);
  }
}
