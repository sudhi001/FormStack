import 'dart:async';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Audio recording input field.
/// Provides record/stop/playback controls and stores the recording status.
///
/// Note: Actual audio recording requires platform-specific packages
/// (e.g., `record` or `audio_recorder`). This widget provides the UI scaffold.
/// The result is a timestamp string indicating recording was completed.
// ignore: must_be_immutable
class AudioInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;

  AudioInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});

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
      constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
      child: StatefulBuilder(builder: (context, setState) {
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
      }),
    );
  }

  void _startRecording(StateSetter setState) {
    _isRecording = true;
    _recordingDurationSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordingDurationSeconds++;
      });
    });
  }

  void _stopRecording(StateSetter setState) {
    _isRecording = false;
    _hasRecording = true;
    _timer?.cancel();
    _timer = null;
    // Store recording timestamp as result
    formStep.result =
        "audio_${DateTime.now().toUtc().toIso8601String()}_${_recordingDurationSeconds}s";
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
