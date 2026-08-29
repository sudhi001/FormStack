import 'package:formstack/formstack.dart';

/// Everything a custom input widget needs in order to build itself.
///
/// Passed to an [InputViewBuilder] so builders take one stable parameter
/// rather than a positional argument list that would break on every addition.
class InputBuildContext {
  /// The step being rendered.
  final QuestionStep step;

  /// The form that owns [step], used for navigation and result aggregation.
  final FormStackForm form;

  /// The validator resolved for this step — explicit if the step declared one,
  /// otherwise the default registered alongside the input type.
  final ResultFormat resultFormat;

  /// Creates an [InputBuildContext].
  const InputBuildContext({
    required this.step,
    required this.form,
    required this.resultFormat,
  });

  /// Convenience accessor for the step title.
  String? get title => step.title;

  /// Convenience accessor for the step body text.
  String? get text => step.text;
}

/// Builds the view for one input type.
typedef InputViewBuilder = FormStepView Function(InputBuildContext context);

/// Supplies the validator used when a step does not declare its own.
typedef DefaultValidatorBuilder = ResultFormat Function();

/// Maps input-type names to the widgets that render them.
///
/// [QuestionStep] consults this registry before falling back to its built-in
/// widgets, which makes the input layer open for extension without modifying
/// the library: applications can add entirely new input types, or replace a
/// built-in one with a different implementation.
///
/// Adding a new input type:
///
/// ```dart
/// InputRegistry.instance.register(
///   'creditCardScanner',
///   (ctx) => CreditCardScannerView(ctx.form, ctx.step, ctx.text, ctx.resultFormat,
///       title: ctx.title),
///   defaultValidator: () => ResultFormat.creditCard('Invalid card'),
/// );
/// ```
///
/// It is then usable from Dart via [InputType.custom]:
///
/// ```dart
/// QuestionStep(
///   inputType: InputType.custom,
///   customInputType: 'creditCardScanner',
///   id: GenericIdentifier(id: 'card'),
/// )
/// ```
///
/// …and from JSON simply as `"inputType": "creditCardScanner"`.
///
/// Replacing a built-in — every `signature` step in every form now uses the
/// application's own pad:
///
/// ```dart
/// InputRegistry.instance.register('signature', (ctx) => MySignaturePad(ctx));
/// ```
class InputRegistry {
  InputRegistry._();

  /// The process-wide registry consulted by [QuestionStep.buildView].
  static final InputRegistry instance = InputRegistry._();

  final Map<String, InputViewBuilder> _builders = {};
  final Map<String, DefaultValidatorBuilder> _validators = {};

  /// Names currently resolvable, sorted alphabetically.
  List<String> get registered => _builders.keys.toList()..sort();

  /// Whether [type] resolves to a registered builder.
  bool contains(String type) => _builders.containsKey(type);

  /// Registers [builder] for [type], replacing any previous entry.
  ///
  /// [defaultValidator] supplies the validator for steps of this type that do
  /// not set one explicitly. It is invoked per step, so each step gets its own
  /// instance rather than sharing mutable validator state.
  void register(
    String type,
    InputViewBuilder builder, {
    DefaultValidatorBuilder? defaultValidator,
  }) {
    if (type.isEmpty) {
      throw ArgumentError.value(type, 'type', 'Input type must not be empty');
    }
    _builders[type] = builder;
    if (defaultValidator != null) {
      _validators[type] = defaultValidator;
    } else {
      _validators.remove(type);
    }
  }

  /// Registers [builder] for [type] only if [type] has no entry yet.
  ///
  /// Used to install the library's own input widgets without clobbering an
  /// override an application registered first. Returns whether it registered.
  bool registerIfAbsent(
    String type,
    InputViewBuilder builder, {
    DefaultValidatorBuilder? defaultValidator,
  }) {
    if (_builders.containsKey(type)) return false;
    register(type, builder, defaultValidator: defaultValidator);
    return true;
  }

  /// Removes a registration. Returns whether anything was removed.
  bool unregister(String type) {
    _validators.remove(type);
    return _builders.remove(type) != null;
  }

  /// Clears every registration. Intended for tests.
  void reset() {
    _builders.clear();
    _validators.clear();
  }

  /// Returns the default validator for [type], or null if none was registered.
  ResultFormat? defaultValidatorFor(String type) => _validators[type]?.call();

  /// Builds the view for [step], or returns null when [type] is not registered.
  ///
  /// Resolves the step's validator first: the step's own if it declared one,
  /// otherwise the default registered alongside [type]. A step with neither is
  /// left without a validator rather than being stamped with
  /// [ResultFormat.none] — stamping it would make a validator assigned later
  /// unreachable, and would silently mark the step as always valid.
  FormStepView? build(String type, QuestionStep step, FormStackForm form) {
    final builder = _builders[type];
    if (builder == null) return null;
    final resolved = step.resultFormat ?? defaultValidatorFor(type);
    if (resolved != null) step.resultFormat = resolved;
    return builder(
      InputBuildContext(
        step: step,
        form: form,
        resultFormat: resolved ?? ResultFormat.none(),
      ),
    );
  }
}
