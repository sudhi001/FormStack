import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class SliderInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final num minValue;
  final num maxValue;
  final num stepValue;

  SliderInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key,
      super.title,
      this.minValue = 0,
      this.maxValue = 100,
      this.stepValue = 1});

  double _currentValue = 0;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _currentValue =
          (formStep.result as num?)?.toDouble() ?? minValue.toDouble();
      _isInitialized = true;
    }

    return Container(
      constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentValue.toStringAsFixed(stepValue % 1 == 0 ? 0 : 1),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(minValue.toString(),
                    style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                  child: Slider(
                    value: _currentValue,
                    min: minValue.toDouble(),
                    max: maxValue.toDouble(),
                    divisions: stepValue > 0
                        ? ((maxValue - minValue) / stepValue).round()
                        : null,
                    label: _currentValue
                        .toStringAsFixed(stepValue % 1 == 0 ? 0 : 1),
                    onChanged: formStep.disabled
                        ? null
                        : (value) {
                            setState(() {
                              _currentValue = value;
                              formStep.result = value;
                            });
                          },
                  ),
                ),
                Text(maxValue.toString(),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        );
      }),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_currentValue);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _currentValue;

  @override
  void clearFocus() {}
}
