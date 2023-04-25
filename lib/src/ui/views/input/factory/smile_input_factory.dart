// ignore: must_be_immutable
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/smile_input_field.dart';

///
/// Create Smile input widget .
/// I will add more type of smile type inputs later.
///
// ignore: must_be_immutable
class SmileInputWidget extends SmileInputWidgetView {
  SmileInputWidget(
      super.formKitForm, super.formStep, super.text, super.resultFormat,
      {super.key, super.title});

  ///
  ///Factory method to create smile wiget.
  ///
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
