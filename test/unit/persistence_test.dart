import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

QuestionStep question(String id) => QuestionStep(
  id: GenericIdentifier(id: id),
  inputType: InputType.text,
  title: id,
);

void main() {
  late InMemoryFormPersistence store;

  setUp(() {
    FormStack.clearConfiguration();
    store = InMemoryFormPersistence();
  });

  FormStackForm buildForm() {
    FormStack.api()
      ..form(
        steps: [question('a'), question('b')],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      )
      ..enablePersistence(store);
    return FormStack.formByInstaceAndName()!;
  }

  group('draft save and resume', () {
    test('a saved draft restores answers into the form', () async {
      final form = buildForm();
      form.getStep('a')!.result = 'first';
      form.getStep('b')!.result = 'second';

      await FormStack.api().saveDraft();
      form.clearResult();
      expect(form.getStep('a')!.result, isNull);

      final resumed = await FormStack.api().resumeDraft();

      expect(resumed, isTrue);
      expect(form.getStep('a')!.result, 'first');
      expect(form.getStep('b')!.result, 'second');
    });

    test('resuming with nothing saved reports false', () async {
      buildForm();
      expect(await FormStack.api().resumeDraft(), isFalse);
    });

    test('a deleted draft can no longer be resumed', () async {
      final form = buildForm();
      form.getStep('a')!.result = 'x';
      await FormStack.api().saveDraft();

      await FormStack.api().deleteDraft();

      expect(await FormStack.api().resumeDraft(), isFalse);
    });

    test('saved drafts are listable', () async {
      buildForm();
      await FormStack.api().saveDraft();
      expect(await FormStack.api().listDrafts(), hasLength(1));
    });

    test('without persistence enabled the calls are no-ops', () async {
      FormStack.clearConfiguration();
      FormStack.api().form(
        steps: [question('a')],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );

      await FormStack.api().saveDraft();
      expect(await FormStack.api().resumeDraft(), isFalse);
      expect(await FormStack.api().listDrafts(), isEmpty);
    });
  });

  group('form statistics', () {
    test('progress and completion track answered steps', () {
      final form = buildForm();
      expect(FormStack.api().isFormCompleted(), isFalse);

      form.getStep('a')!.result = 'x';
      expect(FormStack.api().getFormProgress(), 0.5);

      form.getStep('b')!.result = 'y';
      expect(FormStack.api().getFormProgress(), 1.0);
      expect(FormStack.api().isFormCompleted(), isTrue);
    });

    test('stats summarise required and optional steps', () {
      FormStack.clearConfiguration();
      final optional = question('opt')..isOptional = true;
      FormStack.api().form(
        steps: [question('req'), optional],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );

      final stats = FormStack.api().getFormStats();

      expect(stats['totalSteps'], 2);
      expect(stats['requiredSteps'], 1);
      expect(stats['optionalSteps'], 1);
      expect(stats['isCompleted'], isFalse);
    });
  });
}
