import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/display_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// A read-only step that presents content rather than collecting an answer.
///
/// Renders either an embedded web page or a list of tiles, per
/// [displayStepType].
class DisplayStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "DisplayStep";

  /// Page to embed when [displayStepType] is [DisplayStepType.web].
  final String url;

  /// Whether this step renders a web page or a list of tiles.
  final DisplayStepType displayStepType;

  /// Tiles rendered when [displayStepType] is [DisplayStepType.listTile].
  final List<DynamicData> data;

  /// Creates a [DisplayStep].
  DisplayStep({
    super.id,
    this.url = "",
    super.title = "",
    super.text,
    super.isOptional = false,
    super.relevantConditions,
    super.nextButtonText = "Start",
    super.backButtonText,
    super.componentsStyle,
    super.style,
    this.data = const [],
    this.displayStepType = DisplayStepType.web,
    super.crossAxisAlignmentContent,
    super.titleIconMaxWidth,
    super.titleIconAnimationFile,
    super.cancelButtonText,
    super.cancellable,
  }) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    return DisplayStepView(formStackForm, this, text, title: title);
  }

  /// Creates a [DisplayStep] from its JSON form.
  factory DisplayStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
  ) {
    final json = JsonReader(element, context: 'DisplayStep');
    return DisplayStep(
      data: DynamicData.parseDynamicData(
        cast<List<dynamic>>(element?["data"]) ?? const [],
      ),
      componentsStyle: json.string('componentsStyle') != null
          ? ComponentsStyle.values.firstWhere(
              (e) => e.name == json.string('componentsStyle'),
            )
          : ComponentsStyle.minimal,
      displayStepType: json.string('displayStepType') != null
          ? DisplayStepType.values.firstWhere(
              (e) => e.name == json.string('displayStepType'),
            )
          : DisplayStepType.web,
      style: UIStyle.maybeFrom(json.map('style')),
      cancellable: json.boolean('cancellable'),
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            json.string('crossAxisAlignmentContent') ?? "center",
          ) ??
          CrossAxisAlignment.center,
      relevantConditions: relevantConditions,
      backButtonText: json.string('backButtonText'),
      cancelButtonText: json.string('cancelButtonText'),
      isOptional: json.boolean('isOptional'),
      text: json.string('text'),
      title: json.string('title'),
      nextButtonText: json.string('nextButtonText'),
      url: json.string('url') ?? "",
      titleIconAnimationFile: json.string('titleIconAnimationFile'),
      titleIconMaxWidth: json.decimal('titleIconMaxWidth'),
      id: GenericIdentifier(id: json.string('id')),
    );
  }
}

/// What a [DisplayStep] renders.
enum DisplayStepType {
  /// An embedded web page loaded from [DisplayStep.url].
  web,

  /// A list of tiles built from [DisplayStep.data].
  listTile,
}
