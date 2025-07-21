import 'package:flutter/material.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:lottie/lottie.dart';

///
/// base class of al step view including any componets.
/// Abstract class with basic compoents methods that required for form navigation and validation.
///
// ignore: must_be_immutable
abstract class BaseStepView<T extends FormStep> extends FormStepView<T> {
  BaseStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title});

  /// State of error widget
  final GlobalKey<State> errorKey = GlobalKey<State>();

  /// state of error
  bool showError = false;

  /// Build the Widget / Component to render on the basis o  FormStep object.
  @override
  Widget buildWithFrom(BuildContext context, T formStep) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkAndShowDefaultValidationError();
    });
    final Widget? inputWidget = buildWInputWidget(context, formStep);
    return (formStep.componentOnly)
        ? (formStep.width != null
            ? SizedBox(
                width: formStep.width,
                child: _createComponent(context, inputWidget),
              )
            : _createComponent(context, inputWidget))
        : Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _createAppBar(context),
            body: _createComponent(context, inputWidget),
            bottomNavigationBar: _createFooterView(context));
  }

  /// Check if the step result is valid.
  bool isValid();

  /// Return the validation error message
  String validationError();

  /// Retrun the result value of the step.
  dynamic resultValue();
  //// state of the step is processing on not .
  bool isProcessing = false;

  /// Build the widget view.
  Widget? buildWInputWidget(BuildContext context, T formStep);

  /// Clear the component focus.
  void clearFocus();

  /// Request focus on the component.
  void requestFocus();

  ///
  ///Trigger when the user click on the back button
  ///
  @override
  void onBack() {
    clearFocus();
    formStep.result = resultValue();
    formKitForm.backStep(formStep);
  }

  @override
  void dispose() {
    // Clean up any resources if needed
  }

  ///
  ///Function triggern on When the user cancelled the step.
  ///
  @override
  void onCancel() {
    formKitForm.cancelStep(formStep);
  }

  ///
  ///Next button Click - Event trigger on when the user click on the next button
  ///
  @override
  void onNextButtonClick() async {
    if (isProcessing) return;
    setLoading(true);
    formStep.result = resultValue();
    formKitForm.generateResult();
    await onBeforeFinish(formKitForm.result);
    setLoading(false);
    onNext();
  }

  /// Trigger on Loading state
  @override
  void onLoding(bool isLoading) {}

  ///
  /// set Loading state
  void setLoading(bool isLoading) {
    isProcessing = isLoading;
    onLoding(isProcessing);
  }

  ///
  /// onBeforeFinish - To handle the finish action custom funtionality
  ///

  @override
  Future<bool> onBeforeFinish(Map<String, dynamic> result) {
    return Future.value(true);
  }

  ///
  /// Move the Navigation to next step
  ///
  @override
  void onNext() {
    if (formStep.isOptional ?? false) {
      clearFocus();
      formKitForm.nextStep(formStep);
    } else if (isValid()) {
      clearFocus();
      formKitForm.nextStep(formStep);
    } else {
      showValidationError();
    }
  }

  void _checkAndShowDefaultValidationError() {
    if (formStep.error != null) {
      // ignore: invalid_use_of_protected_member
      errorKey.currentState?.setState(() {
        showError = true;
      });
      formKitForm.validationError(formStep.error!);
      formStep.error = null;
    }
  }

  ///
  /// Show validation Error and hide the validation mesage if it's valid
  ///
  void showValidationError() {
    // ignore: invalid_use_of_protected_member
    errorKey.currentState?.setState(() {
      showError = true;
    });
    formKitForm.validationError(validationError());
  }

  ///
  /// Hide validation Error
  ///
  void hideValidationError() {
    // ignore: invalid_use_of_protected_member
    errorKey.currentState?.setState(() {
      showError = false;
    });
  }

  ///
  /// Create the component widget
  ///
  Widget _createComponent(BuildContext context, Widget? inputWidget) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: formStep.crossAxisAlignmentContent,
              children: [
                if (formStep.titleIconAnimationFile != null) ...[
                  Container(
                    constraints: BoxConstraints(
                        minWidth: 75,
                        maxWidth: formStep.titleIconMaxWidth ?? 300,
                        minHeight: 50,
                        maxHeight: formStep.titleIconMaxWidth ?? 300),
                    child: Lottie.asset(formStep.titleIconAnimationFile!),
                  ),
                  _divisionPadding()
                ],
                if (title != null && title!.isNotEmpty) ...[
                  Container(
                      constraints:
                          const BoxConstraints(minWidth: 75, maxWidth: 500),
                      padding: EdgeInsets.only(
                          bottom: formStep.style?.titleBottomPadding ?? 0),
                      child: Text(title ?? "",
                          style: formStep.display == Display.small
                              ? Theme.of(context).textTheme.bodyLarge
                              : formStep.display == Display.medium
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : (formStep.display == Display.large
                                      ? Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                      : (formStep.display == Display.extraLarge
                                          ? Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                          : Theme.of(context)
                                              .textTheme
                                              .headlineSmall)))),
                  _divisionPadding()
                ],
                if (text != null && text!.isNotEmpty) ...[
                  Container(
                      constraints:
                          const BoxConstraints(minWidth: 75, maxWidth: 500),
                      child: Text(text ?? "",
                          style: formStep.display == Display.medium
                              ? Theme.of(context).textTheme.titleLarge
                              : (formStep.display == Display.large
                                  ? Theme.of(context).textTheme.headlineSmall
                                  : (formStep.display == Display.extraLarge
                                      ? Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge)))),
                  _divisionPadding(),
                ],
                if (inputWidget != null) ...[
                  IgnorePointer(
                      ignoring: formStep.disabled, child: inputWidget),
                ],
                StatefulBuilder(
                    key: errorKey,
                    builder: (context, setState) {
                      return showError
                          ? Text(
                              validationError(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .apply(color: Colors.red.shade900),
                            )
                          : const SizedBox(
                              width: 10,
                              height: 0,
                            );
                    }),
                if (formStep.description?.isNotEmpty ?? false)
                  Text(formStep.description ?? "",
                      style: formStep.display == Display.medium
                          ? Theme.of(context).textTheme.bodyMedium
                          : (formStep.display == Display.large
                              ? Theme.of(context).textTheme.bodyLarge
                              : (formStep.display == Display.extraLarge
                                  ? Theme.of(context).textTheme.bodyLarge
                                  : Theme.of(context).textTheme.bodySmall)),
                      textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Create To Appbar ui
  PreferredSizeWidget? _createAppBar(BuildContext context) {
    return (formStep.cancellable ?? false)
        ? (formStep.footerBackButton)
            ? null
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                actions: [
                  IconButton(
                    constraints: const BoxConstraints.expand(width: 80),
                    icon: Text(formStep.cancelButtonText ?? "Cancel"),
                    onPressed: onCancel,
                  ),
                ],
              )
        : null;
  }

  /// Create Footer View
  Widget? _createFooterView(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (formStep.footerBackButton &&
                (formStep.cancellable ?? false)) ...[
              Expanded(
                child: ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: formStep.style?.backgroundColor,
                        foregroundColor: formStep.style?.foregroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                formStep.style?.borderRadius ?? 0))),
                        minimumSize: const Size(0, 50),
                        maximumSize: const Size(double.infinity, 60)),
                    child: Text(formStep.backButtonText ?? "Back")),
              ),
              const SizedBox(width: 10)
            ],
            Expanded(
              child: ElevatedButton(
                  onPressed: isProcessing ? null : onNextButtonClick,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: formStep.style?.backgroundColor,
                      foregroundColor: formStep.style?.foregroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(
                              formStep.style?.borderRadius ?? 0))),
                      minimumSize: const Size(0, 50),
                      maximumSize: const Size(double.infinity, 60)),
                  child: isProcessing
                      ? const CircularProgressIndicator()
                      : Text(formStep.nextButtonText ?? "Next")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divisionPadding() {
    return SizedBox(height: formStep.display == Display.small ? 2 : 7);
  }
}
