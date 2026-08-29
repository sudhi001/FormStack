import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

void main() {
  group('ResultFormat built-ins', () {
    test('email accepts valid addresses and rejects malformed ones', () {
      final validator = ResultFormat.email('bad email');
      expect(validator.isValid('user@example.com'), isTrue);
      expect(validator.isValid('user.name+tag@sub.example.co.uk'), isTrue);
      expect(validator.isValid('user@'), isFalse);
      expect(validator.isValid('no-at-sign.com'), isFalse);
      expect(validator.isValid(null), isFalse);
      expect(validator.isValid(42), isFalse);
    });

    test('notEmpty distinguishes empty from blank', () {
      expect(ResultFormat.notEmpty('e').isValid(''), isFalse);
      expect(ResultFormat.notEmpty('e').isValid('  '), isTrue);
      expect(ResultFormat.notBlank('e').isValid('  '), isFalse);
      expect(ResultFormat.notBlank('e').isValid(' x '), isTrue);
    });

    test('range enforces inclusive bounds', () {
      final validator = ResultFormat.range('out of range', 1, 10);
      expect(validator.isValid(1), isTrue);
      expect(validator.isValid(10), isTrue);
      expect(validator.isValid(0), isFalse);
      expect(validator.isValid(11), isFalse);
    });

    test('minLength and maxLength bound string length', () {
      expect(ResultFormat.minLength('short', 3).isValid('ab'), isFalse);
      expect(ResultFormat.minLength('short', 3).isValid('abc'), isTrue);
      expect(ResultFormat.maxLength('long', 3).isValid('abcd'), isFalse);
      expect(ResultFormat.maxLength('long', 3).isValid('abc'), isTrue);
    });

    test('creditCard applies the Luhn checksum', () {
      final validator = ResultFormat.creditCard('bad card');
      expect(validator.isValid('4539578763621486'), isTrue);
      expect(validator.isValid('4539 5787 6362 1486'), isTrue);
      expect(validator.isValid('4539578763621487'), isFalse);
      expect(validator.isValid('123'), isFalse);
    });

    test('iban validates the mod-97 checksum', () {
      final validator = ResultFormat.iban('bad iban');
      expect(validator.isValid('GB82 WEST 1234 5698 7654 32'), isTrue);
      expect(validator.isValid('GB82WEST12345698765433'), isFalse);
      expect(validator.isValid('XX'), isFalse);
    });

    test('pattern compiles the expression once and reuses it', () {
      final validator = ResultFormat.pattern('letters only', r'^[a-z]+$');
      for (var i = 0; i < 100; i++) {
        expect(validator.isValid('abc'), isTrue);
      }
      expect(validator.isValid('abc1'), isFalse);
    });

    test('phone accepts E.164 and rejects malformed numbers', () {
      final validator = ResultFormat.phone('bad phone');
      expect(validator.isValid('+14155552671'), isTrue);
      expect(validator.isValid('+0123'), isFalse);
      expect(validator.isValid('abc'), isFalse);
    });
  });

  group('ResultFormat.compose', () {
    test('passes only when every child passes', () {
      final validator = ResultFormat.compose([
        ResultFormat.notEmpty('required'),
        ResultFormat.minLength('too short', 3),
        ResultFormat.maxLength('too long', 5),
      ]);
      expect(validator.isValid('abcd'), isTrue);
      expect(validator.isValid('ab'), isFalse);
      expect(validator.isValid('abcdef'), isFalse);
    });

    test('reports the first failing child', () {
      final validator = ResultFormat.compose([
        ResultFormat.notEmpty('required'),
        ResultFormat.minLength('too short', 3),
      ]);
      final outcome = validator.validate('ab');
      expect(outcome.isValid, isFalse);
      expect(outcome.code, 'minLength');
      expect(outcome.message, 'too short');
      expect(outcome.children.single.params['min'], 3);
    });

    test('validate is stateless across interleaved calls', () {
      final validator = ResultFormat.compose([
        ResultFormat.minLength('too short', 3),
      ]);
      final bad = validator.validate('a');
      final good = validator.validate('abc');
      // The failure captured earlier must not be mutated by the later call.
      expect(bad.isValid, isFalse);
      expect(bad.message, 'too short');
      expect(good.isValid, isTrue);
    });
  });

  group('ValidationResult', () {
    test('carries a stable code and constraint params on failure', () {
      final outcome = ResultFormat.range('out of range', 18, 120).validate(5);
      expect(outcome.isValid, isFalse);
      expect(outcome.code, 'range');
      expect(outcome.params, {'min': 18, 'max': 120});
      expect(outcome.toJson()['code'], 'range');
    });

    test('is empty and code-less when valid', () {
      final outcome = ResultFormat.email('bad').validate('a@b.com');
      expect(outcome.isValid, isTrue);
      expect(outcome.code, isEmpty);
      expect(outcome.toJson(), {'isValid': true});
    });

    test('a custom validator defaults to the "custom" code', () {
      final outcome = ResultFormat.custom(
        'nope',
        (v) => v == 'yes',
      ).validate('no');
      expect(outcome.code, 'custom');
      expect(outcome.message, 'nope');
    });
  });
}
