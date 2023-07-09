import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

abstract class FormStepView<T extends FormStep> extends StatelessWidget {
  final String? title;
  final String? text;

  final FormStackForm formKitForm;
  final T formStep;
  const FormStepView(this.formKitForm, this.formStep, this.text,
      {super.key, this.title});

  Widget buildWithFrom(BuildContext context, T formStep);

  void onNext();
  void onBack();
  void dispose();
  void onCancel();
  void onNextButtonClick();
  void onLoding(bool isLoading);
  Future<bool> onBeforeFinish(Map<String, dynamic> result);

  @override
  Widget build(BuildContext context) {
    return buildWithFrom(context, formStep);
  }
}
