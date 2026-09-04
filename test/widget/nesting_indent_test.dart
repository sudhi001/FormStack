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

  // One content padding at this width. The two cases are measured in separate
  // tests because FormStackView holds its form in State, so a second form built
  // in the same test would reuse the first.
  const contentEdge = 20.0;

  testWidgets('a top-level field sits at the content edge', (tester) async {
    expect(await leftOfField(tester, nested: false), closeTo(contentEdge, 0.5));
  });

  testWidgets('a nested field sits at the same edge', (tester) async {
    // Was 40 — one extra padding per level of nesting.
    expect(await leftOfField(tester, nested: true), closeTo(contentEdge, 0.5),
        reason: 'nesting must not indent');
  });
}
