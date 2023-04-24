import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/pop_step_view.dart';
import 'package:formstack/src/ui/views/step_view.dart';

class PopStep extends FormStep {
  PopStep({super.id}) : super();

  @override
  FormStepView buildView(FormStackForm formKitForm) {
    return PopStepView(formKitForm, this, text, title: title);
  }
}
