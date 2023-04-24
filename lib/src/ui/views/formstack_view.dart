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
    child = widget.formKitForm.render(onUpdate, onUpdateFormStackForm);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _formKitForm.onSystemNagiationBackClick?.call();
        return _formKitForm.preventSystemBackNavigation;
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
      child = widget.formKitForm.render(onUpdate, onUpdateFormStackForm);
    });
  }
}
