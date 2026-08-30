import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/built_in_inputs.dart';
import 'package:formstack/src/utils/alignment.dart';

/// A step that asks the user for one answer.
///
/// The [inputType] selects the widget, which is resolved through
/// [InputRegistry] — see `BuiltInInputs` for the ones shipped with the
/// library, and [InputType.custom] for your own.
///
/// ```dart
/// QuestionStep(
///   id: GenericIdentifier(id: "email"),
///   title: "Your email",
///   inputType: InputType.email,
///   resultFormat: ResultFormat.email("Please enter a valid email"),
/// )
/// ```
class QuestionStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "QuestionStep";

  /// Which input widget renders this step.
  final InputType inputType;

  /// Called with the message when this step fails validation.
  void Function(String)? onValidationError;

  /// Choices for the selection input types.
  List<Options>? options;

  /// Visible lines for a multi-line text input.
  final int? numberOfLines;

  /// Whether choosing an option advances to the next step immediately.
  final bool? autoTrigger;

  /// Border treatment of the input field.
  final InputStyle inputStyle;

  /// Number of digits in an OTP input.
  final int count;

  /// Maximum number of rows in a dynamic key-value input.
  final int maxCount;

  /// Input mask applied to a number field, for example `###-###`.
  final String? mask;

  /// Called with all results when this step completes the form.
  void Function(Map<String, dynamic>)? onFinish;

  /// Height of the map viewport for location inputs.
  final double? maxHeight;

  /// Allowed file extensions for a file input, without the leading dot.
  final List<dynamic>? filter;

  /// How a selected choice is indicated: arrow, tick, toggle or dropdown.
  final SelectionType? selectionType;

  /// Maximum characters accepted, or -1 for no limit.
  final int? lengthLimit;

  /// Horizontal alignment of the entered text.
  final TextAlign textAlign;

  // New properties for industry-standard inputs
  /// Lower bound for slider and numeric inputs.
  final num? minValue;

  /// Upper bound for slider and numeric inputs.
  final num? maxValue;

  /// Increment between slider positions.
  final num? stepValue;

  /// Minimum options the user must select.
  final int? minSelections;

  /// Maximum options the user may select.
  final int? maxSelections;

  /// Text shown beside the consent checkbox.
  final String? consentText;

  /// Symbol prefixed to a currency input, for example `£`.
  final String? currencySymbol;

  /// Default dialling code for a phone input, for example `+44`.
  final String? phoneCountryCode;

  /// Number of stars in a rating input.
  final int? ratingCount;

  /// Expression string to auto-calculate this field's value from other results.
  /// Used with [InputType.calculate]. The expression is evaluated via
  /// [calculateCallback] which receives the current result map.
  final String? calculateExpression;

  /// Callback that computes this field's value from all collected results.
  /// Used with [InputType.calculate].
  ///
  /// ```dart
  /// QuestionStep(
  ///   inputType: InputType.calculate,
  ///   calculateCallback: (results) => (results["weight"] ?? 0) / pow(results["height"] ?? 1, 2),
  /// )
  /// ```
  final dynamic Function(Map<String, dynamic> results)? calculateCallback;

  /// Callback that filters available options based on other step results.
  /// Enables cascading selects (Country -> State -> City).
  ///
  /// ```dart
  /// QuestionStep(
  ///   inputType: InputType.dropdown,
  ///   options: allStates,
  ///   choiceFilter: (options, results) =>
  ///       options.where((o) => o.value == results["country"]).toList(),
  /// )
  /// ```
  final List<Options> Function(
    List<Options> options,
    Map<String, dynamic> results,
  )?
  choiceFilter;

  /// External data provider for loading options dynamically.
  /// Used with [ExternalDataProvider] for API/CSV-backed choice lists.
  final ExternalDataProvider? optionsProvider;

  /// Source ID passed to [optionsProvider] to identify which data set to load.
  final String? optionsSourceId;

  /// Name of an application-supplied input registered with [InputRegistry].
  ///
  /// Only consulted when [inputType] is [InputType.custom], or when it names a
  /// registered override for a built-in type. See [InputRegistry].
  final String? customInputType;

  /// Creates a [QuestionStep].
  QuestionStep({
    super.id,
    this.customInputType,
    super.title = "",
    required this.inputType,
    super.text,
    super.style,
    super.display,
    super.hint,
    super.footerBackButton,
    this.selectionType,
    super.description,
    this.onFinish,
    this.lengthLimit,
    super.label,
    super.disabled,
    this.count = 0,
    this.mask,
    this.maxCount = 100,
    this.maxHeight = 600,
    this.filter,
    this.textAlign = TextAlign.start,
    super.width,
    super.componentsStyle = ComponentsStyle.minimal,
    this.inputStyle = InputStyle.basic,
    super.resultFormat,
    this.onValidationError,
    super.isOptional = false,
    this.options,
    super.crossAxisAlignmentContent,
    super.relevantConditions,
    this.autoTrigger = false,
    this.numberOfLines,
    super.componentOnly,
    super.titleIconAnimationFile,
    super.nextButtonText,
    super.backButtonText,
    super.titleIconMaxWidth,
    super.cancelButtonText,
    super.cancellable,
    super.helperText,
    super.defaultValue,
    super.semanticLabel,
    this.minValue,
    this.maxValue,
    this.stepValue,
    this.minSelections,
    this.maxSelections,
    this.consentText,
    this.currencySymbol,
    this.phoneCountryCode,
    this.ratingCount,
    this.calculateExpression,
    this.calculateCallback,
    this.choiceFilter,
    this.optionsProvider,
    this.optionsSourceId,
  }) : super();

  /// The registry key this step resolves against.
  ///
  /// [customInputType] when set, otherwise the [inputType] enum name.
  String get inputTypeKey => customInputType ?? inputType.name;

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    formStackForm.onValidationError = onValidationError;
    formStackForm.onFinish = onFinish;

    // Built-ins and application-registered inputs resolve through the same
    // registry, so a step's input type is a lookup rather than a switch arm.
    // registerIfAbsent means an override installed by the application wins.
    BuiltInInputs.ensureRegistered();
    final view = InputRegistry.instance.build(
      inputTypeKey,
      this,
      formStackForm,
    );
    if (view != null) return view;

    throw StateError(
      'No input widget is registered for "$inputTypeKey" (step "${id?.id}"). '
      'Register one with InputRegistry.instance.register("$inputTypeKey", '
      '(ctx) => ...). Registered: '
      '${InputRegistry.instance.registered.join(', ')}',
    );
  }

  /// The options for this step, narrowed by [choiceFilter] when one is set.
  ///
  /// Evaluating the filter needs the form's current results, so it cannot be
  /// resolved when the step is constructed.
  List<Options>? filteredOptions(FormStackForm formStackForm) {
    if (choiceFilter != null && options != null) {
      formStackForm.generateResult();
      return choiceFilter!(options!, formStackForm.result);
    }
    return options;
  }

  /// Creates a [QuestionStep] from its JSON form.
  ///
  /// Throws [FormatException] for an unknown `inputType` that is also not
  /// registered with [InputRegistry], or for a malformed `options` entry.
  factory QuestionStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
  ) {
    final json = JsonReader(element, context: 'QuestionStep');
    final List<Options> options = [];
    for (final el in cast<List<dynamic>>(element?["options"]) ?? const []) {
      if (el is! Map) {
        throw FormatException('Each option must be an object, got: $el');
      }
      options.add(
        Options(
          (el["key"] ?? '').toString(),
          (el["title"] ?? '').toString(),
          subTitle: el["subTitle"]?.toString(),
          value: el["value"],
        ),
      );
    }
    final rawInputType = (json.string('inputType') ?? "").toString();
    final matched = InputType.values
        .where((e) => e.name == rawInputType)
        .cast<InputType?>()
        .firstWhere((e) => true, orElse: () => null);
    // An unrecognised name is not necessarily an error: it may be an input the
    // host application registered. Only a name that matches neither is fatal.
    if (matched == null && !InputRegistry.instance.contains(rawInputType)) {
      throw FormatException(
        'Unknown inputType "$rawInputType". Built-in types: '
        '${InputType.values.map((e) => e.name).join(', ')}. '
        'Custom types must be registered with InputRegistry first.',
      );
    }
    final InputType inputType = matched ?? InputType.custom;
    return QuestionStep(
      inputType: inputType,
      customInputType: matched == null ? rawInputType : null,
      resultFormat: ResultFormat.fromJson(
        element?["validators"] ?? element?["validator"],
      ),
      options: options,
      footerBackButton: json.boolean('footerBackButton') ?? false,
      selectionType: json.string('selectionType') != null
          ? SelectionType.values.firstWhere(
              (e) => e.name == json.string('selectionType'),
            )
          : null,
      filter: json.list('filter'),
      lengthLimit: json.integer('lengthLimit') ?? -1,
      count: json.integer('count') ?? 4,
      disabled: json.boolean('disabled') ?? false,
      maxHeight: json.decimal('maxHeight') ?? 600,
      maxCount: json.integer('maxCount') ?? 100,
      mask: json.string('mask'),
      description: json.string('description'),
      textAlign: textAlignmentFromString(json.string('textAlign') ?? ""),
      style: UIStyle.maybeFrom(json.map('style')),
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            json.string('crossAxisAlignmentContent') ?? "center",
          ) ??
          CrossAxisAlignment.center,
      display: json.string('display') != null
          ? Display.values.firstWhere((e) => e.name == json.string('display'))
          : Display.normal,
      relevantConditions: relevantConditions,
      cancellable: json.boolean('cancellable'),
      hint: json.string('hint'),
      label: json.string('label'),
      componentsStyle: json.string('componentsStyle') != null
          ? ComponentsStyle.values.firstWhere(
              (e) => e.name == json.string('componentsStyle'),
            )
          : ComponentsStyle.minimal,
      inputStyle: json.string('inputStyle') != null
          ? InputStyle.values.firstWhere(
              (e) => e.name == json.string('inputStyle'),
            )
          : InputStyle.basic,
      autoTrigger: json.boolean('autoTrigger') ?? false,
      backButtonText: json.string('backButtonText'),
      cancelButtonText: json.string('cancelButtonText'),
      isOptional: json.boolean('isOptional'),
      nextButtonText: json.string('nextButtonText'),
      numberOfLines: json.integer('numberOfLines'),
      text: json.string('text'),
      width: json.decimal('width'),
      title: json.string('title'),
      titleIconAnimationFile: json.string('titleIconAnimationFile'),
      titleIconMaxWidth: json.decimal('titleIconMaxWidth'),
      helperText: json.string('helperText'),
      defaultValue: element?["defaultValue"],
      semanticLabel: json.string('semanticLabel'),
      minValue: json.number('minValue'),
      maxValue: json.number('maxValue'),
      stepValue: json.number('stepValue'),
      minSelections: json.integer('minSelections'),
      maxSelections: json.integer('maxSelections'),
      consentText: json.string('consentText'),
      currencySymbol: json.string('currencySymbol'),
      phoneCountryCode: json.string('phoneCountryCode'),
      ratingCount: json.integer('ratingCount'),
      id: GenericIdentifier(id: json.string('id')),
    );
  }
}
