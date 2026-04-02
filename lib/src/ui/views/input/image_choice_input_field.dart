import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';

/// Image choice input widget - select from a grid of images.
///
/// Uses [Options.key] as the image asset path and [Options.title] as the label.
// ignore: must_be_immutable
class ImageChoiceInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final List<Options> options;
  final bool singleSelection;

  ImageChoiceInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key,
      super.title,
      required this.options,
      this.singleSelection = true});

  List<Options> _selectedOptions = [];
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      if (formStep.result is List<Options>) {
        _selectedOptions = List.from(formStep.result as List<Options>);
      }
      _isInitialized = true;
    }

    return Container(
      constraints: BoxConstraints(minWidth: 200, maxWidth: 500, maxHeight: 500),
      child: StatefulBuilder(builder: (context, setState) {
        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = _selectedOptions.contains(option);
            return _buildImageOption(
              context,
              option: option,
              isSelected: isSelected,
              onTap: formStep.disabled
                  ? null
                  : () {
                      setState(() {
                        if (singleSelection) {
                          _selectedOptions.clear();
                          _selectedOptions.add(option);
                        } else {
                          if (isSelected) {
                            _selectedOptions.remove(option);
                          } else {
                            _selectedOptions.add(option);
                          }
                        }
                        formStep.result = _selectedOptions;
                      });
                      HapticFeedback.selectionClick();
                    },
            );
          },
        );
      }),
    );
  }

  Widget _buildImageOption(
    BuildContext context, {
    required Options option,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildImage(option.key),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
              child: Text(
                option.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.check_circle,
                    size: 20, color: Theme.of(context).colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 48, color: Colors.grey));
    }
    return Image.asset(imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, size: 48, color: Colors.grey));
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_selectedOptions);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _selectedOptions;

  @override
  void clearFocus() {}
}
