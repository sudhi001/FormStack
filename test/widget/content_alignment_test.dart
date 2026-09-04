import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Two separate questions, kept separate.
///
///  * where the *content block* sits in the available width — always centred,
///    so a capped-width form has balanced gutters rather than all the leftover
///    width dead on one side;
///  * where *children* sit inside that block — `crossAxisAlignmentContent`.
///
/// Driving both from one property meant a form asking for "start" was pinned to
/// the leading edge of its container, which is what made a wide dialog look
/// half empty. Start-aligning children inside a centred block is what actually
/// gives a form one shared left edge down the page.
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

  // 1200 wide, capped at maxContentWidth, plus one content padding.
  const blockContentEdge = 320.0;

  testWidgets('the block is centred even when children start-align',
      (tester) async {
    final left = await titleLeft(tester, CrossAxisAlignment.start);
    expect(outerAlignment(tester), Alignment.topCenter,
        reason: 'the block placement is not the child alignment');
    expect(left, closeTo(blockContentEdge, 0.5),
        reason: 'start puts children at the leading edge *of the block*');
  });

  testWidgets('the block is centred when children centre too', (tester) async {
    final left = await titleLeft(tester, CrossAxisAlignment.center);
    expect(outerAlignment(tester), Alignment.topCenter);
    // A narrow title centred inside the block sits well past its leading edge.
    expect(left, greaterThan(blockContentEdge + 50),
        reason: 'centring is what an unset step did, and still does');
  });

  testWidgets('end sends children to the trailing edge of the block',
      (tester) async {
    final left = await titleLeft(tester, CrossAxisAlignment.end);
    expect(outerAlignment(tester), Alignment.topCenter);
    expect(left, greaterThan(blockContentEdge + 50));
  });

  testWidgets('stretch fills the block, so children start at its edge',
      (tester) async {
    final left = await titleLeft(tester, CrossAxisAlignment.stretch);
    expect(outerAlignment(tester), Alignment.topCenter);
    expect(left, closeTo(blockContentEdge, 0.5));
  });
}
