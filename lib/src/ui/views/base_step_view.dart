import 'package:flutter/material.dart';
import 'package:formstack/src/core/form_step.dart';
import 'package:formstack/src/core/form_theme.dart';
import 'package:formstack/src/ui/views/step_view.dart';
import 'package:lottie/lottie.dart';

///
/// Base class of all step views including any components.
/// Abstract class with basic component methods required for form navigation and validation.
///
// ignore: must_be_immutable
abstract class BaseStepView<T extends FormStep> extends FormStepView<T> {
  BaseStepView(
    super.formStackForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
  });

  /// Notifier for error visibility state
  final ValueNotifier<bool> _showErrorNotifier = ValueNotifier<bool>(false);

  /// Notifier for the busy/submitting state of the primary button.
  final ValueNotifier<bool> _processingNotifier = ValueNotifier<bool>(false);

  /// state of error
  bool get showError => _showErrorNotifier.value;
  set showError(bool value) => _showErrorNotifier.value = value;
  bool _hasCheckedError = false;
  bool _isDisposed = false;

  /// Whether this view has already been disposed.
  ///
  /// Guards against the framework and the form both releasing the view.
  bool get isDisposed => _isDisposed;

  /// Build the Widget / Component to render on the basis of FormStep object.
  @override
  Widget buildWithFrom(BuildContext context, T formStep) {
    if (!_hasCheckedError) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _checkAndShowDefaultValidationError();
        _hasCheckedError = true;
      });
    }
    final Widget? inputWidget = buildWInputWidget(context, formStep);
    return (formStep.componentOnly)
        ? (formStep.width != null
              ? SizedBox(
                  width: formStep.width,
                  child: _createComponent(context, inputWidget),
                )
              : _createComponent(context, inputWidget))
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _createAppBar(context),
            body: SafeArea(
              bottom: false,
              child: _createComponent(context, inputWidget),
            ),
            bottomNavigationBar: _createFooterView(context),
          );
  }

  /// Check if the step result is valid.
  bool isValid();

  /// Return the validation error message
  String validationError();

  /// Return the result value of the step.
  dynamic resultValue();

  /// State of the step is processing or not.
  ///
  /// Backed by a [ValueNotifier] so the footer rebuilds when it changes; a
  /// plain field could not repaint the button from a `StatelessWidget`.
  bool get isProcessing => _processingNotifier.value;
  set isProcessing(bool value) => _processingNotifier.value = value;

  /// Build the widget view.
  Widget? buildWInputWidget(BuildContext context, T formStep);

  /// Clear the component focus.
  void clearFocus();

  /// Request focus on the component.
  void requestFocus();

  /// Triggered when the user clicks the back button
  @override
  void onBack() {
    clearFocus();
    formStep.result = resultValue();
    formStackForm.backStep(formStep);
  }

  @override
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _showErrorNotifier.dispose();
    _processingNotifier.dispose();
  }

  /// Function triggered when the user cancels the step.
  @override
  void onCancel() {
    formStackForm.cancelStep(formStep);
  }

  /// Next button click event
  @override
  void onNextButtonClick() async {
    if (isProcessing) return;
    setLoading(true);
    formStep.result = resultValue();
    formStackForm.generateResult();
    await onBeforeFinish(formStackForm.result);
    setLoading(false);
    onNext();
  }

  /// Trigger on Loading state
  @override
  void onLoading(bool isLoading) {}

  /// Set Loading state
  void setLoading(bool isLoading) {
    if (_isDisposed) return;
    isProcessing = isLoading;
    onLoading(isLoading);
  }

  /// onBeforeFinish - To handle the finish action custom functionality
  @override
  Future<bool> onBeforeFinish(Map<String, dynamic> result) {
    return Future.value(true);
  }

  /// Move the Navigation to next step
  @override
  void onNext() {
    if (formStep.isOptional ?? false) {
      clearFocus();
      formStackForm.nextStep(formStep);
    } else if (isValid()) {
      clearFocus();
      formStackForm.nextStep(formStep);
    } else {
      showValidationError();
    }
  }

  void _checkAndShowDefaultValidationError() {
    if (_isDisposed) return;
    if (formStep.error != null && !showError) {
      _showErrorNotifier.value = true;
      formStackForm.validationError(formStep.error!);
      formStep.error = null;
    }
  }

  /// Show validation error
  void showValidationError() {
    if (_isDisposed) return;
    if (!showError) {
      _showErrorNotifier.value = true;
    }
    formStackForm.validationError(validationError());
  }

  /// Hide validation error
  void hideValidationError() {
    if (_isDisposed) return;
    if (showError) {
      _showErrorNotifier.value = false;
    }
  }

  /// Create the component widget - centered with responsive max width
  Widget _createComponent(BuildContext context, Widget? inputWidget) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = FormStackTheme.responsivePadding(context);
        final maxWidth = FormStackTheme.responsiveMaxWidth(context);
        return SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding * 0.75,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: formStep.crossAxisAlignmentContent,
                  children: [
                    if (formStep.showProgressBar &&
                        !formStep.componentOnly) ...[
                      _buildProgressBar(context),
                      _divisionPadding(context: context),
                    ],
                    if (formStep.titleIconAnimationFile != null) ...[
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 75,
                          maxWidth: formStep.titleIconMaxWidth ?? 300,
                          minHeight: 50,
                          maxHeight: formStep.titleIconMaxWidth ?? 300,
                        ),
                        child: Lottie.asset(formStep.titleIconAnimationFile!),
                      ),
                      _divisionPadding(context: context),
                    ],
                    if (formStep.titleIconImagePath != null) ...[
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 75,
                          maxWidth: formStep.titleIconMaxWidth ?? 300,
                          minHeight: 50,
                          maxHeight: formStep.titleIconMaxWidth ?? 300,
                        ),
                        child: formStep.titleIconImagePath!.startsWith('http')
                            ? Image.network(
                                formStep.titleIconImagePath!,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                formStep.titleIconImagePath!,
                                fit: BoxFit.contain,
                              ),
                      ),
                      _divisionPadding(context: context),
                    ],
                    if (title != null && title!.isNotEmpty) ...[
                      Semantics(
                        header: true,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          padding: EdgeInsets.only(
                            bottom: formStep.style?.titleBottomPadding ?? 0,
                          ),
                          child: Text(title ?? "", style: _titleStyle(context)),
                        ),
                      ),
                      _divisionPadding(context: context),
                    ],
                    if (text != null && text!.isNotEmpty) ...[
                      Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Text(text ?? "", style: _subtitleStyle(context)),
                      ),
                      _divisionPadding(context: context),
                    ],
                    if (formStep.helperText?.isNotEmpty ?? false) ...[
                      Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Text(
                          formStep.helperText!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      _divisionPadding(context: context),
                    ],
                    if (inputWidget != null) ...[
                      Semantics(
                        label: formStep.semanticLabel ?? formStep.title,
                        child: IgnorePointer(
                          ignoring: formStep.disabled,
                          child: inputWidget,
                        ),
                      ),
                    ],
                    ValueListenableBuilder<bool>(
                      valueListenable: _showErrorNotifier,
                      builder: (context, isError, _) {
                        return isError
                            ? Semantics(
                                liveRegion: true,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    validationError(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: FormStackTheme.errorColor(
                                            context,
                                          ),
                                        ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    if (formStep.description?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          formStep.description ?? "",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle? _titleStyle(BuildContext context) {
    final style = formStep.style;
    TextStyle? baseStyle;
    if (formStep.display == Display.small) {
      baseStyle = Theme.of(context).textTheme.bodyLarge;
    } else if (formStep.display == Display.medium) {
      baseStyle = Theme.of(context).textTheme.headlineMedium;
    } else if (formStep.display == Display.large) {
      baseStyle = Theme.of(context).textTheme.headlineLarge;
    } else if (formStep.display == Display.extraLarge) {
      baseStyle = Theme.of(context).textTheme.displaySmall;
    } else {
      baseStyle = Theme.of(context).textTheme.headlineSmall;
    }
    if (style?.titleColor != null) {
      return baseStyle?.copyWith(color: style!.titleColor);
    }
    return baseStyle;
  }

  TextStyle? _subtitleStyle(BuildContext context) {
    final style = formStep.style;
    TextStyle? baseStyle;
    if (formStep.display == Display.medium) {
      baseStyle = Theme.of(context).textTheme.titleLarge;
    } else if (formStep.display == Display.large ||
        formStep.display == Display.extraLarge) {
      baseStyle = Theme.of(context).textTheme.headlineSmall;
    } else {
      baseStyle = Theme.of(context).textTheme.bodyLarge;
    }
    if (style?.subtitleColor != null) {
      return baseStyle?.copyWith(color: style!.subtitleColor);
    }
    return baseStyle;
  }

  /// Create AppBar UI
  PreferredSizeWidget? _createAppBar(BuildContext context) {
    return (formStep.cancellable ?? false)
        ? (formStep.footerBackButton)
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Semantics(
                    button: true,
                    label: "Go back",
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    ),
                  ),
                  actions: [
                    Semantics(
                      button: true,
                      label: "Cancel form",
                      child: TextButton(
                        onPressed: onCancel,
                        child: Text(formStep.cancelButtonText ?? "Cancel"),
                      ),
                    ),
                  ],
                )
        : null;
  }

  /// Create Footer View with primary (Next) and secondary (Back) buttons.
  /// Follows Material Design: primary = FilledButton, secondary = OutlinedButton.
  Widget? _createFooterView(BuildContext context) {
    final btnHeight = FormStackTheme.responsiveButtonHeight(context);
    final padding = FormStackTheme.responsivePadding(context);
    final maxWidth = FormStackTheme.responsiveMaxWidth(context);
    final borderRadius = BorderRadius.circular(
      formStep.style?.borderRadius ?? FormStackTheme.radius(context),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Row(
              children: [
                // --- Secondary: Back button (outlined) ---
                if (formStep.footerBackButton &&
                    (formStep.cancellable ?? false)) ...[
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: formStep.backButtonText ?? "Back",
                      child: OutlinedButton.icon(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(formStep.backButtonText ?? "Back"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              formStep.style?.backgroundColor ??
                              Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color:
                                formStep.style?.backgroundColor ??
                                Theme.of(context).colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                          minimumSize: Size(0, btnHeight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // --- Primary: Next button (filled) ---
                Expanded(
                  flex:
                      formStep.footerBackButton &&
                          (formStep.cancellable ?? false)
                      ? 2
                      : 1,
                  child: Semantics(
                    button: true,
                    label: formStep.nextButtonText ?? "Next",
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _processingNotifier,
                      builder: (context, isProcessing, _) => ElevatedButton(
                        onPressed: isProcessing ? null : onNextButtonClick,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              formStep.style?.backgroundColor ??
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              formStep.style?.foregroundColor ??
                              Theme.of(context).colorScheme.onPrimary,
                          disabledBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                          minimumSize: Size(0, btnHeight),
                          maximumSize: Size(double.infinity, btnHeight + 10),
                        ),
                        child: isProcessing
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      formStep.style?.foregroundColor ??
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(formStep.nextButtonText ?? "Next"),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divisionPadding({BuildContext? context}) {
    final spacing = context == null ? 8.0 : FormStackTheme.spacing(context);
    return SizedBox(
      height: formStep.display == Display.small ? spacing / 2 : spacing,
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    // One snapshot, one index pass — the previous code indexed the step list
    // twice on every build.
    final progress = formStackForm.progress;
    if (!progress.isMeaningful) return const SizedBox.shrink();
    final captionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Semantics(
      label:
          "Step ${progress.step} of ${progress.total}, "
          "${progress.percent} percent complete",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${progress.step} of ${progress.total}',
                style: captionStyle,
              ),
              Text('${progress.percent}%', style: captionStyle),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.fraction,
              minHeight: 4,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
