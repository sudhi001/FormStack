import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/display_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class DisplayStep extends FormStep {
  static const String tag = "DisplayStep";
  final String url;
  final DisplayStepType displayStepType;
  final List<DynamicData> data;
  DisplayStep(
      {super.id,
      this.url = "",
      super.title = "",
      super.text,
      super.isOptional = false,
      super.relevantConditions,
      super.nextButtonText = "Start",
      super.backButtonText,
      super.componentsStyle,
      super.buttonStyle,
      this.data = const [],
      this.displayStepType = DisplayStepType.web,
      super.crossAxisAlignmentContent,
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

enum DisplayStepType { web, listTile }
