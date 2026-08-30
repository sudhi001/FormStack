import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Views are rebuilt when the user navigates back to a step, so every input
/// must restore what it shows from `formStep.result` rather than relying on
/// its own fields surviving.
///
/// Before 3.1 a multi-entry view cache hid any input that failed to do this —
/// until the cache evicted it, or `maxCachedViews` was lowered, at which point
/// the answer silently vanished. These tests assert the property directly.

/// Input types that cannot be built in a plain widget test.
const _needsPlatform = {
  InputType.mapLocation,
  InputType.geotrace,
  InputType.geoshape,
  InputType.htmlEditor,
  InputType.custom,
};

/// A representative answer for each input type, in the shape that type stores.
const _answers = <InputType, Object>{
  InputType.email: 'user@example.com',
  InputType.name: 'Ada Lovelace',
  InputType.password: 'Passw0rd!x',
  InputType.text: 'some text',
  InputType.number: '42',
  InputType.currency: '19.99',
  InputType.phone: '+14155552671',
  InputType.barcode: '9780306406157',
  InputType.slider: 30,
  InputType.rating: 3,
  InputType.nps: 8,
  InputType.smile: 3,
  InputType.consent: true,
  InputType.boolean: true,
  // A real 1x1 PNG: the signature view decodes what it restores, so a
  // placeholder string would only exercise the error path.
  InputType.signature:
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
};

QuestionStep stepFor(InputType type, {Object? answer}) => QuestionStep(
  id: GenericIdentifier(id: type.name),
  inputType: type,
  title: 'Question ${type.name}',
  isOptional: true,
  options:
      const [
        InputType.singleChoice,
        InputType.multipleChoice,
        InputType.dropdown,
        InputType.ranking,
        InputType.imageChoice,
      ].contains(type)
      ? [Options('a', 'Option A'), Options('b', 'Option B')]
      : null,
  calculateCallback: type == InputType.calculate
      ? (results) => results.length
      : null,
)..result = answer;

void main() {
  setUp(FormStack.clearConfiguration);

  Future<FormStackForm> pump(WidgetTester tester, List<FormStep> steps) async {
    FormStack.api().form(
      steps: steps,
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
    return FormStack.formByInstaceAndName()!;
  }

  group('an answer survives navigating away and back', () {
    for (final entry in _answers.entries) {
      final type = entry.key;
      if (_needsPlatform.contains(type)) continue;

      testWidgets(type.name, (tester) async {
        final step = stepFor(type, answer: entry.value);
        final second = QuestionStep(
          id: GenericIdentifier(id: 'second'),
          inputType: InputType.text,
          title: 'Second',
          isOptional: true,
        );
        final form = await pump(tester, [step, second]);

        // Forward: the first view leaves the tree and is disposed.
        form.nextStep(step);
        await tester.pumpAndSettle();
        expect(find.text('Second'), findsOneWidget);

        // Back: a fresh view is built and must restore from the step.
        form.backStep(second);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Question ${type.name}'), findsOneWidget);

        // Advancing writes the view's own resultValue() back over the answer.
        // A view that failed to restore reports null or empty here and
        // destroys what the user had already entered -- which is exactly what
        // the old view cache was hiding.
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(
          step.result,
          entry.value,
          reason:
              'InputType.${type.name} did not restore its answer from the '
              'step, so navigating back and forward destroyed it',
        );
      });
    }
  });

  group('view lifetime', () {
    testWidgets('the same view instance is kept while its step is on screen', (
      tester,
    ) async {
      final step = stepFor(InputType.text, answer: 'x');
      final form = await pump(tester, [step, stepFor(InputType.number)]);

      // render() wraps the view in a KeyedSubtree keyed by step; the identity
      // that matters is the view inside it, which holds the controllers.
      final first =
          (form.render((_) {}, null, formStep: step) as KeyedSubtree).child;
      final second =
          (form.render((_) {}, null, formStep: step) as KeyedSubtree).child;

      // Rebuilding must not discard half-typed input by replacing the view.
      expect(identical(first, second), isTrue);
    });

    testWidgets('a different step yields a different view', (tester) async {
      final a = stepFor(InputType.text);
      final b = stepFor(InputType.number);
      final form = await pump(tester, [a, b]);

      final viewA =
          (form.render((_) {}, null, formStep: a) as KeyedSubtree).child;
      final viewB =
          (form.render((_) {}, null, formStep: b) as KeyedSubtree).child;

      expect(identical(viewA, viewB), isFalse);
    });

    testWidgets('typing then navigating away and back keeps the text', (
      tester,
    ) async {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.text,
        title: 'First',
        isOptional: true,
      );
      final second = QuestionStep(
        id: GenericIdentifier(id: 'second'),
        inputType: InputType.text,
        title: 'Second',
        isOptional: true,
      );
      await pump(tester, [step, second]);

      await tester.enterText(find.byType(TextField).first, 'typed by hand');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(step.result, 'typed by hand');
      expect(find.text('typed by hand'), findsOneWidget);
    });
  });
}
