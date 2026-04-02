import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class RankingInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final List<Options> options;

  RankingInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, required this.options});

  late List<Options> _rankedOptions;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      if (formStep.result is List<Options>) {
        _rankedOptions = List.from(formStep.result as List<Options>);
      } else {
        _rankedOptions = List.from(options);
      }
      _isInitialized = true;
    }

    return Container(
      constraints:
          const BoxConstraints(minWidth: 300, maxWidth: 400, maxHeight: 400),
      child: StatefulBuilder(builder: (context, setState) {
        return ReorderableListView.builder(
          shrinkWrap: true,
          itemCount: _rankedOptions.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _rankedOptions.removeAt(oldIndex);
              _rankedOptions.insert(newIndex, item);
              formStep.result = _rankedOptions;
            });
          },
          itemBuilder: (context, index) {
            final option = _rankedOptions[index];
            return Card(
              key: ValueKey(option.key),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(option.title,
                    style: Theme.of(context).textTheme.bodyMedium),
                subtitle: option.subTitle != null
                    ? Text(option.subTitle!,
                        style: Theme.of(context).textTheme.bodySmall)
                    : null,
                trailing: const Icon(Icons.drag_handle, color: Colors.grey),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_rankedOptions);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _rankedOptions;

  @override
  void clearFocus() {}
}
