import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/completion_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// Runs just before a form completes, for a final async step such as
/// posting the results. The returned future is awaited before navigation.
typedef OnBeforeFinishCallback =
    Future<bool> Function(Map<String, dynamic> result);

/// The final step of a form.
///
/// Shows a loading animation while [onBeforeFinishCallback] runs, then a
/// success or error animation, and hands the collected results to [onFinish].
class CompletionStep extends FormStep {
  /// The JSON `type` discriminator for this step.
  static const String tag = "CompletionStep";

  /// Whether the completion action runs on display rather than on tap.
  final bool? autoTrigger;

  /// Lottie animation shown when the form completes successfully.
  String? successLottieAssetsFilePath;

  /// Lottie animation shown while [onBeforeFinishCallback] runs.
  String? loadingLottieAssetsFilePath;

  /// Lottie animation shown when completion fails.
  String? errorLottieAssetsFilePath;

  /// Async work to run before the form completes, such as submission.
  OnBeforeFinishCallback? onBeforeFinishCallback;

  /// Called with all results when this step completes the form.
  Function(Map<String, dynamic>)? onFinish;

  /// Creates a [CompletionStep].
  CompletionStep({
    super.id,
    super.title,
    super.text,
    super.style,
    super.display = Display.normal,
    super.isOptional = false,
    this.onFinish,
    super.crossAxisAlignmentContent,
    super.resultFormat,
    super.relevantConditions,
    super.titleIconAnimationFile,
    this.onBeforeFinishCallback,
    super.titleIconMaxWidth,
    this.successLottieAssetsFilePath,
    this.loadingLottieAssetsFilePath,
    this.errorLottieAssetsFilePath,
    super.nextButtonText = "Finish",
    super.backButtonText,
    this.autoTrigger = false,
    super.cancelButtonText,
    super.cancellable,
  }) : super();
  @override
  FormStepView buildView(FormStackForm formStackForm) {
    formStackForm.onFinish = onFinish;
    resultFormat = resultFormat ??= ResultFormat.date(
      "",
      "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
    );
    return CompletionStepView(
      formStackForm,
      this,
      text,
      title: title,
      autoTrigger: autoTrigger ?? false,
      onBeforeFinishCallback: onBeforeFinishCallback,
    );
  }

  /// Creates a [CompletionStep] from its JSON form.
  factory CompletionStep.from(
    Map<String, dynamic>? element,
    List<RelevantCondition> relevantConditions,
  ) {
    return CompletionStep(
      display: element?["display"] != null
          ? Display.values.firstWhere((e) => e.name == element?["display"])
          : Display.normal,
      crossAxisAlignmentContent:
          crossAlignmentFromString(
            element?["crossAxisAlignmentContent"] ?? "center",
          ) ??
          CrossAxisAlignment.center,
      cancellable: element?["cancellable"],
      autoTrigger: element?["autoTrigger"] ?? false,
      style: UIStyle.maybeFrom(element?["style"]),
      relevantConditions: relevantConditions,
      backButtonText: element?["backButtonText"],
      cancelButtonText: element?["cancelButtonText"],
      isOptional: element?["isOptional"],
      nextButtonText: element?["nextButtonText"],
      successLottieAssetsFilePath: element?["successLottieAssetsFilePath"],
      loadingLottieAssetsFilePath: element?["loadingLottieAssetsFilePath"],
      errorLottieAssetsFilePath: element?["errorLottieAssetsFilePath"],
      text: element?["text"],
      title: element?["title"],
      titleIconAnimationFile: element?["titleIconAnimationFile"],
      titleIconMaxWidth: element?["titleIconMaxWidth"],
      id: GenericIdentifier(id: element?["id"]),
    );
  }
}
