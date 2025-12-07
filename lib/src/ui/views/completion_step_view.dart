// ignore: must_be_immutable
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class CompletionStepView extends BaseStepView<CompletionStep> {
  final OnBeforeFinishCallback? onBeforeFinishCallback;
  final bool autoTrigger;
  CompletionStepView(
    super.formKitForm,
    super.formStep,
    super.text, {
    super.key,
    super.title,
    this.onBeforeFinishCallback,
    required this.autoTrigger,
  });
  final GlobalKey<State> loadingKey = GlobalKey<State>();
  bool isCompleted = false;
  bool isLoading = true;
  Timer? _delayTimer;
  bool _isDisposed = false;
  bool _autoTriggerFired = false;
  Widget? _loadingWidget;
  Widget? _successWidget;
  Widget? _errorWidget;

  Widget _buildLottieWidget(String? assetPath, String defaultPath) {
    final path = assetPath ?? defaultPath;
    return Lottie.asset(
      path,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget? buildWInputWidget(BuildContext context, CompletionStep formStep) {
    if (autoTrigger && !_autoTriggerFired) {
      _autoTriggerFired = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!_isDisposed) {
          onNextButtonClick();
        }
      });
    }

    _loadingWidget ??= _buildLottieWidget(
      formStep.loadingLottieAssetsFilePath,
      'packages/formstack/assets/lottiefiles/loading.json',
    );
    _successWidget ??= _buildLottieWidget(
      formStep.successLottieAssetsFilePath,
      'packages/formstack/assets/lottiefiles/success.json',
    );
    _errorWidget ??= _buildLottieWidget(
      formStep.errorLottieAssetsFilePath,
      'packages/formstack/assets/lottiefiles/failed.json',
    );

    return StatefulBuilder(
        key: loadingKey,
        builder: (context, state) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200.0,
              maxWidth: 200.0,
            ),
            child: isLoading
                ? _loadingWidget!
                : isCompleted
                    ? _successWidget!
                    : _errorWidget!,
          );
        });
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  Future<bool> onBeforeFinish(Map<String, dynamic> result) async {
    _delayTimer?.cancel();

    if (onBeforeFinishCallback != null) {
      isLoading = true;
      isCompleted = await onBeforeFinishCallback!.call(result);
    } else {
      await Future.delayed(const Duration(milliseconds: 90));
      if (_isDisposed) return false;
      isCompleted = await super.onBeforeFinish(result);
    }

    if (_isDisposed) return false;

    isLoading = false;
    // ignore: invalid_use_of_protected_member
    loadingKey.currentState?.setState(() {});

    final completer = Completer<bool>();
    _delayTimer = Timer(const Duration(seconds: 1), () {
      if (!_isDisposed && loadingKey.currentState != null) {
        completer.complete(isCompleted);
      } else {
        completer.complete(false);
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _delayTimer?.cancel();
    _loadingWidget = null;
    _successWidget = null;
    _errorWidget = null;
    super.dispose();
  }

  @override
  String validationError() {
    return "";
  }

  @override
  void requestFocus() {}
  @override
  resultValue() {
    return DateTime.now().toUtc();
  }

  @override
  void clearFocus() {}
}
