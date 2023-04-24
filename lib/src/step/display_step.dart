import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/display_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class DisplayStep extends FormStep {
  final String url;

  DisplayStep(
      {super.id,
      this.url = "",
      super.title = "",
      super.text,
      super.isOptional = false,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.titleIconMaxWidth,
      super.titleIconAnimationFile,
      super.cancelButtonText,
      super.cancellable})
      : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    return DisplayStepView(formKitForm, this, text, title: title);
  }
}
