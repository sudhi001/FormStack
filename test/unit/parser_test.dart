import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

const _survey = '''
{
  "default": {
    "steps": [
      {"type": "InstructionStep", "id": "intro", "title": "Welcome"},
      {
        "type": "QuestionStep",
        "id": "email",
        "title": "Email",
        "inputType": "email",
        "validators": [
          {"type": "notBlank", "message": "Email is required"},
          {"type": "email", "message": "That is not an email"}
        ]
      },
      {
        "type": "QuestionStep",
        "id": "age",
        "inputType": "number",
        "validators": {"type": "range", "message": "18 to 120", "min": 18, "max": 120}
      },
      {"type": "CompletionStep", "id": "done", "title": "Thanks"}
    ]
  }
}
''';

void main() {
  setUp(() {
    FormStack.clearConfiguration();
    ValidatorRegistry.instance.reset();
    StepRegistry.instance.reset();
    InputRegistry.instance.reset();
  });

  group('JSON form parsing', () {
    test('builds every declared step in order', () async {
      await FormStack.api().buildFormFromJsonString(_survey);
      final form = FormStack.formByInstaceAndName()!;

      expect(form.steps.map((s) => s.id?.id), [
        'intro',
        'email',
        'age',
        'done',
      ]);
      expect(form.getStep('intro'), isA<InstructionStep>());
      expect(form.getStep('email'), isA<QuestionStep>());
      expect(form.getStep('done'), isA<CompletionStep>());
    });

    test('attaches validators declared in JSON', () async {
      await FormStack.api().buildFormFromJsonString(_survey);
      final form = FormStack.formByInstaceAndName()!;

      final email = form.getStep('email')!.resultFormat!;
      expect(email.isValid('not-an-email'), isFalse);
      expect(email.isValid('user@example.com'), isTrue);
      expect(email.validate('   ').message, 'Email is required');

      final age = form.getStep('age')!.resultFormat!;
      expect(age.isValid(30), isTrue);
      expect(age.isValid(5), isFalse);
      expect(age.validate(5).code, 'range');
    });

    test('reports the offending step for an unknown type', () {
      const bad = '{"default":{"steps":[{"type":"NoSuchStep","id":"x"}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('NoSuchStep'),
          ),
        ),
      );
    });

    test('reports an unknown inputType rather than failing obscurely', () {
      const bad =
          '{"default":{"steps":[{"type":"QuestionStep","id":"x","inputType":"telepathy"}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('telepathy'),
          ),
        ),
      );
    });

    test('a step without a type is rejected', () {
      const bad = '{"default":{"steps":[{"id":"x"}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(isA<FormatException>()),
      );
    });

    test('malformed JSON surfaces as a FormatException to the caller', () {
      // Regression guard: the parser used to be an `async void` method, so a
      // throw escaped to the zone and the caller saw success.
      expect(
        () => FormStack.api().buildFormFromJsonString('{not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('nested steps are parsed recursively', () async {
      const nested = '''
      {"default":{"steps":[
        {"type":"NestedStep","id":"group","steps":[
          {"type":"QuestionStep","id":"first","inputType":"text"},
          {"type":"QuestionStep","id":"second","inputType":"text"}
        ]},
        {"type":"CompletionStep","id":"done"}
      ]}}''';
      await FormStack.api().buildFormFromJsonString(nested);
      final form = FormStack.formByInstaceAndName()!;
      final group = form.getStep('group')! as NestedStep;
      expect(group.steps?.map((s) => s.id?.id), ['first', 'second']);
    });

    test('relevant conditions are attached to their step', () async {
      const branching = '''
      {"default":{"steps":[
        {"type":"QuestionStep","id":"q","inputType":"text",
         "relevantConditions":[{"id":"target","expression":"= yes"}]},
        {"type":"CompletionStep","id":"target"}
      ]}}''';
      await FormStack.api().buildFormFromJsonString(branching);
      final form = FormStack.formByInstaceAndName()!;
      final conditions = form.getStep('q')!.relevantConditions!;
      expect(conditions, hasLength(1));
      expect(conditions.single.identifier.id, 'target');
    });

    test('multiple named forms are built from one document', () async {
      const multi = '''
      {"onboarding":{"steps":[{"type":"CompletionStep","id":"a"}]},
       "survey":{"steps":[{"type":"CompletionStep","id":"b"}]}}''';
      await FormStack.api().buildFormFromJsonString(multi);
      expect(FormStack.formByInstaceAndName(formName: 'onboarding'), isNotNull);
      expect(FormStack.formByInstaceAndName(formName: 'survey'), isNotNull);
    });

    test('round-trips through jsonEncode without loss of step ids', () async {
      await FormStack.api().buildFormFromJsonString(_survey);
      final form = FormStack.formByInstaceAndName()!;
      form.getStep('email')!.result = 'user@example.com';
      final encoded = jsonEncode(form.exportAsJson());
      expect(encoded, contains('user@example.com'));
    });
  });

  group('malformed definitions are reported, not absorbed', () {
    test('a relevant condition with neither id nor formName is rejected', () {
      const bad = '''
      {"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"text",
        "relevantConditions":[{"expression":"= yes"}]}]}}''';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'a cross-form condition may target a formName instead of an id',
      () async {
        // Empty "id" with a "formName" is how navigation to another form is
        // expressed; it must not be treated as a malformed condition.
        const crossForm = '''
      {"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"text",
        "relevantConditions":[{"id":"","expression":"= yes","formName":"other"}]}]},
       "other":{"steps":[{"type":"CompletionStep","id":"done"}]}}''';
        await FormStack.api().buildFormFromJsonString(crossForm);
        final form = FormStack.formByInstaceAndName()!;
        expect(form.getStep('q')!.relevantConditions!.single.formName, 'other');
      },
    );

    test('a relevant condition without an expression is rejected', () {
      const bad = '''
      {"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"text",
        "relevantConditions":[{"id":"target"}]}]}}''';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(isA<FormatException>()),
      );
    });

    test('relevantConditions must be a list', () {
      const bad =
          '{"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"text","relevantConditions":"nope"}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(isA<FormatException>()),
      );
    });

    test('an option that is not an object is rejected', () {
      const bad =
          '{"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"dropdown","options":["US"]}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(isA<FormatException>()),
      );
    });

    test('an unknown validator names the step it came from', () {
      const bad =
          '{"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"text","validators":[{"type":"wat"}]}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(isA<FormatException>()),
      );
    });

    test('numeric style values survive being written as strings', () async {
      const styled = '''
      {"default":{"theme":{"borderRadius":"14","titleBottomPadding":"6"},
       "steps":[{"type":"CompletionStep","id":"done"}]}}''';
      await FormStack.api().buildFormFromJsonString(styled);
      final form = FormStack.formByInstaceAndName()!;
      expect(form.getStep('done')!.style!.borderRadius, 14.0);
    });
  });

  group('form-level theme', () {
    test('a step without its own style inherits the form theme', () async {
      const themed = '''
      {"default":{"theme":{"borderRadius":18,"backgroundColor":"#FF0000"},
       "steps":[{"type":"QuestionStep","id":"q","inputType":"text"}]}}''';
      await FormStack.api().buildFormFromJsonString(themed);
      final form = FormStack.formByInstaceAndName()!;
      expect(form.getStep('q')!.style!.borderRadius, 18.0);
    });

    test('a step style overrides the form theme', () async {
      const themed = '''
      {"default":{"theme":{"borderRadius":18},
       "steps":[{"type":"QuestionStep","id":"q","inputType":"text",
                 "style":{"borderRadius":4}}]}}''';
      await FormStack.api().buildFormFromJsonString(themed);
      final form = FormStack.formByInstaceAndName()!;
      expect(form.getStep('q')!.style!.borderRadius, 4.0);
    });

    test('without a theme a step has no style of its own', () async {
      const plain =
          '{"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"text"}]}}';
      await FormStack.api().buildFormFromJsonString(plain);
      final form = FormStack.formByInstaceAndName()!;
      expect(form.getStep('q')!.style, isNull);
    });
  });
}
