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
  DateTime? _chosenDateTime;

  DateTime? get chosenDateTime {
    if (formStep.result != null) {
      if (formStep.result is String) {
        try {
          DateResultType? dateResultType = cast<DateResultType>(resultFormat);
          if (dateResultType != null) {
            return DateFormat(dateResultType.format).parse(formStep.result);
          }
        } catch (e) {
          // If parsing fails, return current date
          return DateTime.now();
        }
      } else if (formStep.result is DateTime) {
        return formStep.result as DateTime;
      }
    }
    return _chosenDateTime ?? DateTime.now();
  }

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    _chosenDateTime = chosenDateTime;
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
            minuteInterval: 1,
            key: UniqueKey(),
            mode: format == DateInputFormats.dateTime
                ? CupertinoDatePickerMode.dateAndTime
                : format == DateInputFormats.dateOnly
                    ? CupertinoDatePickerMode.date
                    : CupertinoDatePickerMode.time,
            initialDateTime: chosenDateTime,
            onDateTimeChanged: (DateTime newDateTime) {
              _chosenDateTime = newDateTime;
              formStep.result = newDateTime;
            },
          ),
        ));
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    return resultFormat.isValid(_chosenDateTime);
  }

  @override
  String validationError() {
    _focusNode.requestFocus();
    return resultFormat.error();
  }

  @override
  dynamic resultValue() {
    return _chosenDateTime;
  }

  @override
  void requestFocus() {
    _focusNode.requestFocus();
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
