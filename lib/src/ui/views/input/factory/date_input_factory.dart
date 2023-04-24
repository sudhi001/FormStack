// ignore: must_be_immutable
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/date_input_field.dart';

// ignore: must_be_immutable
class DateInputWidget extends DateInputWidgetView {
  DateInputWidget(
      super.formKitForm, super.formStep, super.text, super.resultFormat,
      {super.key, super.title, super.format});

  factory DateInputWidget.date(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return DateInputWidget(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      title: title,
      format: DateInputFormats.dateOnly,
    );
  }
  factory DateInputWidget.time(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return DateInputWidget(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      title: title,
      format: DateInputFormats.timeOnly,
    );
  }
  factory DateInputWidget.dateTime(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return DateInputWidget(formKitForm, questionStep, text, resultFormat,
        title: title, format: DateInputFormats.dateTime);
  }
}