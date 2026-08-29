import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/pop_step_view.dart';

/// A step that pops the enclosing route instead of rendering anything.
///
/// Use as a branch target to leave the form entirely.
class PopStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "PopStep";

  /// Creates a [PopStep].
  PopStep({super.id}) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    cancellable = false;
    nextButtonText = "";
    return PopStepView(formStackForm, this, text, title: title);
  }
}
