import 'package:formstack/formstack.dart';

/// Builds a [FormStep] from its JSON description.
///
/// [json] is the raw step object; [relevantConditions] are the navigation
/// conditions the parser has already resolved for it.
typedef StepFactory = FormStep Function(
  Map<String, dynamic> json,
  List<RelevantCondition> relevantConditions,
);

/// Maps the JSON `"type"` discriminator to the step it constructs.
///
/// The JSON parser resolves step types through this registry instead of a
/// hard-coded chain of `if` comparisons, so a new step type is a registration
/// rather than an edit to the parser:
///
/// ```dart
/// StepRegistry.instance.register(
///   'PaymentStep',
///   (json, conditions) => PaymentStep.from(json, conditions),
/// );
/// ```
///
/// `{"type": "PaymentStep", ...}` is then parseable by every JSON loader.
class StepRegistry {
  StepRegistry._();

  /// The process-wide registry consulted by the JSON parser.
  static final StepRegistry instance = StepRegistry._();

  final Map<String, StepFactory> _factories = {};

  /// Type names currently resolvable, sorted alphabetically.
  List<String> get registered => _factories.keys.toList()..sort();

  /// Whether [type] resolves to a registered factory.
  bool contains(String type) => _factories.containsKey(type);

  /// Registers [factory] for [type], replacing any previous entry.
  void register(String type, StepFactory factory) {
    if (type.isEmpty) {
      throw ArgumentError.value(type, 'type', 'Step type must not be empty');
    }
    _factories[type] = factory;
  }

  /// Registers [factory] only if [type] has no entry yet.
  ///
  /// Used to install the library's own step types without clobbering an
  /// override an application registered first. Returns whether it registered.
  bool registerIfAbsent(String type, StepFactory factory) {
    if (_factories.containsKey(type)) return false;
    register(type, factory);
    return true;
  }

  /// Removes a registration. Returns whether anything was removed.
  bool unregister(String type) => _factories.remove(type) != null;

  /// Clears every registration, including the built-ins.
  ///
  /// Intended for tests. The library re-registers its own step types on the
  /// next parse, so a reset removes application registrations only.
  void reset() => _factories.clear();

  /// Builds the step described by [json].
  ///
  /// Throws [FormatException] when the object has no `type`, or when the type
  /// is not registered — the message lists what is available so a typo in a
  /// form definition is self-diagnosing.
  FormStep build(
    Map<String, dynamic> json,
    List<RelevantCondition> relevantConditions,
  ) {
    final type = json['type'];
    if (type is! String || type.isEmpty) {
      throw const FormatException('Step element must have a "type" field');
    }
    final factory = _factories[type];
    if (factory == null) {
      throw FormatException(
          'Unknown step type "$type". Registered: ${registered.join(', ')}. '
          'Add your own with StepRegistry.instance.register("$type", ...).');
    }
    return factory(json, relevantConditions);
  }
}
