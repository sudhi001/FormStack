import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

/// Conditional navigation routes on these, so a wrong answer here sends the
/// user down the wrong branch silently. Every case below was verified against
/// the behaviour before the fix.
bool evaluate(dynamic result, String expression) => ExpressionRelevant(
  identifier: GenericIdentifier(id: 'target'),
  expression: expression,
).isValid(result);

void main() {
  group('numeric answers', () {
    // Previously the operand was compared as a String against an int, so `= 5`
    // was always false and `!= 5` always true: no numeric condition matched.
    test('equality compares numerically', () {
      expect(evaluate(5, '= 5'), isTrue);
      expect(evaluate(5, '= 6'), isFalse);
      expect(evaluate(5, '!= 5'), isFalse);
      expect(evaluate(5, '!= 6'), isTrue);
    });

    test('ordering operators work', () {
      expect(evaluate(5, '< 10'), isTrue);
      expect(evaluate(5, '> 10'), isFalse);
      expect(evaluate(5, '<= 5'), isTrue);
      expect(evaluate(5, '>= 6'), isFalse);
    });

    test('doubles are compared numerically, not matched blindly', () {
      // `is int` sent doubles to the catch-all evaluator, which returned true
      // for everything -- a slider could not be branched on.
      expect(evaluate(1.5, '= 1.5'), isTrue);
      expect(evaluate(1.5, '= 2.5'), isFalse);
      expect(evaluate(2.5, '> 1.5'), isTrue);
    });

    test('a non-numeric operand is reported', () {
      expect(() => evaluate(5, '= five'), throwsArgumentError);
    });
  });

  group('boolean and other answers', () {
    // The catch-all evaluator returned true unconditionally, so a boolean
    // question always took its first branch.
    test('booleans compare by value', () {
      expect(evaluate(true, '= true'), isTrue);
      expect(evaluate(true, '= false'), isFalse);
      expect(evaluate(false, '= false'), isTrue);
      expect(evaluate(false, '!= true'), isTrue);
    });

    test('a null answer does not match a value', () {
      expect(evaluate(null, '= yes'), isFalse);
      expect(evaluate(null, '!= yes'), isTrue);
    });

    test('FOR_ALL still converges every path', () {
      expect(evaluate(true, 'FOR_ALL'), isTrue);
      expect(evaluate(null, 'FOR_ALL'), isTrue);
      expect(evaluate(7, 'FOR_ALL'), isTrue);
      expect(evaluate('anything', 'FOR_ALL'), isTrue);
    });
  });

  group('text answers', () {
    test('equality holds for values containing spaces', () {
      // The condition was split on every space, so the operand was truncated
      // to its first word and `= New York` never matched.
      expect(evaluate('New York', '= New York'), isTrue);
      expect(evaluate('New', '= New York'), isFalse);
    });

    test('IN is a substring test', () {
      expect(evaluate('developer', 'IN dev'), isTrue);
      expect(evaluate('designer', 'IN dev'), isFalse);
    });

    test('NOT_IN is the negation of IN', () {
      expect(evaluate('designer', 'NOT_IN dev'), isTrue);
      expect(evaluate('developer', 'NOT_IN dev'), isFalse);
    });
  });

  group('multi-selection answers', () {
    test('IN requires every listed value to be selected', () {
      expect(evaluate(['a', 'b'], 'IN a'), isTrue);
      expect(evaluate(['a', 'b'], 'IN a,b'), isTrue);
      expect(evaluate(['a'], 'IN a,b'), isFalse);
    });

    test('NOT_IN means none of them are selected', () {
      // Was `!every(contains)` -- "not all of them" -- so a selection holding
      // one of two listed values still satisfied NOT_IN.
      expect(evaluate(['a'], 'NOT_IN a,b'), isFalse);
      expect(evaluate(['a', 'b'], 'NOT_IN a,b'), isFalse);
      expect(evaluate(['c'], 'NOT_IN a,b'), isTrue);
      expect(evaluate(<String>[], 'NOT_IN a,b'), isTrue);
    });

    test('Options are matched by key, for IN and NOT_IN alike', () {
      final selection = [Options('a', 'Option A')];
      expect(evaluate(selection, 'IN a'), isTrue);
      expect(evaluate(selection, 'IN b'), isFalse);
      // NOT_IN compared Options objects against strings, so it matched
      // whatever was selected.
      expect(evaluate(selection, 'NOT_IN a'), isFalse);
      expect(evaluate(selection, 'NOT_IN b'), isTrue);
    });

    test('spaces around commas are tolerated', () {
      expect(evaluate(['a', 'b'], 'IN a, b'), isTrue);
    });
  });

  group('date answers', () {
    final answer = DateTime(2024, 6, 15);

    test('comparing the answer against a date works', () {
      // This two-term shape parsed the operator as a date expression and threw
      // a RangeError before comparing anything.
      expect(evaluate(answer, '< DAY(01-01-2025)'), isTrue);
      expect(evaluate(answer, '> DAY(01-01-2025)'), isFalse);
      expect(evaluate(answer, '>= DAY(15-06-2024)'), isTrue);
    });

    test('a bare date needs no function wrapper', () {
      expect(evaluate(answer, '< 01-01-2025'), isTrue);
      expect(evaluate(answer, '> 01-01-2025'), isFalse);
    });

    test('FOR_ALL matches', () {
      expect(evaluate(answer, 'FOR_ALL'), isTrue);
    });

    test('an unparseable condition is reported', () {
      expect(() => evaluate(answer, '<'), throwsArgumentError);
    });
  });

  group('unknown operators are rejected', () {
    test('across every answer type', () {
      expect(() => evaluate('text', 'LIKE x'), throwsArgumentError);
      expect(() => evaluate(1, 'LIKE x'), throwsArgumentError);
      expect(() => evaluate(['a'], 'LIKE x'), throwsArgumentError);
      expect(() => evaluate(true, 'LIKE x'), throwsArgumentError);
    });
  });
}
