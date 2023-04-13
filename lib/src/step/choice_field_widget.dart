import 'package:flutter/material.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/step/question_step.dart';

// ignore: must_be_immutable
class ChoiceInputWidgetView extends InputWidgetView<QuestionStep> {
  final ResultFormat resultFormat;
  final List<Options> options;
  final bool singleSelection;
  final bool autoTrigger;
  ChoiceInputWidgetView(super.formKitForm, super.formStep, super.text,
      this.resultFormat, this.options,
      {super.key,
      super.title,
      this.singleSelection = false,
      this.autoTrigger = false});

  final FocusNode _focusNode = FocusNode();
  List<String> selectedKey = [];
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null && formStep.result is List<String>) {
      selectedKey = formStep.result as List<String>;
    } else {
      selectedKey = [];
    }

    return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 300),
        child: StatefulBuilder(builder: (context, setState) {
          return ListView.separated(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.grey, thickness: 1),
              itemBuilder: (context, index) => ListTile(
                    onTap: () {
                      setState(
                        () {
                          if (singleSelection) {
                            selectedKey.clear();
                            selectedKey.add(options[index].key);
                          } else {
                            if (!selectedKey.contains(options[index].key)) {
                              selectedKey.add(options[index].key);
                            } else {
                              selectedKey.remove(options[index].key);
                            }
                          }
                          if (autoTrigger) {
                            onNext();
                          }
                        },
                      );
                    },
                    title: Text(options[index].text),
                    trailing: selectedKey.contains(options[index].key)
                        ? Icon(
                            Icons.check,
                            color: formKitForm.primaryColor,
                          )
                        : null,
                  ),
              itemCount: options.length,
              shrinkWrap: true);
        }));
  }

  @override
  bool isValid() {
    return resultFormat.isValid(selectedKey);
  }

  @override
  String validationError() {
    _focusNode.requestFocus();
    return resultFormat.error();
  }

  @override
  dynamic resultValue() {
    return selectedKey;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}
