import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Calculated field that auto-computes its value from other step results.
/// Displays the computed value as read-only text.
// ignore: must_be_immutable
class CalculateInputWidgetView extends BaseStepView<QuestionStep> {
  final dynamic Function(Map<String, dynamic>)? calculateCallback;

  CalculateInputWidgetView(super.formStackForm, super.formStep, super.text,
      {super.key, super.title, this.calculateCallback});

  dynamic _calculatedValue;

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) {
    // Compute value from all current results
    formStackForm.generateResult();
    if (calculateCallback != null) {
      _calculatedValue = calculateCallback!(formStackForm.result);
      formStep.result = _calculatedValue;
    }

    if (_calculatedValue == null) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _calculatedValue.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          if (formStep.helperText != null) ...[
            const SizedBox(height: 4),
            Text(formStep.helperText!,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  @override
  bool isValid() => true;

  @override
  String validationError() => "";

  @override
  dynamic resultValue() => _calculatedValue;

  @override
  void requestFocus() {}

  @override
  void clearFocus() {}
}
