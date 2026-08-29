import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// A minimal application-supplied input used to prove the extension point.
// ignore: must_be_immutable
class _StubInputView extends BaseStepView<QuestionStep> {
  _StubInputView(super.form, super.step, super.text, {super.title});

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) =>
      const Text('stub');

  @override
  bool isValid() => true;

  @override
  String validationError() => '';

  @override
  dynamic resultValue() => 'stub-value';

  @override
  void clearFocus() {}

  @override
  void requestFocus() {}
}

FormStackForm formWith(List<FormStep> steps) {
  FormStack.clearConfiguration();
  FormStack.api().form(
    steps: steps,
    mapKey: MapKey('', '', ''),
    initialLocation: LocationWrapper(0, 0),
  );
  return FormStack.formByInstaceAndName()!;
}

void main() {
  setUp(() {
    FormStack.clearConfiguration();
    InputRegistry.instance.reset();
    StepRegistry.instance.reset();
    ValidatorRegistry.instance.reset();
  });

  group('InputRegistry', () {
    test('resolves a custom input type registered by the application', () {
      InputRegistry.instance.register(
        'stub',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text, title: ctx.title),
      );

      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.custom,
        customInputType: 'stub',
      );
      final form = formWith([step]);

      expect(step.buildView(form), isA<_StubInputView>());
    });

    test('a registered name overrides the matching built-in', () {
      InputRegistry.instance.register(
        'text',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text, title: ctx.title),
      );

      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.text,
      );
      final form = formWith([step]);

      expect(step.buildView(form), isA<_StubInputView>());
    });

    test('built-in inputs still resolve when nothing is registered', () {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.text,
      );
      final form = formWith([step]);

      expect(step.buildView(form), isA<BaseStepView<QuestionStep>>());
      expect(step.buildView(form), isNot(isA<_StubInputView>()));
    });

    test('an unregistered custom type fails with an actionable message', () {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.custom,
        customInputType: 'missing',
      );
      final form = formWith([step]);

      expect(
        () => step.buildView(form),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('missing'),
          ),
        ),
      );
    });

    test('a default validator is applied when the step declares none', () {
      InputRegistry.instance.register(
        'stub',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text),
        defaultValidator: () => ResultFormat.notBlank('required'),
      );

      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.custom,
        customInputType: 'stub',
      );
      step.buildView(formWith([step]));

      expect(step.resultFormat!.isValid('  '), isFalse);
      expect(step.resultFormat!.isValid('x'), isTrue);
    });

    test('an explicit validator wins over the registered default', () {
      InputRegistry.instance.register(
        'stub',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text),
        defaultValidator: () => ResultFormat.notBlank('required'),
      );

      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.custom,
        customInputType: 'stub',
        resultFormat: ResultFormat.email('bad email'),
      );
      step.buildView(formWith([step]));

      expect(step.resultFormat!.code, 'email');
    });

    test('each step receives its own validator instance', () {
      var built = 0;
      InputRegistry.instance.register(
        'stub',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text),
        defaultValidator: () {
          built++;
          return ResultFormat.notBlank('required');
        },
      );

      final a = QuestionStep(
        id: GenericIdentifier(id: 'a'),
        inputType: InputType.custom,
        customInputType: 'stub',
      );
      final b = QuestionStep(
        id: GenericIdentifier(id: 'b'),
        inputType: InputType.custom,
        customInputType: 'stub',
      );
      final form = formWith([a, b]);
      a.buildView(form);
      b.buildView(form);

      expect(built, 2);
      expect(a.resultFormat, isNot(same(b.resultFormat)));
    });

    test('unregister restores the built-in behaviour', () {
      InputRegistry.instance.register(
        'text',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text),
      );
      expect(InputRegistry.instance.unregister('text'), isTrue);
      expect(InputRegistry.instance.contains('text'), isFalse);
    });

    test('registering an empty type name is rejected', () {
      expect(
        () =>
            InputRegistry.instance.register('', (ctx) => throw StateError('')),
        throwsArgumentError,
      );
    });
  });

  group('StepRegistry', () {
    test('an application step type becomes parseable from JSON', () async {
      StepRegistry.instance.register(
        'AuditStep',
        (json, conditions) => DisplayStep(
          id: GenericIdentifier(id: json['id']),
          title: json['title'],
          relevantConditions: conditions,
        ),
      );

      await FormStack.api().buildFormFromJsonString(
        '{"default":{"steps":[{"type":"AuditStep","id":"audit","title":"Audit"}]}}',
      );

      final form = FormStack.formByInstaceAndName()!;
      expect(form.getStep('audit')?.title, 'Audit');
    });

    test('built-ins are restored automatically after a reset', () async {
      StepRegistry.instance.reset();
      await FormStack.api().buildFormFromJsonString(
        '{"default":{"steps":[{"type":"CompletionStep","id":"done"}]}}',
      );
      expect(FormStack.formByInstaceAndName()!.getStep('done'), isNotNull);
    });
  });

  group('ValidatorRegistry', () {
    test('builds a single validator from an object', () {
      final validator = ResultFormat.fromJson({
        'type': 'minLength',
        'message': 'too short',
        'min': 4,
      })!;
      expect(validator.isValid('abc'), isFalse);
      expect(validator.isValid('abcd'), isTrue);
    });

    test('composes a list of validators', () {
      final validator = ResultFormat.fromJson([
        {'type': 'notBlank', 'message': 'required'},
        {'type': 'maxLength', 'message': 'too long', 'max': 3},
      ])!;
      expect(validator.isValid(''), isFalse);
      expect(validator.isValid('abcd'), isFalse);
      expect(validator.isValid('abc'), isTrue);
    });

    test('accepts a bare type name as shorthand', () {
      expect(ResultFormat.fromJson('email')!.code, 'email');
    });

    test('returns null for a null specification', () {
      expect(ResultFormat.fromJson(null), isNull);
    });

    test('an unknown type names what is available', () {
      expect(
        () => ResultFormat.fromJson({'type': 'nonsense'}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('nonsense'),
          ),
        ),
      );
    });

    test('an application validator is usable from JSON', () {
      ResultFormat.register(
        'evenNumber',
        (message, args) =>
            ResultFormat.custom(message, (v) => (int.tryParse(v) ?? 1).isEven),
      );

      final validator = ResultFormat.fromJson({
        'type': 'evenNumber',
        'message': 'must be even',
      })!;
      expect(validator.isValid('4'), isTrue);
      expect(validator.isValid('5'), isFalse);
    });

    test('pattern requires a regex', () {
      expect(
        () => ResultFormat.fromJson({'type': 'pattern', 'message': 'x'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('numeric arguments are coerced from strings', () {
      final validator = ResultFormat.fromJson({
        'type': 'range',
        'message': 'out',
        'min': '1',
        'max': '5',
      })!;
      expect(validator.isValid(3), isTrue);
      expect(validator.isValid(9), isFalse);
    });
  });

  group('built-in inputs are registered, not switched on', () {
    test('every InputType except custom resolves to a builder', () {
      // Building any step installs the built-in set.
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.text,
      );
      step.buildView(formWith([step]));

      final missing = InputType.values
          .where((t) => t != InputType.custom)
          .where((t) => !InputRegistry.instance.contains(t.name))
          .map((t) => t.name)
          .toList();
      expect(
        missing,
        isEmpty,
        reason: 'these input types have no registered builder',
      );
    });

    test('an override registered first survives built-in installation', () {
      // registerIfAbsent must not clobber an application's own widget, no
      // matter which type it overrides or when the first form is built.
      InputRegistry.instance.register(
        'geoshape',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text),
      );

      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.geoshape,
      );
      expect(step.buildView(formWith([step])), isA<_StubInputView>());

      // ...and the rest of the built-ins are still installed alongside it.
      expect(InputRegistry.instance.contains('email'), isTrue);
      expect(InputRegistry.instance.contains('slider'), isTrue);
    });

    test('a step keeps its own validator over the built-in default', () {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.text,
        resultFormat: ResultFormat.minLength('too short', 5),
      );
      step.buildView(formWith([step]));
      expect(step.resultFormat!.code, 'minLength');
    });

    test('a step without a validator gets the built-in default', () {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.email,
      );
      step.buildView(formWith([step]));
      expect(step.resultFormat!.code, 'email');
    });

    test('step-dependent defaults read the step', () {
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.rating,
        ratingCount: 10,
      );
      step.buildView(formWith([step]));
      expect(step.resultFormat!.params, {'min': 1, 'max': 10});
    });

    test('a custom input without a default validator is left unvalidated', () {
      // Stamping ResultFormat.none() here would mark the step permanently
      // valid and make a validator assigned later unreachable.
      InputRegistry.instance.register(
        'bare',
        (ctx) => _StubInputView(ctx.form, ctx.step, ctx.text),
      );
      final step = QuestionStep(
        id: GenericIdentifier(id: 'q'),
        inputType: InputType.custom,
        customInputType: 'bare',
      );
      step.buildView(formWith([step]));
      expect(step.resultFormat, isNull);
    });
  });
}
