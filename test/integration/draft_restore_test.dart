import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Offline save and resume round-trips answers through JSON, which changes
/// their types: a `DateTime` becomes a string, `List<Options>` becomes a list
/// of maps, an `int` may come back as a double. Views that cast the restored
/// value without checking threw on resume.
void main() {
  late InMemoryFormPersistence store;

  setUp(() {
    FormStack.clearConfiguration();
    store = InMemoryFormPersistence();
  });

  List<QuestionStep> answeredSteps() => [
    QuestionStep(
      id: GenericIdentifier(id: 'text'),
      inputType: InputType.text,
      title: 'text',
      isOptional: true,
    )..result = 'hello',
    QuestionStep(
      id: GenericIdentifier(id: 'rating'),
      inputType: InputType.rating,
      title: 'rating',
      isOptional: true,
    )..result = 3,
    QuestionStep(
      id: GenericIdentifier(id: 'nps'),
      inputType: InputType.nps,
      title: 'nps',
      isOptional: true,
    )..result = 9,
    QuestionStep(
      id: GenericIdentifier(id: 'slider'),
      inputType: InputType.slider,
      title: 'slider',
      isOptional: true,
    )..result = 42.5,
    QuestionStep(
      id: GenericIdentifier(id: 'when'),
      inputType: InputType.date,
      title: 'when',
      isOptional: true,
    )..result = DateTime(2024, 6, 15),
    QuestionStep(
      id: GenericIdentifier(id: 'choice'),
      inputType: InputType.multipleChoice,
      title: 'choice',
      isOptional: true,
      options: [Options('a', 'A'), Options('b', 'B')],
    )..result = [Options('a', 'A')],
  ];

  Future<void> saveThroughJson(FormStackForm form) async {
    await FormStack.api().saveDraft();
    // A real store persists text, so force the round-trip the in-memory one
    // would otherwise skip.
    final raw = await store.load(form.id!.id!);
    await store.save(
      form.id!.id!,
      jsonDecode(jsonEncode(raw)) as Map<String, dynamic>,
    );
  }

  testWidgets('every answer type survives a JSON draft round-trip', (
    tester,
  ) async {
    final steps = answeredSteps();
    FormStack.api()
      ..form(
        steps: steps,
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      )
      ..enablePersistence(store);
    final form = FormStack.formByInstaceAndName()!;

    await saveThroughJson(form);
    form.clearResult();
    expect(await FormStack.api().resumeDraft(), isTrue);

    // A date used to be dropped from the results map entirely unless the step
    // carried a DateResultType, so it never reached the draft at all.
    expect(form.getStep('when')!.result, isNotNull);
    expect(form.getStep('text')!.result, 'hello');
    expect(form.getStep('rating')!.result, 3);
    expect(form.getStep('choice')!.result, isNotNull);

    // And each restored step must still render.
    for (final step in steps) {
      FormStack.clearConfiguration();
      FormStack.api().form(
        steps: [step],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );
      await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
      expect(
        tester.takeException(),
        isNull,
        reason: 'restoring ${step.id?.id} threw while building its view',
      );
    }
  });

  testWidgets('a repeat group survives a JSON draft round-trip', (
    tester,
  ) async {
    final repeat = RepeatStep(
      id: GenericIdentifier(id: 'people'),
      title: 'People',
      isOptional: true,
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'personName'),
          inputType: InputType.text,
          title: 'Name',
          isOptional: true,
        ),
      ],
    );
    // The shape resultValue() produces, after a JSON round-trip: the element
    // type widens to dynamic, which the unchecked cast on resume rejected.
    repeat.result =
        (jsonDecode(
                  jsonEncode([
                    {'personName': 'Ada'},
                    {'personName': 'Grace'},
                  ]),
                )
                as List)
            .toList();

    FormStack.api().form(
      steps: [repeat],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));

    expect(tester.takeException(), isNull);
    expect(find.text('People'), findsOneWidget);
  });

  test('a date reaches the exported result with and without a format', () {
    for (final format in [null, ResultFormat.date('x', 'yyyy-MM-dd')]) {
      FormStack.clearConfiguration();
      final step = QuestionStep(
        id: GenericIdentifier(id: 'when'),
        inputType: InputType.date,
        resultFormat: format,
      )..result = DateTime(2024, 6, 15);
      FormStack.api().form(
        steps: [step],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );
      final form = FormStack.formByInstaceAndName()!..generateResult();

      expect(
        form.result['when'],
        isNotNull,
        reason: 'a date answer must be exported regardless of its validator',
      );
    }
  });
}
