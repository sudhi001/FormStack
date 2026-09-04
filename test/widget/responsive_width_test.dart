import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// A form sizes itself against the space it is given, not the window.
///
/// The responsive helpers read `MediaQuery.of(context).size.width`, which is the
/// width of the window. A form mounted in a 600px dialog on a 1500px monitor
/// therefore took every "desktop" branch — wide inputs, full padding, large
/// icons — for a viewport it did not have, and a form in a narrow side panel
/// took none of the mobile branches it should have. The window is the wrong
/// question; the constraint is the right one.
void main() {
  /// The width the form published from inside a box of the given width.
  Future<double> publishedWidthInside(
    WidgetTester tester,
    double containerWidth,
  ) async {
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'q'),
          inputType: InputType.text,
          title: 'Question',
        ),
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: containerWidth,
            height: 700,
            child: FormStack.api().render(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Read what the form itself published, rather than a sibling's view of the
    // tree — an InheritedWidget is only visible to its own descendants.
    return tester
        .widget<FormStackAvailableWidth>(
          find.byType(FormStackAvailableWidth).first,
        )
        .width;
  }

  testWidgets('unscoped, it falls back to the window width', (tester) async {
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late double seen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = FormStackAvailableWidth.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(seen, 1500,
        reason: 'nothing published a width, so the window is the best guess');
  });

  testWidgets('a form in a 600px dialog measures 600, not the 1500px window',
      (tester) async {
    final width = await publishedWidthInside(tester, 600);
    expect(width, 600);
  });

  testWidgets('the helpers follow the container across the mobile breakpoint',
      (tester) async {
    // 500 is below FormStack's 600 breakpoint. On a 1500px window the old code
    // read 1500 here and chose the desktop branch for a phone-width panel.
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late double narrow;
    late double wide;
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            SizedBox(
              width: 500,
              child: FormStackAvailableWidth(
                width: 500,
                child: Builder(builder: (c) {
                  narrow = FormStackTheme.responsiveMaxWidth(c);
                  return const SizedBox.shrink();
                }),
              ),
            ),
            SizedBox(
              width: 900,
              child: FormStackAvailableWidth(
                width: 900,
                child: Builder(builder: (c) {
                  wide = FormStackTheme.responsiveMaxWidth(c);
                  return const SizedBox.shrink();
                }),
              ),
            ),
          ],
        ),
      ),
    );

    expect(narrow, 500, reason: 'below the breakpoint it fills its container');
    expect(wide, FormStackTheme.defaults.maxContentWidth,
        reason: 'above it, the content is capped for line length');
  });
}
