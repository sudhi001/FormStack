import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

void main() {
  group('FormStackLocale', () {
    FormStackLocale build() => FormStackLocale(
      defaultLocale: 'en',
      translations: {
        'en': {'title': 'Welcome', 'greeting': 'Hello, {0}! You have {1}.'},
        'es': {'title': 'Bienvenido'},
      },
    );

    test('translates in the active locale', () {
      expect(build().t('title'), 'Welcome');
    });

    test('switching locale changes the translation', () {
      final locale = build()..setLocale('es');
      expect(locale.currentLocale, 'es');
      expect(locale.t('title'), 'Bienvenido');
    });

    test('falls back to the default locale for a missing key', () {
      // 'greeting' exists only in English.
      final locale = build()..setLocale('es');
      expect(locale.t('greeting'), startsWith('Hello'));
    });

    test('an unknown key returns the key itself', () {
      expect(build().t('nope'), 'nope');
    });

    test('switching to an unknown locale is ignored', () {
      final locale = build()..setLocale('de');
      expect(locale.currentLocale, 'en');
    });

    test('tf interpolates positional placeholders', () {
      expect(
        build().tf('greeting', ['Ada', '3 messages']),
        'Hello, Ada! You have 3 messages.',
      );
    });

    test('tf leaves placeholders it has no argument for', () {
      expect(build().tf('greeting', ['Ada']), contains('{1}'));
    });

    test('availableLocales lists what was supplied', () {
      expect(build().availableLocales, containsAll(['en', 'es']));
    });

    test('fromJson reads the documented shape', () {
      final locale = FormStackLocale.fromJson({
        'defaultLocale': 'fr',
        'translations': {
          'fr': {'title': 'Bienvenue'},
        },
      });
      expect(locale.currentLocale, 'fr');
      expect(locale.t('title'), 'Bienvenue');
    });

    test('fromJson defaults to English and tolerates no translations', () {
      final locale = FormStackLocale.fromJson({});
      expect(locale.currentLocale, 'en');
      expect(locale.t('anything'), 'anything');
    });

    test('fromJson stringifies non-string values', () {
      final locale = FormStackLocale.fromJson({
        'defaultLocale': 'en',
        'translations': {
          'en': {'count': 5},
        },
      });
      expect(locale.t('count'), '5');
    });
  });

  group('StaticDataProvider', () {
    test('loads options for a source id', () async {
      final provider = StaticDataProvider({
        'countries': [
          {'key': 'US', 'title': 'United States'},
          {'key': 'GB', 'title': 'United Kingdom'},
        ],
      });

      final options = await provider.loadOptions('countries', {});

      expect(options.map((o) => o.key), ['US', 'GB']);
      expect(options.first.title, 'United States');
    });

    test(
      'an unknown source id yields no options rather than throwing',
      () async {
        final provider = StaticDataProvider({});
        expect(await provider.loadOptions('nope', {}), isEmpty);
      },
    );

    test('carries subTitle and value through', () async {
      final provider = StaticDataProvider({
        'states': [
          {
            'key': 'CA',
            'title': 'California',
            'subTitle': 'West',
            'value': 'US',
          },
        ],
      });

      final option = (await provider.loadOptions('states', {})).single;

      expect(option.subTitle, 'West');
      expect(option.value, 'US');
    });

    test('missing key and title become empty strings, not null', () async {
      final provider = StaticDataProvider({
        'partial': [<String, dynamic>{}],
      });
      final option = (await provider.loadOptions('partial', {})).single;
      expect(option.key, '');
      expect(option.title, '');
    });

    test('fromCsv uses the header row for field names', () async {
      final provider = StaticDataProvider.fromCsv('countries', [
        ['key', 'title'],
        ['US', 'United States'],
        ['GB', 'United Kingdom'],
      ]);

      final options = await provider.loadOptions('countries', {});

      expect(options, hasLength(2));
      expect(options.last.title, 'United Kingdom');
    });

    test('fromCsv with only a header yields no rows', () async {
      final provider = StaticDataProvider.fromCsv('x', [
        ['key', 'title'],
      ]);
      expect(await provider.loadOptions('x', {}), isEmpty);
    });

    test('fromCsv tolerates a row shorter than the header', () async {
      final provider = StaticDataProvider.fromCsv('x', [
        ['key', 'title'],
        ['US'],
      ]);
      final option = (await provider.loadOptions('x', {})).single;
      expect(option.key, 'US');
      expect(option.title, '');
    });
  });

  group('DynamicConditionalRelevant', () {
    test('routes on the callback', () {
      final condition = DynamicConditionalRelevant(
        identifier: GenericIdentifier(id: 'target'),
        isValidCallBack: (result) => result == 'yes',
      );

      expect(condition.isValid('yes'), isTrue);
      expect(condition.isValid('no'), isFalse);
    });

    test('a condition with no callback does not match', () {
      // This used to force-unwrap the callback and crash during navigation.
      final condition = DynamicConditionalRelevant(
        identifier: GenericIdentifier(id: 'target'),
        isValidCallBack: null,
      );

      expect(condition.isValid('anything'), isFalse);
    });

    test('carries a form name for cross-form routing', () {
      final condition = DynamicConditionalRelevant(
        identifier: GenericIdentifier(id: 'target'),
        formName: 'other',
        isValidCallBack: (_) => true,
      );
      expect(condition.formName, 'other');
    });
  });
}
