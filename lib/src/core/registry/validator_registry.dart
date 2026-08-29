import 'package:formstack/formstack.dart';

/// Resolves validators by name so forms defined in JSON can use the full
/// [ResultFormat] library — and so applications can contribute their own.
///
/// Before this registry, a JSON-defined form could only get the default
/// validator implied by its `inputType`; every rule beyond that required
/// dropping down to Dart. A JSON step can now declare:
///
/// ```json
/// {
///   "type": "QuestionStep",
///   "id": "age",
///   "inputType": "number",
///   "validators": [
///     {"type": "notEmpty", "message": "Age is required"},
///     {"type": "range", "message": "Must be 18-120", "min": 18, "max": 120}
///   ]
/// }
/// ```
///
/// Register a domain-specific rule once at start-up and it becomes available
/// to every JSON form:
///
/// ```dart
/// ResultFormat.register('nhsNumber', (message, args) => NhsNumberFormat(message));
/// ```
class ValidatorRegistry {
  ValidatorRegistry._() {
    _registerBuiltIns();
  }

  /// The process-wide registry consulted by [ResultFormat.fromJson].
  static final ValidatorRegistry instance = ValidatorRegistry._();

  final Map<String, ResultFormatFactory> _factories = {};

  /// Names currently resolvable, sorted alphabetically.
  List<String> get registered => _factories.keys.toList()..sort();

  /// Whether [name] resolves to a validator.
  bool contains(String name) => _factories.containsKey(name);

  /// Registers [factory] under [name], replacing any previous entry.
  ///
  /// Registering an existing built-in name overrides it, which is the
  /// supported way to swap in a stricter implementation (for example a
  /// country-specific phone rule).
  void register(String name, ResultFormatFactory factory) {
    _factories[name] = factory;
  }

  /// Removes a registration. Returns whether anything was removed.
  bool unregister(String name) => _factories.remove(name) != null;

  /// Restores the registry to built-ins only. Intended for tests.
  void reset() {
    _factories.clear();
    _registerBuiltIns();
  }

  /// Builds a validator from a JSON object, or a list of them (composed).
  ///
  /// Returns `null` for a null [spec]. Throws [FormatException] when the
  /// shape is wrong or the `type` is not registered.
  ResultFormat? build(Object? spec) {
    if (spec == null) return null;
    if (spec is ResultFormat) return spec;
    if (spec is List) {
      final parts = spec
          .map(build)
          .whereType<ResultFormat>()
          .toList(growable: false);
      if (parts.isEmpty) return null;
      return parts.length == 1 ? parts.first : ResultFormat.compose(parts);
    }
    if (spec is String) return _buildNamed(spec, '', const {});
    if (spec is Map) {
      final map = Map<String, dynamic>.from(spec);
      final type = map['type'];
      if (type is! String || type.isEmpty) {
        throw FormatException(
          'Validator object must carry a non-empty "type": $spec',
        );
      }
      final message = (map['message'] ?? map['error'] ?? '').toString();
      return _buildNamed(type, message, map);
    }
    throw FormatException('Unsupported validator specification: $spec');
  }

  ResultFormat _buildNamed(
    String type,
    String message,
    Map<String, dynamic> args,
  ) {
    final factory = _factories[type];
    if (factory == null) {
      throw FormatException(
        'Unknown validator "$type". Registered: ${registered.join(', ')}. '
        'Add your own with ResultFormat.register("$type", ...).',
      );
    }
    return factory(message, args);
  }

  static num? _num(Object? v) =>
      v is num ? v : (v == null ? null : num.tryParse(v.toString()));

  static int? _int(Object? v) => _num(v)?.toInt();

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  void _registerBuiltIns() {
    void put(String name, ResultFormatFactory f) => _factories[name] = f;

    put('none', (m, a) => ResultFormat.none());
    put('notNull', (m, a) => ResultFormat.notNull(m));
    put('notEmpty', (m, a) => ResultFormat.notEmpty(m));
    put('notBlank', (m, a) => ResultFormat.notBlank(m));
    put('email', (m, a) => ResultFormat.email(m));
    put('name', (m, a) => ResultFormat.name(m));
    put('password', (m, a) => ResultFormat.password(m));
    put('text', (m, a) => ResultFormat.text(m));
    put('number', (m, a) => ResultFormat.number(m));
    put('smile', (m, a) => ResultFormat.smile(m));
    put('phone', (m, a) => ResultFormat.phone(m));
    put('url', (m, a) => ResultFormat.url(m));
    put('creditCard', (m, a) => ResultFormat.creditCard(m));
    put('ssn', (m, a) => ResultFormat.ssn(m));
    put('zipCode', (m, a) => ResultFormat.zipCode(m));
    put('age', (m, a) => ResultFormat.age(m));
    put('percentage', (m, a) => ResultFormat.percentage(m));
    put('iban', (m, a) => ResultFormat.iban(m));
    put('consent', (m, a) => ResultFormat.consent(m));
    put('location', (m, a) => ResultFormat.location(m));
    put('singleChoice', (m, a) => ResultFormat.singleChoice(m));
    put('multipleChoice', (m, a) => ResultFormat.multipleChoice(m));
    put('length', (m, a) => ResultFormat.length(m, _int(a['count']) ?? 0));
    put('min', (m, a) => ResultFormat.min(m, _num(a['min']) ?? 0));
    put('max', (m, a) => ResultFormat.max(m, _num(a['max']) ?? 0));
    put(
      'range',
      (m, a) => ResultFormat.range(
        m,
        _num(a['min']) ?? 0,
        _num(a['max']) ?? double.maxFinite,
      ),
    );
    put('minLength', (m, a) => ResultFormat.minLength(m, _int(a['min']) ?? 0));
    put(
      'maxLength',
      (m, a) => ResultFormat.maxLength(m, _int(a['max']) ?? 1 << 31),
    );
    put(
      'minSelections',
      (m, a) => ResultFormat.minSelections(m, _int(a['min']) ?? 0),
    );
    put(
      'maxSelections',
      (m, a) => ResultFormat.maxSelections(m, _int(a['max']) ?? 1 << 31),
    );
    put(
      'fileSize',
      (m, a) => ResultFormat.fileSize(m, _int(a['maxBytes']) ?? 1 << 31),
    );
    put('pattern', (m, a) {
      final regex = a['regex'] ?? a['pattern'];
      if (regex is! String || regex.isEmpty) {
        throw const FormatException(
          'Validator "pattern" requires a non-empty "regex".',
        );
      }
      return ResultFormat.pattern(m, regex);
    });
    put('expression', (m, a) {
      final expression = a['expression'] ?? a['value'];
      if (expression is! String || expression.isEmpty) {
        throw const FormatException(
          'Validator "expression" requires a non-empty "expression".',
        );
      }
      return ResultFormat.expression(expression);
    });
    put(
      'date',
      (m, a) => ResultFormat.date(m, (a['format'] ?? 'yyyy-MM-dd').toString()),
    );
    put(
      'dateRange',
      (m, a) => ResultFormat.dateRange(
        m,
        (a['format'] ?? 'yyyy-MM-dd').toString(),
        minDate: _date(a['minDate']),
        maxDate: _date(a['maxDate']),
      ),
    );
  }
}
