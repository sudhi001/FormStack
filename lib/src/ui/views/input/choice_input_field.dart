import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class ChoiceInputWidgetView extends BaseStepView<QuestionStep> {
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
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 600),
        child: StatefulBuilder(builder: (context, setState) {
          return ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
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
                      onNextButtonClick();
                    }
                  },
                );
                HapticFeedback.selectionClick();
                showValidationError();
              },
              title: Text(options[index].text),
              trailing: autoTrigger
                  ? Icon(Icons.arrow_forward_ios,
                      color: formKitForm.primaryColor)
                  : (selectedKey.contains(options[index].key)
                      ? Icon(Icons.check, color: formKitForm.primaryColor)
                      : null),
            ),
            itemCount: options.length,
          );
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
  void requestFocus() {
    _focusNode.requestFocus();
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
