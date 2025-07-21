import 'package:flutter/widgets.dart';
import 'package:formstack/formstack.dart';
import 'package:lottie/lottie.dart';

class FormStackView extends StatefulWidget {
  const FormStackView(this.formKitForm, {super.key});
  final FormStackForm formKitForm;

  @override
  State<StatefulWidget> createState() => _FormStackViewState();
}

class _FormStackViewState extends State<FormStackView> {
  late Widget child;
  late FormStackForm _formKitForm;
  @override
  void initState() {
    super.initState();
    _formKitForm = widget.formKitForm;
    child = _formKitForm.render(onUpdate, onUpdateFormStackForm);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_formKitForm.preventSystemBackNavigation,
      onPopInvoked: (didPop) {
        if (didPop) {
          _formKitForm.onSystemNagiationBackClick?.call();
        }
      },
      child: _formKitForm.backgroundAnimationFile != null
          ? Stack(
              alignment: _formKitForm.backgroundAlignment ?? Alignment.center,
              children: [
                Lottie.asset(_formKitForm.backgroundAnimationFile!,
                    fit: BoxFit.cover),
                child,
              ],
            )
          : child,
    );
  }

  onUpdate(FormStep formStep) {
    setState(() {
      child = _formKitForm.render(onUpdate, onUpdateFormStackForm,
          formStep: formStep);
    });
  }

  onUpdateFormStackForm(FormStackForm formStackForm) {
    _formKitForm = formStackForm;
    setState(() {
      child = _formKitForm.render(onUpdate, onUpdateFormStackForm);
    });
  }
}
