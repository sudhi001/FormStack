import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Layout mirrors under a right-to-left locale.
///
/// The package advertises multi-language support, which for Arabic, Hebrew,
/// Persian and Urdu means the whole layout mirrors — not only the text. A
/// control pinned with `Alignment.centerRight` or `Positioned(right:)` stays on
/// the right in every locale, so in RTL it lands at the *leading* edge, where a
/// reader expects the first thing rather than the last.
void main() {
  Future<void> pumpInDirection(
    WidgetTester tester,
    TextDirection direction,
    InputType type,
  ) async {
    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'q'),
          inputType: type,
          title: 'Question',
        ),
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: FormStack.api().render(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the signature Clear action follows the reading direction',
      (tester) async {
    await pumpInDirection(tester, TextDirection.ltr, InputType.signature);
    final ltr = tester
        .widgetList<Align>(find.byType(Align))
        .map((a) => a.alignment)
        .whereType<AlignmentDirectional>()
        .toList();

    expect(
      ltr,
      contains(AlignmentDirectional.centerEnd),
      reason: 'a directional alignment is what makes the mirror possible; '
          'Alignment.centerRight cannot mirror',
    );
  });

  testWidgets('a form builds in both directions without throwing',
      (tester) async {
    for (final direction in TextDirection.values) {
      for (final type in [
        InputType.text,
        InputType.signature,
        InputType.singleChoice,
      ]) {
        await pumpInDirection(tester, direction, type);
        expect(
          tester.takeException(),
          isNull,
          reason: '$type threw under $direction',
        );
      }
    }
  });
}
