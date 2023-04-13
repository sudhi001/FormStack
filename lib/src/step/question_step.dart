import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';
import 'package:formstack/src/step/global_input_widget.dart';

class QuestionStep extends FormStep<QuestionStep> {
  final String? title;
  final String? text;
  final InputType inputType;
  final Function(String)? onValidationError;
  final List<Options>? options;
  final int? numberOfLines;
  final bool autoTrigger;

  QuestionStep(
      {super.id,
      this.title = "",
      required this.inputType,
      this.text,
      super.resultFormat,
      this.onValidationError,
      super.isOptional = false,
      this.options,
      super.relevantConditions,
      this.autoTrigger = false,
      this.numberOfLines,
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
    switch (inputType) {
      case InputType.email:
        resultFormat =
            resultFormat ?? ResultFormat.email("Please enter a valid email.");
        return GlobalInputWidgetView.email(
            this, formKitForm, text, resultFormat!, title);
      case InputType.name:
        resultFormat =
            resultFormat ?? ResultFormat.name("Please enter a valid name.");
        return GlobalInputWidgetView.name(
            this, formKitForm, text, resultFormat!, title);
      case InputType.password:
        resultFormat = resultFormat ??
            ResultFormat.password("Please enter a valid password.");
        return GlobalInputWidgetView.password(
            this, formKitForm, text, resultFormat!, title);
      case InputType.text:
        resultFormat =
            resultFormat ?? ResultFormat.name("Please enter a valid data.");
        return GlobalInputWidgetView.text(
            this, formKitForm, text, resultFormat!, title, numberOfLines);
      case InputType.number:
        resultFormat =
            resultFormat ?? ResultFormat.number("Please enter a valid number.");
        return GlobalInputWidgetView.number(
            this, formKitForm, text, resultFormat!, title);
      case InputType.date:
        resultFormat = resultFormat ??
            ResultFormat.date("Please enter a valid date.", "dd-MM-yyyy");
        return DateInputWidget.date(
            this, formKitForm, text, resultFormat!, title);
      case InputType.time:
        resultFormat = resultFormat ??
            ResultFormat.date("Please enter a valid time.", "HH:mm:ss a");
        return DateInputWidget.time(
            this, formKitForm, text, resultFormat!, title);
      case InputType.dateTime:
        resultFormat = resultFormat ??
            ResultFormat.date(
                "Please enter a valid date.", "dd-MM-yyyy HH:mm:ss a");
        return DateInputWidget.dateTime(
            this, formKitForm, text, resultFormat!, title);
      case InputType.smile:
        resultFormat = resultFormat ?? ResultFormat.smile("Please select.");
        return SmileInputWidget.smile(
            this, formKitForm, text, resultFormat!, title);
      case InputType.singleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.singleChoice("Please select any.");
        return ChoiceInputWidget.single(this, formKitForm, text, resultFormat!,
            title, options, autoTrigger);
      case InputType.multipleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.multipleChoice("Please select any.");
        return ChoiceInputWidget.multiple(
          this,
          formKitForm,
          text,
          resultFormat!,
          title,
          options,
        );

      default:
    }
    throw UnimplementedError();
  }
}
