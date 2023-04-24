// ignore: must_be_immutable
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/smile_input_field.dart';

// ignore: must_be_immutable
class SmileInputWidget extends SmileInputWidgetView {
  SmileInputWidget(
      super.formKitForm, super.formStep, super.text, super.resultFormat,
      {super.key, super.title});

  factory SmileInputWidget.smile(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return SmileInputWidget(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      title: title,
    );
  }
}
