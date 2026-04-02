import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// View for the structured consent document step.
// ignore: must_be_immutable
class ConsentStepViewWidget extends BaseStepView<ConsentStep> {
  ConsentStepViewWidget(super.formStackForm, super.formStep, super.text,
      {super.key, super.title});

  bool _isAgreed = false;
  bool _isInitialized = false;

  @override
  Widget? buildWInputWidget(BuildContext context, ConsentStep formStep) {
    if (!_isInitialized) {
      _isAgreed = formStep.result == true;
      _isInitialized = true;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Consent sections list
            if (formStep.sections.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  cacheExtent: 300,
                  itemCount: formStep.sections.length,
                  itemBuilder: (context, index) {
                    return _buildSectionTile(context, formStep.sections[index]);
                  },
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            // Agreement checkbox
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: formStep.disabled
                  ? null
                  : () {
                      setState(() {
                        _isAgreed = !_isAgreed;
                        formStep.result = _isAgreed;
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isAgreed,
                      onChanged: formStep.disabled
                          ? null
                          : (value) {
                              setState(() {
                                _isAgreed = value ?? false;
                                formStep.result = _isAgreed;
                              });
                            },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          formStep.agreementText,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTile(BuildContext context, ConsentSection section) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            section.icon ?? section.defaultIcon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(section.title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(section.summary,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        children: [
          if (section.content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(section.content!,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return _isAgreed;
  }

  @override
  String validationError() => "You must agree to continue.";

  @override
  dynamic resultValue() => _isAgreed;

  @override
  void requestFocus() {}

  @override
  void clearFocus() {}
}
