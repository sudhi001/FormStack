import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/step/question_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class DateInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final DateInputFormats format;
  DateInputWidgetView(
      super.formKitForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.format = DateInputFormats.dateOnly});

  final FocusNode _focusNode = FocusNode();
  DateTime? chosenDateTime;
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      DateResultType dateResultType = cast(resultFormat);
      chosenDateTime = DateFormat(dateResultType.format).parse(formStep.result);
    } else {
      chosenDateTime = DateTime.now();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
    return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 150),
        child: ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: CupertinoDatePicker(
            key: UniqueKey(),
            mode: format == DateInputFormats.dateTime
                ? CupertinoDatePickerMode.dateAndTime
                : format == DateInputFormats.dateOnly
                    ? CupertinoDatePickerMode.date
                    : CupertinoDatePickerMode.time,
            initialDateTime: chosenDateTime,
            onDateTimeChanged: (DateTime newDateTime) {
              chosenDateTime = newDateTime;
            },
          ),
        ));
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    return resultFormat.isValid(chosenDateTime);
  }

  @override
  String validationError() {
    _focusNode.requestFocus();
    return resultFormat.error();
  }

  @override
  dynamic resultValue() {
    return chosenDateTime?.toUtc();
  }

  @override
  void requestFocus() {
    _focusNode.requestFocus();
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

enum DateInputFormats {
  dateOnly,
  dateTime,
  timeOnly,
}
