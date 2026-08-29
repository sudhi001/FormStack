import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Input types that cannot be built in a plain widget test because they reach
/// for a platform channel or a native view at construction time.
const _needsPlatform = {
  InputType.mapLocation,
  InputType.geotrace,
  InputType.geoshape,
  InputType.htmlEditor,
  InputType.custom,
};

/// Input types whose widget needs options to render anything meaningful.
const _needsOptions = {
  InputType.singleChoice,
  InputType.multipleChoice,
  InputType.dropdown,
  InputType.ranking,
  InputType.imageChoice,
};

QuestionStep stepFor(InputType type) => QuestionStep(
      id: GenericIdentifier(id: type.name),
      inputType: type,
      title: 'Question ${type.name}',
      text: 'Body text',
      options: _needsOptions.contains(type)
          ? [Options('a', 'Option A'), Options('b', 'Option B')]
          : null,
      calculateCallback:
          type == InputType.calculate ? (results) => results.length : null,
    );

void main() {
  setUp(FormStack.clearConfiguration);

  Future<void> pumpStep(WidgetTester tester, QuestionStep step) async {
    FormStack.api().form(
      steps: [step, InstructionStep(id: GenericIdentifier(id: 'end'))],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
  }

  group('every built-in input type builds', () {
    for (final type in InputType.values) {
      if (_needsPlatform.contains(type)) continue;

      testWidgets(type.name, (tester) async {
        await pumpStep(tester, stepFor(type));
        await tester.pump();

        expect(tester.takeException(), isNull,
            reason: 'building InputType.${type.name} threw');

        if (type == InputType.hidden) {
          // A hidden field has no UI and advances on its own, so the step it
          // was declared on is never shown.
          expect(find.text('Question ${type.name}'), findsNothing);
        } else {
          expect(find.text('Question ${type.name}'), findsOneWidget);
        }
      });
    }
  });

  group('validation surfaces on the step', () {
    testWidgets('an invalid answer blocks navigation and shows the message',
        (tester) async {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'email'),
        inputType: InputType.email,
        title: 'Email',
        resultFormat: ResultFormat.email('Enter a valid email'),
      );
      await pumpStep(tester, step);

      await tester.enterText(find.byType(TextField).first, 'nonsense');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget, reason: 'should not advance');
    });

    testWidgets('a valid answer advances to the next step', (tester) async {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'email'),
        inputType: InputType.email,
        title: 'Email',
        resultFormat: ResultFormat.email('Enter a valid email'),
      );
      FormStack.api().form(
        steps: [
          step,
          InstructionStep(id: GenericIdentifier(id: 'end'), title: 'Finished'),
        ],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );
      await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Finished'), findsOneWidget);
    });

    testWidgets('an optional step advances without a valid answer',
        (tester) async {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'email'),
        inputType: InputType.email,
        title: 'Email',
        isOptional: true,
      );
      FormStack.api().form(
        steps: [
          step,
          InstructionStep(id: GenericIdentifier(id: 'end'), title: 'Finished'),
        ],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );
      await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Finished'), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('the step title is exposed as a header', (tester) async {
      await pumpStep(tester, stepFor(InputType.text));
      final semantics = tester.getSemantics(find
          .ancestor(
            of: find.text('Question text'),
            matching: find.byType(Semantics),
          )
          .first);
      expect(semantics.hasFlag(SemanticsFlag.isHeader), isTrue);
    });

    testWidgets('the progress bar announces position and percentage',
        (tester) async {
      await pumpStep(tester, stepFor(InputType.text));
      expect(
        find.bySemanticsLabel(RegExp(r'Step 1 of 2, \d+ percent complete')),
        findsOneWidget,
      );
    });
  });
}
