import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Tappable controls meet the accessibility minimum.
///
/// WCAG 2.5.8 asks for 44x44 at AAA and Material for 48dp. Widgets that go
/// through `IconButton` or `ElevatedButton` inherit a Material minimum for
/// free; the ones built from `InkWell` and `GestureDetector` do not, and those
/// are the ones that drifted — an NPS scale at 40x40 and a rating star with a
/// 40px-tall tap area.
void main() {
  Future<void> pump(WidgetTester tester, InputType type, {List<Options>? options}) async {
    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'q'),
          inputType: type,
          title: 'Question',
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

  test('the guideline minimum is the WCAG AAA figure', () {
    expect(FormStackTheme.minTouchTarget, greaterThanOrEqualTo(44));
  });

  testWidgets('every NPS button is at least the minimum in both axes',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pump(tester, InputType.nps);

    // Only the square scale buttons — the step chrome has its own controls,
    // and measuring everything on screen tests the wrong widgets.
    final taps = find.byType(InkWell);
    expect(taps, findsWidgets, reason: 'the scale should render its buttons');

    var measured = 0;
    for (final element in taps.evaluate()) {
      final size = element.size;
      if (size == null || size.width != size.height) continue;
      measured++;
      expect(size.height, greaterThanOrEqualTo(FormStackTheme.minTouchTarget),
          reason: 'an NPS button is only ${size.height}px tall');
      expect(size.width, greaterThanOrEqualTo(FormStackTheme.minTouchTarget),
          reason: 'an NPS button is only ${size.width}px wide');
    }
    expect(measured, greaterThan(0), reason: 'no scale button was measured');
  });

  testWidgets('a rating star is tappable at the minimum height',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pump(tester, InputType.rating);

    final stars = find.byType(GestureDetector);
    expect(stars, findsWidgets);

    var checked = 0;
    for (final element in stars.evaluate()) {
      final size = element.size;
      // The GestureDetector itself has no render object, so the measured box is
      // the Padding beneath it. Layout wrappers are far wider than a star.
      if (size == null || size.width > 200) continue;
      expect(size.height, greaterThanOrEqualTo(FormStackTheme.minTouchTarget),
          reason: 'a star is only ${size.height}px tall');
      checked++;
    }
    expect(checked, greaterThan(0), reason: 'no star was actually measured');
  });
}
