// ignore: must_be_immutable
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/text_input_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

///
/// TextFieldWidgetView creates and displays all text field UI components.
///
///
// ignore: must_be_immutable
class TextFieldWidgetView extends TextFieldInputWidgetView {
  TextFieldWidgetView(super.formStackForm, super.formStep, super.text,
      super.resultFormat, super.formatter,
      {super.key,
      super.title,
      super.keyboardType,
      super.textCapitalization,
      super.numberOfLines = 1,
      super.filter = const []});

  ///
  /// Create Email input field
  ///
  factory TextFieldWidgetView.email(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFieldWidgetView(
      formStackForm,
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
  /// Create Name input field
  ///
  factory TextFieldWidgetView.name(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFieldWidgetView(
      formStackForm,
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
  /// Create File input field
  ///
  factory TextFieldWidgetView.file(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<dynamic>? filter) {
    return TextFieldWidgetView(
        formStackForm, questionStep, text, resultFormat, const [],
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
  /// Create Password input field
  ///
  factory TextFieldWidgetView.password(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFieldWidgetView(
        formStackForm,
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
  /// Create Text input field
  ///
  factory TextFieldWidgetView.text(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int? numberOfLines) {
    return TextFieldWidgetView(
        formStackForm,
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
  /// Create Number input field
  ///
  factory TextFieldWidgetView.number(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return TextFieldWidgetView(
      formStackForm,
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
