// ignore: must_be_immutable
import 'package:flutter/services.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';
import 'package:formstack/src/step/choice_field_widget.dart';
import 'package:formstack/src/step/date_field_widget.dart';
import 'package:formstack/src/step/question_step.dart';
import 'package:formstack/src/step/smile_field_widget.dart';
import 'package:formstack/src/step/text_field_input.dart';

// ignore: must_be_immutable
class GlobalInputWidgetView extends TextFeildInputWidgetView {
  GlobalInputWidgetView(super.formKitForm, super.formStep, super.text,
      super.resultFormat, super.formatter,
      {super.key,
      super.title,
      super.keyboardType,
      super.textCapitalization,
      super.numberOfLines = 1});

  factory GlobalInputWidgetView.email(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return GlobalInputWidgetView(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      [
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z@.]")),
        LengthLimitingTextInputFormatter(30)
      ],
      title: title,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
    );
  }
  factory GlobalInputWidgetView.name(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return GlobalInputWidgetView(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
        LengthLimitingTextInputFormatter(30)
      ],
      title: title,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    );
  }
  factory GlobalInputWidgetView.password(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return GlobalInputWidgetView(formKitForm, questionStep, text, resultFormat,
        [LengthLimitingTextInputFormatter(30)],
        title: title, keyboardType: TextInputType.visiblePassword);
  }
  factory GlobalInputWidgetView.text(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int? numberOfLines) {
    return GlobalInputWidgetView(
        formKitForm, questionStep, text, resultFormat, const [],
        title: title,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        numberOfLines: numberOfLines);
  }
  factory GlobalInputWidgetView.number(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return GlobalInputWidgetView(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      [
        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        LengthLimitingTextInputFormatter(1000)
      ],
      title: title,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.none,
    );
  }
}

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
