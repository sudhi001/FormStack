import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

Future<FormStackForm> pump(WidgetTester tester, List<FormStep> steps) async {
  FormStack.clearConfiguration();
  FormStack.api().form(
    steps: steps,
    mapKey: MapKey('', '', ''),
    initialLocation: LocationWrapper(0, 0),
  );
  await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
  return FormStack.formByInstaceAndName()!;
}

void main() {
  setUp(FormStack.clearConfiguration);

  group('ConsentStep', () {
    ConsentStep consent({bool optional = false}) => ConsentStep(
      id: GenericIdentifier(id: 'consent'),
      title: 'Consent',
      isOptional: optional,
      agreementText: 'I agree to take part',
      sections: [
        ConsentSection(
          type: ConsentSectionType.overview,
          title: 'Overview',
          summary: 'What this study involves',
          content: 'The long form text.',
        ),
        ConsentSection(
          type: ConsentSectionType.dataGathering,
          title: 'Data',
          summary: 'What we collect',
        ),
      ],
    );

    testWidgets('renders its sections and the agreement', (tester) async {
      await pump(tester, [consent()]);

      expect(find.text('Consent'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('I agree to take part'), findsOneWidget);
    });

    testWidgets('blocks navigation until agreed', (tester) async {
      final step = consent();
      final form = await pump(tester, [
        step,
        InstructionStep(
          id: GenericIdentifier(id: 'end'),
          title: 'Finished',
        ),
      ]);
      form.onValidationError = (_) {};

      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();
      expect(find.text('Finished'), findsNothing);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();

      expect(find.text('Finished'), findsOneWidget);
      expect(step.result, isTrue);
    });

    testWidgets('an optional consent step may be skipped', (tester) async {
      await pump(tester, [
        consent(optional: true),
        InstructionStep(
          id: GenericIdentifier(id: 'end'),
          title: 'Finished',
        ),
      ]);

      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();

      expect(find.text('Finished'), findsOneWidget);
    });

    testWidgets('a prior agreement is restored', (tester) async {
      final step = consent()..result = true;
      await pump(tester, [step]);

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    test('sections parse from JSON, unknown types falling back to custom', () {
      final section = ConsentSection.from({
        'type': 'nonsense',
        'title': 'T',
        'summary': 'S',
      });
      expect(section.type, ConsentSectionType.custom);
      expect(section.title, 'T');
      expect(section.defaultIcon, isA<IconData>());
    });
  });

  group('ReviewStep', () {
    testWidgets('lists the answers collected so far', (tester) async {
      final email = QuestionStep(
        id: GenericIdentifier(id: 'email'),
        inputType: InputType.text,
        title: 'Email',
        isOptional: true,
      )..result = 'user@example.com';
      final review = ReviewStep(
        id: GenericIdentifier(id: 'review'),
        title: 'Review',
      );

      final form = await pump(tester, [email, review]);
      form.render((_) {}, null, formStep: review);
      await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
      form.onUpdate?.call(review);
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('says so when there is nothing to review', (tester) async {
      final review = ReviewStep(
        id: GenericIdentifier(id: 'review'),
        title: 'Review',
      );
      await pump(tester, [review]);

      expect(find.text('No answers to review.'), findsOneWidget);
    });
  });

  group('CompletionStep', () {
    testWidgets('runs onBeforeFinish then reports the result', (tester) async {
      var beforeFinishRan = false;
      Map<String, dynamic>? finished;

      final answer = QuestionStep(
        id: GenericIdentifier(id: 'answer'),
        inputType: InputType.text,
        title: 'Answer',
        isOptional: true,
      )..result = 'given';
      final done = CompletionStep(
        id: GenericIdentifier(id: 'done'),
        title: 'All done',
        autoTrigger: false,
        onBeforeFinishCallback: (result) async {
          beforeFinishRan = true;
          return true;
        },
        onFinish: (result) => finished = Map.of(result),
      );

      final form = await pump(tester, [answer, done]);
      form.onUpdate?.call(done);
      await tester.pump();

      expect(find.text('All done'), findsOneWidget);

      // The completion view animates continuously, so pumpAndSettle would
      // never return; step time forward explicitly instead. Completion runs
      // onBeforeFinish, then a one-second delay before reporting.
      await tester.tap(find.text('Finish'));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(beforeFinishRan, isTrue);
      expect(finished?['answer'], 'given');
    });
  });

  group('DisplayStep with tiles', () {
    testWidgets('renders each row', (tester) async {
      await pump(tester, [
        DisplayStep(
          id: GenericIdentifier(id: 'list'),
          title: 'Choose',
          url: '',
          displayStepType: DisplayStepType.listTile,
          data: [
            DynamicData('First', subTitle: 'one'),
            DynamicData('Second', subTitle: 'two'),
          ],
        ),
      ]);

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('one'), findsOneWidget);
    });

    testWidgets('a display step is always valid', (tester) async {
      await pump(tester, [
        DisplayStep(
          id: GenericIdentifier(id: 'list'),
          title: 'Choose',
          url: '',
          displayStepType: DisplayStepType.listTile,
          data: const [],
        ),
        InstructionStep(
          id: GenericIdentifier(id: 'end'),
          title: 'Finished',
        ),
      ]);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Finished'), findsOneWidget);
    });

    test('a JSON-defined step keeps its own button default', () async {
      // Absent keys used to pass null, wiping the per-type default: a JSON
      // DisplayStep showed "Next" where a Dart one showed "Start".
      FormStack.clearConfiguration();
      await FormStack.api().buildFormFromJsonString(
        '{"default":{"steps":['
        '{"type":"DisplayStep","id":"d","displayStepType":"listTile"},'
        '{"type":"ReviewStep","id":"r"},'
        '{"type":"CompletionStep","id":"c"}]}}',
      );
      final form = FormStack.formByInstaceAndName()!;

      expect(form.getStep('d')!.nextButtonText, 'Start');
      expect(form.getStep('r')!.nextButtonText, 'Submit');
      expect(form.getStep('c')!.nextButtonText, 'Finish');
    });
  });
}
