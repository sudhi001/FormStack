import 'package:intl/intl.dart';

///This grammar allows us to define date conditions with a comparison
///operator (e.g., <, >, <=, >=, =, or !=) and two date expressions,
/// which can be either date values (e.g., 2023-04-13) or date functions
///  (e.g., YEAR(2023-04-13)). The YEAR, MONTH, and DAY functions return
///  the corresponding value of the given date expression.
///
class DateTimeExpressionEvaluator {
  DateTimeExpressionEvaluator._();
  static bool evaluateCondition(String condition, DateTime date) {
    var parts = condition.split(' ');
    var left = parts.isNotEmpty ? parseExpression(parts[0], date) : null;
    var right = parts.length > 1 ? parseExpression(parts[2], date) : null;
    var operator = parts.length > 1 ? parts[1] : parts[0];

    switch (operator) {
      case '<':
        return left!.isBefore(right!);
      case '>':
        return left!.isAfter(right!);
      case '<=':
        return !left!.isAfter(right!);
      case '>=':
        return !left!.isBefore(right!);
      case '=':
        return left!.isAtSameMomentAs(right!);
      case '!=':
        return !left!.isAtSameMomentAs(right!);
      case 'FOR_ALL':
        return true;
      default:
        throw ArgumentError('Invalid operator: $operator');
    }
  }

  static DateTime? parseExpression(String expression, DateTime date) {
    String format = "dd-MM-yyyy";
    var parts = expression.split('(');
    var functionName = parts[0];
    if (functionName == "FOR_ALL") {
      return null;
    }
    var argument = parts[1].substring(0, parts[1].length - 1);

    switch (functionName) {
      case 'YEAR':
        return DateFormat(format).parse(argument).add(
            Duration(days: date.difference(DateTime(date.year, 1, 1)).inDays));
      case 'MONTH':
        return DateFormat(format).parse(argument).add(Duration(
            days: date.difference(DateTime(date.year, date.month, 1)).inDays));
      case 'DAY':
        return DateFormat(format).parse(argument);
      default:
        return DateFormat(format).parse(expression);
    }
  }
}
