import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Dragging a ranking option to a new position.
///
/// `ReorderableListView.onReorder` was deprecated in favour of
/// `onReorderItem`, and the two disagree about `newIndex`: the old callback
/// reported the index *before* the dragged item was lifted out, so every caller
/// had to write `if (newIndex > oldIndex) newIndex--`. The new one has already
/// made that adjustment. Migrating the callback without deleting the decrement —
/// or deleting the decrement without migrating — puts every downward drag one
/// place off, and the existing suite would not have noticed: it only checked
/// that a ranking question renders.
void main() {
  Future<void> pumpRanking(WidgetTester tester, List<Options> options) async {
    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'ranking'),
          inputType: InputType.ranking,
          title: 'Rank these',
          options: options,
        ),
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
    await tester.pumpAndSettle();
  }

  /// The order as the list currently displays it.
  List<String> visibleOrder(WidgetTester tester) {
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    return List.generate(list.itemCount, (i) {
      final tile = list.itemBuilder(tester.element(find.byType(ReorderableListView)), i);
      return (tile.key as ValueKey).value as String;
    });
  }

  testWidgets('the list starts in the declared order', (tester) async {
    await pumpRanking(tester, [
      Options('a', 'Alpha'),
      Options('b', 'Bravo'),
      Options('c', 'Charlie'),
    ]);
    expect(visibleOrder(tester), ['a', 'b', 'c']);
  });

  testWidgets('dragging the first item down lands it where it was dropped',
      (tester) async {
    await pumpRanking(tester, [
      Options('a', 'Alpha'),
      Options('b', 'Bravo'),
      Options('c', 'Charlie'),
    ]);

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    // Move 'a' to the last position. With onReorderItem, newIndex is already
    // expressed against the list with 'a' removed, so 2 means "last".
    list.onReorderItem!(0, 2);
    await tester.pumpAndSettle();

    expect(visibleOrder(tester), ['b', 'c', 'a'],
        reason: 'a stale newIndex-- would have produced [b, a, c]');
  });

  testWidgets('dragging an item up lands it where it was dropped',
      (tester) async {
    await pumpRanking(tester, [
      Options('a', 'Alpha'),
      Options('b', 'Bravo'),
      Options('c', 'Charlie'),
    ]);

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem!(2, 0);
    await tester.pumpAndSettle();

    // Upward drags were unaffected by the decrement, so this guards the
    // migration rather than the bug — it should hold either way.
    expect(visibleOrder(tester), ['c', 'a', 'b']);
  });

  testWidgets('the reordered list is what the step reports as its result',
      (tester) async {
    await pumpRanking(tester, [
      Options('a', 'Alpha'),
      Options('b', 'Bravo'),
      Options('c', 'Charlie'),
    ]);

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem!(0, 2);
    await tester.pumpAndSettle();

    final step = FormStack.formByInstaceAndName()?.steps.first as QuestionStep?;
    final result = step?.result;
    expect(result, isA<List<Options>>());
    expect(
      (result as List<Options>).map((o) => o.key).toList(),
      ['b', 'c', 'a'],
      reason: 'the answer must match what the user sees, not the original order',
    );
  });
}
