import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/pop_step_view.dart';

class PopStep extends FormStep {
  static const String tag = "PopStep";
  PopStep({super.id}) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    cancellable = false;
    nextButtonText = "";
    return PopStepView(formStackForm, this, text, title: title);
  }
}
