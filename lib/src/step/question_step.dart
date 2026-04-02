import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/factory/choice_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/common_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/date_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/text_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/smile_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/survey_input_factory.dart';
import 'package:formstack/src/utils/alignment.dart';

class QuestionStep extends FormStep<QuestionStep> {
  static const String tag = "QuestionStep";
  final InputType inputType;
  Function(String)? onValidationError;
  List<Options>? options;
  final int? numberOfLines;
  final bool? autoTrigger;
  final InputStyle inputStyle;
  final int count;
  final int maxCount;
  final String? mask;

  Function(Map<String, dynamic>)? onFinish;
  final double? maxHeight;
  final List<dynamic>? filter;
  final SelectionType? selectionType;
  final int? lengthLimit;

  final TextAlign textAlign;

  // New properties for industry-standard inputs
  final num? minValue;
  final num? maxValue;
  final num? stepValue;
  final int? minSelections;
  final int? maxSelections;
  final String? consentText;
  final String? currencySymbol;
  final String? phoneCountryCode;
  final int? ratingCount;

  QuestionStep(
      {super.id,
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
      this.ratingCount})
      : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    formStackForm.onValidationError = onValidationError;
    formStackForm.onFinish = onFinish;
    switch (inputType) {
      case InputType.email:
        resultFormat =
            resultFormat ?? ResultFormat.email("Please enter a valid email.");
        return TextFieldWidgetView.email(
            this, formStackForm, text, resultFormat!, title);
      case InputType.name:
        resultFormat =
            resultFormat ?? ResultFormat.name("Please enter a valid name.");
        return TextFieldWidgetView.name(
            this, formStackForm, text, resultFormat!, title);
      case InputType.file:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please select a file.");
        return TextFieldWidgetView.file(
            this, formStackForm, text, resultFormat!, title, filter);
      case InputType.password:
        resultFormat = resultFormat ??
            ResultFormat.password("Please enter a valid password.");
        return TextFieldWidgetView.password(
            this, formStackForm, text, resultFormat!, title);
      case InputType.text:
        resultFormat =
            resultFormat ?? ResultFormat.notBlank("Please enter a valid data.");
        return TextFieldWidgetView.text(
            this, formStackForm, text, resultFormat!, title, numberOfLines);
      case InputType.number:
        resultFormat =
            resultFormat ?? ResultFormat.number("Please enter a valid number.");
        return TextFieldWidgetView.number(
            this, formStackForm, text, resultFormat!, title);
      case InputType.date:
        resultFormat = resultFormat ??
            ResultFormat.date("Please enter a valid date.", "dd-MM-yyyy");
        return DateInputWidget.date(
            this, formStackForm, text, resultFormat!, title);
      case InputType.time:
        resultFormat = resultFormat ??
            ResultFormat.date("Please enter a valid time.", "HH:mm:ss");
        return DateInputWidget.time(
            this, formStackForm, text, resultFormat!, title);
      case InputType.dateTime:
        resultFormat = resultFormat ??
            ResultFormat.date(
                "Please enter a valid date.", "yyyy-MM-dd'T'HH:mm");
        return DateInputWidget.dateTime(
            this, formStackForm, text, resultFormat!, title);
      case InputType.smile:
        resultFormat = resultFormat ?? ResultFormat.smile("Please select.");
        return SmileInputWidget.smile(
            this, formStackForm, text, resultFormat!, title);
      case InputType.singleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.singleChoice("Please select any.");
        return ChoiceInputWidget.single(
            this,
            formStackForm,
            text,
            resultFormat!,
            title,
            options,
            selectionType ?? SelectionType.arrow,
            autoTrigger ?? false);
      case InputType.dropdown:
        resultFormat =
            resultFormat ?? ResultFormat.singleChoice("Please select any.");
        return ChoiceInputWidget.dropdown(this, formStackForm, text,
            resultFormat!, title, options, autoTrigger ?? false);
      case InputType.multipleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.multipleChoice("Please select any.");
        return ChoiceInputWidget.multiple(this, formStackForm, text,
            resultFormat!, title, selectionType ?? SelectionType.tick, options);
      case InputType.otp:
        resultFormat = resultFormat ??
            ResultFormat.length("Please enter all fields", count);
        return CommonInputWidget.otp(
            this, formStackForm, text, resultFormat!, title, count);
      case InputType.dynamicKeyValue:
        resultFormat =
            resultFormat ?? ResultFormat.notEmpty("Please add any one");
        return CommonInputWidget.dynamicKeyValueField(
            this, formStackForm, text, resultFormat!, title, maxCount);
      case InputType.htmlEditor:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please enter any.");
        return CommonInputWidget.htmlWidget(
            this, formStackForm, text, resultFormat!, title);
      case InputType.mapLocation:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please enter any.");
        return CommonInputWidget.map(
            this, formStackForm, text, resultFormat!, title, maxHeight ?? 600);
      case InputType.avatar:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please update image.");
        return CommonInputWidget.avatar(
            this, formStackForm, text, resultFormat!, title);
      case InputType.banner:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please update image.");
        return CommonInputWidget.banner(
            this, formStackForm, text, resultFormat!, title);

      // --- New industry-standard input types ---
      case InputType.slider:
        resultFormat = resultFormat ??
            ResultFormat.range(
                "Please select a value.", minValue ?? 0, maxValue ?? 100);
        return SurveyInputWidget.slider(this, formStackForm, text,
            resultFormat!, title, minValue, maxValue, stepValue);
      case InputType.rating:
        resultFormat = resultFormat ??
            ResultFormat.range("Please select a rating.", 1, ratingCount ?? 5);
        return SurveyInputWidget.rating(
            this, formStackForm, text, resultFormat!, title, ratingCount);
      case InputType.nps:
        resultFormat =
            resultFormat ?? ResultFormat.range("Please select a score.", 0, 10);
        return SurveyInputWidget.nps(
            this, formStackForm, text, resultFormat!, title);
      case InputType.consent:
        resultFormat =
            resultFormat ?? ResultFormat.consent("You must agree to continue.");
        return SurveyInputWidget.consent(
            this, formStackForm, text, resultFormat!, title, consentText);
      case InputType.signature:
        resultFormat = resultFormat ??
            ResultFormat.notNull("Please provide your signature.");
        return SurveyInputWidget.signature(
            this, formStackForm, text, resultFormat!, title);
      case InputType.ranking:
        resultFormat =
            resultFormat ?? ResultFormat.notEmpty("Please rank the items.");
        return SurveyInputWidget.ranking(
            this, formStackForm, text, resultFormat!, title, options);
      case InputType.phone:
        resultFormat = resultFormat ??
            ResultFormat.phone("Please enter a valid phone number.");
        return SurveyInputWidget.phone(
            this, formStackForm, text, resultFormat!, title, phoneCountryCode);
      case InputType.currency:
        resultFormat =
            resultFormat ?? ResultFormat.notBlank("Please enter an amount.");
        return SurveyInputWidget.currency(
            this, formStackForm, text, resultFormat!, title, currencySymbol);
      case InputType.boolean:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please select Yes or No.");
        return SurveyInputWidget.boolean(
            this, formStackForm, text, resultFormat!, title);
      case InputType.imageChoice:
        resultFormat = resultFormat ??
            ResultFormat.singleChoice("Please select an option.");
        return SurveyInputWidget.imageChoice(
            this, formStackForm, text, resultFormat!, title, options, true);
      default:
    }
    throw UnimplementedError();
  }

  factory QuestionStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    List<Options> options = [];
    cast<List>(element?["options"])?.forEach((el) {
      options.add(Options(el?["key"], el?["title"], subTitle: el?["subTitle"]));
    });
    InputType inputType =
        InputType.values.firstWhere((e) => e.name == element?["inputType"]);
    return QuestionStep(
        inputType: inputType,
        options: options,
        footerBackButton: element?["footerBackButton"] ?? false,
        selectionType: element?["selectionType"] != null
            ? SelectionType.values
                .firstWhere((e) => e.name == element?["selectionType"])
            : null,
        filter: element?["filter"] ?? [],
        lengthLimit: element?["lengthLimit"] ?? -1,
        count: element?["count"] ?? 4,
        disabled: element?["disabled"] ?? false,
        maxHeight: element?["maxHeight"] ?? 600,
        maxCount: element?["maxCount"] ?? 100,
        mask: element?["mask"],
        description: element?["description"],
        textAlign: textAlignmentFromString(element?["textAlign"] ?? ""),
        style: UIStyle.from(element?["style"]),
        crossAxisAlignmentContent: crossAlignmentFromString(
                element?["crossAxisAlignmentContent"] ?? "center") ??
            CrossAxisAlignment.center,
        display: element?["display"] != null
            ? Display.values.firstWhere((e) => e.name == element?["display"])
            : Display.normal,
        relevantConditions: relevantConditions,
        cancellable: element?["cancellable"],
        hint: element?["hint"],
        label: element?["label"],
        componentsStyle: element?["componentsStyle"] != null
            ? ComponentsStyle.values
                .firstWhere((e) => e.name == element?["componentsStyle"])
            : ComponentsStyle.minimal,
        inputStyle: element?["inputStyle"] != null
            ? InputStyle.values
                .firstWhere((e) => e.name == element?["inputStyle"])
            : InputStyle.basic,
        autoTrigger: element?["autoTrigger"] ?? false,
        backButtonText: element?["backButtonText"],
        cancelButtonText: element?["cancelButtonText"],
        isOptional: element?["isOptional"],
        nextButtonText: element?["nextButtonText"],
        numberOfLines: element?["numberOfLines"],
        text: element?["text"],
        width: element?["width"],
        title: element?["title"],
        titleIconAnimationFile: element?["titleIconAnimationFile"],
        titleIconMaxWidth: element?["titleIconMaxWidth"],
        helperText: element?["helperText"],
        defaultValue: element?["defaultValue"],
        semanticLabel: element?["semanticLabel"],
        minValue: element?["minValue"],
        maxValue: element?["maxValue"],
        stepValue: element?["stepValue"],
        minSelections: element?["minSelections"],
        maxSelections: element?["maxSelections"],
        consentText: element?["consentText"],
        currencySymbol: element?["currencySymbol"],
        phoneCountryCode: element?["phoneCountryCode"],
        ratingCount: element?["ratingCount"],
        id: GenericIdentifier(id: element?["id"]));
  }
}
