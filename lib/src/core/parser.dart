import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/pop_step.dart';
import 'package:formstack/src/utils/alignment.dart';

/// Translates JSON form definitions into [FormStep] graphs.
///
/// Step construction is delegated to [StepRegistry], so supporting a new step
/// type is a registration rather than a change here.
class ParserUtils {
  ParserUtils._();

  /// Registers the step types shipped with the library.
  ///
  /// Called automatically before any parse. Registration is per-type and
  /// skipped when a type is already present, which makes this both idempotent
  /// and safe after [StepRegistry.reset] — and leaves any application override
  /// of a built-in tag in place.
  static void ensureBuiltInStepsRegistered() {
    final registry = StepRegistry.instance;
    registry
      ..registerIfAbsent(QuestionStep.tag, QuestionStep.from)
      ..registerIfAbsent(CompletionStep.tag, CompletionStep.from)
      ..registerIfAbsent(InstructionStep.tag, InstructionStep.from)
      ..registerIfAbsent(DisplayStep.tag, DisplayStep.from)
      ..registerIfAbsent(ReviewStep.tag, ReviewStep.from)
      ..registerIfAbsent(ConsentStep.tag, ConsentStep.from)
      ..registerIfAbsent(
        PopStep.tag,
        (json, conditions) => PopStep(id: GenericIdentifier(id: json['id'])),
      )
      ..registerIfAbsent(
        NestedStep.tag,
        (json, conditions) =>
            NestedStep.from(json, conditions, _parseChildSteps(json)),
      )
      ..registerIfAbsent(
        RepeatStep.tag,
        (json, conditions) =>
            RepeatStep.from(json, conditions, _parseChildSteps(json)),
      );
  }

  /// Builds every form described by [body] into [formStack].
  ///
  /// [body] maps a form name to its definition:
  /// `{"default": {"steps": [...], "theme": {...}}}`.
  ///
  /// Throws [FormatException] with the offending form and step named, so a
  /// malformed definition points at itself. This method is deliberately
  /// synchronous: as an `async` method its exceptions would escape to the zone
  /// instead of reaching the caller.
  static void buildFormFromJson(
    FormStack formStack,
    Map<String, dynamic>? body,
    MapKey mapKey,
    LocationWrapper locationWrapper,
  ) {
    if (body == null) {
      throw ArgumentError.notNull('body');
    }
    ensureBuiltInStepsRegistered();
    body.forEach((key, value) {
      try {
        final definition = value is Map ? Map<String, dynamic>.from(value) : {};
        final steps = <FormStep>[];
        for (final element in (definition['steps'] as List? ?? const [])) {
          addFormStep(steps, element);
        }
        formStack.form(
          steps: steps,
          name: key,
          mapKey: mapKey,
          backgroundAnimationFile: definition['backgroundAnimationFile'],
          backgroundAlignment: alignmentFromString(
            definition['backgroundAlignment'],
          ),
          defaultStyle: definition['theme'] != null
              ? UIStyle.from(definition['theme'])
              : null,
          initialLocation: locationWrapper,
        );
      } on FormatException {
        rethrow;
      } catch (e) {
        throw FormatException('Error parsing form "$key": $e');
      }
    });
  }

  /// Parses the nested `steps` array of a container step.
  static List<FormStep> _parseChildSteps(Map<String, dynamic> json) {
    final steps = <FormStep>[];
    for (final element in (json['steps'] as List? ?? const [])) {
      addFormStep(steps, element);
    }
    return steps;
  }

  /// Parses the navigation conditions declared on a step.
  ///
  /// Each entry must be an object carrying at least `id` (the target step) and
  /// `expression`. Malformed entries are reported rather than silently
  /// producing a condition that can never match.
  static List<RelevantCondition> parseRelevant(Map<String, dynamic>? element) {
    final conditions = <RelevantCondition>[];
    final declared = element?['relevantConditions'];
    if (declared == null) return conditions;
    if (declared is! List) {
      throw FormatException(
        '"relevantConditions" must be a list, got: $declared',
      );
    }
    for (final el in declared) {
      if (el is! Map) {
        throw FormatException(
          'Each relevant condition must be an object, got: $el',
        );
      }
      // A condition targets either a step in this form ("id") or another form
      // ("formName"). One of the two must be present; neither would produce a
      // condition that can match but go nowhere.
      final target = (el['id'] ?? '').toString();
      final formName = (el['formName'] ?? '').toString();
      if (target.isEmpty && formName.isEmpty) {
        throw FormatException(
          'A relevant condition needs a target step "id" or a "formName": $el',
        );
      }
      final expression = el['expression'];
      if (expression is! String || expression.isEmpty) {
        throw FormatException(
          'Relevant condition for "${target.isEmpty ? formName : target}" '
          'needs an "expression": $el',
        );
      }
      conditions.add(
        ExpressionRelevant(
          expression: expression,
          formName: formName,
          identifier: GenericIdentifier(id: target),
        ),
      );
    }
    return conditions;
  }

  /// Appends the step described by [element] to [steps].
  static void addFormStep(List<FormStep> steps, Object? element) {
    if (element == null) {
      throw const FormatException('Step element cannot be null');
    }
    if (element is! Map) {
      throw FormatException('Step element must be an object, got: $element');
    }
    ensureBuiltInStepsRegistered();
    final json = Map<String, dynamic>.from(element);
    try {
      steps.add(StepRegistry.instance.build(json, parseRelevant(json)));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException(
        'Error creating step of type "${json['type']}": $e',
      );
    }
  }
}
