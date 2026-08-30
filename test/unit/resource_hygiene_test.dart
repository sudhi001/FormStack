import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level guards against the leak patterns this library is prone to.
///
/// Step views hold their controllers as fields, and dialogs are built inside
/// closures that Flutter re-invokes — two shapes where a missing `dispose()`
/// is invisible at review and at runtime until a profiler is attached. These
/// tests read the source and assert the shapes directly, because there is no
/// way to observe a leaked `TextEditingController` from a widget test.

final _libDir = Directory('lib');

List<File> _dartFiles() => _libDir
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Types that must be released explicitly.
const _disposables = {
  'TextEditingController': 'dispose',
  'FocusNode': 'dispose',
  'AnimationController': 'dispose',
  'ScrollController': 'dispose',
  'ValueNotifier': 'dispose',
  'OverlayEntry': 'remove',
};

void main() {
  group('every disposable field is released', () {
    for (final file in _dartFiles()) {
      final source = file.readAsStringSync();
      final relative = file.path;

      // Fields, not locals: `final X _y = Type(...)` at class level.
      final declared = <String>{};
      for (final type in _disposables.keys) {
        final fieldPattern = RegExp(
          r'^\s{2}(?:final\s+|late\s+final\s+)?' +
              type +
              r'[<?\w >]*\s+\w+\s*=',
          multiLine: true,
        );
        if (fieldPattern.hasMatch(source)) declared.add(type);
      }
      if (declared.isEmpty) continue;

      test(
        '${relative.replaceFirst('lib/', '')} disposes ${declared.join(', ')}',
        () {
          expect(
            source.contains('void dispose()'),
            isTrue,
            reason:
                '$relative holds ${declared.join(', ')} as a field but declares '
                'no dispose(). Step views are released by the framework only if '
                'they override it.',
          );
          for (final type in declared) {
            final release = _disposables[type]!;
            expect(
              RegExp(r'\.' + release + r'\(\)').hasMatch(source),
              isTrue,
              reason: '$relative allocates a $type but never calls .$release()',
            );
          }
        },
      );
    }
  });

  group('dialogs do not own controllers', () {
    for (final file in _dartFiles()) {
      final source = file.readAsStringSync();
      // Matches showDialog(...) and showDialog<T>(...) alike -- keying on the
      // bare 'showDialog(' silently skipped every call site once the type
      // argument was added for strict-inference.
      final dialogCall = RegExp(r'showDialog(<[^>]*>)?\(');
      if (!dialogCall.hasMatch(source)) continue;
      // DialogTextField is the sanctioned owner: it holds the controller in a
      // State the framework disposes, which is the fix this rule enforces.
      if (file.path.endsWith('dialog_text_field.dart')) continue;

      test(
        '${file.path.replaceFirst('lib/', '')} builds no controller inside a dialog',
        () {
          // A controller constructed inside a showDialog builder is never
          // disposed, and the builder runs on every rebuild of the dialog route
          // -- so the leak is per rebuild, not per dialog. Use DialogTextField,
          // which ties the controller to an element the framework disposes.
          final dialogStart = source.indexOf('showDialog');
          final dialogSource = source.substring(dialogStart);
          expect(
            dialogSource.contains('TextEditingController('),
            isFalse,
            reason:
                '${file.path} constructs a TextEditingController inside a dialog '
                'builder. Use DialogTextField instead.',
          );
        },
      );
    }
  });

  group('platform-backed controllers are not built during build()', () {
    test('WebViewController is created in a State, not a build method', () {
      final source = File('lib/src/ui/views/web_view.dart').readAsStringSync();
      // It previously lived in a static buildView() called straight from
      // build(), so every rebuild created another native web view and issued
      // another loadRequest.
      expect(source.contains('extends State<'), isTrue);
      expect(
        RegExp(
          r'static\s+Widget\s+buildView[^}]*WebViewController\(',
        ).hasMatch(source),
        isFalse,
        reason: 'WebViewController must not be constructed in a build path',
      );
    });
  });

  group('image bytes are decoded once, not per build', () {
    for (final path in [
      'lib/src/ui/views/input/image_input_field.dart',
      'lib/src/ui/views/input/signature_input_field.dart',
    ]) {
      test('${path.split('/').last} caches its decoded bytes', () {
        final source = File(path).readAsStringSync();
        // Image.memory keys its cache entry on the Uint8List instance, so
        // decoding afresh each build re-decodes and evicts other entries.
        expect(
          source.contains('Uint8List?'),
          isTrue,
          reason: '$path should hold decoded bytes rather than decode inline',
        );
      });
    }
  });
}
