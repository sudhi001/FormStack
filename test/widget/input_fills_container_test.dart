import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// A field fills the content width of the block it sits in.
///
/// The text input carried a hardcoded `maxWidth: 400` that no container could
/// influence. A form's progress bar spans the whole content area, so in a 600
/// dialog the fields stopped 160px short of it and the form looked pushed to
/// one side — which is the "alignment" complaint, even though every field
/// already shared a left edge.
void main() {
  const dialogWidth = 600.0;

  Future<Rect> fieldRect(
    WidgetTester tester, {
    FormStackTheme? theme,
    InputType inputType = InputType.text,
    Type widgetType = TextFormField,
  }) async {
    tester.view.physicalSize = const Size(1450, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    FormStack.clearForms();
    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'name'),
          inputType: inputType,
          title: 'Name',
          options: inputType == InputType.dropdown
              ? [Options('a', 'Option A'), Options('b', 'Option B')]
              : null,
          crossAxisAlignmentContent: CrossAxisAlignment.start,
        ),
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );

    Widget form = FormStack.api().render();
    if (theme != null) {
      form = FormStackThemeScope(theme: theme, child: form);
    }
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: dialogWidth, height: 660, child: form),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return tester.getRect(find.byType(widgetType).first);
  }

  testWidgets('the cap still applies on a wide container', (tester) async {
    // Default inputMaxWidth is 500, and the content area here is 560, so the
    // cap is what bounds it — a field must not run to any width at all.
    final rect = await fieldRect(tester);
    expect(rect.width, closeTo(500, 1),
        reason: 'the theme cap bounds the field');
    expect(rect.width, greaterThan(400),
        reason: 'the old hardcoded 400 no longer decides this');
  });

  testWidgets('raising the cap lets a field reach the content edge',
      (tester) async {
    // What the app scopes for its dialogs: a cap above the content width, so
    // the field lines up with the progress bar rather than stopping short.
    final rect = await fieldRect(
      tester,
      theme: const FormStackTheme(inputMaxWidth: 600, maxContentWidth: 600),
    );
    // 600 dialog less one content padding each side.
    expect(rect.width, closeTo(560, 1),
        reason: 'the field fills the content width');
  });

  testWidgets('a dropdown reaches the same edge as a text field',
      (tester) async {
    // The Position dropdown carried its own hardcoded cap of 400, so it sat
    // visibly short of the text fields above it in the same form.
    final rect = await fieldRect(
      tester,
      theme: const FormStackTheme(inputMaxWidth: 600, maxContentWidth: 600),
      inputType: InputType.dropdown,
      widgetType: DropdownButtonHideUnderline,
    );
    expect(rect.width, closeTo(560, 1),
        reason: 'a dropdown fills the content width like any other field');
  });
}
