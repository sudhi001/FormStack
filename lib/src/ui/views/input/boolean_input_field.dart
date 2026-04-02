import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Boolean Yes/No input widget with two toggle buttons.
// ignore: must_be_immutable
class BooleanInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final String yesLabel;
  final String noLabel;

  BooleanInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.yesLabel = "Yes", this.noLabel = "No"});

  bool? _selectedValue;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _selectedValue = formStep.result as bool?;
      _isInitialized = true;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
      child: StatefulBuilder(builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildOption(
                context,
                label: yesLabel,
                icon: Icons.check_circle_outline,
                isSelected: _selectedValue == true,
                onTap: formStep.disabled
                    ? null
                    : () {
                        setState(() {
                          _selectedValue = true;
                          formStep.result = true;
                        });
                      },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOption(
                context,
                label: noLabel,
                icon: Icons.cancel_outlined,
                isSelected: _selectedValue == false,
                onTap: formStep.disabled
                    ? null
                    : () {
                        setState(() {
                          _selectedValue = false;
                          formStep.result = false;
                        });
                      },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.08) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_selectedValue);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _selectedValue;

  @override
  void clearFocus() {}
}
