import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

void main() {
  group('JsonReader', () {
    const source = {
      'title': 'Hello',
      'count': 4,
      'countAsText': '7',
      'ratio': 1.5,
      'flag': true,
      'flagAsText': 'false',
      'items': [1, 2],
      'nested': {'a': 1},
      'display': 'medium',
    };
    const read = JsonReader(source, context: 'Step');

    test('reads each type', () {
      expect(read.string('title'), 'Hello');
      expect(read.integer('count'), 4);
      expect(read.decimal('ratio'), 1.5);
      expect(read.boolean('flag'), isTrue);
      expect(read.list('items'), [1, 2]);
      expect(read.map('nested'), {'a': 1});
    });

    test('coerces the shapes JSON authors actually write', () {
      expect(read.integer('countAsText'), 7);
      expect(read.boolean('flagAsText'), isFalse);
      // A number where text is expected is common and harmless.
      expect(read.string('count'), '4');
    });

    test('a missing key is null, not an error', () {
      expect(read.string('nope'), isNull);
      expect(read.integer('nope'), isNull);
      expect(read.boolean('nope'), isNull);
      expect(read.map('nope'), isNull);
      expect(read.list('nope'), isEmpty);
    });

    test('a null source reads as entirely absent', () {
      const empty = JsonReader(null);
      expect(empty.string('anything'), isNull);
      expect(empty.list('anything'), isEmpty);
      expect(empty.has('anything'), isFalse);
    });

    test('a wrong type is an error naming the field and the context', () {
      expect(
        () => read.integer('title'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('Step'), contains('title')),
          ),
        ),
      );
      expect(() => read.list('title'), throwsA(isA<FormatException>()));
      expect(() => read.map('title'), throwsA(isA<FormatException>()));
      expect(() => read.boolean('title'), throwsA(isA<FormatException>()));
    });

    test('enumValue matches by name', () {
      expect(read.enumValue('display', Display.values), Display.medium);
      expect(read.enumValue('nope', Display.values), isNull);
    });

    test('an unknown enum name lists what was expected', () {
      const bad = JsonReader({'display': 'gigantic'}, context: 'Step');
      expect(
        () => bad.enumValue('display', Display.values),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('gigantic'), contains('extraLarge')),
          ),
        ),
      );
    });
  });

  group('parsing surfaces bad field types', () {
    setUp(FormStack.clearConfiguration);

    test('a non-numeric count is reported, not silently defaulted', () {
      const bad =
          '{"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"otp","count":"many"}]}}';
      expect(
        () => FormStack.api().buildFormFromJsonString(bad),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('count'),
          ),
        ),
      );
    });

    test('a numeric string where a number is expected still parses', () async {
      const ok =
          '{"default":{"steps":[{"type":"QuestionStep","id":"q","inputType":"otp","count":"6"}]}}';
      await FormStack.api().buildFormFromJsonString(ok);
      final step =
          FormStack.formByInstaceAndName()!.getStep('q')! as QuestionStep;
      expect(step.count, 6);
    });
  });
}
