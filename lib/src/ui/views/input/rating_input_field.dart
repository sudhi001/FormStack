import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';

// ignore: must_be_immutable
class RatingInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final int maxRating;

  RatingInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.maxRating = 5});

  int _selectedRating = 0;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _selectedRating = (formStep.result as int?) ?? 0;
      _isInitialized = true;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
      child: StatefulBuilder(builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: formStep.disabled
                  ? null
                  : () {
                      setState(() {
                        _selectedRating = starIndex;
                        formStep.result = starIndex;
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  starIndex <= _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 40,
                  color: starIndex <= _selectedRating
                      ? Colors.amber
                      : Colors.grey.shade400,
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_selectedRating);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _selectedRating;

  @override
  void clearFocus() {}
}
