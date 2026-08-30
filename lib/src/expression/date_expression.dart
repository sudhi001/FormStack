import 'package:formstack/src/expression/base_expression.dart';
import 'package:intl/intl.dart';

///This grammar allows us to define date conditions with a comparison
///operator (e.g., <, >, <=, >=, =, or !=) and two date expressions,
/// which can be either date values (e.g., 2023-04-13) or date functions
///  (e.g., YEAR(2023-04-13)). The YEAR, MONTH, and DAY functions return
///  the corresponding value of the given date expression.
///
class DateTimeExpressionEvaluator extends ExpressionEvaluator<DateTime> {
  DateTimeExpressionEvaluator(super.input);

  @override
  bool isValid(String condition, DateTime input) {
    final parts = condition.trim().split(RegExp(r'\s+'));
    if (parts.first == 'FOR_ALL') return true;

    // Two shapes are supported:
    //   "< DAY(01-01-2024)"                   compares the answer itself
    //   "DAY(01-01-2024) < DAY(02-01-2024)"   compares two expressions
    // The first used to be parsed as though `<` were a date expression, which
    // threw a RangeError before any comparison happened.
    final String operator;
    final DateTime? left;
    final DateTime? right;
    if (parts.length == 2) {
      operator = parts[0];
      left = input;
      right = parseExpression(parts[1], input);
    } else if (parts.length >= 3) {
      operator = parts[1];
      left = parseExpression(parts[0], input);
      right = parseExpression(parts[2], input);
    } else {
      throw ArgumentError('Invalid date condition: "$condition"');
    }

    if (left == null || right == null) {
      throw ArgumentError(
        'Date condition "$condition" has an operand that is not a date.',
      );
    }

    switch (operator) {
      case '<':
        return left.isBefore(right);
      case '>':
        return left.isAfter(right);
      case '<=':
        return !left.isAfter(right);
      case '>=':
        return !left.isBefore(right);
      case '=':
        return left.isAtSameMomentAs(right);
      case '!=':
        return !left.isAtSameMomentAs(right);
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }

  /// Parses one side of a date condition.
  ///
  /// Accepts a bare date in `dd-MM-yyyy`, or a `YEAR(...)`, `MONTH(...)` or
  /// `DAY(...)` call around one.
  static DateTime? parseExpression(String expression, DateTime date) {
    const String format = "dd-MM-yyyy";
    final parts = expression.split('(');
    final functionName = parts[0];
    if (functionName == "FOR_ALL") {
      return null;
    }
    // A bare date has no parenthesis; reaching for parts[1] threw.
    if (parts.length < 2) {
      return DateFormat(format).parse(expression);
    }
    final argument = parts[1].substring(0, parts[1].length - 1);

    switch (functionName) {
      case 'YEAR':
        return DateFormat(format)
            .parse(argument)
            .add(
              Duration(days: date.difference(DateTime(date.year, 1, 1)).inDays),
            );
      case 'MONTH':
        return DateFormat(format)
            .parse(argument)
            .add(
              Duration(
                days: date
                    .difference(DateTime(date.year, date.month, 1))
                    .inDays,
              ),
            );
      case 'DAY':
        return DateFormat(format).parse(argument);
      default:
        return DateFormat(format).parse(expression);
    }
  }
}
