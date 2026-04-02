import 'dart:convert';

import 'package:formstack/formstack.dart';

T? cast<T>(dynamic x) => x is T ? x : null;

abstract class ResultFormat {
  ResultFormat._();
  factory ResultFormat.none() = _NoneResultType;
  factory ResultFormat.length(String errorMsg, int count) = _LengthResultType;
  factory ResultFormat.notNull(String errorMsg) = _NotNullResultType;
  factory ResultFormat.notEmpty(String errorMsg) = _NotEmptyResultType;
  factory ResultFormat.notBlank(String errorMsg) = _NotBlankResultType;
  factory ResultFormat.email(String errorMsg) = _EmailResultType;
  factory ResultFormat.smile(String errorMsg) = _SmileResultType;
  factory ResultFormat.name(String errorMsg) = _NameResultType;
  factory ResultFormat.password(String errorMsg) = _PasswordResultType;
  factory ResultFormat.text(String errorMsg) = _TextResultType;
  factory ResultFormat.number(String errorMsg) = _NumberResultType;
  factory ResultFormat.expression(String expression) = _ExpressionResultType;
  factory ResultFormat.date(String errorMsg, String format) = DateResultType;
  factory ResultFormat.singleChoice(String errorMsg) = _SingleChoiceResultType;
  factory ResultFormat.multipleChoice(String errorMsg) =
      _MultipleChoiceResultType;
  factory ResultFormat.location(String errorMsg) = _GeoLocationResultType;
  factory ResultFormat.phone(String errorMsg) = _PhoneResultType;
  factory ResultFormat.url(String errorMsg) = _URLResultType;
  factory ResultFormat.creditCard(String errorMsg) = _CreditCardResultType;
  factory ResultFormat.ssn(String errorMsg) = _SSNResultType;
  factory ResultFormat.zipCode(String errorMsg) = _ZipCodeResultType;
  factory ResultFormat.age(String errorMsg) = _AgeResultType;
  factory ResultFormat.percentage(String errorMsg) = _PercentageResultType;
  factory ResultFormat.custom(
      String errorMsg, bool Function(String) validator) = _CustomResultType;
  factory ResultFormat.min(String errorMsg, num min) = _MinResultType;
  factory ResultFormat.max(String errorMsg, num max) = _MaxResultType;
  factory ResultFormat.range(String errorMsg, num min, num max) =
      _RangeResultType;
  factory ResultFormat.minLength(String errorMsg, int min) =
      _MinLengthResultType;
  factory ResultFormat.maxLength(String errorMsg, int max) =
      _MaxLengthResultType;
  factory ResultFormat.pattern(String errorMsg, String regex) =
      _PatternResultType;
  factory ResultFormat.minSelections(String errorMsg, int min) =
      _MinSelectionsResultType;
  factory ResultFormat.maxSelections(String errorMsg, int max) =
      _MaxSelectionsResultType;
  factory ResultFormat.fileSize(String errorMsg, int maxBytes) =
      _FileSizeResultType;
  factory ResultFormat.iban(String errorMsg) = _IBANResultType;
  factory ResultFormat.consent(String errorMsg) = _ConsentResultType;
  factory ResultFormat.compose(List<ResultFormat> validators) =
      _CompositeResultType;
  bool isValid(dynamic input);
  String error();
}

class DateResultType extends ResultFormat {
  final String errorMsg;
  final String format;
  DateResultType(this.errorMsg, this.format) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<DateTime>(input) != null;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _LengthResultType extends ResultFormat {
  final String errorMsg;
  final int count;
  _LengthResultType(this.errorMsg, this.count) : super._();

  @override
  bool isValid(dynamic input) {
    final intValue = cast<int>(input);
    return intValue != null && intValue.toString().length == count;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NotBlankResultType extends ResultFormat {
  final String errorMsg;
  _NotBlankResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NotEmptyResultType extends ResultFormat {
  final String errorMsg;
  _NotEmptyResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final list = cast<List>(input);
    return list != null && list.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NotNullResultType extends ResultFormat {
  final String errorMsg;
  _NotNullResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return input != null;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NoneResultType extends ResultFormat {
  _NoneResultType() : super._();

  @override
  bool isValid(dynamic input) {
    return true;
  }

  @override
  String error() {
    return "";
  }
}

class _SmileResultType extends ResultFormat {
  final String errorMsg;
  _SmileResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<int>(input) != null;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _EmailResultType extends ResultFormat {
  final String errorMsg;
  _EmailResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.isValidEmail();
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _TextResultType extends ResultFormat {
  final String errorMsg;
  _TextResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _PasswordResultType extends ResultFormat {
  final String errorMsg;
  _PasswordResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.isValidPassword();
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NameResultType extends ResultFormat {
  final String errorMsg;
  _NameResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.isValidName();
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NumberResultType extends ResultFormat {
  final String errorMsg;
  _NumberResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.isValidNumber();
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _GeoLocationResultType extends ResultFormat {
  final String errorMsg;
  _GeoLocationResultType(this.errorMsg) : super._();
  @override
  bool isValid(dynamic input) {
    final list = cast<List<String>>(input);
    return list != null && list.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _SingleChoiceResultType extends ResultFormat {
  final String errorMsg;
  _SingleChoiceResultType(this.errorMsg) : super._();
  @override
  bool isValid(dynamic input) {
    final list = cast<List<Options>>(input);
    return list != null && list.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _MultipleChoiceResultType extends ResultFormat {
  final String errorMsg;
  _MultipleChoiceResultType(this.errorMsg) : super._();
  @override
  bool isValid(dynamic input) {
    final list = cast<List<Options>>(input);
    return list != null && list.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool isValidName() {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(this) && length >= 2;
  }

  bool isValidPassword() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(this);
  }

  bool isValidNumber() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  bool isValidPhoneNumber() {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(this);
  }

  bool isValidURL() {
    return RegExp(
            r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$')
        .hasMatch(this);
  }

  bool isValidCreditCard() {
    // Luhn algorithm for credit card validation
    String cleaned = replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit = (digit % 10) + 1;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  bool isValidSSN() {
    return RegExp(r'^\d{3}-?\d{2}-?\d{4}$').hasMatch(this);
  }

  bool isValidZipCode() {
    return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(this);
  }

  bool isValidAge() {
    int? age = int.tryParse(this);
    return age != null && age >= 0 && age <= 150;
  }

  bool isValidPercentage() {
    double? percentage = double.tryParse(this);
    return percentage != null && percentage >= 0 && percentage <= 100;
  }
}

// Additional validation result types
class _PhoneResultType extends ResultFormat {
  final String errorMsg;
  _PhoneResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidPhoneNumber() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _URLResultType extends ResultFormat {
  final String errorMsg;
  _URLResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidURL() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _CreditCardResultType extends ResultFormat {
  final String errorMsg;
  _CreditCardResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidCreditCard() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _SSNResultType extends ResultFormat {
  final String errorMsg;
  _SSNResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidSSN() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _ZipCodeResultType extends ResultFormat {
  final String errorMsg;
  _ZipCodeResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidZipCode() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _AgeResultType extends ResultFormat {
  final String errorMsg;
  _AgeResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidAge() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _PercentageResultType extends ResultFormat {
  final String errorMsg;
  _PercentageResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidPercentage() ?? false;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _CustomResultType extends ResultFormat {
  final String errorMsg;
  final bool Function(String) validator;
  _CustomResultType(this.errorMsg, this.validator) : super._();

  @override
  bool isValid(dynamic input) {
    String? inputString = cast<String>(input);
    return inputString != null && validator(inputString);
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _ExpressionResultType extends ResultFormat {
  final String expression;
  final ExpressionValidator expressionValidator = ExpressionValidator();
  _ExpressionResultType(this.expression) : super._();

  @override
  bool isValid(dynamic input) {
    final map = cast<Map<String, dynamic>>(input);
    if (map == null) return false;
    return expressionValidator.validate(map, expression);
  }

  @override
  String error() {
    return expressionValidator.error;
  }
}

class ExpressionValidator {
  String error = "";

  bool validate(Map<String, dynamic> input, String expression) {
    ExpressionLanguage expressionLanguage =
        ExpressionLanguage.fromJson(json.decode(expression));
    bool isOrValid = false;
    if (expressionLanguage.or.isNotEmpty) {
      for (var element in expressionLanguage.or) {
        if (input.containsKey(element.id)) {
          if (element.expression == "IS_NOT_EMPTY") {
            final value = cast<String>(input[element.id]);
            if (value != null && value.isNotEmpty) {
              isOrValid = true;
              break;
            }
          }
        }
      }
    }
    if (!isOrValid) {
      error = expressionLanguage.orValidationMessage ?? "";
    }
    return isOrValid;
  }
}

class ExpressionObject {
  String? id;
  String? expression;

  ExpressionObject({this.id, this.expression});

  ExpressionObject.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    expression = json["expression"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['expression'] = expression;
    return data;
  }
}

class ExpressionLanguage {
  List<ExpressionObject> or = [];
  String? orValidationMessage;

  ExpressionLanguage({required this.or});

  ExpressionLanguage.fromJson(Map<String, dynamic> json) {
    if (json['or'] != null) {
      or = [];
      json['or'].forEach((v) {
        or.add(ExpressionObject.fromJson(v));
      });
    }
    orValidationMessage = json["orValidationMessage"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['or'] = or.map((v) => v.toJson()).toList();
    data['orValidationMessage'] = orValidationMessage;
    return data;
  }
}

// --- New validators ---

class _MinResultType extends ResultFormat {
  final String errorMsg;
  final num min;
  _MinResultType(this.errorMsg, this.min) : super._();

  @override
  bool isValid(dynamic input) {
    final value = _toNum(input);
    return value != null && value >= min;
  }

  @override
  String error() => errorMsg;
}

class _MaxResultType extends ResultFormat {
  final String errorMsg;
  final num max;
  _MaxResultType(this.errorMsg, this.max) : super._();

  @override
  bool isValid(dynamic input) {
    final value = _toNum(input);
    return value != null && value <= max;
  }

  @override
  String error() => errorMsg;
}

class _RangeResultType extends ResultFormat {
  final String errorMsg;
  final num min;
  final num max;
  _RangeResultType(this.errorMsg, this.min, this.max) : super._();

  @override
  bool isValid(dynamic input) {
    final value = _toNum(input);
    return value != null && value >= min && value <= max;
  }

  @override
  String error() => errorMsg;
}

class _MinLengthResultType extends ResultFormat {
  final String errorMsg;
  final int min;
  _MinLengthResultType(this.errorMsg, this.min) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.length >= min;
  }

  @override
  String error() => errorMsg;
}

class _MaxLengthResultType extends ResultFormat {
  final String errorMsg;
  final int max;
  _MaxLengthResultType(this.errorMsg, this.max) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.length <= max;
  }

  @override
  String error() => errorMsg;
}

class _PatternResultType extends ResultFormat {
  final String errorMsg;
  final String regex;
  _PatternResultType(this.errorMsg, this.regex) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && RegExp(regex).hasMatch(str);
  }

  @override
  String error() => errorMsg;
}

class _MinSelectionsResultType extends ResultFormat {
  final String errorMsg;
  final int min;
  _MinSelectionsResultType(this.errorMsg, this.min) : super._();

  @override
  bool isValid(dynamic input) {
    final list = cast<List>(input);
    return list != null && list.length >= min;
  }

  @override
  String error() => errorMsg;
}

class _MaxSelectionsResultType extends ResultFormat {
  final String errorMsg;
  final int max;
  _MaxSelectionsResultType(this.errorMsg, this.max) : super._();

  @override
  bool isValid(dynamic input) {
    final list = cast<List>(input);
    return list != null && list.length <= max;
  }

  @override
  String error() => errorMsg;
}

class _FileSizeResultType extends ResultFormat {
  final String errorMsg;
  final int maxBytes;
  _FileSizeResultType(this.errorMsg, this.maxBytes) : super._();

  @override
  bool isValid(dynamic input) {
    if (input == null) return false;
    if (input is List<int>) return input.length <= maxBytes;
    return true;
  }

  @override
  String error() => errorMsg;
}

class _IBANResultType extends ResultFormat {
  final String errorMsg;
  _IBANResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)?.isValidIBAN() ?? false;
  }

  @override
  String error() => errorMsg;
}

class _ConsentResultType extends ResultFormat {
  final String errorMsg;
  _ConsentResultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return input == true;
  }

  @override
  String error() => errorMsg;
}

class _CompositeResultType extends ResultFormat {
  final List<ResultFormat> validators;
  String _lastError = "";
  _CompositeResultType(this.validators) : super._();

  @override
  bool isValid(dynamic input) {
    for (final v in validators) {
      if (!v.isValid(input)) {
        _lastError = v.error();
        return false;
      }
    }
    return true;
  }

  @override
  String error() => _lastError;
}

num? _toNum(dynamic input) {
  if (input is num) return input;
  if (input is String) return num.tryParse(input);
  return null;
}

extension IBANValidator on String {
  bool isValidIBAN() {
    final cleaned = replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (cleaned.length < 15 || cleaned.length > 34) return false;
    if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]+$').hasMatch(cleaned)) {
      return false;
    }
    // Move first 4 chars to end and convert letters to numbers
    final rearranged = cleaned.substring(4) + cleaned.substring(0, 4);
    final numericString = rearranged.split('').map((c) {
      final code = c.codeUnitAt(0);
      return code >= 65 && code <= 90 ? '${code - 55}' : c;
    }).join();
    // Mod 97 check
    BigInt value = BigInt.parse(numericString);
    return value % BigInt.from(97) == BigInt.one;
  }
}
