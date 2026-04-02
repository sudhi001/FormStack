import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

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
                if (isSelected) {
                  bgColor = index <= 6
                      ? Colors.red.shade400
                      : index <= 8
                          ? Colors.amber.shade400
                          : Colors.green.shade400;
                } else {
                  bgColor = index <= 6
                      ? Colors.red.shade50
                      : index <= 8
                          ? Colors.amber.shade50
                          : Colors.green.shade50;
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
                            color: isSelected ? Colors.white : Colors.black87,
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
