import 'package:flutter/cupertino.dart';
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
        decoration: formStep.componentsStyle == ComponentsStyle.minimal
            ? const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
              )
            : null,
        constraints:
            const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 600),
        child: StatefulBuilder(builder: (context, setState) {
          return ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            separatorBuilder: (context, index) => Divider(
                color: formStep.componentsStyle == ComponentsStyle.minimal
                    ? Colors.grey
                    : CupertinoColors.white,
                height: 5),
            itemBuilder: (context, index) => ClipRRect(
                borderRadius: formStep.componentsStyle == ComponentsStyle.basic
                    ? const BorderRadius.vertical(
                        top: Radius.circular(12),
                        bottom: Radius.circular(12),
                      )
                    : const BorderRadius.vertical(),
                child: Container(
                  color: formStep.componentsStyle == ComponentsStyle.basic
                      ? const Color.fromRGBO(242, 242, 247, 1)
                      : null,
                  padding: const EdgeInsets.all(7),
                  child: ListTile(
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
                    title: Text(options[index].title,
                        style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: options[index].subTitle != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(options[index].subTitle ?? "",
                                style: Theme.of(context).textTheme.bodySmall),
                          )
                        : null,
                    trailing: autoTrigger
                        ? const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                            size: 24,
                          )
                        : (selectedKey.contains(options[index].key)
                            ? Icon(Icons.check, color: formKitForm.primaryColor)
                            : null),
                  ),
                )),
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
