import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

FormStackForm buildForm(List<FormStep> steps) {
  FormStack.clearConfiguration();
  FormStack.api().form(
    steps: steps,
    mapKey: MapKey('', '', ''),
    initialLocation: LocationWrapper(0, 0),
  );
  return FormStack.formByInstaceAndName()!;
}

QuestionStep question(String id, {List<RelevantCondition>? conditions}) =>
    QuestionStep(
      id: GenericIdentifier(id: id),
      inputType: InputType.text,
      title: id,
      relevantConditions: conditions,
    );

void main() {
  setUp(FormStack.clearConfiguration);

  group('sequential navigation', () {
    test('advances through steps in declaration order', () {
      final form = buildForm([question('a'), question('b'), question('c')]);
      final visited = <String?>[];
      form.onUpdate = (step) => visited.add(step.id?.id);

      form.nextStep(form.getStep('a'));
      form.nextStep(form.getStep('b'));

      expect(visited, ['b', 'c']);
    });

    test('back navigation returns to the previous step', () {
      final form = buildForm([question('a'), question('b')]);
      final visited = <String?>[];
      form.onUpdate = (step) => visited.add(step.id?.id);

      form.backStep(form.getStep('b'));

      expect(visited, contains('a'));
    });

    test('stepAfter and stepBefore bound at the ends of the form', () {
      final form = buildForm([question('a'), question('b')]);
      expect(form.stepBefore(form.getStep('a')), isNull);
      expect(form.stepAfter(form.getStep('b')), isNull);
      expect(form.stepAfter(form.getStep('a'))?.id?.id, 'b');
      expect(form.stepBefore(form.getStep('b'))?.id?.id, 'a');
    });

    test('finishing the last step reports the collected result', () {
      final form = buildForm([question('a')]);
      Map<String, dynamic>? finished;
      form.onUpdate = (_) {};
      form.onFinish = (result) => finished = Map.of(result);

      form.getStep('a')!.result = 'answer';
      form.generateResult();
      form.nextStep(form.getStep('a'));

      expect(finished, isNotNull);
      expect(finished!['a'], 'answer');
    });
  });

  group('conditional navigation', () {
    test('a matching condition routes to its target step', () {
      final branching = question('start', conditions: [
        ExpressionRelevant(
          expression: '= yes',
          identifier: GenericIdentifier(id: 'yesPath'),
        ),
      ]);
      final form =
          buildForm([branching, question('noPath'), question('yesPath')]);
      final visited = <String?>[];
      form.onUpdate = (step) => visited.add(step.id?.id);

      branching.result = 'yes';
      form.nextStep(branching);

      expect(visited, ['yesPath']);
    });

    test('a non-matching condition falls through to the next step', () {
      final branching = question('start', conditions: [
        ExpressionRelevant(
          expression: '= yes',
          identifier: GenericIdentifier(id: 'yesPath'),
        ),
      ]);
      final form =
          buildForm([branching, question('noPath'), question('yesPath')]);
      final visited = <String?>[];
      form.onUpdate = (step) => visited.add(step.id?.id);

      branching.result = 'no';
      form.nextStep(branching);

      expect(visited, ['noPath']);
    });

    test('back from a branch target returns to the branching step', () {
      final branching = question('start', conditions: [
        ExpressionRelevant(
          expression: '= yes',
          identifier: GenericIdentifier(id: 'yesPath'),
        ),
      ]);
      final form =
          buildForm([branching, question('noPath'), question('yesPath')]);
      final visited = <String?>[];
      form.onUpdate = (step) => visited.add(step.id?.id);

      branching.result = 'yes';
      form.nextStep(branching);
      form.backStep(form.getStep('yesPath'));

      expect(visited.last, 'start');
    });
  });

  group('step index', () {
    test('getStep resolves by id and returns null for unknown ids', () {
      final form = buildForm([question('a'), question('b')]);
      expect(form.getStep('a')?.title, 'a');
      expect(form.getStep('nope'), isNull);
    });

    test('progress reports position, total and percentage together', () {
      final form = buildForm(
          [question('a'), question('b'), question('c'), question('d')]);
      form.render((_) {}, null, formStep: form.getStep('c'));

      final progress = form.progress;
      expect(progress.total, 4);
      expect(progress.index, 2);
      expect(progress.step, 3);
      expect(progress.percent, 50);
      expect(progress.isMeaningful, isTrue);
    });

    test('progress is not meaningful for a single-step form', () {
      final form = buildForm([question('only')]);
      expect(form.progress.isMeaningful, isFalse);
    });

    test('the index tracks steps appended after construction', () {
      final form = buildForm([question('a')]);
      form.steps.add(question('late'));
      expect(form.getStep('late'), isNotNull);
      expect(form.getTotalSteps(), 2);
    });
  });

  group('result aggregation', () {
    test('collects every answered step into a flat map', () {
      final form = buildForm([question('a'), question('b')]);
      form.getStep('a')!.result = 1;
      form.getStep('b')!.result = 'two';

      form.generateResult();

      expect(form.result, {'a': 1, 'b': 'two'});
    });

    test('clearResult wipes answers and timestamps', () {
      final form = buildForm([question('a')]);
      final step = form.getStep('a')!;
      step.result = 'x';
      step.startTime = DateTime.now();

      form.clearResult();

      expect(step.result, isNull);
      expect(step.startTime, isNull);
    });

    test('exportAsJson carries step results and a flat map', () {
      final form = buildForm([question('a')]);
      form.getStep('a')!.result = 'answer';

      final json = form.exportAsJson();

      expect(json['results'], containsPair('a', 'answer'));
      expect(json['stepResults'], isA<List<dynamic>>());
    });
  });

  group('step reuse', () {
    test('one step definition can be shared by two forms', () {
      // Under the previous LinkedList model this threw, because a step could
      // only ever belong to a single list.
      final shared = question('shared');
      FormStack.api()
        ..form(
          name: 'first',
          steps: [shared],
          mapKey: MapKey('', '', ''),
          initialLocation: LocationWrapper(0, 0),
        )
        ..form(
          name: 'second',
          steps: [shared],
          mapKey: MapKey('', '', ''),
          initialLocation: LocationWrapper(0, 0),
        );

      expect(FormStack.formByInstaceAndName(formName: 'first'), isNotNull);
      expect(FormStack.formByInstaceAndName(formName: 'second'), isNotNull);
    });
  });
}
