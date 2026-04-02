import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class NPSInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;

  NPSInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});

  int? _selectedScore;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _selectedScore = formStep.result as int?;
      _isInitialized = true;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: List.generate(11, (index) {
                final isSelected = _selectedScore == index;
                Color bgColor;
                if (index <= 6) {
                  bgColor = FormStackTheme.npsDetractorColor(context,
                      selected: isSelected);
                } else if (index <= 8) {
                  bgColor = FormStackTheme.npsPassiveColor(context,
                      selected: isSelected);
                } else {
                  bgColor = FormStackTheme.npsPromoterColor(context,
                      selected: isSelected);
                }
                return SizedBox(
                  width: 40,
                  height: 40,
                  child: Material(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: formStep.disabled
                          ? null
                          : () {
                              setState(() {
                                _selectedScore = index;
                                formStep.result = index;
                              });
                            },
                      child: Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Not at all likely',
                    style: Theme.of(context).textTheme.bodySmall),
                Text('Extremely likely',
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
    return resultFormat.isValid(_selectedScore);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _selectedScore;

  @override
  void clearFocus() {}
}
