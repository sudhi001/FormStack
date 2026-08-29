import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';
import 'dart:convert';
import 'dart:io';

/// Parses the form definitions the example app actually ships.
///
/// A synthetic fixture can drift from what real users write; these files
/// exercise cross-form navigation, nested steps and per-step styling as they
/// are used in practice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // loading.json and success.json are Lottie animations, not form definitions.
  for (final name in ['app', 'comprehensive_demo', 'full']) {
    test('example asset $name parses', () async {
      final data = File('example/assets/$name.json').readAsStringSync();
      FormStack.clearConfiguration();
      await FormStack.api().buildFormFromJsonString(data);
      // Every top-level key is a form; assert each one built with steps.
      final names = (jsonDecode(data) as Map<String, dynamic>).keys;
      for (final formName in names) {
        final form = FormStack.formByInstaceAndName(formName: formName);
        expect(form, isNotNull,
            reason: 'form "$formName" missing in $name.json');
        expect(form!.steps, isNotEmpty,
            reason: 'form "$formName" has no steps');
      }
    });
  }
}
