import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Nesting must not indent.
///
/// The content padding is applied by every step, including the ones rendered as
/// components inside another step — so each level of nesting added another
/// margin. A field on its own and a field inside a nested row got different
/// left edges, which is what makes a form look unaligned, and a second level of
/// nesting would compound it again.
void main() {
  Future<double> leftOfField(
    WidgetTester tester, {
    required bool nested,
  }) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final field = QuestionStep(
      id: GenericIdentifier(id: 'target'),
      inputType: InputType.text,
      title: 'Target',
      crossAxisAlignmentContent: CrossAxisAlignment.start,
    );

    FormStack.clearForms();
    FormStack.api().form(
      steps: [
        if (nested)
          NestedStep(
            id: GenericIdentifier(id: 'row'),
            crossAxisAlignmentContent: CrossAxisAlignment.start,
            verticalPadding: 8,
            validationExpression: "",
            steps: [field],
          )
        else
          field,
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
    await tester.pumpAndSettle();
    return tester.getRect(find.text('Target')).left;
  }

  // The leading edge of the centred content block, plus one content padding.
  // The two cases are measured in separate tests because FormStackView holds
  // its form in State, so a second form built in the same test would reuse the
  // first. What matters is that both land on the same number.
  const contentEdge = 320.0;

  testWidgets('a top-level field sits at the content edge', (tester) async {
    expect(await leftOfField(tester, nested: false), closeTo(contentEdge, 0.5));
  });

  testWidgets('a nested field sits at the same edge', (tester) async {
    // Was 40 — one extra padding per level of nesting.
    expect(await leftOfField(tester, nested: true), closeTo(contentEdge, 0.5),
        reason: 'nesting must not indent');
  });

  testWidgets('nesting adds no vertical padding either', (tester) async {
    // The same compounding showed up down the page as well as across it: each
    // nested child re-applied the page's vertical padding, so rows drifted
    // apart by roughly 30px per level.
    //
    // This mirrors the real shape of the Create Applicant form — one step
    // holding a full-width field, then a row of two — because FormStack shows
    // one step per page, so the drift is only visible inside a step.
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    QuestionStep q(String id, String title) => QuestionStep(
          id: GenericIdentifier(id: id),
          inputType: InputType.text,
          title: title,
          crossAxisAlignmentContent: CrossAxisAlignment.start,
        );

    FormStack.clearForms();
    FormStack.api().form(
      steps: [
        NestedStep(
          id: GenericIdentifier(id: 'page'),
          crossAxisAlignmentContent: CrossAxisAlignment.start,
          verticalPadding: 8,
          validationExpression: "",
          steps: [
            q('first', 'First'),
            NestedStep(
              id: GenericIdentifier(id: 'row'),
              crossAxisAlignmentContent: CrossAxisAlignment.start,
              verticalPadding: 8,
              validationExpression: "",
              steps: [q('inRow', 'InRow')],
            ),
          ],
        ),
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
    await tester.pumpAndSettle();

    final gap = tester.getRect(find.text('InRow')).top -
        tester.getRect(find.text('First')).bottom;
    debugPrint('gap before a nested row = $gap');
    // Field height plus the row's own verticalPadding. Was far larger when
    // every level contributed its own page padding on top.
    expect(gap, lessThan(110),
        reason: 'a nested row must not be pushed down by stacked page padding');

    // And it still lines up horizontally.
    expect(tester.getRect(find.text('InRow')).left,
        closeTo(tester.getRect(find.text('First')).left, 0.5));
  });
}
