import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Records disposal so the test can assert the form released its views.
// ignore: must_be_immutable
class _TrackedInputView extends BaseStepView<QuestionStep> {
  _TrackedInputView(
    super.form,
    super.step,
    super.text,
    this.onDisposed, {
    super.title,
  });

  final void Function(String id) onDisposed;
  final TextEditingController controller = TextEditingController();

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) =>
      TextField(controller: controller);

  @override
  bool isValid() => true;

  @override
  String validationError() => '';

  @override
  dynamic resultValue() => controller.text;

  @override
  void clearFocus() {}

  @override
  void requestFocus() {}

  @override
  void dispose() {
    controller.dispose();
    onDisposed(formStep.id?.id ?? '');
    super.dispose();
  }
}

QuestionStep trackedStep(String id) => QuestionStep(
  id: GenericIdentifier(id: id),
  inputType: InputType.custom,
  customInputType: 'tracked',
  title: id,
);

void main() {
  late List<String> disposed;

  setUp(() {
    disposed = [];
    FormStack.clearConfiguration();
    InputRegistry.instance.reset();
    InputRegistry.instance.register(
      'tracked',
      (ctx) => _TrackedInputView(
        ctx.form,
        ctx.step,
        ctx.text,
        disposed.add,
        title: ctx.title,
      ),
    );
  });

  tearDown(InputRegistry.instance.reset);

  Widget hostFor(List<FormStep> steps) {
    FormStack.api().form(
      steps: steps,
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    return MaterialApp(home: FormStack.api().render());
  }

  testWidgets('a form renders its first step', (tester) async {
    await tester.pumpWidget(hostFor([trackedStep('a'), trackedStep('b')]));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsNothing);
  });

  testWidgets('removing the form disposes every cached step view', (
    tester,
  ) async {
    // Regression guard: step views are StatelessWidgets holding controllers,
    // so nothing in the framework disposes them. The form must do it.
    await tester.pumpWidget(hostFor([trackedStep('a'), trackedStep('b')]));
    expect(disposed, isEmpty);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    expect(disposed, contains('a'));
  });

  testWidgets('navigating away disposes the view that left the tree', (
    tester,
  ) async {
    // The framework owns step-view lifetime now: leaving the tree disposes.
    await tester.pumpWidget(hostFor([trackedStep('a'), trackedStep('b')]));
    final form = FormStack.formByInstaceAndName()!;

    form.nextStep(form.getStep('a'));
    await tester.pumpAndSettle();

    expect(disposed, contains('a'));
    expect(disposed, isNot(contains('b')));
  });

  testWidgets('a long form retains only the view on screen', (tester) async {
    // Previously every visited step's controllers were held by a cache until
    // it evicted them; now each is released as soon as its step is left.
    final steps = List.generate(6, (i) => trackedStep('s$i'));
    await tester.pumpWidget(hostFor(steps));
    final form = FormStack.formByInstaceAndName()!;

    for (var i = 0; i < 5; i++) {
      form.nextStep(form.getStep('s$i'));
      await tester.pumpAndSettle();
    }

    expect(disposed, containsAll(['s0', 's1', 's2', 's3', 's4']));
    expect(disposed, isNot(contains('s5')));
  });

  testWidgets('a view is disposed exactly once', (tester) async {
    await tester.pumpWidget(hostFor([trackedStep('a')]));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    expect(disposed.where((id) => id == 'a'), hasLength(1));
  });

  testWidgets('navigating forward shows the next step', (tester) async {
    await tester.pumpWidget(hostFor([trackedStep('a'), trackedStep('b')]));
    final form = FormStack.formByInstaceAndName()!;

    form.nextStep(form.getStep('a'));
    await tester.pumpAndSettle();

    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('a progress bar reports position out of total', (tester) async {
    await tester.pumpWidget(
      hostFor([trackedStep('a'), trackedStep('b'), trackedStep('c')]),
    );
    expect(find.text('Step 1 of 3'), findsOneWidget);
  });
}
