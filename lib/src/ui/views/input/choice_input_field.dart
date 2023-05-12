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
  final SelectionType selectionType;
  ChoiceInputWidgetView(super.formKitForm, super.formStep, super.text,
      this.resultFormat, this.options,
      {super.key,
      super.title,
      required this.selectionType,
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
          if (selectionType == SelectionType.dropdown) {
            return Container(
                padding: formStep.componentsStyle == ComponentsStyle.basic
                    ? const EdgeInsets.all(5)
                    : null,
                decoration: formStep.componentsStyle == ComponentsStyle.basic
                    ? BoxDecoration(
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(5),
                      )
                    : null,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    focusColor: Colors.transparent,
                    hint: selectedKey.isEmpty
                        ? const Text('Select...')
                        : Text(selectedKey.first),
                    isExpanded: true,
                    iconSize: 30.0,
                    items: options.map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val.key,
                          child: Text(val.title),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(
                          () {
                            if (singleSelection) {
                              selectedKey.clear();
                              selectedKey.add(val);
                            } else {
                              if (!selectedKey.contains(val)) {
                                selectedKey.add(val);
                              } else {
                                selectedKey.remove(val);
                              }
                            }
                            if (autoTrigger) {
                              onNextButtonClick();
                            }
                          },
                        );
                        HapticFeedback.selectionClick();
                        showValidationError();
                      }
                    },
                  ),
                ));
          }
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
                    onTap: selectionType == SelectionType.toggle
                        ? null
                        : () => onItemTap(setState, index),
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
                        ? _selectionIcon(setState, index)
                        : selectionType != SelectionType.tick
                            ? _selectionIcon(setState, index)
                            : (selectedKey.contains(options[index].key)
                                ? _selectionIcon(setState, index)
                                : null),
                  ),
                )),
            itemCount: options.length,
          );
        }));
  }

  void onItemTap(setState, int index) {
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
  }

  Widget _selectionIcon(setState, int index) {
    switch (selectionType) {
      case SelectionType.arrow:
        return const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.grey, size: 24);
      case SelectionType.tick:
        return Icon(Icons.check, color: formKitForm.primaryColor);
      case SelectionType.toggle:
        return Switch(
          inactiveThumbColor: Colors.black,
          activeColor: Colors.black,
          activeTrackColor: const Color.fromRGBO(242, 242, 247, 1),
          inactiveTrackColor: const Color.fromRGBO(242, 242, 247, 1),
          value: selectedKey.contains(options[index].key),
          onChanged: (bool value) {
            onItemTap(setState, index);
          },
        );
      default:
        return Icon(Icons.check, color: formKitForm.primaryColor);
    }
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
