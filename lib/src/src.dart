import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/result_format.dart';
import 'package:formstack/src/form.dart';
import 'package:lottie/lottie.dart';

class FormStack {
  // Ensures end-users cannot initialize the class.
  FormStack._();

  static final Map<String, FormStack> _delegate = {};

  final Map<String, FormStackForm> _forms = {};

  static FormStack api({String name = "default"}) {
    if (!_delegate.containsKey(name)) {
      _delegate.putIfAbsent(name, () => FormStack._());
    }
    return _delegate[name]!;
  }

  FormStack form({
    String name = "default",
    String? googleMapAPIKey,
    GeoLocationResult? initialPosition,
    String? backgroundAnimationFile,
    required List<FormStep> steps,
  }) {
    var list = LinkedList<FormStep>();
    list.addAll(steps);
    FormWizard form = FormWizard(list,
        googleMapAPIKey: googleMapAPIKey,
        backgroundAnimationFile: backgroundAnimationFile);
    _forms.putIfAbsent(name, () => form);
    return this;
  }

  Widget render({String name = "default"}) {
    return FormStackView(_forms[name]!); //.render();
  }
}

class FormStackView extends StatefulWidget {
  final FormStackForm formKitForm;
  const FormStackView(this.formKitForm, {super.key});

  @override
  State<StatefulWidget> createState() => _FormStackViewState();
}

class _FormStackViewState extends State<FormStackView> {
  late Widget child;
  @override
  void initState() {
    super.initState();
    child = widget.formKitForm.render(onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            showCloseIcon: true,
            closeIconColor: Colors.white,
            content: Text(
              "System back navigation prevented. Please use \"Back\" button.",
            )));
        return false;
      },
      child: Scaffold(
          body: widget.formKitForm.backgroundAnimationFile != null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(widget.formKitForm.backgroundAnimationFile!,
                        fit: BoxFit.fill),
                    child,
                  ],
                )
              : child),
    );
  }

  onUpdate(FormStep formStep) {
    setState(() {
      child = widget.formKitForm.render(onUpdate, formStep: formStep);
    });
  }
}
