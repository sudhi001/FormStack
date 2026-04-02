import 'package:formstack/formstack.dart';

/// Provides options from an external data source (CSV, API, database).
///
/// Implement this to load choice lists dynamically at runtime.
///
/// ```dart
/// class ApiOptionsProvider implements ExternalDataProvider {
///   @override
///   Future<List<Options>> loadOptions(String sourceId, Map<String, dynamic> params) async {
///     final response = await http.get('https://api.example.com/options/$sourceId');
///     final data = jsonDecode(response.body) as List;
///     return data.map((e) => Options(e['id'], e['name'])).toList();
///   }
/// }
///
/// // Use it
/// QuestionStep(
///   title: "Select City",
///   inputType: InputType.dropdown,
///   optionsProvider: ApiOptionsProvider(),
///   optionsSourceId: "cities",
/// )
/// ```
abstract class ExternalDataProvider {
  /// Load options from the external source.
  ///
  /// [sourceId] identifies which data set to load (e.g., table name, endpoint).
  /// [params] contains any filter parameters (e.g., `{"country": "US"}`).
  Future<List<Options>> loadOptions(
      String sourceId, Map<String, dynamic> params);
}

/// Loads options from a static list of maps (simulates CSV/JSON data).
///
/// ```dart
/// final provider = StaticDataProvider({
///   'countries': [
///     {'key': 'US', 'title': 'United States'},
///     {'key': 'UK', 'title': 'United Kingdom'},
///   ],
///   'states': [
///     {'key': 'CA', 'title': 'California', 'value': 'US'},
///     {'key': 'NY', 'title': 'New York', 'value': 'US'},
///     {'key': 'LDN', 'title': 'London', 'value': 'UK'},
///   ],
/// });
/// ```
class StaticDataProvider implements ExternalDataProvider {
  /// Data keyed by source ID.
  final Map<String, List<Map<String, dynamic>>> data;

  /// Creates a [StaticDataProvider] with the given data.
  StaticDataProvider(this.data);

  @override
  Future<List<Options>> loadOptions(
      String sourceId, Map<String, dynamic> params) async {
    final rows = data[sourceId] ?? [];
    return rows
        .map((row) => Options(
              row['key']?.toString() ?? '',
              row['title']?.toString() ?? '',
              subTitle: row['subTitle']?.toString(),
              value: row['value'],
            ))
        .toList();
  }

  /// Creates from a CSV-like list of rows with headers.
  ///
  /// ```dart
  /// StaticDataProvider.fromCsv('countries', [
  ///   ['key', 'title'],
  ///   ['US', 'United States'],
  ///   ['UK', 'United Kingdom'],
  /// ])
  /// ```
  factory StaticDataProvider.fromCsv(String sourceId, List<List<String>> rows) {
    if (rows.length < 2) return StaticDataProvider({sourceId: []});
    final headers = rows[0];
    final data = rows.sublist(1).map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length && i < row.length; i++) {
        map[headers[i]] = row[i];
      }
      return map;
    }).toList();
    return StaticDataProvider({sourceId: data});
  }
}
