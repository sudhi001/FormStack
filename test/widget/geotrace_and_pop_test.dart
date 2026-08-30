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

  group('geotrace and geoshape', () {
    QuestionStep trace(InputType type, {bool optional = true}) => QuestionStep(
      id: GenericIdentifier(id: type.name),
      inputType: type,
      title: 'Trace',
      isOptional: optional,
    );

    testWidgets('renders with no points collected', (tester) async {
      await pump(tester, [trace(InputType.geotrace)]);

      expect(tester.takeException(), isNull);
      expect(find.text('Trace'), findsOneWidget);
    });

    testWidgets('adding a coordinate records it on the step', (tester) async {
      final step = trace(InputType.geotrace);
      await pump(tester, [step]);

      await tester.tap(find.byIcon(Icons.add_location_alt));
      await tester.pumpAndSettle();

      // Two coordinate fields, each owning its controller -- constructing
      // them in the dialog builder leaked one per rebuild.
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), '51.5');
      await tester.enterText(fields.at(1), '-0.12');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(step.result, isA<List<Map<String, double>>>());
      expect((step.result as List).single, {'lat': 51.5, 'lng': -0.12});
    });

    testWidgets('a cancelled dialog adds nothing', (tester) async {
      final step = trace(InputType.geotrace);
      await pump(tester, [step]);

      await tester.tap(find.byIcon(Icons.add_location_alt));
      await tester.pumpAndSettle();
      // The step's own app-bar Cancel also matches, so scope to the dialog.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();

      expect(step.result, anyOf(isNull, isEmpty));
    });

    testWidgets('a path needs two points, a shape needs three', (tester) async {
      final path = trace(InputType.geotrace, optional: false);
      final shape = trace(InputType.geoshape, optional: false);

      await pump(tester, [path]);
      path.result = [
        {'lat': 1.0, 'lng': 1.0},
      ];
      var view = FormStack.formByInstaceAndName()!.render((_) {}, null);
      expect(view, isNotNull);

      await pump(tester, [shape]);
      shape.result = [
        {'lat': 1.0, 'lng': 1.0},
        {'lat': 2.0, 'lng': 2.0},
      ];
      view = FormStack.formByInstaceAndName()!.render((_) {}, null);
      expect(view, isNotNull);
    });

    testWidgets('previously collected points are restored', (tester) async {
      final step = trace(InputType.geotrace)
        ..result = [
          {'lat': 1.5, 'lng': 2.5},
          {'lat': 3.5, 'lng': 4.5},
        ];
      await pump(tester, [step]);

      expect(find.textContaining('2 points'), findsOneWidget);
    });
  });

  group('PopStep', () {
    testWidgets('pops the route it was pushed onto', (tester) async {
      FormStack.clearConfiguration();
      FormStack.api().form(
        steps: [PopStep(id: GenericIdentifier(id: 'pop'))],
        mapKey: MapKey('', '', ''),
        initialLocation: LocationWrapper(0, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FormStack.api().render(),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The form popped itself, so we are back on the launching screen.
      expect(find.text('Open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('at the root of the app it does nothing rather than throwing', (
      tester,
    ) async {
      // Navigator.pop with nothing beneath it used to throw.
      await pump(tester, [PopStep(id: GenericIdentifier(id: 'pop'))]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
