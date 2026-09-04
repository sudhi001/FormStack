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
    // Step views are disposed by the framework as they leave the tree; the
    // form no longer holds any itself.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    // Measure the space this form was actually given and publish it, so the
    // responsive helpers size against the container rather than the window. A
    // form in a 600px dialog on a 1500px monitor was taking every desktop
    // branch; one in a narrow panel took none of them.
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        return FormStackAvailableWidth(
          width: available,
          child: _buildForm(context),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
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
        child = _formStackForm.render(
          onUpdate,
          onUpdateFormStackForm,
          formStep: formStep,
        );
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
