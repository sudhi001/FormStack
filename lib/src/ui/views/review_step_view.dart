import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// View that displays all form results for review before final submission.
// ignore: must_be_immutable
class ReviewStepView extends BaseStepView<ReviewStep> {
  ReviewStepView(
    super.formStackForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
  });

  @override
  Widget? buildWInputWidget(BuildContext context, ReviewStep formStep) {
    formStackForm.generateResult();
    final reviewable = _reviewableAnswers();

    if (reviewable.isEmpty) {
      return const Center(child: Text("No answers to review."));
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      child: ListView.separated(
        cacheExtent: 300,
        shrinkWrap: true,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: reviewable.length,
        itemBuilder: (context, index) {
          final entry = reviewable[index];
          return _buildResultTile(context, entry.key, entry.value);
        },
      ),
    );
  }

  /// The entries worth showing on a review screen.
  ///
  /// The flat result map carries one entry per step, including the steps that
  /// never ask anything — the review step itself, instructions, the completion
  /// step — so an unfiltered list rendered them all as "Not provided".
  /// Answers nested inside a group are kept: they have no top-level step, and
  /// they are exactly what the user came to check.
  List<MapEntry<String, dynamic>> _reviewableAnswers() {
    return formStackForm.result.entries.where((entry) {
      final step = formStackForm.getStep(entry.key);
      if (step == null) return true;
      return step is QuestionStep || step is RepeatStep;
    }).toList();
  }

  Widget _buildResultTile(BuildContext context, String key, dynamic value) {
    final displayValue = _formatValue(value);
    return ListTile(
      dense: true,
      title: Text(
        _formatKey(key),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          displayValue,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase or snake_case to human-readable
    return key
        .replaceAllMapped(RegExp(r'[_]'), (m) => ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ')
        .trim();
  }

  String _formatValue(dynamic value) {
    if (value == null) return "Not provided";
    if (value is bool) return value ? "Yes" : "No";
    if (value is DateTime) {
      return "${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}";
    }
    if (value is List<Options>) {
      return value.map((o) => o.title).join(", ");
    }
    if (value is List<KeyValue>) {
      return value.map((kv) => "${kv.key}: ${kv.value}").join(", ");
    }
    if (value is List) {
      return value.map((e) => e.toString()).join(", ");
    }
    if (value is Map) {
      return value.entries.map((e) => "${e.key}: ${e.value}").join(", ");
    }
    final str = value.toString();
    // Truncate base64 strings (signatures, images)
    if (str.length > 100) return "${str.substring(0, 50)}... (data)";
    return str;
  }

  @override
  bool isValid() => true;

  @override
  String validationError() => "";

  @override
  dynamic resultValue() => DateTime.now().toUtc();

  @override
  void requestFocus() {}

  @override
  void clearFocus() {}
}
