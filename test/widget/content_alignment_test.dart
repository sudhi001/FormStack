import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// A step's content block honours `crossAxisAlignmentContent`.
///
/// The block was always `Alignment.topCenter`, and the step's own alignment
/// only reached the Column *inside* it — so a form asking for "start" still
/// centred every component. Inside a nested row that means each field is
/// centred in its own slot, and a full-width field above a pair of half-width
/// fields ends up with two different left edges. The form stops lining up, and
/// nothing available to the form's author could change it.
///
/// Each case is its own test on purpose: `FormStackView` keeps its form in
/// State, so rebuilding within one test reuses the first one and both
/// measurements come back identical — which reads as "the fix does nothing".
void main() {
  Future<double> titleLeft(
    WidgetTester tester,
    CrossAxisAlignment alignment,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Forms register with putIfAbsent, so a re-declaration is otherwise ignored.
    FormStack.clearForms();
    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'q'),
          inputType: InputType.text,
          title: 'Question',
          crossAxisAlignmentContent: alignment,
        ),
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
    await tester.pumpAndSettle();
    return tester.getRect(find.text('Question')).left;
  }

  AlignmentGeometry outerAlignment(WidgetTester tester) =>
      (find.byType(Align).evaluate().first.widget as Align).alignment;

  testWidgets('start puts the content at the leading edge', (tester) async {
    final left = await titleLeft(tester, CrossAxisAlignment.start);
    expect(outerAlignment(tester), AlignmentDirectional.topStart);
    // The content padding, and nothing more.
    expect(left, lessThan(100), reason: 'a start-aligned step must not be centred');
  });

  testWidgets('center remains the default behaviour', (tester) async {
    final left = await titleLeft(tester, CrossAxisAlignment.center);
    expect(outerAlignment(tester), Alignment.topCenter);
    // Forms that never set this keep exactly the layout they had.
    expect(left, greaterThan(300), reason: 'centring is what an unset step did');
  });

  testWidgets('end aligns to the trailing edge', (tester) async {
    await titleLeft(tester, CrossAxisAlignment.end);
    // Directional, so this is the right edge in English and the left in Arabic.
    expect(outerAlignment(tester), AlignmentDirectional.topEnd);
  });

  testWidgets('stretch keeps centring, since the child fills anyway',
      (tester) async {
    await titleLeft(tester, CrossAxisAlignment.stretch);
    expect(outerAlignment(tester), Alignment.topCenter);
  });
}
