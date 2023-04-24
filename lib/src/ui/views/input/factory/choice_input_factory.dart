// ignore: must_be_immutable
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/choice_input_field.dart';

// ignore: must_be_immutable
class ChoiceInputWidget extends ChoiceInputWidgetView {
  ChoiceInputWidget(super.formKitForm, super.formStep, super.text,
      super.resultFormat, super.options,
      {super.key, super.title, super.singleSelection, super.autoTrigger});

  factory ChoiceInputWidget.single(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<Options>? options,
      bool autoTrigger) {
    return ChoiceInputWidget(
        formKitForm, questionStep, text, resultFormat, options ?? [],
        title: title, singleSelection: true, autoTrigger: autoTrigger);
  }
  factory ChoiceInputWidget.multiple(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<Options>? options) {
    return ChoiceInputWidget(
        formKitForm, questionStep, text, resultFormat, options ?? [],
        title: title, singleSelection: false);
  }
}