/// Typed accessors for the JSON maps that form definitions are parsed from.
///
/// Reading `json['title']` yields `dynamic`, so passing it to a `String?`
/// parameter is an implicit downcast: the analyzer accepts it and the program
/// throws at the point of use, often several frames from the malformed field.
/// These accessors move that failure to the boundary and name the field, and
/// they let the package build with `strict-casts` enabled.
///
/// ```dart
/// final json = JsonReader(element, context: 'QuestionStep');
/// QuestionStep(
///   title: json.string('title'),
///   count: json.integer('count') ?? 4,
///   isOptional: json.boolean('isOptional'),
/// );
/// ```
///
/// Every accessor tolerates a null map and a missing key, returning null.
/// A value of the wrong type is an error rather than a silent null: a
/// definition that says `"count": "many"` is a mistake worth surfacing.
class JsonReader {
  /// The map being read, which may be null.
  final Map<String, dynamic>? source;

  /// Name used in error messages to identify what was being parsed.
  final String context;

  /// Creates a reader over [source].
  const JsonReader(this.source, {this.context = 'element'});

  /// Whether [key] is present with a non-null value.
  bool has(String key) => source?[key] != null;

  /// The raw value at [key], untyped.
  Object? raw(String key) => source?[key];

  /// The string at [key], or null.
  ///
  /// Numbers and booleans are accepted and stringified, since JSON authors
  /// commonly write `"count": 4` where text is expected.
  String? string(String key) {
    final value = source?[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    throw FormatException(
      '$context: "$key" should be a string, got ${value.runtimeType}',
    );
  }

  /// The integer at [key], or null. Accepts a numeric string.
  int? integer(String key) => _num(key)?.toInt();

  /// The double at [key], or null. Accepts a numeric string.
  double? decimal(String key) => _num(key)?.toDouble();

  /// The number at [key], or null. Accepts a numeric string.
  num? number(String key) => _num(key);

  num? _num(String key) {
    final value = source?[key];
    if (value == null) return null;
    if (value is num) return value;
    final parsed = num.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException(
        '$context: "$key" should be a number, got "$value"',
      );
    }
    return parsed;
  }

  /// The boolean at [key], or null. Accepts `"true"` and `"false"`.
  bool? boolean(String key) {
    final value = source?[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    throw FormatException('$context: "$key" should be a boolean, got "$value"');
  }

  /// The list at [key], or an empty list when absent.
  List<dynamic> list(String key) {
    final value = source?[key];
    if (value == null) return const [];
    if (value is List) return value;
    throw FormatException(
      '$context: "$key" should be a list, got ${value.runtimeType}',
    );
  }

  /// The nested object at [key], or null.
  Map<String, dynamic>? map(String key) {
    final value = source?[key];
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException(
      '$context: "$key" should be an object, got ${value.runtimeType}',
    );
  }

  /// The enum constant at [key] whose `name` matches, or null.
  ///
  /// Throws [FormatException] naming the permitted values when the string
  /// matches none of them — a typo in a form definition should say so rather
  /// than fall back to a default the author did not choose.
  T? enumValue<T extends Enum>(String key, List<T> values) {
    final name = string(key);
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    throw FormatException(
      '$context: "$key" is "$name", expected one of '
      '${values.map((v) => v.name).join(', ')}',
    );
  }
}
