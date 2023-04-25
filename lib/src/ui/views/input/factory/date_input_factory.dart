// ignore: must_be_immutable
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/date_input_field.dart';

///
/// Date & DateTime related components creation
///
///
// ignore: must_be_immutable
class DateInputWidget extends DateInputWidgetView {
  DateInputWidget(
      super.formKitForm, super.formStep, super.text, super.resultFormat,
      {super.key, super.title, super.format});

//// Crete date Only components
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
  // Create Time only components
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

  /// Create Date and Time components
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
