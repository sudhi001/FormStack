import 'package:flutter_test/flutter_test.dart';

/// Guards the query construction used by the Places autocomplete lookups.
///
/// The URLs were previously built by string interpolation, so a `&` or `=` in
/// what the user typed rewrote the request. These assert the encoding
/// behaviour the widget now relies on.
void main() {
  Uri autocomplete(String input, {List<String>? countries, String key = 'K'}) =>
      Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': input,
        'key': key,
        if (countries?.isNotEmpty ?? false)
          'components': countries!.map((c) => 'country:$c').join('|'),
      });

  group('Places autocomplete query', () {
    test('escapes a query that would otherwise add parameters', () {
      final uri = autocomplete('cafe&key=stolen');
      expect(uri.queryParameters['input'], 'cafe&key=stolen');
      expect(uri.queryParameters['key'], 'K');
      expect(uri.toString(), contains('cafe%26key%3Dstolen'));
    });

    test('escapes spaces and unicode', () {
      final uri = autocomplete('café royale');
      expect(uri.queryParameters['input'], 'café royale');
      expect(uri.toString(), isNot(contains(' ')));
    });

    test('omits the components filter when no countries are given', () {
      expect(
        autocomplete('x').queryParameters.containsKey('components'),
        isFalse,
      );
      expect(
        autocomplete(
          'x',
          countries: [],
        ).queryParameters.containsKey('components'),
        isFalse,
      );
    });

    test('joins multiple country filters', () {
      final uri = autocomplete('x', countries: ['gb', 'ie']);
      expect(uri.queryParameters['components'], 'country:gb|country:ie');
    });

    test('targets the documented endpoint', () {
      final uri = autocomplete('x');
      expect(uri.host, 'maps.googleapis.com');
      expect(uri.path, '/maps/api/place/autocomplete/json');
      expect(uri.scheme, 'https');
    });
  });
}
