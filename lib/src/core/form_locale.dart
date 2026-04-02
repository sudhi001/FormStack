/// Multi-language support for FormStack forms.
///
/// Define translations and switch languages at runtime.
///
/// ```dart
/// final locale = FormStackLocale(
///   defaultLocale: 'en',
///   translations: {
///     'en': {'welcome_title': 'Welcome', 'welcome_text': 'Please fill the form'},
///     'es': {'welcome_title': 'Bienvenido', 'welcome_text': 'Por favor complete el formulario'},
///     'fr': {'welcome_title': 'Bienvenue', 'welcome_text': 'Veuillez remplir le formulaire'},
///   },
/// );
///
/// // Use in step definitions
/// InstructionStep(
///   title: locale.t('welcome_title'),
///   text: locale.t('welcome_text'),
/// )
///
/// // Switch language at runtime
/// locale.setLocale('es');
/// ```
class FormStackLocale {
  /// The current active locale key.
  String _currentLocale;

  /// The default locale to fall back to when a key is not found.
  final String defaultLocale;

  /// Translation map: `{'locale': {'key': 'translated_value'}}`.
  final Map<String, Map<String, String>> translations;

  /// Creates a [FormStackLocale] with the given translations.
  FormStackLocale({
    required this.defaultLocale,
    required this.translations,
  }) : _currentLocale = defaultLocale;

  /// Returns the current locale key.
  String get currentLocale => _currentLocale;

  /// Returns all available locale keys.
  List<String> get availableLocales => translations.keys.toList();

  /// Switches the active locale.
  void setLocale(String locale) {
    if (translations.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  /// Translates a key to the current locale.
  /// Falls back to [defaultLocale], then returns the key itself if not found.
  String t(String key) {
    return translations[_currentLocale]?[key] ??
        translations[defaultLocale]?[key] ??
        key;
  }

  /// Translates a key with positional placeholders.
  /// Replaces `{0}`, `{1}`, etc. with the provided arguments.
  ///
  /// ```dart
  /// locale.tf('greeting', ['John']); // "Hello, John!"
  /// ```
  String tf(String key, List<String> args) {
    var text = t(key);
    for (int i = 0; i < args.length; i++) {
      text = text.replaceAll('{$i}', args[i]);
    }
    return text;
  }

  /// Creates a [FormStackLocale] from a JSON map.
  ///
  /// ```json
  /// {
  ///   "defaultLocale": "en",
  ///   "translations": {
  ///     "en": {"title": "Welcome"},
  ///     "es": {"title": "Bienvenido"}
  ///   }
  /// }
  /// ```
  factory FormStackLocale.fromJson(Map<String, dynamic> json) {
    final translations = <String, Map<String, String>>{};
    final rawTranslations = json['translations'] as Map<String, dynamic>? ?? {};
    for (var entry in rawTranslations.entries) {
      final localeMap = <String, String>{};
      (entry.value as Map<String, dynamic>).forEach((k, v) {
        localeMap[k] = v.toString();
      });
      translations[entry.key] = localeMap;
    }
    return FormStackLocale(
      defaultLocale: json['defaultLocale'] as String? ?? 'en',
      translations: translations,
    );
  }
}
