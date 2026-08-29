import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Exercises the extension-point wiring the example app demonstrates.
///
/// The example is the reference users copy from, so the combination it shows —
/// a registered input, a named validator resolved from a JSON spec, and a
/// device capability, all inside a themed scope — is worth a test of its own.
void main() {
  setUp(() {
    FormStack.clearConfiguration();
    InputRegistry.instance.reset();
    ValidatorRegistry.instance.reset();
    DeviceCapabilities.instance.reset();
  });

  tearDown(() {
    InputRegistry.instance.reset();
    ValidatorRegistry.instance.reset();
    DeviceCapabilities.instance.reset();
  });

  testWidgets('a form combining all three extension points renders and runs', (
    tester,
  ) async {
    InputRegistry.instance.register(
      'colorPicker',
      (ctx) => _SwatchView(ctx.form, ctx.step, ctx.text, title: ctx.title),
      defaultValidator: () => ResultFormat.notNull('Please pick a colour.'),
    );
    ResultFormat.register(
      'evenNumber',
      (message, args) => ResultFormat.custom(
        message,
        (value) => (int.tryParse(value) ?? 1).isEven,
      ),
    );

    final colour = QuestionStep(
      id: GenericIdentifier(id: 'colour'),
      title: 'Pick a colour',
      inputType: InputType.custom,
      customInputType: 'colorPicker',
    );
    final evens = QuestionStep(
      id: GenericIdentifier(id: 'evens'),
      title: 'Even number',
      inputType: InputType.number,
      resultFormat: ResultFormat.fromJson({
        'type': 'evenNumber',
        'message': 'That is not an even number.',
      }),
    );

    FormStack.api().form(
      steps: [colour, evens],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FormStackThemeScope(
          theme: const FormStackTheme(maxContentWidth: 520, borderRadius: 4),
          child: Scaffold(body: FormStack.api().render()),
        ),
      ),
    );

    // The registered input renders, and the registered default validator
    // was applied to a step that declared none.
    expect(find.text('Pick a colour'), findsOneWidget);
    expect(colour.resultFormat!.code, 'notNull');

    // The JSON-resolved validator is the one attached to the second step.
    expect(evens.resultFormat!.isValid('4'), isTrue);
    expect(evens.resultFormat!.isValid('5'), isFalse);

    // The scoped theme reaches the rendered form.
    final scoped = tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .where((c) => c.constraints.maxWidth == 520);
    expect(scoped, isNotEmpty);
  });

  testWidgets('unregistering an extension restores the previous behaviour', (
    tester,
  ) async {
    // The example unregisters in dispose so reopening it starts clean; this
    // guards that the registries really do come back to their built-in state.
    InputRegistry.instance.register(
      'colorPicker',
      (ctx) => _SwatchView(ctx.form, ctx.step, ctx.text),
    );
    expect(InputRegistry.instance.contains('colorPicker'), isTrue);

    InputRegistry.instance.unregister('colorPicker');
    ValidatorRegistry.instance.unregister('evenNumber');

    expect(InputRegistry.instance.contains('colorPicker'), isFalse);
    expect(
      () => ResultFormat.fromJson({'type': 'evenNumber'}),
      throwsA(isA<FormatException>()),
    );
    // Built-ins are untouched by an application unregistering its own entries.
    expect(ValidatorRegistry.instance.contains('email'), isTrue);
  });
}

// ignore: must_be_immutable
class _SwatchView extends BaseStepView<QuestionStep> {
  _SwatchView(super.form, super.step, super.text, {super.title});

  final ValueNotifier<String?> _selected = ValueNotifier<String?>(null);

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) =>
      const SizedBox(width: 64, height: 64);

  @override
  bool isValid() => formStep.resultFormat?.isValid(_selected.value) ?? true;

  @override
  String validationError() => formStep.resultFormat?.error() ?? '';

  @override
  dynamic resultValue() => _selected.value;

  @override
  void requestFocus() {}

  @override
  void clearFocus() {}

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }
}
