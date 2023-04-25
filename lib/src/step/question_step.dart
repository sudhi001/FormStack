import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/factory/choice_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/date_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/text_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/smile_input_factory.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class QuestionStep extends FormStep<QuestionStep> {
  final InputType inputType;
  Function(String)? onValidationError;
  final List<Options>? options;
  final int? numberOfLines;
  final bool? autoTrigger;

  QuestionStep(
      {super.id,
      super.title = "",
      required this.inputType,
      super.text,
      super.display,
      super.hint,
      super.label,
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
            title, options, autoTrigger ?? false);
      case InputType.multipleChoice:
        resultFormat =
            resultFormat ?? ResultFormat.multipleChoice("Please select any.");
        return ChoiceInputWidget.multiple(
            this, formKitForm, text, resultFormat!, title, options);
      default:
    }
    throw UnimplementedError();
  }
}
