// ignore: must_be_immutable
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/text_input_field.dart';

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
