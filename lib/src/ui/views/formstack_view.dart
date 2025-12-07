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
  Widget? _backgroundWidget;
  bool _hasBackgroundAnimation = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _formKitForm = widget.formKitForm;
    _hasBackgroundAnimation = _formKitForm.backgroundAnimationFile != null;

    child = _formKitForm.render(onUpdate, onUpdateFormStackForm);
  }

  Widget? _buildBackgroundWidget() {
    if (!_hasBackgroundAnimation) return null;
    if (_backgroundWidget == null &&
        _formKitForm.backgroundAnimationFile != null) {
      _backgroundWidget = Lottie.asset(
        _formKitForm.backgroundAnimationFile!,
        fit: BoxFit.cover,
      );
    }
    return _backgroundWidget;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _backgroundWidget = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: !_formKitForm.preventSystemBackNavigation,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isDisposed) {
          _formKitForm.onSystemNavigationBackClick?.call();
        }
      },
      child: _hasBackgroundAnimation
          ? Stack(
              alignment: _formKitForm.backgroundAlignment ?? Alignment.center,
              children: [
                _buildBackgroundWidget() ?? const SizedBox.shrink(),
                child,
              ],
            )
          : child,
    );
  }

  void onUpdate(FormStep formStep) {
    if (mounted && !_isDisposed) {
      setState(() {
        child = _formKitForm.render(onUpdate, onUpdateFormStackForm,
            formStep: formStep);
      });
    }
  }

  void onUpdateFormStackForm(FormStackForm formStackForm) {
    if (mounted && !_isDisposed) {
      _formKitForm = formStackForm;
      setState(() {
        child = _formKitForm.render(onUpdate, onUpdateFormStackForm);
      });
    }
  }
}
