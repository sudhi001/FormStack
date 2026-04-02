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
      super.formStackForm, super.formStep, super.text, super.resultFormat,
      {super.key, super.title, super.format});

  /// Create date only components
  factory DateInputWidget.date(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return DateInputWidget(
      formStackForm,
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
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return DateInputWidget(
      formStackForm,
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
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return DateInputWidget(formStackForm, questionStep, text, resultFormat,
        title: title, format: DateInputFormats.dateTime);
  }
}
