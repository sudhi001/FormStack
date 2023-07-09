import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/core/ui_style.dart';
import 'package:formstack/src/relevant/relevant_condition.dart';
import 'package:formstack/src/ui/views/input/factory/choice_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/common_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/date_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/text_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/smile_input_factory.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

class QuestionStep extends FormStep<QuestionStep> {
  static const String tag = "QuestionStep";
  final InputType inputType;
  Function(String)? onValidationError;
  final List<Options>? options;
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
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    formKitForm.onValidtionError = onValidationError;
    formKitForm.onFinish = onFinish;
    switch (inputType) {
      case InputType.email:
        resultFormat =
            resultFormat ?? ResultFormat.email("Please enter a valid email.");
        return TextFeildWidgetView.email(
            this, formKitForm, text, resultFormat!, title);
      case InputType.name:
        resultFormat =
            resultFormat ?? ResultFormat.name("Please enter a valid name.");
        return TextFeildWidgetView.name(
            this, formKitForm, text, resultFormat!, title);
      case InputType.file:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please select a file.");
        return TextFeildWidgetView.file(
            this, formKitForm, text, resultFormat!, title, filter);
      case InputType.password:
        resultFormat = resultFormat ??
            ResultFormat.password("Please enter a valid password.");
        return TextFeildWidgetView.password(
            this, formKitForm, text, resultFormat!, title);
      case InputType.text:
        resultFormat =
            resultFormat ?? ResultFormat.name("Please enter a valid data.");
        return TextFeildWidgetView.text(
            this, formKitForm, text, resultFormat!, title, numberOfLines);
      case InputType.number:
        resultFormat =
            resultFormat ?? ResultFormat.number("Please enter a valid number.");
        return TextFeildWidgetView.number(
            this, formKitForm, text, resultFormat!, title);
      case InputType.date:
        resultFormat = resultFormat ??
            ResultFormat.date("Please enter a valid date.", "dd-MM-yyyy");
        return DateInputWidget.date(
            this, formKitForm, text, resultFormat!, title);
      case InputType.time:
        resultFormat = resultFormat ??
            ResultFormat.date("Please enter a valid time.", "hh:mm:ss a");
        return DateInputWidget.time(
            this, formKitForm, text, resultFormat!, title);
      case InputType.dateTime:
        resultFormat = resultFormat ??
            ResultFormat.date(
                "Please enter a valid date.", "yyyy-MM-dd'T'HH:mm");
        return DateInputWidget.dateTime(
            this, formKitForm, text, resultFormat!, title);
      case InputType.smile:
        resultFormat = resultFormat ?? ResultFormat.smile("Please select.");
        return SmileInputWidget.smile(
            this, formKitForm, text, resultFormat!, title);
      case InputType.singleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.singleChoice("Please select any.");
        return ChoiceInputWidget.single(
            this,
            formKitForm,
            text,
            resultFormat!,
            title,
            options,
            selectionType ?? SelectionType.arrow,
            autoTrigger ?? false);
      case InputType.dropdown:
        resultFormat =
            resultFormat ?? ResultFormat.singleChoice("Please select any.");
        return ChoiceInputWidget.dropdown(this, formKitForm, text,
            resultFormat!, title, options, autoTrigger ?? false);
      case InputType.multipleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.multipleChoice("Please select any.");
        return ChoiceInputWidget.multiple(this, formKitForm, text,
            resultFormat!, title, selectionType ?? SelectionType.tick, options);
      case InputType.otp:
        resultFormat = resultFormat ??
            ResultFormat.length("Please enter all fields", count);
        return CommonInputWidget.otp(
            this, formKitForm, text, resultFormat!, title, count);
      case InputType.dynamicKeyValue:
        resultFormat =
            resultFormat ?? ResultFormat.notEmpty("Please add any one");
        return CommonInputWidget.dynamicKeyValueField(
            this, formKitForm, text, resultFormat!, title, maxCount);
      case InputType.htmlEditor:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please enter any.");
        return CommonInputWidget.htmlWidget(
            this, formKitForm, text, resultFormat!, title);
      case InputType.mapLocation:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please enter any.");
        return CommonInputWidget.map(
            this, formKitForm, text, resultFormat!, title, maxHeight ?? 600);
      case InputType.avatar:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please update image.");
        return CommonInputWidget.avatar(
            this, formKitForm, text, resultFormat!, title);
      case InputType.banner:
        resultFormat =
            resultFormat ?? ResultFormat.notNull("Please update image.");
        return CommonInputWidget.banner(
            this, formKitForm, text, resultFormat!, title);
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
        id: GenericIdentifier(id: element?["id"]));
  }
}
