import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/nested_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class NestedStepView extends BaseStepView<NestedStep> {
  NestedStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, cancellable});

  List<BaseStepView> componets = [];
  ResultFormat? resultFormat;

  @override
  Widget? buildWInputWidget(BuildContext context, NestedStep formStep) {
    if (componets.isEmpty) {
      formStep.steps?.forEach((element) {
        FormStep questions = element;
        questions.componentOnly = true;
        componets.add(questions.buildView(formKitForm) as BaseStepView);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(milliseconds: 2));
      requestFocus();
    });
    return Wrap(
      spacing: 14,
      runSpacing: formStep.verticalPadding.toDouble(),
      children: componets,
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    bool isAllValid = true;
    for (var element in componets) {
      var isAllValidM = element.isValid();
      if (!isAllValidM) {
        isAllValid = isAllValidM;
        element.showValidationError();
      }
    }
    if (formStep.validationExpression.isNotEmpty) {
      resultFormat = ResultFormat.expression(formStep.validationExpression);
      isAllValid = resultFormat!.isValid(resultValue());
    }
    return isAllValid;
  }

  @override
  String validationError() {
    return resultFormat?.error() ?? "";
  }

  @override
  resultValue() {
    Map<String, dynamic> result = {};
    for (var element in componets) {
      element.formStep.result = element.resultValue();
      result.putIfAbsent(
          element.formStep.id?.id ?? "", () => element.resultValue());
    }

    return result;
  }

  @override
  void requestFocus() {
    if (componets.isNotEmpty) {
      componets.first.requestFocus();
    }
  }

  @override
  void clearFocus() {}
}

//  height: min(
//           MediaQuery.of(context).size.height - kToolbarHeight * 0.8, 1024),
//       width: min(MediaQuery.of(context).size.width * 0.8, 1024),
