import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

Widget host(Widget child, {Size size = const Size(1200, 900)}) => MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(home: child),
    );

void main() {
  setUp(FormStack.clearConfiguration);

  Widget formWidget() {
    FormStack.api().form(
      steps: [
        QuestionStep(
          id: GenericIdentifier(id: 'q'),
          inputType: InputType.text,
          title: 'Question',
        ),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    return FormStack.api().render();
  }

  group('FormStackTheme', () {
    testWidgets('falls back to defaults with no scope', (tester) async {
      late FormStackTheme resolved;
      await tester.pumpWidget(host(Builder(builder: (context) {
        resolved = FormStackTheme.of(context);
        return const SizedBox();
      })));
      expect(resolved, FormStackTheme.defaults);
      expect(resolved.maxContentWidth, 600);
    });

    testWidgets('a scope overrides the dimensions for its subtree',
        (tester) async {
      late FormStackTheme resolved;
      await tester.pumpWidget(host(FormStackThemeScope(
        theme: const FormStackTheme(maxContentWidth: 900, contentPadding: 40),
        child: Builder(builder: (context) {
          resolved = FormStackTheme.of(context);
          return const SizedBox();
        }),
      )));
      expect(resolved.maxContentWidth, 900);
      expect(resolved.contentPadding, 40);
    });

    testWidgets('responsiveMaxWidth honours the scoped value on wide screens',
        (tester) async {
      late double width;
      await tester.pumpWidget(host(FormStackThemeScope(
        theme: const FormStackTheme(maxContentWidth: 900),
        child: Builder(builder: (context) {
          width = FormStackTheme.responsiveMaxWidth(context);
          return const SizedBox();
        }),
      )));
      expect(width, 900);
    });

    testWidgets('responsivePadding scales the scoped padding down when narrow',
        (tester) async {
      late double wide;
      late double narrow;
      await tester.pumpWidget(host(
        FormStackThemeScope(
          theme: const FormStackTheme(contentPadding: 40),
          child: Builder(builder: (context) {
            wide = FormStackTheme.responsivePadding(context);
            return const SizedBox();
          }),
        ),
      ));
      await tester.pumpWidget(host(
        FormStackThemeScope(
          theme: const FormStackTheme(contentPadding: 40),
          child: Builder(builder: (context) {
            narrow = FormStackTheme.responsivePadding(context);
            return const SizedBox();
          }),
        ),
        size: const Size(360, 800),
      ));
      expect(wide, 40);
      expect(narrow, lessThan(40));
    });

    testWidgets('a scoped theme reaches a rendered form', (tester) async {
      // Regression guard: FormStackTheme's fields used to be inert -- every
      // call site used the static helpers with hard-coded defaults, so
      // constructing one had no effect at all.
      await tester.pumpWidget(host(FormStackThemeScope(
        theme: const FormStackTheme(maxContentWidth: 320),
        child: formWidget(),
      )));

      final constrained = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((c) => c.constraints.maxWidth == 320);
      expect(constrained, isNotEmpty,
          reason: 'the scoped maxContentWidth should constrain step content');
    });

    testWidgets('copyWith replaces only the named fields', (tester) async {
      const base = FormStackTheme(maxContentWidth: 600, borderRadius: 12);
      final derived = base.copyWith(borderRadius: 4);
      expect(derived.borderRadius, 4);
      expect(derived.maxContentWidth, 600);
      expect(derived, isNot(base));
    });
  });
}
