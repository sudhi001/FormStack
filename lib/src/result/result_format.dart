import 'dart:convert';

import 'package:formstack/formstack.dart';

/// Safely casts [x] to type [T], returning null if the cast fails.
T? cast<T>(dynamic x) => x is T ? x : null;

/// Validation format for form step results.
///
/// Provides 35+ built-in validators via factory constructors, plus
/// [ResultFormat.compose] for chaining multiple validators.
///
/// ```dart
/// // Built-in validators
/// ResultFormat.email("Invalid email")
/// ResultFormat.range("Must be 1-10", 1, 10)
/// ResultFormat.pattern("Letters only", r'^[a-zA-Z]+$')
///
/// // Compose multiple validators
/// ResultFormat.compose([
///   ResultFormat.minLength("Too short", 3),
///   ResultFormat.maxLength("Too long", 50),
/// ])
/// ```
abstract class ResultFormat {
  /// Internal constructor for built-in validators.
  ResultFormat._();

  /// Public constructor for creating custom [ResultFormat] subclasses.
  ///
  /// ```dart
  /// class MyValidator extends ResultFormat {
  ///   final String errorMsg;
  ///   MyValidator(this.errorMsg);
  ///
  ///   @override
  ///   bool isValid(dynamic input) => input != null && input.toString().length > 5;
  ///
  ///   @override
  ///   String error() => errorMsg;
  /// }
  /// ```
  const ResultFormat();

  /// Accepts anything. Use for steps that collect data but impose no rule.
  factory ResultFormat.none() = _NoneResultType;

  /// Requires a string of exactly [count] characters — PINs, fixed-width codes.
  factory ResultFormat.length(String errorMsg, int count) = _LengthResultType;

  /// Requires any non-null value. The weakest "answer this" rule.
  factory ResultFormat.notNull(String errorMsg) = _NotNullResultType;

  /// Requires a non-empty [String], [Iterable] or [Map].
  factory ResultFormat.notEmpty(String errorMsg) = _NotEmptyResultType;

  /// Requires a string with at least one non-whitespace character.
  factory ResultFormat.notBlank(String errorMsg) = _NotBlankResultType;

  /// Requires a syntactically valid email address.
  factory ResultFormat.email(String errorMsg) = _EmailResultType;

  /// Requires a satisfaction rating to have been chosen.
  factory ResultFormat.smile(String errorMsg) = _SmileResultType;

  /// Requires two or more characters, letters and spaces only.
  factory ResultFormat.name(String errorMsg) = _NameResultType;

  /// Requires 8+ characters with upper, lower, digit and symbol.
  factory ResultFormat.password(String errorMsg) = _PasswordResultType;

  /// Requires a non-empty string.
  factory ResultFormat.text(String errorMsg) = _TextResultType;

  /// Requires a string of digits.
  factory ResultFormat.number(String errorMsg) = _NumberResultType;

  /// Validates against the FormStack expression grammar. See [ExpressionLanguage].
  factory ResultFormat.expression(String expression) = _ExpressionResultType;

  /// Requires a [DateTime]. [format] is the pattern used when exporting it.
  factory ResultFormat.date(String errorMsg, String format) = DateResultType;

  /// Requires a [DateTime] within [minDate] and [maxDate], either of which may be null for an open bound.
  factory ResultFormat.dateRange(
    String errorMsg,
    String format, {
    DateTime? minDate,
    DateTime? maxDate,
  }) = _DateRangeResultType;

  /// Requires exactly one option to be selected.
  factory ResultFormat.singleChoice(String errorMsg) = _SingleChoiceResultType;

  /// Requires at least one option to be selected.
  factory ResultFormat.multipleChoice(String errorMsg) =
      _MultipleChoiceResultType;

  /// Requires a location to have been picked.
  factory ResultFormat.location(String errorMsg) = _GeoLocationResultType;

  /// Requires an E.164-shaped phone number, for example `+14155552671`.
  factory ResultFormat.phone(String errorMsg) = _PhoneResultType;

  /// Requires an `http` or `https` URL.
  factory ResultFormat.url(String errorMsg) = _URLResultType;

  /// Requires a 13-19 digit card number that passes the Luhn checksum.
  factory ResultFormat.creditCard(String errorMsg) = _CreditCardResultType;

  /// Requires a US Social Security Number, with or without dashes.
  factory ResultFormat.ssn(String errorMsg) = _SSNResultType;

  /// Requires a US ZIP code, five digits or ZIP+4.
  factory ResultFormat.zipCode(String errorMsg) = _ZipCodeResultType;

  /// Requires an integer between 0 and 150.
  factory ResultFormat.age(String errorMsg) = _AgeResultType;

  /// Requires a number between 0 and 100.
  factory ResultFormat.percentage(String errorMsg) = _PercentageResultType;

  /// Validates with your own predicate over the string form of the answer.
  factory ResultFormat.custom(
    String errorMsg,
    bool Function(String) validator,
  ) = _CustomResultType;

  /// Requires a number greater than or equal to [min].
  factory ResultFormat.min(String errorMsg, num min) = _MinResultType;

  /// Requires a number less than or equal to [max].
  factory ResultFormat.max(String errorMsg, num max) = _MaxResultType;

  /// Requires a number within [min] and [max], both inclusive.
  factory ResultFormat.range(String errorMsg, num min, num max) =
      _RangeResultType;

  /// Requires a string of at least [min] characters.
  factory ResultFormat.minLength(String errorMsg, int min) =
      _MinLengthResultType;

  /// Requires a string of at most [max] characters.
  factory ResultFormat.maxLength(String errorMsg, int max) =
      _MaxLengthResultType;

  /// Requires the answer to match [regex]. The pattern is compiled once.
  factory ResultFormat.pattern(String errorMsg, String regex) =
      _PatternResultType;

  /// Requires at least [min] options to be selected.
  factory ResultFormat.minSelections(String errorMsg, int min) =
      _MinSelectionsResultType;

  /// Requires at most [max] options to be selected.
  factory ResultFormat.maxSelections(String errorMsg, int max) =
      _MaxSelectionsResultType;

  /// Requires a picked file no larger than [maxBytes].
  factory ResultFormat.fileSize(String errorMsg, int maxBytes) =
      _FileSizeResultType;

  /// Requires an IBAN that passes the mod-97 checksum.
  factory ResultFormat.iban(String errorMsg) = _IBANResultType;

  /// Requires the consent checkbox to be ticked.
  factory ResultFormat.consent(String errorMsg) = _ConsentResultType;

  /// Applies [validators] in order and reports the first failure.
  factory ResultFormat.compose(List<ResultFormat> validators) =
      _CompositeResultType;

  /// Registers a named validator so `"type": "<name>"` can be used in JSON
  /// forms. See [ValidatorRegistry].
  static void register(String name, ResultFormatFactory factory) =>
      ValidatorRegistry.instance.register(name, factory);

  /// Builds a validator from its JSON description.
  ///
  /// Accepts either a single object or a list (which is composed):
  ///
  /// ```json
  /// {"type": "email", "message": "Please enter a valid email"}
  /// [{"type": "notEmpty", "message": "Required"},
  ///  {"type": "maxLength", "message": "Too long", "max": 50}]
  /// ```
  ///
  /// Returns `null` when [spec] is null. Throws [FormatException] for an
  /// unknown `type`.
  static ResultFormat? fromJson(Object? spec) =>
      ValidatorRegistry.instance.build(spec);

  /// Whether [input] satisfies this constraint.
  bool isValid(dynamic input);

  /// Human-readable message shown when [isValid] returns false.
  String error();

  /// Stable machine-readable identifier for this constraint.
  ///
  /// Used as [ValidationResult.code] and as the JSON `type` discriminator.
  /// Override it in custom subclasses to make failures identifiable without
  /// string-matching on [error]; the default is `"custom"`.
  String get code => 'custom';

  /// Constraint parameters surfaced on failure, for message interpolation.
  ///
  /// Override to expose bounds — e.g. `{'min': 3}` for a minimum-length rule.
  Map<String, Object?> get params => const {};

  /// Validates [input], returning the reason for failure alongside the verdict.
  ///
  /// Prefer this over [isValid] when the caller needs to localize the message
  /// or report the failure. The default implementation is expressed in terms of
  /// [isValid]/[error], so existing subclasses keep working unchanged.
  ValidationResult validate(dynamic input) => isValid(input)
      ? const ValidationResult.valid()
      : ValidationResult.invalid(code, error(), params: params);
}

/// Builds a [ResultFormat] from its JSON description.
///
/// `message` is the caller-supplied error text; `args` carries the remaining
/// keys of the JSON object (`min`, `max`, `regex`, …).
typedef ResultFormatFactory =
    ResultFormat Function(String message, Map<String, dynamic> args);

/// Validator requiring a [DateTime], carrying the [format] used to render it.
///
/// Public because [FormStackForm.addItem] inspects it to decide how a date
/// answer is serialized into the flat result map.
class DateResultType extends ResultFormat {
  @override
  String get code => 'date';

  @override
  Map<String, Object?> get params => {'format': format};

  /// Message shown when the answer is not a date.
  final String errorMsg;

  /// Pattern used to render the date on export.
  final String format;

  /// Creates a [DateResultType].
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

class _DateRangeResultType extends ResultFormat {
  @override
  String get code => 'dateRange';

  @override
  Map<String, Object?> get params => {
    'minDate': minDate?.toIso8601String(),
    'maxDate': maxDate?.toIso8601String(),
  };

  final String errorMsg;
  final String format;
  final DateTime? minDate;
  final DateTime? maxDate;
  _DateRangeResultType(this.errorMsg, this.format, {this.minDate, this.maxDate})
    : super._();

  @override
  bool isValid(dynamic input) {
    final date = cast<DateTime>(input);
    if (date == null) return false;
    if (minDate != null && date.isBefore(minDate!)) return false;
    if (maxDate != null && date.isAfter(maxDate!)) return false;
    return true;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _LengthResultType extends ResultFormat {
  @override
  String get code => 'length';

  @override
  Map<String, Object?> get params => {'length': count};

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
  @override
  String get code => 'notBlank';

  final String errorMsg;
  _NotBlankResultType(this.errorMsg) : super._();

  /// A value is blank when it is null, or a string of only whitespace.
  ///
  /// The trim was previously missing, so `"   "` passed a `notBlank` check.
  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && str.trim().isNotEmpty;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NotEmptyResultType extends ResultFormat {
  @override
  String get code => 'notEmpty';

  final String errorMsg;
  _NotEmptyResultType(this.errorMsg) : super._();

  /// Accepts any value that carries a length: a [String], an [Iterable] or a
  /// [Map]. Previously only [List] was recognised, so this validator could
  /// never pass on a text field — it silently rejected every string.
  @override
  bool isValid(dynamic input) {
    if (input == null) return false;
    if (input is String) return input.isNotEmpty;
    if (input is Iterable) return input.isNotEmpty;
    if (input is Map) return input.isNotEmpty;
    return true;
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _NotNullResultType extends ResultFormat {
  @override
  String get code => 'notNull';

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
  @override
  String get code => 'none';

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
  @override
  String get code => 'smile';

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
  @override
  String get code => 'email';

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
  @override
  String get code => 'text';

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
  @override
  String get code => 'password';

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
  @override
  String get code => 'name';

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
  @override
  String get code => 'number';

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
  @override
  String get code => 'location';

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
  @override
  String get code => 'singleChoice';

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
  @override
  String get code => 'multipleChoice';

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

// --- Pre-compiled patterns -------------------------------------------------
// RegExp construction compiles the pattern; validators run on every keystroke,
// so the patterns are compiled once at first use rather than per call.

final RegExp _emailPattern = RegExp(
  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
);
final RegExp _namePattern = RegExp(r'^[a-zA-Z\s]+$');
final RegExp _passwordPattern = RegExp(
  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
);
final RegExp _digitsPattern = RegExp(r'^[0-9]+$');
final RegExp _phonePattern = RegExp(r'^\+?[1-9]\d{1,14}$');
final RegExp _urlPattern = RegExp(
  r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
);
final RegExp _nonDigitPattern = RegExp(r'\D');
final RegExp _ssnPattern = RegExp(r'^\d{3}-?\d{2}-?\d{4}$');
final RegExp _zipPattern = RegExp(r'^\d{5}(-\d{4})?$');
final RegExp _whitespacePattern = RegExp(r'\s');
final RegExp _ibanPattern = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]+$');

/// String predicates backing the built-in validators.
///
/// These are exported so a custom [ResultFormat] can reuse the same rules the
/// library applies, rather than restating a regular expression.
extension EmailValidator on String {
  /// Whether this is a syntactically valid email address.
  bool isValidEmail() {
    return _emailPattern.hasMatch(this);
  }

  /// Whether this is two or more characters of letters and spaces.
  bool isValidName() {
    return _namePattern.hasMatch(this) && length >= 2;
  }

  /// Whether this has 8+ characters with upper, lower, digit and symbol.
  bool isValidPassword() {
    return _passwordPattern.hasMatch(this);
  }

  /// Whether this consists only of digits.
  bool isValidNumber() {
    return _digitsPattern.hasMatch(this);
  }

  /// Whether this is an E.164-shaped phone number.
  bool isValidPhoneNumber() {
    return _phonePattern.hasMatch(this);
  }

  /// Whether this is an `http` or `https` URL.
  bool isValidURL() {
    return _urlPattern.hasMatch(this);
  }

  /// Whether this is a 13-19 digit card number passing the Luhn checksum.
  bool isValidCreditCard() {
    // Luhn algorithm for credit card validation
    final String cleaned = replaceAll(_nonDigitPattern, '');
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

  /// Whether this is a US Social Security Number, with or without dashes.
  bool isValidSSN() {
    return _ssnPattern.hasMatch(this);
  }

  /// Whether this is a US ZIP code, five digits or ZIP+4.
  bool isValidZipCode() {
    return _zipPattern.hasMatch(this);
  }

  /// Whether this parses to an integer between 0 and 150.
  bool isValidAge() {
    final int? age = int.tryParse(this);
    return age != null && age >= 0 && age <= 150;
  }

  /// Whether this parses to a number between 0 and 100.
  bool isValidPercentage() {
    final double? percentage = double.tryParse(this);
    return percentage != null && percentage >= 0 && percentage <= 100;
  }
}

// Additional validation result types
class _PhoneResultType extends ResultFormat {
  @override
  String get code => 'phone';

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
  @override
  String get code => 'url';

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
  @override
  String get code => 'creditCard';

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
  @override
  String get code => 'ssn';

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
  @override
  String get code => 'zipCode';

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
  @override
  String get code => 'age';

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
  @override
  String get code => 'percentage';

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
  @override
  String get code => 'custom';

  final String errorMsg;
  final bool Function(String) validator;
  _CustomResultType(this.errorMsg, this.validator) : super._();

  @override
  bool isValid(dynamic input) {
    final String? inputString = cast<String>(input);
    return inputString != null && validator(inputString);
  }

  @override
  String error() {
    return errorMsg;
  }
}

class _ExpressionResultType extends ResultFormat {
  @override
  String get code => 'expression';

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

/// Evaluates an [ExpressionLanguage] document against collected results.
///
/// Used by `ResultFormat.expression` for cross-field rules such as
/// "at least one of these fields must be answered".
class ExpressionValidator {
  /// Message describing the most recent failure, empty when the last run passed.
  String error = "";

  /// Whether [input] satisfies [expression], a JSON-encoded [ExpressionLanguage].
  bool validate(Map<String, dynamic> input, String expression) {
    final ExpressionLanguage expressionLanguage = ExpressionLanguage.fromJson(
      json.decode(expression) as Map<String, dynamic>,
    );
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

/// One clause of an [ExpressionLanguage] document: a step [id] and the
/// [expression] its answer must satisfy.
class ExpressionObject {
  /// Identifier of the step whose answer this clause tests.
  String? id;

  /// The condition applied to that answer.
  String? expression;

  /// Creates an [ExpressionObject].
  ExpressionObject({this.id, this.expression});

  /// Creates an [ExpressionObject] from its JSON form.
  ExpressionObject.fromJson(Map<String, dynamic> json) {
    id = json["id"]?.toString();
    expression = json["expression"]?.toString();
  }

  /// Converts to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['expression'] = expression;
    return data;
  }
}

/// A cross-field validation document.
///
/// Holds a set of clauses joined by OR: the document passes when any clause
/// does, and [orValidationMessage] is reported when none do.
class ExpressionLanguage {
  /// Clauses joined by OR; the document passes when any of them does.
  List<ExpressionObject> or = [];

  /// Message reported when no clause passes.
  String? orValidationMessage;

  /// Creates an [ExpressionLanguage].
  ExpressionLanguage({required this.or});

  /// Creates an [ExpressionLanguage] from its JSON form.
  ExpressionLanguage.fromJson(Map<String, dynamic> json) {
    final clauses = json['or'];
    if (clauses is List) {
      or = [
        for (final v in clauses)
          ExpressionObject.fromJson(Map<String, dynamic>.from(v as Map)),
      ];
    }
    orValidationMessage = json["orValidationMessage"]?.toString();
  }

  /// Converts to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['or'] = or.map((v) => v.toJson()).toList();
    data['orValidationMessage'] = orValidationMessage;
    return data;
  }
}

// --- New validators ---

class _MinResultType extends ResultFormat {
  @override
  String get code => 'min';

  @override
  Map<String, Object?> get params => {'min': min};

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
  @override
  String get code => 'max';

  @override
  Map<String, Object?> get params => {'max': max};

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
  @override
  String get code => 'range';

  @override
  Map<String, Object?> get params => {'min': min, 'max': max};

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
  @override
  String get code => 'minLength';

  @override
  Map<String, Object?> get params => {'min': min};

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
  @override
  String get code => 'maxLength';

  @override
  Map<String, Object?> get params => {'max': max};

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
  @override
  String get code => 'pattern';

  @override
  Map<String, Object?> get params => {'regex': regex};

  late final RegExp _compiled = RegExp(regex);

  final String errorMsg;
  final String regex;
  _PatternResultType(this.errorMsg, this.regex) : super._();

  @override
  bool isValid(dynamic input) {
    final str = cast<String>(input);
    return str != null && _compiled.hasMatch(str);
  }

  @override
  String error() => errorMsg;
}

class _MinSelectionsResultType extends ResultFormat {
  @override
  String get code => 'minSelections';

  @override
  Map<String, Object?> get params => {'min': min};

  final String errorMsg;
  final int min;
  _MinSelectionsResultType(this.errorMsg, this.min) : super._();

  @override
  bool isValid(dynamic input) {
    final list = cast<List<dynamic>>(input);
    return list != null && list.length >= min;
  }

  @override
  String error() => errorMsg;
}

class _MaxSelectionsResultType extends ResultFormat {
  @override
  String get code => 'maxSelections';

  @override
  Map<String, Object?> get params => {'max': max};

  final String errorMsg;
  final int max;
  _MaxSelectionsResultType(this.errorMsg, this.max) : super._();

  @override
  bool isValid(dynamic input) {
    final list = cast<List<dynamic>>(input);
    return list != null && list.length <= max;
  }

  @override
  String error() => errorMsg;
}

class _FileSizeResultType extends ResultFormat {
  @override
  String get code => 'fileSize';

  @override
  Map<String, Object?> get params => {'maxBytes': maxBytes};

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
  @override
  String get code => 'iban';

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
  @override
  String get code => 'consent';

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
  @override
  String get code => 'compose';

  final List<ResultFormat> validators;

  /// Failure of the most recent [isValid] call, or null when it passed.
  ///
  /// Kept only so the legacy [error] contract (a no-argument getter) still
  /// works; [validate] is stateless and should be preferred.
  ValidationResult? _last;

  _CompositeResultType(this.validators) : super._();

  @override
  bool isValid(dynamic input) => validate(input).isValid;

  @override
  ValidationResult validate(dynamic input) {
    for (final v in validators) {
      final outcome = v.validate(input);
      if (!outcome.isValid) {
        _last = outcome;
        return ValidationResult.invalid(
          outcome.code,
          outcome.message,
          params: outcome.params,
          children: [outcome],
        );
      }
    }
    _last = null;
    return const ValidationResult.valid();
  }

  @override
  String error() => _last?.message ?? '';
}

num? _toNum(dynamic input) {
  if (input is num) return input;
  if (input is String) return num.tryParse(input);
  return null;
}

/// IBAN checksum validation, separated so it can be reused independently.
extension IBANValidator on String {
  /// Whether this is an IBAN passing the mod-97 checksum.
  bool isValidIBAN() {
    final cleaned = replaceAll(_whitespacePattern, '').toUpperCase();
    if (cleaned.length < 15 || cleaned.length > 34) return false;
    if (!_ibanPattern.hasMatch(cleaned)) {
      return false;
    }
    // Move first 4 chars to end and convert letters to numbers
    final rearranged = cleaned.substring(4) + cleaned.substring(0, 4);
    final numericString = rearranged.split('').map((c) {
      final code = c.codeUnitAt(0);
      return code >= 65 && code <= 90 ? '${code - 55}' : c;
    }).join();
    // Mod 97 check
    final BigInt value = BigInt.parse(numericString);
    return value % BigInt.from(97) == BigInt.one;
  }
}
