import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/nested_question_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class NestedQuestionsStepView extends BaseStepView<NestedQuestionStep> {
  NestedQuestionsStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, cancellable});

  List<BaseStepView> componets = [];

  @override
  Widget? buildWInputWidget(BuildContext context, NestedQuestionStep formStep) {
    formStep.questions?.forEach((element) {
      QuestionStep questions = element;
      questions.componentOnly = true;
      componets.add(questions.buildView(formKitForm) as BaseStepView);
    });
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return componets[index];
      },
      itemCount: componets.length,
    );
  }

  @override
  bool isValid() {
    bool isAllValid = false;
    for (var element in componets) {
      isAllValid = element.isValid();
      if (!isAllValid) {
        element.showValidationError();
      }
    }
    return isAllValid;
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
  void clearFocus() {}
}


  //  height: min(
  //           MediaQuery.of(context).size.height - kToolbarHeight * 0.8, 1024),
  //       width: min(MediaQuery.of(context).size.width * 0.8, 1024),