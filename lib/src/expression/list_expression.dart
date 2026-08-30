import 'package:collection/collection.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/expression/base_expression.dart';
import 'package:formstack/src/expression/expression_terms.dart';

/// Evaluates navigation conditions against a multi-selection answer.
///
/// Supports `IN`, `NOT_IN` and `FOR_ALL`, each taking a comma-separated list:
/// `IN dev,designer`. Selections are matched by [Options.key] when the answer
/// holds [Options], and by value otherwise.
class ListExpressionEvaluator extends ExpressionEvaluator<List<dynamic>> {
  /// Creates a [ListExpressionEvaluator] for [input].
  ListExpressionEvaluator(super.input);

  /// Whether [input] holds [value], comparing by [Options.key] where the
  /// selection is an [Options].
  bool _contains(List<dynamic> input, String value) =>
      input.firstWhereOrNull(
        (e) => e is Options ? e.key == value : e?.toString() == value,
      ) !=
      null;

  @override
  bool isValid(String condition, List<dynamic> input) {
    final terms = ExpressionTerms.parse(condition);
    if (terms.operator == 'FOR_ALL') return true;

    final wanted = terms.operands;
    switch (terms.operator) {
      case 'IN':
        return wanted.every((value) => _contains(input, value));
      case 'NOT_IN':
        // "None of these are selected". This was `!wanted.every(contains)` --
        // "not all of them" -- so a selection matching one of two listed
        // values still satisfied NOT_IN. It also compared Options objects
        // against strings, so it matched whatever was selected.
        return !wanted.any((value) => _contains(input, value));
      default:
        throw ArgumentError('Invalid operator: ${terms.operator}');
    }
  }
}
