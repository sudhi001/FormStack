import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:formstack/formstack.dart';

/// View for RepeatStep - renders child steps N times with add/remove controls.
// ignore: must_be_immutable
class RepeatStepView extends BaseStepView<RepeatStep> {
  RepeatStepView(
    super.formStackForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
  });

  final List<List<BaseStepView>> _repetitions = [];
  bool _isInitialized = false;

  @override
  Widget? buildWInputWidget(BuildContext context, RepeatStep formStep) {
    if (!_isInitialized) {
      // Initialize with existing results or minimum repetitions
      // A restored draft arrives as List<dynamic> of Map<String, dynamic>
      // rather than the List<Map<String, dynamic>> resultValue() produces, so
      // an unchecked cast here threw on resume.
      final saved = formStep.result;
      final existingResults = saved is List
          ? saved
                .whereType<Map<dynamic, dynamic>>()
                .map(Map<String, dynamic>.from)
                .toList()
          : const <Map<String, dynamic>>[];
      final initialCount = existingResults.isEmpty
          ? formStep.minRepeat
          : existingResults.length;
      for (int i = 0; i < initialCount; i++) {
        _addRepetition(i < existingResults.length ? existingResults[i] : null);
      }
      _isInitialized = true;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(300),
                  shrinkWrap: true,
                  itemCount: _repetitions.length,
                  itemBuilder: (context, index) {
                    return _buildRepetitionCard(context, index, setState);
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_repetitions.length < formStep.maxRepeat)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _addRepetition(null);
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: Text(formStep.addButtonText),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRepetitionCard(
    BuildContext context,
    int index,
    StateSetter setState,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${index + 1}",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (_repetitions.length > formStep.minRepeat)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    iconSize: 20,
                    onPressed: () {
                      setState(() {
                        for (var component in _repetitions[index]) {
                          component.dispose();
                        }
                        _repetitions.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            Wrap(spacing: 7, runSpacing: 7, children: _repetitions[index]),
          ],
        ),
      ),
    );
  }

  void _addRepetition(Map<String, dynamic>? prefilledData) {
    if (formStep.steps == null) return;
    final components = <BaseStepView>[];
    for (var step in formStep.steps!) {
      final clone = _cloneStep(step);
      clone.componentOnly = true;
      if (prefilledData != null && clone.id?.id != null) {
        clone.result = prefilledData[clone.id!.id!];
      }
      components.add(clone.buildView(formStackForm) as BaseStepView);
    }
    _repetitions.add(components);
  }

  FormStep _cloneStep(FormStep original) {
    if (original is QuestionStep) {
      return QuestionStep(
        id: GenericIdentifier(id: original.id?.id),
        title: original.title ?? "",
        inputType: original.inputType,
        text: original.text,
        inputStyle: original.inputStyle,
        hint: original.hint,
        label: original.label,
        isOptional: original.isOptional,
        width: original.width,
        resultFormat: original.resultFormat,
      );
    }
    return original;
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    for (var rep in _repetitions) {
      for (var component in rep) {
        if (!component.isValid()) {
          component.showValidationError();
          return false;
        }
      }
    }
    return _repetitions.length >= formStep.minRepeat;
  }

  @override
  String validationError() =>
      "At least ${formStep.minRepeat} entries required.";

  @override
  dynamic resultValue() {
    final results = <Map<String, dynamic>>[];
    for (var rep in _repetitions) {
      final entry = <String, dynamic>{};
      for (var component in rep) {
        component.formStep.result = component.resultValue();
        entry[component.formStep.id?.id ?? ""] = component.resultValue();
      }
      results.add(entry);
    }
    return results;
  }

  @override
  void requestFocus() {
    if (_repetitions.isNotEmpty && _repetitions.first.isNotEmpty) {
      _repetitions.first.first.requestFocus();
    }
  }

  @override
  void clearFocus() {
    for (var rep in _repetitions) {
      for (var component in rep) {
        component.clearFocus();
      }
    }
  }

  @override
  void dispose() {
    // The repetition views are in the widget tree, so the framework disposes
    // each as it unmounts. Cascading here as well disposed them twice, which
    // trips "A TextEditingController was used after being disposed".
    _repetitions.clear();
    super.dispose();
  }
}
