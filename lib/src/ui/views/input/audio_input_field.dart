import 'dart:async';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Audio recording input field.
///
/// Uses [DeviceCapabilities.audioRecorder] when the application has supplied
/// one, in which case the result is the recorded file's path. Without a
/// recorder the widget still runs its timer and stores a duration marker, so
/// the form remains usable, but no audio is captured. FormStack declares no
/// microphone dependency of its own.
// ignore: must_be_immutable
class AudioInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;

  AudioInputWidgetView(
    super.formStackForm,
    super.formStep,
    super.text,
    this.resultFormat, {
    super.key,
    super.title,
  });

  bool _isRecording = false;
  bool _hasRecording = false;
  int _recordingDurationSeconds = 0;
  Timer? _timer;
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      _hasRecording = formStep.result != null;
      _isInitialized = true;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 500),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recording visualization
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.shade50
                      : _hasRecording
                      ? Colors.green.shade50
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isRecording
                        ? Colors.red.shade200
                        : _hasRecording
                        ? Colors.green.shade200
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRecording
                            ? Icons.mic
                            : _hasRecording
                            ? Icons.audio_file
                            : Icons.mic_none,
                        size: 40,
                        color: _isRecording
                            ? Colors.red
                            : _hasRecording
                            ? Colors.green.shade700
                            : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRecording
                            ? _formatDuration(_recordingDurationSeconds)
                            : _hasRecording
                            ? "Recording saved (${_formatDuration(_recordingDurationSeconds)})"
                            : "Tap record to start",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _isRecording ? Colors.red : null,
                          fontWeight: _isRecording ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_hasRecording && !_isRecording) ...[
                    // Delete button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _hasRecording = false;
                          _recordingDurationSeconds = 0;
                          formStep.result = null;
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      tooltip: "Delete recording",
                    ),
                    const SizedBox(width: 16),
                  ],
                  // Record/Stop button
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: formStep.disabled
                          ? null
                          : () {
                              setState(() {
                                if (_isRecording) {
                                  _stopRecording(setState);
                                } else {
                                  _startRecording(setState);
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: _isRecording
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startRecording(StateSetter setState) async {
    final recorder = DeviceCapabilities.instance.audioRecorder;
    try {
      await recorder?.start();
    } catch (e, stack) {
      _report(e, stack, 'starting an audio recording');
      return;
    }
    _isRecording = true;
    _recordingDurationSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordingDurationSeconds++;
      });
    });
  }

  Future<void> _stopRecording(StateSetter setState) async {
    _isRecording = false;
    _timer?.cancel();
    _timer = null;

    final recorder = DeviceCapabilities.instance.audioRecorder;
    if (recorder == null) {
      // No recorder registered: nothing was captured, so record only that the
      // step was completed and how long it ran. See [DeviceCapabilities].
      _hasRecording = true;
      formStep.result =
          "audio_${DateTime.now().toUtc().toIso8601String()}_${_recordingDurationSeconds}s";
      return;
    }
    try {
      final recording = await recorder.stop();
      _hasRecording = recording != null;
      formStep.result = recording?.path;
      setState(() {});
    } catch (e, stack) {
      _report(e, stack, 'stopping an audio recording');
    }
  }

  void _report(Object error, StackTrace stack, String what) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'formstack',
        context: ErrorDescription('$what for step ${formStep.id?.id}'),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(formStep.result);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => formStep.result;

  @override
  void clearFocus() {}
}
