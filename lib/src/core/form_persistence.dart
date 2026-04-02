import 'dart:convert';

/// Abstract interface for persisting form state.
///
/// Implement this to provide platform-specific storage (SharedPreferences,
/// Hive, SQLite, etc.). FormStack uses this for offline save & resume.
///
/// ```dart
/// class SharedPrefsPersistence implements FormPersistence {
///   final SharedPreferences prefs;
///   SharedPrefsPersistence(this.prefs);
///
///   @override
///   Future<void> save(String formId, Map<String, dynamic> data) async {
///     await prefs.setString('form_$formId', jsonEncode(data));
///   }
///
///   @override
///   Future<Map<String, dynamic>?> load(String formId) async {
///     final json = prefs.getString('form_$formId');
///     return json != null ? jsonDecode(json) : null;
///   }
///
///   @override
///   Future<void> delete(String formId) async {
///     await prefs.remove('form_$formId');
///   }
///
///   @override
///   Future<List<String>> listDrafts() async {
///     return prefs.getKeys().where((k) => k.startsWith('form_'))
///         .map((k) => k.substring(5)).toList();
///   }
/// }
///
/// // Use it
/// FormStack.api().enablePersistence(SharedPrefsPersistence(prefs));
/// ```
abstract class FormPersistence {
  /// Save form state for the given form ID.
  Future<void> save(String formId, Map<String, dynamic> data);

  /// Load saved form state. Returns null if no saved state exists.
  Future<Map<String, dynamic>?> load(String formId);

  /// Delete saved form state.
  Future<void> delete(String formId);

  /// List all saved form draft IDs.
  Future<List<String>> listDrafts();
}

/// In-memory implementation of [FormPersistence] for testing and simple use cases.
class InMemoryFormPersistence implements FormPersistence {
  final Map<String, String> _store = {};

  @override
  Future<void> save(String formId, Map<String, dynamic> data) async {
    _store[formId] = jsonEncode(data);
  }

  @override
  Future<Map<String, dynamic>?> load(String formId) async {
    final json = _store[formId];
    return json != null ? jsonDecode(json) as Map<String, dynamic> : null;
  }

  @override
  Future<void> delete(String formId) async {
    _store.remove(formId);
  }

  @override
  Future<List<String>> listDrafts() async {
    return _store.keys.toList();
  }
}

/// Serializable form draft containing all step results and metadata.
class FormDraft {
  /// Form identifier.
  final String formId;

  /// Form name.
  final String? formName;

  /// Step results as flat key-value map.
  final Map<String, dynamic> results;

  /// ID of the current step when the draft was saved.
  final String? currentStepId;

  /// When the draft was saved.
  final DateTime savedAt;

  /// Creates a [FormDraft].
  FormDraft({
    required this.formId,
    this.formName,
    required this.results,
    this.currentStepId,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now().toUtc();

  /// Converts to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'formId': formId,
        'formName': formName,
        'results': results,
        'currentStepId': currentStepId,
        'savedAt': savedAt.toIso8601String(),
      };

  /// Creates a [FormDraft] from a JSON map.
  factory FormDraft.fromJson(Map<String, dynamic> json) {
    return FormDraft(
      formId: json['formId'] as String,
      formName: json['formName'] as String?,
      results: Map<String, dynamic>.from(json['results'] as Map),
      currentStepId: json['currentStepId'] as String?,
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? ''),
    );
  }
}
