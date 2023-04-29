import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/pop_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class PopStep extends FormStep {
  static const String tag = "PopStep";
  PopStep({super.id}) : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    cancellable = false;
    nextButtonText = "";
    return PopStepView(formKitForm, this, text, title: title);
  }
}
