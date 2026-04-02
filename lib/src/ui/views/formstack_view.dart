import 'package:flutter/widgets.dart';
import 'package:formstack/formstack.dart';
import 'package:lottie/lottie.dart';

class FormStackView extends StatefulWidget {
  const FormStackView(this.formStackForm, {super.key});
  final FormStackForm formStackForm;

  @override
  State<StatefulWidget> createState() => _FormStackViewState();
}

class _FormStackViewState extends State<FormStackView> {
  late Widget child;
  late FormStackForm _formStackForm;
  Widget? _backgroundWidget;
  bool _hasBackgroundAnimation = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _formStackForm = widget.formStackForm;
    _hasBackgroundAnimation = _formStackForm.backgroundAnimationFile != null;

    child = _formStackForm.render(onUpdate, onUpdateFormStackForm);
  }

  Widget? _buildBackgroundWidget() {
    if (!_hasBackgroundAnimation) return null;
    if (_backgroundWidget == null &&
        _formStackForm.backgroundAnimationFile != null) {
      _backgroundWidget = Lottie.asset(
        _formStackForm.backgroundAnimationFile!,
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
      canPop: !_formStackForm.preventSystemBackNavigation,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isDisposed) {
          _formStackForm.onSystemNavigationBackClick?.call();
        }
      },
      child: _hasBackgroundAnimation
          ? Stack(
              alignment: _formStackForm.backgroundAlignment ?? Alignment.center,
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
        child = _formStackForm.render(onUpdate, onUpdateFormStackForm,
            formStep: formStep);
      });
    }
  }

  void onUpdateFormStackForm(FormStackForm formStackForm) {
    if (mounted && !_isDisposed) {
      _formStackForm = formStackForm;
      setState(() {
        child = _formStackForm.render(onUpdate, onUpdateFormStackForm);
      });
    }
  }
}
