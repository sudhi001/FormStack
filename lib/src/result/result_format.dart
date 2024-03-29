import 'dart:convert';

import 'package:formstack/formstack.dart';

T? cast<T>(x) => x is T ? x : null;

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
  factory ResultFormat.text(String errorMsg) = _TextesultType;
  factory ResultFormat.number(String errorMsg) = _NumberResultType;
  factory ResultFormat.expression(String expression) = _ExpressionResultType;
  factory ResultFormat.date(String errorMsg, String format) = DateResultType;
  factory ResultFormat.singleChoice(String errorMsg) = _SingleChoiceResultType;
  factory ResultFormat.multipleChoice(String errorMsg) =
      _MultipleChoiceesultType;
  factory ResultFormat.location(String errorMsg) = _GeoLocationResultType;
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
    return input != null && cast<int>(input)!.toString().length == count;
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
    return input != null && cast<String>(input)!.isNotEmpty;
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
    return input != null && cast<List>(input)!.isNotEmpty;
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
    return cast<String>(input)!.isValidEmail();
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _TextesultType extends ResultFormat {
  final String errorMsg;
  _TextesultType(this.errorMsg) : super._();

  @override
  bool isValid(dynamic input) {
    return cast<String>(input)!.isNotEmpty;
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
    return cast<String>(input)!.isValidPassword();
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
    return cast<String>(input)!.isValidName();
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
    return cast<String>(input)!.isValidNumber();
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
    return cast<List<String>>(input)!.isNotEmpty;
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
    return cast<List<Options>>(input)!.isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _MultipleChoiceesultType extends ResultFormat {
  final String errorMsg;
  _MultipleChoiceesultType(this.errorMsg) : super._();
  @override
  bool isValid(dynamic input) {
    return cast<List<Options>>(input)!.isNotEmpty;
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
    return RegExp("[a-zA-Z]").hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(this);
  }

  bool isValidNumber() {
    return RegExp("[0-9]").hasMatch(this);
  }
}

class _ExpressionResultType extends ResultFormat {
  final String expression;
  final ExpressionValidator expressionValidator = ExpressionValidator();
  _ExpressionResultType(this.expression) : super._();

  @override
  bool isValid(dynamic input) {
    return expressionValidator.validate(
        cast<Map<String, dynamic>>(input)!, expression);
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
            if (input[element.id] != null &&
                cast<String>(input[element.id])!.isNotEmpty) {
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
