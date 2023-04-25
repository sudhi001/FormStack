import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class InstructionStepView extends BaseStepView<InstructionStep> {
  InstructionStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, InstructionStep formStep) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DynamicData instruction = formStep.instructions![index];
            return Center(
                child: ListTile(
                    title: Text(instruction.title),
                    trailing: instruction.trailing == null
                        ? null
                        : Text(instruction.trailing ?? ""),
                    leading: instruction.leading == null
                        ? null
                        : Text(instruction.leading ?? "",
                            style: Theme.of(context).textTheme.headlineMedium),
                    subtitle: instruction.subTitle == null
                        ? null
                        : Text(instruction.subTitle ?? "")));
          },
          itemCount: formStep.instructions?.length ?? 0,
        ));
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  String validationError() {
    return "";
  }

  @override
  resultValue() {
    return DateTime.now();
  }

  @override
  void requestFocus() {}
  @override
  void clearFocus() {}
}
