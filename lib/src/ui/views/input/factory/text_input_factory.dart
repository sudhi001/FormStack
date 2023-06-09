// ignore: must_be_immutable
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/text_input_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

///
/// TextFeildWidgetView Create and disply all textfield like ui.
///
///
// ignore: must_be_immutable
class TextFeildWidgetView extends TextFieldInputWidgetView {
  TextFeildWidgetView(super.formKitForm, super.formStep, super.text,
      super.resultFormat, super.formatter,
      {super.key,
      super.title,
      super.keyboardType,
      super.textCapitalization,
      super.numberOfLines = 1,
      super.filter = const []});

  ///
  /// Creat Email input field
  ///
  factory TextFeildWidgetView.email(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFeildWidgetView(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      [
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z@.]")),
        LengthLimitingTextInputFormatter(
            questionStep.lengthLimit == -1 ? 30 : questionStep.lengthLimit)
      ],
      title: title,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
    );
  }

  ///
  /// Creat Name input field
  ///
  factory TextFeildWidgetView.name(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFeildWidgetView(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
        LengthLimitingTextInputFormatter(
            questionStep.lengthLimit == -1 ? 30 : questionStep.lengthLimit)
      ],
      title: title,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    );
  }

  ///
  /// Creat File input field
  ///
  factory TextFeildWidgetView.file(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<dynamic>? filter) {
    return TextFeildWidgetView(
        formKitForm, questionStep, text, resultFormat, const [],
        title: title,
        keyboardType: TextInputType.none,
        textCapitalization: TextCapitalization.none,
        filter: filter ??
            [
              LengthLimitingTextInputFormatter(questionStep.lengthLimit == -1
                  ? 255
                  : questionStep.lengthLimit)
            ]);
  }

  ///
  /// Creat Password input field
  ///
  factory TextFeildWidgetView.password(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFeildWidgetView(
        formKitForm,
        questionStep,
        text,
        resultFormat,
        [
          LengthLimitingTextInputFormatter(
              questionStep.lengthLimit == -1 ? 30 : questionStep.lengthLimit)
        ],
        title: title,
        keyboardType: TextInputType.visiblePassword);
  }

  ///
  /// Creat Text input field
  ///
  factory TextFeildWidgetView.text(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int? numberOfLines) {
    return TextFeildWidgetView(
        formKitForm,
        questionStep,
        text,
        resultFormat,
        [
          LengthLimitingTextInputFormatter(
              questionStep.lengthLimit == -1 ? 255 : questionStep.lengthLimit)
        ],
        title: title,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        numberOfLines: numberOfLines);
  }

  ///
  /// Creat Number input field
  ///
  factory TextFeildWidgetView.number(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFeildWidgetView(
      formKitForm,
      questionStep,
      text,
      resultFormat,
      [
        (questionStep.mask != null)
            ? MaskTextInputFormatter(
                mask: questionStep.mask,
                filter: {"#": RegExp(r'[0-9]')},
                type: MaskAutoCompletionType.lazy)
            : FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        LengthLimitingTextInputFormatter(
            questionStep.lengthLimit == -1 ? 30 : questionStep.lengthLimit)
      ],
      title: title,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.none,
    );
  }
}
